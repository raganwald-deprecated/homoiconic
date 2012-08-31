![Dos Equis Guy Endorses YouAreDaChef](http://i.minus.com/i3niTDYu2cbR1.jpg)
  
  
What Does YouAreDaChef Make Easy?
=================================

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

And what is this [YouAreDaChef]? It's a library that appears to solve the same problem. Here's a look at how it works, starting with our advice. Note that these are not decorators, they don't modify a function:

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

YouAreDaChef's design takes a very different approach to solving what appears to be the same problem that method decorators solve. The differences between method decorators and YouAreDaChef are deliberate, they're a consequence of each approach solving the same basic problem but also attempting to solve some other software development problems at the same time. The unstated problems represent a set of what you might call "hidden assumptions" about the challenges of software development.

Ease
----

Software Development is all about satisfying requirements, which we can express as enabling user stories peopled by persona. Of course, we know that, those people are our software's "users." But everyone who interacts with our program is a user of sorts. That also includes the IT department who maintains the servers, the DBAs who optimize our queries, QA analysts, product managers, interns, documentation specialists, and (I've saved my favourite for last) the developers themselves. And yes, that means YOU.

We developers are personas and have user stories. Although it has little to do with method decoration, here's one of my favourites courtesy of Joel Spolsky:

> A developer should be able to compile and deploy the application in one step.

Simple, easy to test. Can you do one thing (e.g. `cap deploy`) and push the latest changes to staging or production?

We programmers don't usually talk about program designs in terms of "user stories," but we think about them. The jargon I usually hear from programmers is "Optimizing for \_\_\_\_\_\_\_." For example, we might say that we believe that polymorphism optimizes for creating or changing objects and their implementations. Or we might say that we believe that inheritance optimizes for easy sharing of implementations.

A more colloquial thing to say is that a particular design choice "makes something easy." For example, many people believe that good automated test coverage makes refactoring easy. So, what does YouAreDaChef make easy? And what does that tell us about designing programs?

YouAreDaChef makes testing easy
-------------------------------

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

YouAreDaChef's decoupling makes writing tests easy.

YouAreDaChef makes working with cross-cutting concerns easy
-----------------------------------------------------------

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

YouAreDaChef makes working with cross-cutting concerns easy when you have inheritance hierarchies
-------------------------------------------------------------------------------------------

Method decorators do exactly what they look like they do: They are expressions that return a function that is then bound to a property in a prototype. Everything else we might say about "inheritance" and "classes" works exactly as it always works in JavaScript.

Duh, one might say. That's how inheritance works. Actually, inheritance can work in a lot of different ways. Ruby inheritance is different from C++ inheritance. JavaScript inheritance is different from Java inheritance.

Method decorators make working with JavaScript's existing inheritance mechanism easy. What kind of inheritance does YouAreDaChef make easy?

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

YouAreDaChef makes working with cross-cutting concerns easy when you have inheritance hierarchies.

What does this tell us?
-----------------------

YouAreDaChef:

1. Makes testing easy
2. Makes working with cross-cutting concerns easy
3. Makes working with cross-cutting concerns easy when you have inheritance hierarchies

Is it worth using a library when method decorators are a simple design pattern arising from JavaScript's existing functional model? Like anything, it depends on whether you really need help with your tests. It depends on whether your cross-cutting concerns are entangling your code, and whether you are already philosophically inclined to write deep inheritance hierarchies.

There's nothing wrong with taking a YAGNI approach. Don't worry about YouAreDaChef until you find yourself writing a lot of mocking and stubbing every time you write some new tests. When you do, have another look. Don't worry about YouAreDaChef until you find that modifying cross-cutting concerns sends you on a chase across files and classes because its dependencies are scattered through the code. When you do, have another look. And don't worry about YouAreDaChef if your classes tend to be organized in shallow hierarchies with more composition than inheritance. Those of you who prefer [a more ontological approach][oop] already know who you are.

[oop]: https://github.com/raganwald/homoiconic/blob/master/2010/12/oop.md#oop-practiced-backwards-is-poo

In the end, software design decisions, including choosing how to handle cross-cutting concerns, are expressions of your beliefs about how the software will be used by other programmers. They are the consequences of your beliefs of what is likely to change frequently and what is unlikely to change. they are expressions of your belief in what needs to be well understood and what can be cursorily scanned.

Should you use method decorators or YouAreDaChef? It all depends on what you believe is going to happen to your program.

Notes
-----

1. And because it's a shiny cool thing I wrote and I want you to say "Ooh!" and "Ah!" But I'd never admit to that in writing. Even now, I'm pretending this is self-deprecating humour, not a serious troll for attention and validation from strangers on the Internet.
2. [Café au Life][Recursive Universe] demonstrates the YouAreDaChef approach with the knobs turned up to eleven: Concerns like caching and garbage collection are entirely separated from core classes, and you can learn how the code works one concern at a time.

[Recursive Universe]: http://recursiveuniver.se