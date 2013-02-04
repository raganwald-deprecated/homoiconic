Method Combinators in CoffeeScript
===

Whenever I catch myself thinking that a language I'm using doesn't have the conveniences I need to write programs in the style of [some other language that I like][snobol], I try to remind myself that:

[snobol]: ftp://ftp.cs.arizona.edu/snobol/gb.pdf

> [Real programmers][rp] can write FORTRAN in any language.

If I don't catch myself, I tend to think in my favourite programming language and then translate my thoughts into whatever notation the compiler or interpreter accepts.

[rp]: http://www.pbm.com/~lindahl/real.programmers.html "Real programmers don't use Pascal—Ed Post"

The advantage of this approach is apparent when we're working down the [power continuum][avg]. Because we think in a higher-level language, we Greenspun more powerful features into a less powerful language. The Ruby on Rails framework is a good example of this: ActiveController and ActiveRecord bake method-advice and method decorators into Ruby.

[avg]: http://www.paulgraham.com/avg.html "Beating the Averages—Paul Graham"

The disadvantage of this thinking in one language and writing in another is that sometimes we are blind to a language's own features and styles that are equally or even more powerful than the language we find comfortable to use. I've seen this in SQL where people sometimes write out stored procedures with loops when they could have learned how to use SQL's relational calculus to obtain the same results.

When I go from one language to another, it's fine to try bring my best stuff, but not at the expense of ignoring the good things that the new language does well. Ruby-informed CoffeeScript might be wonderful. A Ruby program in CoffeeScript, not so nice.

Enough hand-waving, let's discuss a specific example!

Untangling Cross-Cutting Concerns
---

As you know, Ruby and JavaScript both have Object Models. And objects have methods. And good software often involves *decorating* a method. Let's start off by agreeing on what I mean in this context. By "decorating a method," I mean adding some functionality to a method external to the method's body. The functionality you're adding is a "method decorator." (Some people call the mechanism the decorator, but let's use my definition in this essay.)

If you've written a `before_validation` method in Ruby on Rails, you've written a method decorator. You're decorating ActiveRecord's baked-in validation code with something you want done before it does its validation. Likewise, ActiveController's `before` filters do exactly the same thing, albeit with a different syntax.

These are good things. Without decorators, you end up "tangling" every method with a lot of heterogenous cross-cutting concerns:

```coffeescript
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
```
        
(These are not meant to be serious examples, but just credible enough that we can grasp the idea of cross-cutting concerns and tangling.)

Faced with this problem and some Ruby experience, an intelligent but not particularly wise developer might rush off and write something like [YouAreDaChef][y], an Aspect-Oriented Framework for JavaScript. With YouAreDaChef, we can "untangle" the cross-cutting concerns from the primary purpose of each method:

[y]: https://github.com/raganwald/YouAreDaChef "YouAreDaChef, AOP for JavaScript and CoffeeScript"

```coffeescript
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

  .around 'switchToEditMode', (callback, argv...) ->
    if currentUser.hasPermissionTo('write', WidgetModel)
      callback.apply(this, argv)
    else
      controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'

  .around 'switchToReadMode', (callback, argv...) ->
    if currentUser.hasPermissionTo('read', WidgetModel)
      callback.apply(this, argv)
    else
      controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
      
  .around 'switchToEditMode', (callback, argv...) ->
    loggingMechanism.log 'debug', "entering switchToEditMode"
    value = callback.apply(this, argv)
    loggingMechanism.log 'debug', "leaving switchToEditMode"
    value
      
  .around 'switchToReadMode', (callback, argv...) ->
    loggingMechanism.log 'debug', "entering switchToReadMode"
    value = callback.apply(this, argv)
    loggingMechanism.log 'debug', "leaving switchToReadMode"
    value
```
        
YouAreDaChef provides a mechanism for adding "advice" to each method, separating our base behaviour from the cross-cutting concerns. This example isn't particularly DRY, but let's not waste time fixing it up. It's interesting, but hardly "Thinking in CoffeeScript."
        
Decorating Methods
---

In CoffeeScript, we rarely need all the Architecture Astronautics. Can we untangle the concerns with a simpler mechanism? Yes. Python provides [a much simpler way to decorate methods][pyd] if you don't mind annotating the method definition itself.

[pyd]: http://en.wikipedia.org/wiki/Python_syntax_and_semantics#Decorators "Python Method Decorators"

CoffeeScript doesn't provide a similar annotation mechanism, because you don't need one in JavaScript. Unlike Ruby, there is no distinction between methods and functions. Furthermore, there is no 'magic' syntax for declaring a method. No `def` keyword, nothing. Methods are object and prototype properties that happen to be functions. And in CoffeeScript, we can provide any expression for a method body, it doesn't have to be a function literal.

Let's create our own method decorators `withPermissionTo` and `debugEntryAndExit`. They will return functions that take a method's body (a function) and return a decorated method. We'll make sure `this` is set correctly:

```coffeescript
withPermissionTo = (verb, subject) ->
  (callback) ->
    ->
      if currentUser.hasPermissionTo(verb, subject)
        callback.apply(this, arguments)
      else
        controller.redirect_to 'https://en.wikipedia.org/wiki/PEBKAC'
    
debugEntryAndExit = (what) ->
  (callback) ->
    ->
      loggingMechanism.log 'debug', "entering #{what}"
      value = callback.apply(this, arguments)
      loggingMechanism.log 'debug', "leaving #{what}"
      value
```
          
Now we can write them directly in our class definition:

```coffeescript
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
```

Our decorators work just like Python method decorators, only we don't need any syntactic sugar for them ([1](#notes)). CoffeeScript (and JavaScript, although these examples are in CoffeeScript) doesn't have any special syntax for defining methods, it's just an expression that evaluates to a function. In this case, our methods are expressions that take two decorators and apply them to a function literal. Because there's no special syntax, any expression will do. We exploit this when using our method decorators inline as part of the method "definition."

So: We've worked out how to separate cross-cutting concerns from our method bodies and how to decorate our methods with them, without any special framework or module. It's just a natural consequence of JavaScript's underlying functional model.

All it takes is to "Think in CoffeeScript." And you'll find that many other patterns and designs from other languages can be expressed in simple and straightforward ways if we just embrace the the things that CoffeeScript does well instead of fighting against it and trying to write a Ruby program in CoffeeScript syntax.

Decorators are Combinators
---

After writing a few decorators, you'll notice that common patterns keep cropping up. Perusing the literature, they have names:

1. You want to do something *before* the method's base logic is executed.
2. You want to do something *after* the method's base logic is executed.
3. You want to do wrap some logic *around* the method's base logic.
4. You only want to execute the method's base logic *provided* some condition is truthy.

Rails gives you special methods that call other methods for this, but let's think in JavaScript, or more specifically, in functions. We wrote method decorators that were really functions that consumed a function and returned another function.

So let's do that exact same thing again. We want functions that consume a function representing the "something" we want done and return a method decorator that can consume a method's base function and return a decorated method.

Such as:

```coffeescript
before = (decoration) ->
           (base) ->
             ->
               decoration.apply(this, arguments)
               base.apply(this, arguments)
               
after  = (decoration) ->
           (base) ->
             ->
               __value__ = base.apply(this, arguments)
               decoration.apply(this, arguments)
               __value__
          
around = (decoration) ->
           (base) ->
             (argv...) ->
               callback = => base.apply(this, argv)
               decoration.apply(this, [callback].concat(argv))

provided = (condition) ->
             (base) ->
               ->
                 if condition.apply(this, arguments)
                   base.apply(this, arguments)
```

Combinatory Logic fans will recognize these as [basic combinators like the Bluebird and the Queer Bird][aopcombinators]. We can use our new combinators to create method decorators without having to handle messy details like arguments and managing `this` correctly:

[aopcombinators]: https://github.com/raganwald/homoiconic/blob/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#aspect-oriented-programming-in-ruby-using-combinator-birds "Aspect-Oriented Programming in Ruby using Combinator Birds"

```coffeescript
triggers = (eventStrings...) ->
             after ->
               for eventString in eventStrings
                 @trigger(eventString)

displaysWait = do ->
                 waitLevel = 0
                 around (yield) ->
                   someDOMElement.show() if (waitLevel += 1) > 0
                   yield()
                   someDOMElement.hide() if (waitLevel -= 1) <= 0
```

And then we use the new decorators:

```coffeescript
class SomeExampleModel

  setHeavyweightProperty:
    triggers('cache:dirty') \
    (property, value) ->
      # set some property in a complicated way
    
  recalculate:
    displaysWait \
    triggers('cache:dirty') \
    ->
      # Do something that takes a long time
```

Now that we see the combinators turn functions into decorators, and the decorators turn functions into method bodies, we see that Python's method decorators are combinators too. JavaScript's functional model makes expressing these ideas natural, without requiring a heavyweight framework or special syntax.

Try using method combinators in your next project. You'll be "Thinking in CoffeeScript." And of course, everything we've done here works 100% the same way in JavaScript, it's just that the syntax is a little cleaner. So you're "Thinking in JavaScript" too.

More Reading
---

* [npm install method-combinators](https://github.com/raganwald/method-combinators)
* [Using Method Decorators to Decouple Code](https://github.com/raganwald/homoiconic/blob/master/2012/08/decoupling_with_method_decorators.md#using-method-decorators-to-decouple-code)
* [Understanding Python Decorators](http://stackoverflow.com/questions/739654/understanding-python-decorators) on StackOverflow
* [Introduction to Python Decorators](http://www.artima.com/weblogs/viewpost.jsp?thread=240808) by Bruce Eckel
* [Aspect-Oriented programming using Combinator Birds](https://github.com/raganwald/homoiconic/blob/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#aspect-oriented-programming-in-ruby-using-combinator-birds)

Notes
---

1. To be clear, Python *does* have the idea of functions returning functions, and it does have anonymous functions ("lambdas"). The point here is that because CoffeeScript does not distinguish between a function and a method when defining a method, all of the things you can do with any expression apply to "defining" a method, like having an expression where one or more functions are chained together. There is no need for syntactic sugar or for a workaround like defining a method and then assigning a decorated function to it. (Clarifications courtesy of [masklinn](http://news.ycombinator.com/item?id=4443068)). [go back](#decorating-methods).

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


