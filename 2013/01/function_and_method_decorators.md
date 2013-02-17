# Function and Method Decorators

(a/k/a **"More than you ever wanted to know about "this" in JavaScript, Part II"**)

*This is the second of two excerpts from the book [JavaScript Allongé][ja] on the common theme of "this," also known as "function context." The posts are intended to stand alone: There's no need to read the entire book to benefit from reading this material. [Part I is here][I], along with discussion [here][proggit_i].*

[ja]: http://leanpub.com/javascript-allonge
[I]: https://github.com/raganwald/homoiconic/blob/master/2013/01/this.md#more-than-you-ever-wanted-to-know-about-this-in-javascript-part-i "More than you ever wanted to know about "this" in JavaScript, Part I"
[proggit_i]: http://www.reddit.com/r/javascript/comments/179j51/more_than_you_ever_wanted_to_know_about_this_in/
[allong.es]: http://allong.es
[u]:http://underscorejs.org

---

In [Part I][I], we compared and contrasted two versions of function composition. The first version is more-or-less a direct port of `compose` in functional languages that don't have any notion of a context:

```javascript
function compose (fn1, fn2) {
  return function compose_ (something) {
    return fn1(fn2(something));
  }
}

function add1 (n) { return n + 1 };

function times3 (n) { return n * 3 };

var collatz = compose(add1, times3);

collatz(5);
  //=> 16
```

It simply calls functions. It works with functions that don't have a context or are bound to a specific context. It doesn't work if you're trying to pass a context. That happens when you're calling methods, so this version of `compose` doesn't work with functions that are used as method implementations.

Here's one that does work. It uses `.call` to carefully pass the current context along:

```javascript
function compose (fn1, fn2) {
  return function compose_ (something) {
    return fn1.call(this, fn2.call(this, something));
  }
}
```

The second version of compose is *context-agnostic*. It doesn't interfere with the context by erasing it or injecting a context. In this second part, we're going to take a short look at the concept and its relation to the *Function Decorator Pattern*.

### the function decorator pattern

A "function decorator" is a function that consumes a function and returns a decorated version of the function it consumes. For example, the [Underscore][u] and [allong.es] libraries both include the "once" function decorator. Here's a function you might want to call:

```javascript
function preloadLotsOfStuff () {
  // ...
};
```

What if you only want to execute it once but you might want to call it from multiple points in the code? You can do something like this:

```javascript
var hasntRun = true;

function preloadLotsOfStuff () {
  if (hasntRun) {
    hasntRun = false;
    // ...
  }
};
```

Now we're cluttering up the code with two orthogonal concerns:

1. How to preload lost of stuff;
2. How to ensure you only do that once.

The better way forward is with a function decorator, like this:

```javascript
var _ = require('underscore');

var preloadLotsOfStuff = _.once( function () {
  // ...
});
```

As you can see from the [source code](http://underscorejs.org/docs/underscore.html), `once` is simple:

```javascript
_.once = function(func) {
  var ran = false, memo;
  return function() {
    if (ran) return memo;
    ran = true;
    memo = func.apply(this, arguments);
    func = null;
    return memo;
  };
};
```
Notice that `_.once` takes a function as an argument, and returns a new function wrapping the original with the "decoration" behaviour. We call `_.once` the function decorator, and the anonymous wrapper function the *decoration*.

That's the function decorator pattern in a nutshell. You have three pieces: a function decorator that wraps your function with a decoration function. This separates concerns and makes reusing the decoration behaviour trivial.

### writing our own decorators

We can write our own function decorators very easily. Let's take an extremely simple example: logging the result of a function. Instead of:

```javascript
function numberOfLoginAttempts (user) {
  var attempts;
  //...
  console.log(attempts);
  return attempts;
};
```

We want a decorator that does the logging for us. Like this:

```javascript
function logsItsResult (fn) {
  return function () {
    var result = fn.apply(this, arguments);
    console.log(result);
    return result;
  }
};
```

Now, whenever we wish to log the result of a function, we write:

```javascript
var numberOfLoginAttempts = logsItsResult( function (user) {
  var attempts;
  //...
  return attempts;
});
```

This post is ostensibly about "this." Well, what are the functions that care the most about "this?" Methods! Can we use our decorator on a method? Yes. Instead of:

```javascript
function User (name, passwordHash, salt) {
  if (!(this instanceof User)) {
    return new User(name, passwordHash, salt);
  }
  this.name = name;
  this.passwordHash = passwordHash;
  this.salt = salt;
};

User.prototype.isAnAdministrator = function () {
  var hasAdminPrivs;
  //...
  console.log(hasAdminPrivs);
  return hasAdminPrivs;
};
```

We can use our decorator on the method's function just as we used it on a "global" function:

```javascript
User.prototype.isAnAdministrator = logsItsResult( function () {
  var hasAdminPrivs;
  //...
  return hasAdminPrivs;
});
```

The key is to always write function decorators so that they are context agnostic: They need to call the decorated function with `.call` or `.apply`, passing the current context.

### what we get from using the function decorator pattern:

Although we're working with one-liners to keep things compact, here's what we get:

1. We *untangle* concerns central to a method (like whether a user is an administrator) from cross-cutting concerns (like what we want to log).
2. We extract the cross-cutting functionality into a function. We can use that to DRY up functions and methods *scattered* across our code.

(I've emphasized the words "tangled" and "scattered" because a big part of good coding comes down to reducing tangling and scattering.)

### why being context-agnostic matters

Writing context-agnostic function decorators makes them work equally well with ordinary functions and with methods. As a rule-of-thumb, if you don't have a good reason not to be context-agnostic, you should write all higher-order functions in a context-agnostic fashion.

Thanks for being patient enough to read the whole thing!

([discuss](http://www.reddit.com/r/javascript/comments/17pqjh/function_and_method_decorators/))

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

