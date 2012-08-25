Thinking in CoffeeScript for Ruby Developers
===

I spotted a funny joke on Twitter the other day:

![Ruby Programmers](http://i.minus.com/ibvAEhE5ovIyjF.png)

There *is* a grain of truth in this statement. Ruby programmers have become accustomed to a language that is fairly expressive. Raw JavaScript can be cumbersome. Ruby programmers are used to parentheses being optional for method calls. And there are a lot of tools in place for making CoffeeScript easy to deploy in Ruby projects, such as support baked into the Rails asset pipeline.

Of course, there's a logical fallacy in its implication. There might be a strong implication that if someone is a Ruby programmer and they program in JavaScript, then they may be very likely to use CoffeeScript. But this isn't a biconditional. There are excellent reasons for using CoffeeScript even if you never use Ruby. I'd wager that CoffeeScript's whitespace significance is appealing to Python programmers.

But besides a little fun with people's tribal inclinations, this tweet reminded me of an old saying that I have found to be very deep:

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
        
This is a well-factored solution in many languages (it isn't DRY yet, but we have untangled our methods).
        
Thinking in CoffeeScript
---

Let's starting thinking on CoffeeScript. Or more importantly, to start thinking about the things that CoffeeScript/JavaScript does well that Ruby does poorly. The above code is very OO. That's nice. But JavaScript is an old-school *functional* language. So let's refactor the above code to take advantage of the fact that functions are first-class entities in JavaScript:

    withPermissionTo = (verb, subject, callback, args...) ->
      if currentUser.hasPermissionTo(verb, subject)
        callback(args...)
      else
        controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
        
    debugEntryAndExit = (what, callback, args...) ->
      loggingMechanism.log 'debug', "entering #{what}"
      value = callback(args...)
      loggingMechanism.log 'debug', "leaving #{what}"
      value

    YouAreDaChef(WidgetViewInSomeFramework)
    
      .around 'switchToEditMode', (callback, args...) ->
        withPermissionTo('write', WidgetModel, callback, args...)
    
      .around 'switchToReadMode', (callback, args...) ->
        withPermissionTo('read', WidgetModel, callback, args...)
          
      .around 'switchToEditMode', (callback, args...) ->
        debugEntryAndExit('switchToEditMode', callback, args...)
          
      .around 'switchToReadMode', (callback, args...) ->
        debugEntryAndExit('switchToReadMode', callback, args...)

This is a lot better, especially if `withPermissionTo` and `debugEntryAndExit` are cross-cutting concerns you're going to reuse all over the application. But since we're getting into the functional swing of things, let's introduce [partial function application][pfa].

[pfa]: https://en.wikipedia.org/wiki/Partial_application

Partial function application is the conversion of a function that takes multiple arguments into a function that takes fewer arguments but binds some of its arguments. For example, if we have:

    theSomethingOfYourSomething = (something1, something2) ->
      "The #{something1} of your #{something2}"
      
    theSomethingOfYourSomething('touch', 'lips')
      # => "The touch of your lips"
      
We can make a function that only takes the first argument and returns a function that takes the second argument:

    theSomething = (something1) ->
      (something2) ->
        "The #{something1} of your #{something2}"
        
So:

    ofYour = theSomething('touch')
    ofYour('lips')
      # => "The touch of your lips"

Or even:
  
    theSomething('touch')('lips')
      # => "The touch of your lips"
      
We can use this technique to create method decorators that we can use directly as advice instead of making advice that calls a helper function:

    withPermissionTo = (verb, subject) ->
      (callback, args...) ->
        if currentUser.hasPermissionTo(verb, subject)
          callback.apply(this, args)
        else
          controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
        
    debugEntryAndExit = (what) ->
      (callback, args...) ->
        loggingMechanism.log 'debug', "entering #{what}"
        value = callback.apply(this, args)
        loggingMechanism.log 'debug', "leaving #{what}"
        value

    YouAreDaChef(WidgetViewInSomeFramework)
    
      .around 'switchToEditMode', withPermissionTo('write', WidgetModel)
    
      .around 'switchToReadMode', withPermissionTo('read', WidgetModel)
    
      .around 'switchToEditMode', debugEntryAndExit('switchToEditMode')
    
      .around 'switchToReadMode', debugEntryAndExit('switchToReadMode')
      
Now our cross-cutting functions return method decorator functions. Functions returning functions are definitely functional. But wait, we can take this another step. YouAreDaChef is extremely useful when we want to completely separate cross-cutting concerns from business logic. For example, if we want to put our debug advice into a file called `debug.js` and conditionally include or exclude it, YouAreDaChef lets us 'MonkeyPatch' our classes from a distance.

That can be a very nice style when we're trying to eliminate dependencies. For example, we may want to write Jasmine tests on our `WidgetViewInSomeFramework` class without having to mock up all our debugging and permissions behaviour.

Decorating Methods
---

But what if we don't need all the Architecture Astronautics? Python provides [a much simpler way to decorate methods][pyd] if you don't mind annotating the method definition itself.

[pyd]: http://en.wikipedia.org/wiki/Python_syntax_and_semantics#Decorators "Python Method Decorators"

CoffeeScript doesn't provide such a mechanism, because you don't need one in JavaScript. Unlike Ruby, there is no distinction between methods and functions. Furthermore, there is no 'magic' syntax for declaring a method. No `def` keyword, nothing. Methods are object and prototype properties that happen to be functions. And in CoffeeScript, we can provide any expression for a method body, it doesn't have to be a function literal.

> Every problem in Computer Science can be solved by adding another layer of abstraction, except for the problem of having too many layers of abstraction.--Alan Perlis

Let's add another later of abstraction. Our decorators `withPermissionTo` and `debugEntryAndExit` will return functions that take a method function and return a decorated method. So they'll mix the decoration and the mechanism. YouAReDaChef does some magic to make sure `this` is correctly set, but we'll do it ourselves:

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

Addendum: Why would we ever want to use YouAreDaChef?
---

Having rubbished YouAreDaChef with faint praise, we should be a little more fair. YouAreDaChef (and other "action at a distance" approaches) are good when you want to separate dependencies and not just concerns.  For a example of this technique, see [Recursive Universe][ru], an implementation of HashLife written in CoffeeScript with YouAreDaChef.

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
    
You can count on `withPermissionTo('read', Fubars)` to apply to `A::foo` and to `B:foo`. It's a different way to think about programming, and it may be what you want, but it isn't "thinking in CoffeeScript."

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)


