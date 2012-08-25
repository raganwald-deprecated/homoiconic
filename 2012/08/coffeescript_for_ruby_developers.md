**WARNING** *This is a working draft, not a finished essay. I'm soliciting feedback. While you're welcome to share it/tweet it, I ask you NOT to post it to Reddit/Hacker News &c. until it is no longer a working draft, likely on Monday morning. Thanks for your understanding.*

Thinking in CoffeeScript
===

I spotted a funny joke on Twitter the other day: "I can always tell when a Ruby developer writes JavaScript, because it's not JavaScript, it's CoffeeScript."——[Vance Lucas][vlucas]. Besides having a little fun with people's tribal inclinations, this tweet reminded me of an old saying that I have found to be very deep:

[vlucas]: http://twitter.com/vlucas

> [Real programmers][rp] can write FORTRAN in any language.

We tend to think in our favourite programming language and then translate our thoughts into whatever notation the compiler or interpreter accepts. If we're a "real programmer," I suppose we think in FORTRAN at all times even if were given a quiche-eater's language like Pascal or--God forbid--Smalltalk. We would just write a FORTRAN program with Pascal's syntax.

[rp]: http://www.pbm.com/~lindahl/real.programmers.html "Real programmers don't use Pascal--Ed Post"

The advantage of this approach is apparent when we're working down the [power continuum][avg]. Because we think in a higher-level language, we Greenspun more powerful features into a less powerful language. The Ruby on Rails framework is a good example of this: ActiveController and ActiveRecord bake method-advice and method decorators into Ruby.

[avg]: http://www.paulgraham.com/avg.html "Beating the Averages--Paul Graham"

The disadvantage of this thinking in one language and writing in another is that sometimes we are blind to a language's own features and styles that are equally or even more powerful than the language we find comfortable to use. It may be apocryphal, but supposedly this is evident when someone uses a `for` loop in Ruby instead of `.each`, `.map`, or `.inject` to iterate over a collection. I'm not 100% convinced that using `for` is always bad thing, but I've certainly seen a similar thing in SQL where people sometimes write out stored procedures with loops when they could have learned how to use SQL's relational calculus to obtain the same results.

So my thesis is that when you go from one language to another, it's fine to bring your best stuff, but not at the expense of ignoring the good things that the new language does well. Ruby-flavoured CoffeeScript might be wonderful. A Ruby program in CoffeeScript syntax, not so nice.

Enough hand-waving, let's discuss a specific example!

Decorating Methods in CoffeeScript
---

As you know, Ruby and JavaScript both have Object Models. And objects have methods. And good software often involves *decorating* a method. Let's start off by agreeing on what I mean in this context. By "decorating a method," I mean adding some functionality to a method external to the method's body. The functionality you're adding is a "method decorator." (Some people call the mechanism the decorator, but let's use my definition in this essay.)

If you've written a `before_validation` method in Ruby on Rails, you've written a method decorator. You're decorating ActiveRecord's baked-in validation code with something you want done before it does its validation. Likewise, ActiveController's `before` filters do exactly the same thing, albeit with a different syntax.

These are good things. Without decorators, you end up "tangling" every method with a lot of heterogenous cross-cutting concerns:

    class WidgetViewInSomeFramework extends BuiltInFrameWorkView
      
      # ...
      
      switchToEditMode: (evt) ->
        loggingMechanism.log 'debug', 'entering switchToEditMode'
        if currentUser.hasPermissionTo('write', WidgetModel)
          # actual
          # code
          # switching to
          # edit
          # mode
        else
          controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
        loggingMechanism.log 'debug', 'leaving switchToEditMode'
      
      switchToReadMode: (evt) ->
        loggingMechanism.log 'debug', 'entering switchToReadMode'
        if currentUser.hasPermissionTo('read', WidgetModel)
          # actual
          # code
          # switching to
          # view-only
          # mode
        else
          controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
        loggingMechanism.log 'debug', 'leaving switchToReadMode'
        
(These are not meant to be serious examples, but just credible enough that we can grasp the idea of cross-cutting concerns and tangling.)

Faced with this problem and some Ruby experience, an intelligent but not particularly wise developer might rush off and write something like [YouAreDaChef][y], an Aspect-Oriented Framework for JavaScript. With YouAreDaChef, you can "untangle" the cross-cutting concerns from the primary purpose of each method:

[y]: https://github.com/raganwald/YouAreDaChef "YouAreDaChef, AOP for JavaScript and CoffeeScript"

    class WidgetViewInSomeFramework extends BuiltInFrameWorkView
      
      # ...
      
      switchToEditMode: (evt) ->
        # actual
        # code
        # switching to
        # edit
        # mode
      
      switchToReadMode: (evt) ->
        # actual
        # code
        # switching to
        # view-only
        # mode
    
    YouAreDaChef(WidgetViewInSomeFramework)
    
      .around 'switchToEditMode', (callback, args...) ->
        if currentUser.hasPermissionTo('write', WidgetModel)
          callback.apply(this, args)
        else
          controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
    
      .around 'switchToReadMode', (callback, args...) ->
        if currentUser.hasPermissionTo('read', WidgetModel)
          callback.apply(this, args)
        else
          controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
          
      .around 'switchToEditMode', (callback, args...) ->
        loggingMechanism.log 'debug', "entering switchToEditMode"
        value = callback.apply(this, args)
        loggingMechanism.log 'debug', "leaving switchToEditMode"
        value
          
      .around 'switchToReadMode', (callback, args...) ->
        loggingMechanism.log 'debug', "entering switchToReadMode"
        value = callback.apply(this, args)
        loggingMechanism.log 'debug', "leaving switchToReadMode"
        value
        
YouAreDaChef provides a mechanism for adding "advice" to each method, separating our base behaviour from the cross-cutting concerns. This example isn't particularly DRY, but let's not waste time fixing it up. It's interesting, but hardly "Thinking in CoffeeScript."
        
Decorating Methods
---

In CoffeeScript, we rarely need all the Architecture Astronautics. Can we do untangle the concerns with a simpler mechanism? Yes. Python provides [a much simpler way to decorate methods][pyd] if you don't mind annotating the method definition itself.

[pyd]: http://en.wikipedia.org/wiki/Python_syntax_and_semantics#Decorators "Python Method Decorators"

CoffeeScript doesn't provide such a mechanism, because you don't need one in JavaScript. Unlike Ruby, there is no distinction between methods and functions. Furthermore, there is no 'magic' syntax for declaring a method. No `def` keyword, nothing. Methods are object and prototype properties that happen to be functions. And in CoffeeScript, we can provide any expression for a method body, it doesn't have to be a function literal.

> Every problem in Computer Science can be solved by adding another layer of abstraction, except for the problem of having too many layers of abstraction.--Alan Perlis

Let's add our own method decorators `withPermissionTo` and `debugEntryAndExit`. They will return functions that take a method's body--a function--and return a decorated method. So they'll mix the decoration and the mechanism. We'll make sure `this` is set correctly:

    withPermissionTo = (verb, subject) ->
      (callback) ->
        (args...) ->
          if currentUser.hasPermissionTo(verb, subject)
            callback.apply(this, args)
          else
            controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
        
    debugEntryAndExit = (what) ->
      (callback) ->
        (args...) ->
          loggingMechanism.log 'debug', "entering #{what}"
          value = callback.apply(this, args)
          loggingMechanism.log 'debug', "leaving #{what}"
          value
          
Now we can write them directly in our class definition:

    class WidgetViewInSomeFramework extends BuiltInFrameWorkView
      
      # ...
      
      switchToEditMode: 
        withPermissionTo('write', WidgetModel) \
        debugEntryAndExit('switchToEditMode') \
        (evt) ->
          # actual
          # code
          # switching to
          # edit
          # mode
      
      switchToReadMode:
        withPermissionTo('read', WidgetModel) \
        debugEntryAndExit('switchToReadMode') \
        (evt) ->
          # actual
          # code
          # switching to
          # view-only
          # mode

Our decorators work just like Python method decorators, only we don't need any magic syntax for them because CoffeeScript, like JavaScript, already has this idea that functions can return functions and there's nothing particularly magic about defining a method, it's just an expression that evaluates to a function. In this case, our methods are expressions that take two decorators and apply them to a function literal.

Now we've worked out how to separate cross-cutting concerns from our method bodies and how to decorate our methods with them, without any special framework or module like YouAreDaChef. And there's no magic support from CoffeeScript for this, it's just a natural consequence of JavaScript's underlying functional model.

All it takes is to "Think in CoffeeScript." And you'll find that many other patterns and designs from other languages can be expressed in simple and straightforward ways if we just embrace the the things that CoffeeScript does well instead of fighting against it and trying to write a Ruby program in CoffeeScript syntax.

**The End**

### Addendum: Why would we ever want to use YouAreDaChef?

Having rubbished [YouAreDaChef][y] with faint praise, we should be a little more fair. YouAreDaChef (and other "action at a distance" approaches) are good when you want to separate dependencies and not just concerns.  For a example of this technique, see [Recursive Universe][ru], an implementation of HashLife written in CoffeeScript.

[ru]: http://recursiveuniver.se

Another reason to consider the more heavyweight approach is if you have a lot of implementation inheritance. Consider:

  class A
  
    foo: ->
      withPermissionTo('read', Fubars) \
      #
      # ...base behaviour...
      #
      
Let's write:

  class B extends A
  
    foo: ->
      #
      # ...overriding behaviour...
      #
  
With the method decorators above, class B's implementation of `foo` completely override's class A's implementation, including the decoration. `withPermissionTo('read', Fubars)` only applies to that specific method body.

Another way forward is to consider `withPermissionTo('read', Fubars)` something that should apply to *every* implementation of `foo` in class A or its descendants. Class B can override the inner behaviour but not the decoration. YouAreDaChef works that way: Method advice is inherited. So when you write:

  class A
  
    foo: ->
      #
      # ...base behaviour...
      #

  class B extends A
  
    foo: ->
      #
      # ...overriding behaviour...
      #
      
  YouAreDaChef(A)
  
    .around 'foo', withPermissionTo('read', Fubars)
    
You can count on `withPermissionTo('read', Fubars)` to apply to `A::foo` and to `B:foo`. It's a different way to think about programming, and it may be what you want, but it isn't "Thinking in CoffeeScript."

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)


