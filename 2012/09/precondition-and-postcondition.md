More Practical Method Combinators: Pre- and Post-conditions
===========================================================

Today we're going to look at two more useful [method combinators]. Before we get into precondition, postcondition, and how useful they are from a practitioner's viewpoint, we're going to look at how they're implemented. Precondition looks like this in CoffeeScript:

[method combinators]: https://github.com/raganwald/method-combinators

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

It's a two-line function, where the first line is some argument handling so that you can write either `precondition 'receiver is not valid', -> @isValid()` if you want to declare your own throwable or `precondition -> @isValid()` if you're the taciturn type.

The second line does the actual work. As you can see, precondition combines your `condition` function with the before combinator. Yes, precondition is a combinator that combines a function with a combinator. That's how combinators work, they can be built into new combinators just as functions can call functions.

This is a natural consequence of JavaScript's elegant first-class functional model. Making a function out of a function that itself is made out of a function is what JavaScript does. Our code just as elegant in JavaScript even if we did use a few more symbols to make the parser happy.[[note]] 

[note]: https://github.com/raganwald/homoiconic/blob/master/2012/09/precondition-and-postcondition.md#note

Method combinators cut with the grain of JavaScript's functional model, so they are naturally elegant and there're turtles all the way down: There is no messy greenspunned engine hiding behind a curtain. That's great, because method combinators combine with each other and can be used to build new combinators and decorators. Don't just use the ones that come in the module, write some new ones!

Let's look at how.

`precondition`
--------------

As mentioned above, precondition can be called in either of two ways:

1. You can write `precondition 'receiver is not valid', -> @isValid()` if you want to declare your own throwable.
2. You can write or `precondition -> @isValid()`, leaving out the throwable. This is equivalent to writing `precondition 'Failed precondition', -> @isValid()`.

So what does precondition do? It throws an error if the condition function fails. Let's flesh out our example:

```coffeescript
receiverMustBeValid = precondition 'receiver is not valid', -> @isValid()

class ChequingAccount extends BackboneModel 
# Obviously one of the five (count 'em on one hand) Canadian banks

  validate: ->
    # code ensuring that the account is in a valid state
    # this is a simple example, in real life there's probably
    # a state machine involved. In backbone.js, the #isValid()
    # method calls validate for you.
    
  processCreditTransfer:
    receiverMustBeValid \
    (transferModel) ->
      # credit the account
  
  processDebitTransfer:
    receiverMustBeValid \
    (transferModel) ->
      # debit the account
      
  # ...
```

If a `ChequingAccount` model is not in a valid state, an error will be thrown when you try to process a transfer against it before actually doing the transfer.

Preconditions can also do more than examine the state of the object implementing the method. A precondition is passed the method's arguments, so you can check them too:

```javascript
noBlankArguments = precondition(
  'null or undefined is not allowed as an argument',
  function () { 
    return _.all(arguments, function (arg) {
      return !(_.isNull(arg) || _.isUndefined(arg));
    });
  }
);
```

Preconditions can obviously be used in conjunction with error handling code to deal with exceptional but nevertheless expected cases. Another and equally intriguing possibility is to use preconditions as assertions: To check for cases that should *never* occur. In the above code, perhaps account models are always expected to be valid, and the precondition serves to identify when a programming error has put the code into an incorrect state.

Preconditions of that nature serve double duty: In development and staging, the help to find bugs. They also serve as executable documentation: Write as many as you can, programmers reading the code later will glean a wealth of information about what to expect.

`postcondition`
---------------

You've probably figured postcondition out. It looks like this:

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

A postcondition tests its condition function *after* the method returns a value. Because it's based on the after combinator, the condition is paramaterized by the *return value* rather than by the arguments (that's how `after` works). It's a great way to check that anything created or mutated meets specific conditions. For example, you can check that a model stays valid after executing a method:

```javascript
var receiverMustRemainValid = postcondition(
  'receiver invalidated by method',
  function () { return this.isValid(); }
);

var returnsElements = postcondition(
  function (value) { return _.isArray(value) && !_.isEmpty(value); }
); 

// ...

var Project = Backbone.Model.extend({

  validate: function (attrs) {
    // ...
  },
  
  set: receiverMustRemainValid(
    function () { return Backbone.Model.prototype.set.call(this, arguments); }
  ),
  
  unset: receiverMustRemainValid(
    function () { return Backbone.Model.prototype.unset.call(this, arguments); }
  ),
  
  contacts: returnsElements(
    function () {
      // ...
    }
  ),

  # ...

});
```

The possibilities are endless. And don't restrict them to models. In views, postconditions can assert that DOM elements are correctly positioned and populated. Postconditions are a great way of documenting what view methods are supposed to accomplish.

Summary
-------

Preconditions and postconditions are simple method combinators that implement error-checking for methods. Their use and implementation are simple because they "cut with the grain" of JavaScript's functional model. They can be used in either of two ways:

1. To implement expected error checking such as invalid user input, or;
2. To act as assertions documenting the program's expected behaviour under all circumstances.

Note
----

Compare and contrast our precondition to a [this ruby implementation][pr]. The Ruby implementation looks elegant to the OO-trained eye, but that's only because its `MethodDecorator` superclass is doing the heavy lifting. Have a look at  [method_decorators.rb][mds] for yourself! In my (anecdotal!) experience, this is often the way with OO languages like Ruby: You can make something appear very elegant at one level of abstraction, but if you peek behind the curtain at the abstraction's infrastructure, it's very messy and wild.

The Ruby program's author has done an outstanding job of working with Ruby's OO model, hooking methods that act like event listeners to detect when a method is added to a class and modifying it in place. Likewise, he maintains a list of decorators to be added to the next method, creating the illusion that you are writing declarative code. That's how it goes: Some languages present a very specific kind of API optimized for programming according to a specific model. When you come along to program to a different model, you end up greenspunning a new abstraction.

[pr]: https://github.com/michaelfairley/method_decorators/blob/master/lib/method_decorators/decorators/precondition.rb "precondition.rb"
[mds]: https://github.com/michaelfairley/method_decorators/blob/master/lib/method_decorators.rb "method_decorators.rb"