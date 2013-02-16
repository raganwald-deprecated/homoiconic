# Practical Applications of Partial Application

What is [partial application](http://en.wikipedia.org/wiki/Partial_application)? And most importantly, why do we care about it?

## Recap

First, a quick recap (You can skip this if you're familiar with functions in JavaScript). Just about everything here applies to CoffeeScript as well, except for some folderol about handling multiple arguments. And everything except `this` applies to just about any programming language that supports functions as first class objects.

The functions we're going to discuss look like this:

```javascript
function add (a, b) {
  return a + b;
}
```

Or this:

```javascript
var something = function (a, b) {
  return a + b;
};
```

### arity and higher-order functions

JavaScript functions take values as arguments and return values. A function that doesn't take arguments is *nullary*, a function taking one argument is *unary*, a function taking two or more arguments is *polyadic*, and a function that can take a variable number of arguments is *variadic*. JavaScript functions are values, so JavaScript functions can take functions as arguments, return functions, or both. Generally speaking, a function that either takes at least one function as an argument or returns a function (or both) is referred to as a "higher-order" function.

Here'a very simple higher-order function that takes a number and a function as arguments:

    function repeat (num, fn) {
      var i, value;
      
      for (i = 1; i <= num; ++i)
        value = fn(i);
      
      return value;
    }
    
    repeat(3, function () { 
      console.log('Hello') 
    })
      //=>
        'Hello'
        'Hello'
        'Hello'
        undefined
        
## Helper Function

For the purposes of this article, assume the presence of the helper function `variadic` (or `ellipsis`) that converts any variadic function into a unary function taking an array of parameters. It saves us the drudgery of slicing `arguments`:

```javascript
var __slice = Array.prototype.slice;

function ellipsis (fn) {
  if (fn.length < 1) return fn;

  return function () {
    var ordinaryArgs = (1 <= arguments.length ? 
          __slice.call(arguments, 0, fn.length - 1) : []),
        restOfTheArgsList = __slice.call(arguments, fn.length - 1),
        args = (fn.length <= arguments.length ?
          ordinaryArgs.concat([restOfTheArgsList]) : []);
    
    return fn.apply(this, args);
  }
};

var variadic = ellipsis;

function unary (first) {
  return first
}

unary('why', 'hello', 'there')
  //=> 'why'
  
variadic(unary)('why', 'hello', 'there')
  //=> [ 'why', 'hello', 'there' ]
  
function binary (first, rest) {
  return [first, rest]
}

binary('why', 'hello', 'there')
  //=> [ 'why', 'hello' ]

variadic(binary)('why', 'hello', 'there')
  //=> [ 'why', [ 'hello', 'there' ] ]
```

Variadic is a *function decorator*, it "decorates" a function with some additional functionality while remaining true to its underlying purpose.

[![Nixie Clock Case](http://farm5.staticflickr.com/4043/4259022251_43edf87308_z.jpg)](http://www.flickr.com/photos/randomskk/4259022251/)

## What is Partial Application?

Partial application is an operation that we can apply to polyadic (arity two or more) functions. Normally, function application is a single operation:

```javascript
function greet (me, you) {
  return "Hello, " + you + ", my name is " + me
}

greet('Helios', 'Eartha')
  //=> 'Hello, Eartha, my name is Helios'
```

Partial application allows us to break that single operation into two applications, one "here and right away," and one possibly elsewhere and possibly later. How do we do something elsewhere and possibly later in JavaScript? With a function, of course, and elaborate architectures are built around this idea using techniques such as Continuation-Passing Style (a/k/a Callbacks) and Promises.

But for our purposes, we understand partial application to be an operation that takes a polyadic function and applies some of the arguments and produces a function to be executed elsewhere and/or later. A fully generalized partial application operation permits us to apply one or more arguments in any position (possibly leaving holes to be filled), but let's consider the simplest of all possible partial applications: Given a polyadic function and a single value, it applies the value to the first argument and returns a function representing the rest of the application.

Let's do it by hand. Working backwards, we want a function that looks like this:

```javascript
var heliosGreets = function (you) {
  var me = 'Helios';
  
  return greet(me, you)
};

heliosGreets('Eartha')
  //=> 'Hello, Eartha, my name is Helios'
```

We can't have `'Helios'` hard-coded, so we'll hoist it out into an Immediately Invoked Function Expression:

```javascript
var heliosGreets = (function (me) {
  return function (you) {
    return greet(me, you)
  }
})('Helios');

heliosGreets('Eartha')
  //=> 'Hello, Eartha, my name is Helios'
```

Let's hoist the `greet` function too, and genericize the names a bit:

```javascript
var heliosGreets = (function (fn, first) {
  return function (second) {
    return fn(first, second);
  }
})(greet, 'Helios');

heliosGreets('Eartha')
  //=> 'Hello, Eartha, my name is Helios'
```

Now our inner function is a bit generalized. Some of the functions it may use might require the current context. Let's preserve it:

```javascript
var heliosGreets = (function (fn, first) {
  return function (second) {
    return fn.apply(this, [first, second]);
  }
})(greet, 'Helios');

heliosGreets('Eartha')
  //=> 'Hello, Eartha, my name is Helios'
```

And you know what else? Some functions we might apply have more than two arguments. Let's make the inner function variadic:

```javascript
var heliosGreets = (function (fn, first) {
  return variadic( function (args) {
    return fn.apply(this, [first].concat(args));
  })
})(greet, 'Helios');

heliosGreets('Eartha')
  //=> 'Hello, Eartha, my name is Helios'
```

There's only one thing left to do, extract our IIFE and give it a name:

```javascript
function applyFirst (fn, first) {
  return variadic( function (args) {
    return fn.apply(this, [first].concat(args))
  })
}

var heliosGreets = applyFirst(greet, 'Helios');

heliosGreets('Eartha')
  //=> 'Hello, Eartha, my name is Helios'
```

In essence, we have split one function (greet) into two pieces, one taking the first argument when we called `applyFirst(greet, 'Helios')`, and one taking  the rest, which we put in the variable `heliosGreets` and indeed when we called it with `'Eartha'`, we got back the completed application of the greet function.

To summarize, partial application splits the application of a function into two pieces, one of which we apply now with an argument, and one of which we can apply elsewhere and later with the remaining argument(s).

This "splitting into two" has another name in programming, it's called *decomposition*. Normally we decompose functions by extracting sub-functions manually, or perhaps with the assistance of a refactoring editor. Refactoring and decomposition are deeply related. Refactoring is the process of decomposing a program and then recombining the parts along different lines.

If we think of partial application as a kind of decomposition, something interesting emerges. We're decomposing along the lines of the arguments a function takes. This is often congruent to something in the domain, because different arguments tend to represent different things.

### applyleft

Before we go further, here is a more general version of `applyFirst` that takes a variable number of arguments. `applyFirst` is simpler and executes faster when you only need one argument, but `applyLeft` allows you to partially apply any number of arguments.

```javascript
var applyLeft = variadic( function (fnAndLeftArguments) {
  var fn = fnAndLeftArguments[0],
      leftArguments = fnAndLeftArguments.slice(1);
      
  return variadic( function (rightArguments) {
    return fn.apply(this, leftArguments.concat(rightArguments))
  })
});
```

JavaScript's `.bind` function looks a lot like `applyLeft`, however `.bind` forces you to bind the context, `applyLeft` allows you to skip binding the context. It's useful when writing combinators and other higher-order functions. Again, these are function that could very well live in a library, it's how to use them that matters.

[![Switchboard](http://i.minus.com/ibxLN2qmaDYNnz.jpg)](http://www.flickr.com/photos/nix-pix/2529018779/)

## Binding is Partial Application

Lots of libraries include a `map` function. Modern JavaScript includes a map method for arrays, but that obviously won't work with array-like data structures (`arguments` and so forth). Typically, they look like this:

```javascript
var results = map(array, function (element) {
  // ...
}, this);
```

Note the third parameter (`this`) that specifies the context for the function applications. If you don't supply it, the function being applied to each element cannot access anything in the current context. This is especially important if we're using a map inside of a method. Depending on how `map` is written, the context will be the global context, `null`, or even some array (yecch!).

Before we go any further, let's get rid of `this`. We can bind our function to `this` so that it always evaluates in the current context:

```javascript
var results = map(array, function (element) {
  // ...
}.bind(this));
```

Now it doesn't matter how `map` deals with not supplying a context. Hey, this seems vaguely familiar. This is a function to be evaluated when given a context and an element: `function (element) { ... }`. And this applies  the context now and waits for the element later: `function (element) { ... }.bind(this)`.

Binding the context is a JavaScript-specific form of partial application. It's very useful. And all we have to do with the rest of partial application is open our mind to other possibilities.

[![Phone-wire tangle](http://farm4.staticflickr.com/3175/2570338478_8efc990bba_z.jpg)](http://www.flickr.com/photos/doctorow/2570338478/)

## Partial Application Of Mapping

Mapping (and folding/reducing) is extremely common. After fooling around with `for` loops for years, a programmer can be forgiven for being extremely satisfied by writing maps whenever he wants to do something to a collection. But further abstraction is not only possible, but preferable.

Before we illustrate that, let's introduce another partial application function in both single and general form:

```javascript
function applyLast (fn, last) {
  return variadic( function (args) {
    return fn.apply(this, args.concat([last]))
  })
}

var applyRight = variadic( function (fnAndRightArguments) {
  var fn = fnAndRightArguments[0],
      rightArguments = fnAndRightArguments.slice(1);
      
  return variadic( function (leftArguments) {
    return fn.apply(this, leftArguments.concat(rightArguments))
  })
});
```

Now we can do something interesting. Let's say we have a collection of reference objects representing something in a cache. We are doing some reference counting so we can do cache eviction. Incrementing a reference and decrementing a reference are rather obvious: `ref.incrementReferenceCount()` and `ref.decrementReferenceCount()`. Each `ref` contains a list of dependents `this.dependentRefs()`. Here's our implementation of `decrementReferenceCount`:

```javascript
Reference.prototype.decrementReferenceCount = function () {
  --this.referenceCount;
  if (referenceCount === 0)
    this.decrementDependentCounts();
};

Reference.prototype.decrementDependentCounts = function () {
  map(this.dependentRefs(), function (dependent) {
    dependent.decrementReferenceCount();
  });
};
```

We use our `applyLast` function on `map`:

```javascript
Reference.decrementCounts = applyLast(map, function (ref) {
  ref.decrementReferenceCount();
});
```

Now we have a so-called class method that can decrement the counts of any list. Let's use it to refactor things:

```javascript
Reference.prototype.decrementReferenceCount = function () {
  --this.referenceCount;
  if (referenceCount === 0)
    Reference.decrementCounts(this.dependentRefs());
};
```

We still have two functions, but one of them is now a general decrementer that can be used elsewhere. Is this important? Possibly! Is it handy? Very much so when DRYing up code. And you can use this technique with filter/select, with reduce, and anything else working over collections.

[![Innards of telephone at the station on the Gwili Railway](http://farm7.staticflickr.com/6136/5990961019_892e10aa2d_z.jpg)](http://www.flickr.com/photos/nox_noctis_silentium/5990961019/)

## Another Partial Application with Binding Semantics

Languages that don't do anything special with `this` are quite happy with a few forms of partial application. JavaScript needs a few more in very large part because of the importance of managing `this` when working with objects. This function, `send`, is useful for mapping over objects by sending them a message. It emulates Ruby's `Symbol#to_proc` with some extra partial application goodness. For our purposes, the implementation is:

```javascript
var send = variadic( function (nameAndArgs) {
  var methodName = nameAndArgs[0],
      leftArguments = nameAndArgs.slice(1);
  
  return variadic( function (receiverAndArgs) {
    var receiver = receiverAndArgs[0],
        rightArguments = receiverAndArgs.slice(1);
    return receiver[methodName].apply(receiver, leftArguments.concat(rightArguments))
  })
})
```

We use `send` like this. Instead of:

```javascript
Reference.decrementCounts = applyLast(map, function (ref) {
  ref.decrementReferenceCount();
});
```

We write:

```javascript
Reference.decrementCounts = applyLast(map, send('decrementReferenceCount'));
```

And people complain JavaScript is verbose. *JavaScript is not verbose, attempting to write Java code in JavaScript is verbose*. JavaScript is a functional language. When you use functional programming idioms in JavaScript, you are "cutting with the grain."

Speaking of which... When you're holding the partial application hammer, every piece of code begins to look like a function to be decomposed nail. The third time you write `applyLast(map, ...)`, you ought to ask yourself, "Can I extract this?"

Yes you can:

```javascript
var splat = applyFirst(applyLast, map);

var squareAll = splat(function (n) { return n * n });

squareAll([1, 2, 3, 4, 5])
  //=> [1, 4, 9, 16, 25]
```

Which leads us to:

```javascript
Reference.decrementCounts = splat(send('decrementReferenceCount'));
```

![What are the applications?](http://i.minus.com/ibweUTQ6MzlKIm.png)

## Conclusion

**Partial application is what allows us to abstract away a lot of function scaffolding, in large part because it's a compact way to decompose functions**.

(discuss on [lobste.rs](https://lobste.rs/s/u2oed1/practical_applications_of_partial_application), [/r/programming](http://www.reddit.com/r/programming/comments/160mtu/practical_applications_of_partial_application_js/) or  [/r/javascript](http://www.reddit.com/r/javascript/comments/160ls5/practical_applications_of_partial_application/))

Notes:

* `variadic`/`ellipsis`, `applyFirst` and `applyLast` are just a few of the utility functions in the [allong.es](http://allong.es) library.
* `applyFirst` and `applyLast` were inspired by Michael Fogus' [Lemonad](https://github.com/fogus/lemonad). Thanks!
* The ideas in this post are shamelessly extracted from my book [JavaScript Allongé](http://leanpub.com/javascript-allonge). Yes I am pimping it out! Please consider downloading the free sample PDF. It comes with a no questions asked, 100% money-back guarantee.

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)][ja]![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)][cr]![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé][ja], [CoffeeScript Ristretto][ja], and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code. 

[ja]: http://leanpub.com/javascript-allonge "JavaScript Allongé"
[cr]: http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto"

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)
