The Madness of King JavaScript
==============================

From time to time, people notice something is very wrong with functional-style programming in JavaScript. For example:

```javascript
['1', '2', '3'].map(parseFloat);
  //=> [1, 2, 3]
  
// HOWEVER:

['1', '2', '3'].map(parseInt);
  //=> [ 1, NaN, NaN ]
```

Shouts of "William-Thomas-Fredrick" ensue. The strange behaviour of `.map(parseInt)` is caused by the interaction of one language choice and two library choices. When all three come together, you get an unexpected result:

1. The language feature is that JavaScript does not enforce function arity. So you can define a function with three arguments but pass one parameter. Or pass five parameters to a function that only expects one.
2. `.map` is designed such that it passes *three* parameters to the mapper function. The first is the element, the second is the index of the element, and the third is the context (the array, in this case).
3. `.parseInt` works just fine with one parameter, but [you can also pass an additional parameter to define the radix](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/parseInt).

So what happens here? Well, the `.map` method is passing in a string and a number on each call, and `parseInt` is interpreting that number as a radix. Boom.

Okay. So?

Well, reasonable people can take either or both of the following two positions:

1. You need to know your language and libraries. If you don't, you're at fault.
2. Libraries should be designed to avoid suprises. `.map` being so "helpful" with the extra parameters is not helpful and contrary to practice elsewhere. This is a design problem, not a programmer problem. (There should be a `.map` and a `.mapWithIndex` in the library, not one function trying to do too many jobs)

There's plenty of opportunity to debate those positions, but if you have chosen to use JavaScript because "On the whole it's a good thing for a particular project," here are two different things you can do to avoid surprising yourself or colleagues who haven't read this blog post.

### first, use a safer mapping construct

There's nothing wrong with rolling your own mapper. I'm a big fan of combinators, so I use `.splat` from the [allong.es] library. Splat looks something like this:

```javascript
function splat (fn) {
  fn = functionalize(fn);
  return function (list) {
    return __map.call(list, function (something) { return fn(something) });
  };
};
```

And we use it like this:

```javascript
splat = require('allong.es').splat;

splat(parseInt)(['1', '2', '3']);
  //=> [1, 2, 3]
```

Splat looks a little different than map because instead of operating directly on an array, it turns a function expecting one argument into a "splatter" expecting an array. And of course, there's a `splatWithIndex` if that's what you need, although your should probably just use `.map` for that.

> WHy the crazy idea of using a splatter instead of a mapping method or function? This is a bit of a digression, but when you have a  function that takes a single argument, you can combine it with almost any other function that takes one argument, like `fluent` or `maybe` from the [allong.es] library, or perhaps `debounce` from the Underscore library.

### second, use a safer function

The [allong.es] library includes a very handy "variadic" function for turning a function that takes one argument into a function that takes more than one argument. It also includes `unary` for turning a function that takes more than one argument into a function that takes one argument, it looks like this:

```javascript
function unary (fn) {
  fn = functionalize(fn);

	if (fn.length == 1) {
		return fn;
	}
	else return function (something) {
		return fn.call(this, something);
	};
} 
```

We use it like this:

```javascript
unary = require('allong.es').unary;

['1', '2', '3'].map(unary(parseInt));
  //=> [ 1, 2, 3 ]
```

[allong.es] also includes the `applyLast` function for partial application. It takes any function and lets you bind a value to the last parameter it expects. We can use this with functions like `parseInt` like so:

```javascript
applyRight = require('allong.es').applyRight;

['1', '2', '3'].map(applyRight(parseInt, 10));
  //=> [ 1, 2, 3 ]
```

This works because we've bound `10` to the radix parameter, so the additional parameters that `map` supplies are ignored.

JavaScript can have some surprises for us, but it has an inherent functional flexibility that allows us to make our own sandpaper to smooth out its knots and whorls.

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


[allong.es]: http://allong.es