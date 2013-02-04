Andand Even More
===

Here's a little tip for using `Object#andand`. You already know that you can use it to conditionally invoke a method on an object:

    "foo".andand + "bar"
        # => "foobar"
    nil.andand + "bar"
        # => nil

In other words, it's a [Quirky Bird](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown "Quirky Birds and Meta-Syntactic Programming"). But did you know that you can also use it to conditionally invoke a block? 

    (1..10).andand do |numbers|
      doubles = numbers.map { |n| n * 2 }
      double_doubles = doubles.map { |n| n * 2 }
    end
        # => [4, 8, 12, 16, 20, 24, 28, 32, 36, 40]
    
    nil.andand do |numbers|
      doubles = numbers.map { |n| n * 2 }
      double_doubles = doubles.map { |n| n * 2 }
    end
        # => nil

It's not just a Quirky Bird, it's also a [Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown "Songs of the Cardinal").

Consider this conditional code:

    if my_var = something_or_other()
      3.times do
        yada(my_var)
      end
    end

I'm not a big fan. The obvious sin is the pathetic 90s cultural reference. But I'm even more annoyed by having side-effects in the predicate of an `if` clause, in this case assigning something to the variable `my_var`. Although I'm not switching to a purely functional language any time soon, I strongly prefer that when you write `if something()`, then "something()" should not cause any side effects, ever.

Another problem is that we are obviously creating `my_var` just to use inside the block, but we're declaring it in top-level scope. We could fool around with a [Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown "The Thrush") like `let`, but instead let's use `Object#andand`:

    something_or_other().andand do |my_var|
      3.times do
        yada(my_var)
      end
    end
  
Now we are making it clear that we wish to execute this block only if `something_or_other()` is not nil. Furthermore, we are assigning the result of `something_or_other()` to `my_var` and using it within the block. [Crisp and clean, no caffeine](http://www.youtube.com/watch?v=ryXsn7fLV-M "YouTube - 7-UP Commercial featuring Geoffrey Holder").

Note that if we don't actually *need* `my_var` in the block, we don't really need `andand` either:

    something_or_other() and begin
      3.times do
        yada()
      end
    end
    
Like anything else, `andand do ... end` is a tool to be used in specialized situations. Use it whenever you want to do something more complicated than a simple message send, but only when the subject is not `nil`.

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