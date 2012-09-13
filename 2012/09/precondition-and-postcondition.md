More Practical Method Combinators: `precondition` and `postcondition`
=====================================================================

Before we get into `precondition`, `postcondition`, and how useful they are from a practitioner's viewpoint, we're going to look at how they're implemented. `precondition` looks like this in CoffeeScript:

```coffeescript
this.precondition =
  (throwable, condition) ->
    (condition = throwable) and (throwable = 'Failed precondition') unless condition
    this.before -> throw throwable unless condition.apply(this, arguments)
```

And like this in JavaScript:

```javascript
this.precondition = function(throwable, condition) {
  if (!condition) {
    (condition = throwable) && (throwable = 'Failed precondition');
  }
  return this.before(function() {
    if (!condition.apply(this, arguments)) {
      throw throwable;
    }
  });
};
```

It's a two-line function, where the first line is some argument handling so that you can write either `precondition 'backbone.js model is not valid', -> @isValid()` if you want to declare your own throwable or `precondition -> @isValid()` if you're the taciturn type.

The second line does the actual work. As you can see, `precondition` combines your `condition` function with the `before` combinator. Yes, `precondition` is a combinator that combines a function with a combinator. That's how combinators work, they can be built into new combinators just as functions can call functions.

This is a natural consequence of JavaScript's elegant first-class functional model. Making a function out of a function that itself is made out of a function is what JavaScript does. Our code just as elegant in JavaScript even if we did use a few more symbols to make the parser happy.[1] 

Method combinators cut with the grain of JavaScript's functional model, so they are naturally elegant and there're turtles all the way down: There is no messy greenspunned engine hiding behind a curtain. That's great, because method combinators combine with each other and can be used to build new combinators and decorators. Don't just use the ones that come in the module, write some new ones!

Let's look at how.

`precondition`
--------------

As mentioned above, `precondition` can be called in either of two ways: `precondition 'backbone.js model is not valid', -> @isValid()` if you want to declare your own throwable or `precondition -> @isValid()`. The second form is equivalent to `precondition 'Failed precondition', -> @isValid()`.

So what does `precondition` do? It throws an error if the condition function fails. Let's flesh out our example:

```coffeescript
modelMustBeValid = precondition 'backbone.js model is not valid', -> @isValid()

class ChequingAccount extends BackboneModel 
# Obviously one of the five (count 'em on one hand) Canadian banks

  validate: ->
    # code ensuring that the account is in a valid state
    # this is a simple example, in real life there's probably
    # a state machine involved. In backbone.js, the #isValid()
    # method calls validate for you.
    
  processCreditTransfer:
    modelMustBeValid \
    (transferModel) ->
      # credit the account
  
  processDebitTransfer:
    modelMustBeValid \
    (transferModel) ->
      # debit the account
      
  # ...
```

If a `ChequingAccount` model is not in a valid state, an error will be thrown when you try to process a transfer against it before actually doing the transfer.

Preconditions can also do more than examine the state of the object implementing the method. A precondition is passed the method's arguments, so you can check them too:

```javascript
argumentMustBeValid = precondition(
  'argument model is not valid',
  function (modelArg) { return modelArg.isValid(); }
);
```

Preconditions can obviously be used in conjunction with error handling code to deal with exceptional but nevertheless expected cases. Another and equally intriguing possibility is to use preconditions as assertions: To check for cases that should *never* occur. In the above code, perhaps account models are always expected to be valid, and the precondition serves to identify when a programming error has put the code into an incorrect state.

Preconditions of that nature serve double duty: In development and staging, the help to find bugs. They also serve as executable documentation: Write as many as you can, programmers reading the code later will glean a wealth of information about what to expect.

What about `postcondition`?
---------------------------

You've probably figured it out already:

```coffeescript
this.postcondition =
  (throwable, condition) ->
    (condition = throwable) and (throwable = 'Failed postcondition') unless condition
    this.after -> throw throwable unless condition.apply(this, arguments)
```

And like this in JavaScript:

```javascript
this.postcondition = function(throwable, condition) {
  if (!condition) {
    (condition = throwable) && (throwable = 'Failed postcondition');
  }
  return this.after(function() {
    if (!condition.apply(this, arguments)) {
      throw throwable;
    }
  });
};
```

A `postcondition` tests its condition function *after* the method returns a value. Because it's based on `after`, the condition is paramaterized by the *return value* rather than by the arguments. It's a great way to check that anything created or mutated meets specific conditions. For example, you can check that a model stays valid after executing a method:

```coffeescript
modelMustBeValid = postcondition 'backbone.js model invalidated by method', -> @isValid()
```

Or assert something about the return value:

```javascript
returnsElements = postcondition (value) -> _.isArray(value) and !_.isEmpty(value)
```

Notes
-----

1. Compare and contrast our `precondition` to a [this ruby implementation][pr]. The Ruby implementation looks elegant to the OO-trained eye, but that's only because its `MethodDecorator` superclass is doing the heavy lifting. Have a look at  [method_decorators.rb][mds] for yourself! In my (anecdotal!) experience, this is often the way with OO languages like Ruby: You can make something appear very elegant at one level of abstraction, but if you peek behind the curtain at the abstraction's infrastructure, it's very messy and wild.

  The programmer is not at fault, far from it. It's just that some languages present a very arbitrary kind of API optimized for programming according to a specific model. When you come along to program to a different model, you end up greenspunning things in a way that cuts against the grain of the language.

[pr]: https://github.com/michaelfairley/method_decorators/blob/master/lib/method_decorators/decorators/precondition.rb "precondition.rb"
[mds]: https://github.com/michaelfairley/method_decorators/blob/master/lib/method_decorators.rb "method_decorators.rb"