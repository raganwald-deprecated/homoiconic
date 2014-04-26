Memoized, the *practical* method decorator
=========================================

> In computing, [memoization] is an optimization technique used primarily to speed up computer programs by having function calls avoid repeating the calculation of results for previously processed inputs.

[memoization]: https://en.wikipedia.org/wiki/Memoization

In other words, if you calculate something, save the result. The next time you need to perform the same calculation, you just look it up. This applies to any algorithm, and many time we can use it with methods on an object.

Let's start with a naive fibonacci algorithm in CoffeeScript:

```coffeescript
fibonacci = (n) ->
  if n < 2
    n
  else
    fibonacci(n-2) + fibonacci(n-1)
```

Since this is a post about method decorators, we'll gratuitously rewrite this function into an object with a helper method:

```coffeescript
class Fibonacci

  constructor: (@n) ->
  
  toInt: ->
    @fibonacci(@n)
  
  fibonacci:
    (n) ->
      if n < 2
        n
      else
        @fibonacci(n-2) + @fibonacci(n-1)
```
    
And we'll time it:
      
```bash
coffee> s = (new Date()).getTime(); new Fibonacci(45).toInt(); ( (new Date()).getTime() - s ) / 1000
28.565
```

Yecch! There are other, faster and [more interesting][matrix] algorithms, of course. But this one is good precisely because it is almost maximally pessimum: Computing `fibonacci(n - 2)` is going to require computing `fibonacci(n - 3)`. Having done this, it computes `fibonacci(n - 1)`. But of course, computing `fibonacci(n - 1)` is going to require computing `fibonacci(n - 2)` and `fibonacci(n - 3)`, ignoring the work it has already done!

[matrix]: https://github.com/raganwald/homoiconic/blob/master/2008-12-12/fibonacci.md "A program to compute the nth Fibonacci number"

We can easily rewrite the algorithm in another form that doesn't do the same work twice, but let's stick with it and see what we get from memoization. 

Introducing `memoized`, our method decorator
--------------------------------------------

Time to write a memoization decorator! If you aren't familiar with method decorators, [Method Combinators in CoffeeScript][mcc] explains that a method decorator is a function that adds functionality to a method. We're going to write one that memoizes the result of our fibonacci helper, this time in JavaScript:

[mcc]: https://github.com/raganwald/homoiconic/blob/master/2012/08/method-decorators-and-combinators-in-coffeescript.md#method-combinators-in-coffeescript

```javascript
memoized = function(methodBody) {
  var memos;
  memos = {};
  return function() {
    var key;
    key = JSON.stringify(arguments);
    if (memos.hasOwnProperty(key)) { 
      return memos[key];
    } else {
      return memos[key] = methodBody.apply(this, arguments);
    }
  };
};
```

Our decorator is a little limited: It can only handle methods that take zero or more arguments, each of which must be amenable to `JSON.stringify`. It works perfectly for our example, but you can build something more robust if you need more flexibility.

Let's redo our class to use it:

```javascript
FastFibonacci = (function() {

  function FastFibonacci(n) {
    this.n = n;
  }

  FastFibonacci.prototype.toInt = function() {
    return this.fibonacci(this.n);
  };

  FastFibonacci.prototype.fibonacci = memoized(
    function(n) {
      if (n < 2) {
        return n;
      } else {
        return this.fibonacci(n - 2) + this.fibonacci(n - 1);
      }
    }
  );

  return FastFibonacci;

})();
```
    
And we'll time it again:
      
```bash
js> s = (new Date()).getTime(); new FastFibonacci(45).toInt(); ( (new Date()).getTime() - s ) / 1000
0.001
```

That makes quite the difference! Memoization isn't limited to mathematical computations or recursive algorithms. If you are careful about preserving [idempotence], memoization can be used to save superfluous database lookups, AJAX calls and almost anything else that takes time to resolve.

[idempotence]: https://en.wikipedia.org/wiki/Idempotence

What does a decorator get us?
-----------------------------

The `memoized` decorator is quite handy. We can memoize any method we like with a single label. We don't have to write something like this CoffeeScript snippet:

```coffeescript
  fibonacci:
    do ->
      memos = {}
      (n) ->
        memos[n] ?= if n < 2
                      n
                    else
                      @fibonacci(n-2) + @fibonacci(n-1)
```

This tangles the memoize implementation with the base logic of the fibonacci function, and it isn't reusable. And of course, it composes with other decorators we might use without tangling even more concerns and responsibilities in our code.

Sounds good, but `memoized` seems familiar...
--------------------------------------------

Indeed it does. Jeremy Ashkenas' Underscore.js library has a [memoize] function that does this exact thing for any arbitrary function. It can also be used for methods.

[memoize]: http://underscorejs.org/#memoize

What's that? Methods are functions, so anything that works with a function must *necessarily* work with a method? Not exactly. Anything that works with a function also works with a method that never refers to JavaScript's `this` pseudo-variable. And that's the case with our `fibonacci` helper method above. But once you start referring to `this`, method decorators will break your methods unless they preserve the correct receiver object. That's why our `memoized` decorator invokes `.apply(this, arguments)`, to preserve the correct receiver. Perusing the source code for Underscore 1.3.1, we see that `memoize` preserves `this` and can be used as a method decorator:

```javascript
_.memoize = function(func, hasher) {
    var memo = {};
    hasher || (hasher = _.identity);
    return function() {
      var key = hasher.apply(this, arguments);
      return _.has(memo, key) ? memo[key] : (memo[key] = func.apply(this, arguments));
    };
  };
```

Underscore provides other useful functions that act as method decorators. Both `memoize` and `once` can be used directly as decorators:

[once]: http://underscorejs.org/#once

```javascript
UnderscoreEg = (function() {

  function UnderscoreEg() {}

  UnderscoreEg.prototype.initialize = _.once(
    function() {
      // Initialization that must not be performed
      // more than once
    }
  );

  return UnderscoreEg;

})();
```

`throttle` and `debounce` have additional parameters you can handle with a little partial evaluation. Here's `throttled` in CoffeeScript:

[throttle]: http://underscorejs.org/#throttle
[debounce]: http://underscorejs.org/#debounce

```coffeescript
throttled = 
  (milliseconds) ->
    (methodBody) ->
      _.throttle(methodBody, milliseconds)
    
class AnotherUnderscoreEg

  sayWhat:
    throttled(10000) \
    ->
      alert('What!?')
```

Summary
-------

`memoized` is a practical method decorator you can use right away. If you use Underscore.js in your projects, you can use its `_.memoize` and `_.once` directly as decorators. You can also make method decorators out of `_.throttle` and `_.debounce` with partial evaluation.

More Reading
---

* [npm install method-combinators](https://github.com/raganwald/method-combinators)
* [Using Method Decorators to Decouple Code](https://github.com/raganwald/homoiconic/blob/master/2012/08/decoupling_with_method_decorators.md#using-method-decorators-to-decouple-code)
* [Understanding Python Decorators](http://stackoverflow.com/questions/739654/understanding-python-decorators) on StackOverflow
* [Introduction to Python Decorators](http://www.artima.com/weblogs/viewpost.jsp?thread=240808) by Bruce Eckel
* [Aspect-Oriented programming using Combinator Birds](https://github.com/raganwald/homoiconic/blob/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#aspect-oriented-programming-in-ruby-using-combinator-birds)

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