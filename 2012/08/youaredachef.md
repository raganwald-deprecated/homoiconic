*This essay is a work in progress. Feel free to comment, tweet, &c. but it is definately not ready or Hacker News, Reddit, and so forth. Thanks!*

Three Reasons to use YouAreDaChef
===

In [Method Combinators in CoffeeScript][mcc], I described method decorators, an elegant way of separating concerns in CoffeeScript and JavaScript methods, for example:

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

Of course, "rarely" does not mean "never." Method decorators look great and are easy to write. The obvious question is, "What is YouAreDaChef, what does it do that method decorators can't do, and when would you prefer YouAreDaChef to method decorators?"

I'm glad you asked.

![Dos Equis Guy Endorses YouAreDaChef](http://i.minus.com/i3niTDYu2cbR1.jpg)

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

Why should a view know anything about permissions? Permissions and authorization should be decoupled from correctly rendering or updating a view. After all, if it's a seperate 