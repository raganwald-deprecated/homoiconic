![Dos Equis Guy Endorses YouAreDaChef](http://i.minus.com/i3niTDYu2cbR1.jpg)
  
  
Using Method Decorators to Decouple Code
========================================

[Method Combinators in CoffeeScript][mcc] described method decorators, an elegant way of separating concerns in CoffeeScript methods. Here are some decorators:

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

And here they are in use:

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

(The idea of mixing some kind of view-ish `displayWait` responsibility with a model responsibility may set our teeth on edge, but let's hand-wave that furiously and stay focused on how these things work rather than arguing whether the colour of the bike shed is appropriate for a nuclear installation.)

I also wrote, more-or-less:

[mcc]: https://github.com/raganwald/homoiconic/blob/master/2012/08/method-decorators-and-combinators-in-coffeescript.md#method-combinators-in-coffeescript

> Without method decorators, you end up "tangling" every method with a lot of heterogenous cross-cutting concerns. Faced with this problem and some Ruby experience, an intelligent but not particularly wise developer might rush off and write something like [YouAreDaChef], an Aspect-Oriented Framework for JavaScript. YouAreDaChef provides a mechanism for adding "advice" to each method, separating our base behaviour from the cross-cutting concerns.

> In CoffeeScript, we rarely need all of YouAreDaChef's Architecture Astronautics.

[YouAreDaChef]: https://github.com/raganwald/YouAreDaChef "YouAreDaChef, AOP for JavaScript and CoffeeScript"

And what is this [YouAreDaChef]? It's an [Aspect-Oriented Programming] library that appears to solve the same problem. Here's a look at how it works, starting with our advice. Note that these are not decorators, they don't modify a function:

[Aspect-Oriented Programming]: https://en.wikipedia.org/wiki/Aspect-oriented_programming

```coffeescript
triggers = (eventStrings...) ->
             for eventString in eventStrings
               @trigger(eventString)

displaysWait = do ->
                 waitLevel = 0
                 (yield) ->
                   someDOMElement.show() if (waitLevel += 1) > 0
                   yield()
                   someDOMElement.hide() if (waitLevel -= 1) <= 0
```

And our class, bereft of any references to the advice:

```coffeescript
class SomeExampleModel

  setHeavyweightProperty: (property, value) ->
    # set some property in a complicated way
    
  recalculate: ->
    # Do something that takes a long time
```

And finally, YouAreDaChef binds them together:

```coffeescript
YouAreDaChef

  .clazz(SomeExampleModel)
  
    .method('setHeavyweightProperty', 'recalculate')
      .after triggers('cache:dirty')
      
    .method('recalculate')
      .around displaysWait
```

YouAreDaChef's design takes a very different approach to solving what appears to be the same problem that method decorators solve. The colloquial thing programmers often say is that a particular design choice "makes something easy." For example, many people believe that good automated test coverage makes refactoring easy. So, what does YouAreDaChef make easy?

Does YouAreDaChef make testing easy?
------------------------------------

Let's look more closely at YouAreDaChef and see if we can glean some insights by looking at what it "makes easy." ([1](#Notes))

The first and most obvious thing that YouAreDaChef makes easy is using *three* pieces of code to separate some advice from some methods. the advice is one chunk. The methods are another, and YouAreDaChef's bindings are a third. With method decorators, you only need two, the decorators and the method declarations that separate the invocation of the decorators from the method bodies, but are still in the same big chunk of code.

The both have three chunks of code, but YouAreDaChef completely breaks them apart:

```coffeescript
YouAreDaChef
  .clazz(SomeExampleModel)
    .method('setHeavyweightProperty')
      .after triggers('cache:dirty')
      
```

While method decorators have them separate but adjacent within the class definition:

```coffeescript
class SomeExampleModel

  setHeavyweightProperty:
    triggers('cache:dirty') \ # separate from the body but within the overall delcaration
    (property, value) ->
      # set some property in a complicated way
```

Having the binding in a third chunk of code does make a few things easy. What happens if you omit the third chunk of code? If you are careful to make the YouAreDaChef bindings the only dependency between the advice and the method bodies, you have decoupled the advice from the methods.

What does this make easy? Well, for one thing, it makes testing easy. You don't need your tests to elaborately mock up a lot of authorization code to appease the authorization advice, you simply don't bind it when you're unit testing the base functionality, and you bind it when you're integration testing the whole thing.

YouAreDaChef's decoupling makes writing tests easy by decoupling code so that you can test one responsibility at a time.

Does YouAreDaChef makes working with cross-cutting concerns easy?
-----------------------------------------------------------------

YouAreDaChef does allow you to break things into three pieces, but you can also put them back into two pieces, but in a different way than method decorators.

Almost any technique allows you to separate the implementation of a cross-cutting concern from the code that uses it. Method decorators extracts the use of the concern from the body of the method, but puts them adjacent to each other. So while the concern is separated from the method body, they're both within the class definition. This makes it easy to look at a class--like `SomeExampleModel`--and know everything about that model's behaviour.

Here's another way to organize the code in two pieces:

```coffeescript

# YouAreDaChef I

triggers = (eventStrings...) ->
             for eventString in eventStrings
               @trigger(eventString)
               
YouAreDaChef
  .clazz(SomeExampleModel)
    .method('setHeavyweightProperty', 'recalculate')
      .after triggers('cache:dirty')

# YouAreDaChef II

class SomeExampleModel

  setHeavyweightProperty: (property, value) ->
    # set some property in a complicated way
    
  recalculate: ->
    # Do something that takes a long time
```

We've put the YouAreDaChef code binding the advice to the methods with the implementation of the advice. This makes it easy to look at a particular concern--like managing a cache--and know everything about its behaviour. The YouAreDaChef approach makes working with cross-cutting concerns easy: You never have to go hunting through the app to find out what classes and methods are advised by the concern.([2](#Notes))

Anything you can do, I can do better
------------------------------------

The JavaScript object model is extremely flexible. That's because it is extremely minimal but relatively unconstrained, so you can usually build whatever you want out of it. And in fact, if we want to decouple the method decorators from the declaration of methods, we can do it:

```coffeescript
class SomeExampleModel

  setHeavyweightProperty: (property, value) ->
    # set some property in a complicated way
    
  recalculate: ->
    # Do something that takes a long time
      
# ...

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

SomeExampleModel::setHeavyweightProperty = 
  triggers('cache:dirty') \
  SomeExampleModel::setHeavyweightProperty

SomeExampleModel::recalculate =
  displaysWait \
  triggers('cache:dirty') \
  SomeExampleModel::recalculate
```

Hah! If we wanted to make testing easy and work with cross-cutting concerns, we can do that with method decorators too. This is an important pattern: **Method decorators can be used to decouple code**.

What is YouAreDaChef's special sauce?
-------------------------------------

So what does YouAreDaChef make easy that method decorators can't manage?

YouAreDaChef treats methods as having advice and a *default* body. So in the `triggers` example above, `triggers` is *after advice* and the body of `recalculate` is the *default body*. If there is no inheritance involved, it works exactly like method decorators.

But when we have inheritance, YouAreDaChef has a more complex model than JavaScript's baked-in protocol. With YouAreDaChef, the before, after, around, and guard advice is always inherited. Only the default body is overridden. Here's a contrived example:

```coffeescript
class ShowyModel extends SomeExampleModel
               
YouAreDaChef
  .clazz(ShowyModel)
    .method('setHeavyweightProperty')
      .around displaysWait
```

This code says that a `ShowyModel` extends a `SomeExampleModel`, obviously. It also says that the `setHeavyweightProperty` of a `ShowyModel` has some around advice, `displaysWait`. But it also inherits `SomeExampleModel`'s default method body and its after advice of `triggers('cache:dirty')`. In YouAreDaChef, advice is additive.

We could also change the default body without changing the after advice, like this:

```coffeescript
class DifferentPropertyImplementationModel extends SomeExampleModel
               
YouAreDaChef
  .clazz(DifferentPropertyImplementationModel)
    .method('setHeavyweightProperty')
      .default (property, value) ->
        # set some property in a different way
```

Our `DifferentPropertyImplementationModel` inherits the `after` advice from `SomeExampleModel` but overrides the default body. Default bodies are not additive, they override.

This style of inheritance looks very weird if you think in terms of the implementation. If you try to figure out what YouAreDaChef is doing rather than what its declarations mean, it's a lot. But if you accept the abstraction at face value, it's very simple: If you declare that `triggers('cache:dirty')` happens after the `setHeavyweightProperty` method of `SomeExampleModel` is invoked, well, doesn't that obviously mean it happens after the `setHeavyweightProperty` methods of `ShowyModel` or `DifferentPropertyImplementationModel` are invoked? They're `SomeExampleModel`s too!

If it didn't, we'd have to redeclare all of our advice every time we subclassed. And worse, it would be a maintenance nightmare. if you add a new piece of advice to `SomeExampleModel`, can you be sure you remembered to add it to all of its subclasses that might override its methods?

This is YouAreDaChef's special sauce: It makes working with inheritance easy by decoupling advice inheritance from method body inheritance.

Summary
-------

Is it worth using a library to decouple code when method decorators are a simple design pattern arising from JavaScript's existing functional model? There's nothing wrong with taking a YAGNI approach. Don't worry about your decorators until you find yourself writing a lot of mocking and stubbing every time you write some new tests. When you do, consider refactoring your decorators to decouple them from your methods.

Don't worry about your decorators until you find that modifying cross-cutting concerns sends you on a chase across files and classes because its dependencies are scattered through the code. When you do, refactoring your decorators to couple them with the concerns so that everything to do with the concern is in one place.

And don't worry about your decorators if your classes tend to be organized in shallow hierarchies with more composition than inheritance. Those of you who prefer [a more ontological approach][oop] already know who you are. But if you find yourself doing some back flips to ensure that your decorators are applied consistently up and down a class hierarchy, it's time to take a closer look at [YouAreDaChef].

[oop]: https://github.com/raganwald/homoiconic/blob/master/2010/12/oop.md#oop-practiced-backwards-is-poo

p.s. [Method combinators github repository](https://github.com/raganwald/method-combinators)

Notes
-----

1. And because it's a shiny cool thing I wrote and I want you to say "Ooh!" and "Ah!" But I'd never admit to that in writing. Even now, I'm pretending this is self-deprecating humour, not a serious troll for attention and validation from strangers on the Internet.
2. [Café au Life][Recursive Universe] demonstrates the YouAreDaChef approach with the knobs turned up to eleven: Concerns like caching and garbage collection are entirely separated from core classes, and you can learn how the code works one concern at a time.

[Recursive Universe]: http://recursiveuniver.se