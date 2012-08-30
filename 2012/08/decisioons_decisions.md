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

We have other, more subjective requirements we can express as stories. For example, the great mantra of "bondage and discipline" coding environments is that a large team of moderately inexperienced developers with a relatively low level of communication can sustain a consistent velocity of development. Whether you agree that languages like Java and tools like XML make this possible or not, this is a user story with well-understood persona.

When we say that method decorators and YouAreDaChef both solve the same problem, another way to say it is that they appear in the same user story. That story is one where a developer wishes to separate some cross-cutting functionality (like authorization, logging, displaying feedback, &c.) from some core functionality.

If we stop right there, method decorators are the clear winners. They're simple and require only that you wrap your head around functions returning functions. But we needn't stop right there. Why is the developer separating these concerns with decorators instead of inline? What other developer user stories are involved?

What does YouAreDaChef make easy?
---------------------------------

Let's look more closely at YouAreDaChef and see if we can glean some of the other user stories by looking at what it "makes easy." ([1](#Notes))

![Dos Equis Guy Endorses YouAreDaChef](http://i.minus.com/i3niTDYu2cbR1.jpg)

The first and most obvious thing that YouAreDaChef makes easy is using *three* pieces of code to separate some advice from some methods. the advice is one chunk. The methods are another, and YouAreDaChef's bindings are a third. With method decorators, you only need two, the decorators and the method declarations that separate the invocation of the decorators from the method bodies, but are still in the same big chunk of code.

The both have three chunks of code, but YouAreDaChef completely breaks them apart, while method decorators have them separate but adjacent:

```coffeescript
class SomeExampleModel

  setHeavyweightProperty:
    triggers('cache:dirty') \ # separate from the body but within the overall delcaration
    (property, value) ->
      # set some property in a complicated way
```

[YouAreDaChef] is a meta-programming framework. It modifies an existing class or hierarchy of classes to add *method advice*. In the very simplest cases, method advice resembles decoration. You can provide "advice" in the form of a function that is executed `before`, `after`, or `around` a method. You can also `guard` a method with a predicate. You can do all of these things with method decorators, of course.

First, method decorators do something very simple: They modify the behaviour of one method body. Nothing else is changed. Second, method decorators are  almost always used in the declaration of a method. Finally, method decorators make use of functions calling other functions, so at runtime the structure of a decorated method can only be deduced by tracing its execution. There is no runtime-introspection capability that might be used for debugging or advanced meta-programming purposes.

YouAreDaChef differs from method decorators on all three counts:

1. YouAreDaChef decouples advice from class declarations.
2. YouAreDaChef understands inheritance.
3. YouAreDaChef can be introspected at run time.

YouAreDaChef decouples advice from class declarations
---

With method decorators, you decorate the method right in the class "declaration." That is nice when you're reading a method and want to know everything it does. There's no spooky "action at a distance."

However, it tightly couples classes to cross-cutting concerns. For example:

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

Why should a view know anything about permissions? Permissions and authoriz

Notes
-----

1. And because it's a shiny cool thing I wrote and I want you to say "Ooh!" and "Ah!" But I'd never admit to that in writing. Even now, I'm pretending this is self-deprecating humour, not a serious troll for attention and validation from strangers on the Internet.