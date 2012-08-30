*This essay is a work in progress. Feel free to comment, tweet, &c. but it is definately not ready or Hacker News, Reddit, and so forth. Thanks!*

Decisions, Decisions
====================

In [Method Combinators in CoffeeScript][mcc], I described method decorators, an elegant way of separating concerns in CoffeeScript and JavaScript methods. Here's an example:

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

I also wrote, more-or-less:

[mcc]: https://github.com/raganwald/homoiconic/blob/master/2012/08/method-decorators-and-combinators-in-coffeescript.md#method-combinators-in-coffeescript

> Without method decorators, you end up "tangling" every method with a lot of heterogenous cross-cutting concerns. Faced with this problem and some Ruby experience, an intelligent but not particularly wise developer might rush off and write something like [YouAreDaChef], an Aspect-Oriented Framework for JavaScript. YouAreDaChef provides a mechanism for adding "advice" to each method, separating our base behaviour from the cross-cutting concerns.

> In CoffeeScript, we rarely need all of YouAreDaChef's Architecture Astronautics.

[YouAreDaChef]: https://github.com/raganwald/YouAreDaChef "YouAreDaChef, AOP for JavaScript and CoffeeScript"

![Dos Equis Guy Endorses YouAreDaChef](http://i.minus.com/i3niTDYu2cbR1.jpg)

And what is this YouAreDaChef? It's a library that appears to solve the same problem. Here's a look at how it works, starting with our advice. Note that these are not decorators, they don't modify a function:

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

User Stories in Software Development
------------------------------------

Software Development is all about satisfying requirements, which we can express as enabling user stories peopled by persona. Of course, we know that, those people are our software's "users." But everyone who interacts with our program is a user of sorts. That also includes the IT department who maintains the servers, the DBAs who optimize our queries, QA analysts, product managers, interns, documentation specialists, and (I've saved my favourite for last) the developers themselves. And yes, that means YOU.

We developers are personas and have user stories. Although it has little to do with method decoration, here's one of my favourites courtesy of Joel Spolsky:

> A developer should be able to compile and deploy the application in one step.

Simple, easy to test. Can you do one thing (e.g. `cap deploy`) and push the latest changes to staging or production?

We programmers don't usually talk about program designs in terms of "user stories," but we think about them. The jargon I usually hear from programmers is "Optimizing for \_\_\_\_\_\_\_." For example, we might say that we believe that polymorphism optimizes for creating or changing objects and their implementations. Or we might say that we believe that inheritance optimizes for easy sharing of implementations.

A more colloquial thing to say is that a particular design choice "makes something easy." For example, many people believe that good automated test coverage makes refactoring easy. So, what does YouAreDaChef make easy? And what does that tell us about designing programs?

What does YouAreDaChef make easy?
---------------------------------

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

What else does YouAreDaChef make easy?
--------------------------------------

YouAreDaChef does allow you to break things into three pieces, but you can also put them in two pieces, but in a different way. Consider the difference between:

```coffeescript

# Method Decorators I

triggers = (eventStrings...) ->
             after ->
               for eventString in eventStrings
                 @trigger(eventString)
                   
# Method Decorators II

class SomeExampleModel

  setHeavyweightProperty:
    triggers('cache:dirty') \
    (property, value) ->
      # set some property in a complicated way
    
  recalculate:
    triggers('cache:dirty') \
    ->
      # Do something that takes a long time
```

And:

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

The first one is organized such that the class being 'decorated' knows what does the decorating. So the decorated class depends on the decoration. The second one is organized such that the method advice knows what it advises. So the advice depends on the class being advised.

The first one, written with method decorators, makes it easy to look at a class--like `SomeExampleModel`--and know everything about that model's behaviour. The second one, written with YouAreDaChef, makes it easy to look at a particular concern--like managing a cache--and know everything about the concern's behaviour. They both make it easy to look at a model class and understand its primary responsibility, uncluttered by other concerns.

The YouAreDaChef approach is thus superior when you want to make working with cross-cutting concerns easy. [Café au Life][Recursive Universe] demonstrates this approach with the knobs turned up to eleven: Concerns like caching and garbage collection are entirely separated from core classes, and you can learn how the code works a piece at a time.

[Recursive Universe]: http://recursiveuniver.se




Notes
-----

1. And because it's a shiny cool thing I wrote and I want you to say "Ooh!" and "Ah!" But I'd never admit to that in writing. Even now, I'm pretending this is self-deprecating humour, not a serious troll for attention and validation from strangers on the Internet.