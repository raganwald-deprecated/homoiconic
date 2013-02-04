# Read-Only Code is an Anti-Pattern

### preamble

I recently found myself with a chunk of unplanned free time ([hint!](http://braythwayt.com/reginald/RegBraithwaite20120423.pdf)). After the shock wore off, I turned my attention to tasks and projects that I thought were important, but had been starved of attention by other, more urgent activities. In the words of [Steven Covey][7habits], things that were important but not urgent.

[7habits]: http://www.amazon.com/gp/product/0743269519/ref=as_li_ss_tl?ie=UTF8&tag=raganwald001-20

One of those things was refactoring [Café au Life][cafe]. As the home page says, Café au Life is an implementation of Bill Gosper's HashLife algorithm written in CoffeeScript for V8. One of the things I tried to do when I first wrote it was to organize the code as a series of successive "reveals." The intent of the "successive reveals" was the make the program *easier to read*. When presenting something unfamiliar and complex, a standard technique is to explain the simplest part of it first, then add some complexity, then some more, and so on until the whole thing has been explained in sufficient detail. At each step of the way, you introduce one cohesive new topic.

As I discovered, the effort to make Café au Life easy to read inadvertently made it read-only code.

### Making code writeable

Culturally, programmer's celebrate the concept of making code easy to read. An oft-quoted line comes from a book about programming in Scheme:

> Programs must be written for people to read, and only incidentally for machines to execute.—Abelson & Sussman, [Structure and Interpretation of Computer Programs][sicp]

[sicp]: http://mitpress.mit.edu/sicp/

In casual exchanges, programmers often refer to making code easy-to-write as an anti-pattern. The reasoning is that you read code far more than you write it, so techniques that ease writing at the expense of reading are a mistake. This is true, of course: techniques that favour reading over writing should be viewed with extreme caution. The trouble comes when we assume that the two positions form a dichotomy.

Some techniques that produce less code are, in fact, harmful to readability. They are a kind of "code golf." Other techniques for producing less code enhance readability by removing accidental complexity. It would be a mistake to generalize and think of writing less code as being an exercise in writing code at the expense of reading it. Nevertheless, programmers are generally sensitive to the possibility that code optimized for the author might be pessimized for the reader.

One thing that interests me is the reverse position: Sometimes, an effort to make the code easier to read makes it more difficult to write. Since we spend more time reading code than writing it, we are tempted to consider this a worthwhile tradeoff. However, we usually are over-simplifying and thinking of code that is difficult to write in the first place. It usually is a worthwhile trade-off to invest more time up front in order to make code more readable over its lifetime.

But what about *modifying* code? All too often we assume that if we can read and understand it, we can modify it. This is absolutely untrue. Some code is easy to read, but it has such coupling and reliance on carefully orchestrated imperative state that it is very difficult to modify. Programmers jokingly insult Perl as producing "write-only code." I think of some programs as composed of "read-only code:" It's relatively easy to figure out what's going on, but challenging to make changes safely.

I once tried to make a Rails project "easy to read" by segregating some functionality into plugins. The initial goal was that new functionality could be added and removed by adding and removing plugins from the project. It turned out to be a mistake. The code required to make this work ended up adding a lot of accidental complexity to the application, reducing writeability instead of enhancing it. As an additional irritant, Rails works hard to make development mode convenient for the programmer, but it does assume--quite reasonably--that plugins are not being dynamically updated on the fly.

Unsurprisingly that design turned out to be a net loss: I had inadvertently created read-only code. It could be read and understood, but it was a pain to modify (and worse, colleagues reported that it wasn't that easy to read when you considered the accidental complexity). With this in mind, I approached segregating Café au Life's functionality with trepidation.

### Café au Life

As described above, Café au Life was written to use two basic classes (`Cell` and `Square`) and to segregate their functionality into four modules. Other strategies are possible, of course: I would like to explore escaping the "Kingdom of Nouns" at some point and experiment with the [Strategy][strategy] and [Command][cmd] patterns in the future.

[strategy]: https://en.wikipedia.org/wiki/Strategy_pattern
[cmd]: https://en.wikipedia.org/wiki/Command_pattern

The algorithm's core functionality was implemented in the `cafeaulife`, `rules`, `future`, and `cache` modules, with all four modules depending upon each other and necessary for the algorithm to operate.

The `cafeaulife` module was mostly exposition, including only the barest skeleton of code for the program's essential `Cell` and `Square` classes. The `rules` module added some basic arithmetic for counting neighbours and generating canonical squares of the two smallest sizes. The `future` module introduced the HashLife algorithm proper, and the `cache` module introduced the cache that handled canonicalizing squares.

In Café au Life, each module added functionality by adding methods and other members to the `Cell` and `Square` classes (as well as new subclasses and other detritus) when the modules were loaded. There are many ways to accomplish this. For example, languages like Ruby support Mixins to accomplish this goal in the coarse:

```ruby

    # app/models/post.rb
    class Post
      include Behaviors::PostBehavior
    end

    # app/models/behaviors/post_behavior.rb
    module Behaviors
      module PostBehavior
        attr_accessor :blog, :title, :body

        def initialize(attrs={})
          attrs.each do |k,v| send("#{k}=",v) end 
        end

        def publish
          blog.add_entry(self)
        end

        # ... twenty more methods go here
      end
    end
    
```

(code from [Mixins: A refactoring anti-pattern](http://blog.steveklabnik.com/posts/2012-05-07-mixins--a-refactoring-anti-pattern))

In CoffeeScript, you can use tools like Underscore's `.extend` to achieve the same goal with similar syntax:

```coffeescript

    class Post
    
      constructor: (args...) ->
        @initialize(args...)
        
      initialize: (args...) ->
    
    PostBehaviour =
    
      initialize: ({@blog, @title, @body}) ->
      
      publish: ->
        @blog.add_entry(this)

      # ... twenty more methods go here
      
    _.extend Post.prototype, PostBehaviour
    
```
    
CoffeeScript also provides syntactic sugar for directly modifying a prototype if your "module" is not a cross-cutting concern:

```coffeescript
    
    Post::initialize = ({@blog, @title, @body}) ->
      
    Post::publish = ->
      @blog.add_entry(this)

    # ... twenty more methods go here
    
```

[cafe]: http://recursiveuniver.se

These techniques are straightforward, and work well for situations where the functionality to be segregated factors very cleanly at the method level. The sticking point in Café au Life was the `initialize` method, or more specifically, constructors. Each chunk of functionality wanted to rewrite the constructor to perform its own initialization.

### Flavours and AOP

To solve this problem, I introduced [method flavours][flavors] using [YouAreDaChef][yadc]. Flavours is an archaic term, today we usually talk about method combinators or method advice, a term from the Aspect-Oriented Programming movement. I personally prefer to call them combinators when they are stand-alone ways of modifying methods or functions, and to call them advice when they are part of a larger aspect-oriented effort to separate cross-cutting concerns.

[flavors]: https://en.wikipedia.org/wiki/Flavors_(programming_language)
[yadc]: https://github.com/raganwald/YouAreDaChef

My first crack at allowing each module to modify the initialization of a square was to provide *after advice* to the `initialize` method for squares. Using YouAreDaChef, I could write:

```coffeescript
    
    class Square
      constructor: ({@nw, @ne, @se, @sw}) ->
        @level = @nw.level + 1
        @initialize.apply(this, arguments)
      initialize: ->
    
```

And in another module, write:

```coffeescript
    
    YouAreDaChef(Square)
      .after 'initialize', ->
        @population = @nw.population + @ne.population + @se.population + @sw.population
    
```

YouAreDaChef takes care of modifying Square's `initialize` method such that it executes the original method body *and* the advice that computes its population.

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)](http://leanpub.com/javascript-allonge "JavaScript Allongé")![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)