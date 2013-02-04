# The End of Days: Implementing a CoffeeScript Feature in Pure JavaScript

*This kind of thing normally wouldn't merit a full blog post all by itself, but just in case today really is the end of the world, I'm taking no chances and sharing the idea while I can.*

The CoffeeScript programming language has a useful feature: If a parameter of a method is written with trailing ellipsis, it collects a list of parameters into an array. It can be used in various ways, and the CoffeeScript transpiler does some pattern matching to sort things out, but 80% of the use is to collect a variable number of arguments without using the `arguments` pseudo-variable, and 19% of the uses are to collect a trailing list of arguments.

Here's what it looks like collecting a variable number of arguments and trailing arguments:

```coffeescript
leftPartial = (fn, args...) ->
  (remainingArgs...) ->
    fn.apply(this, args.concat(remainingArgs))
```

Which translates to:

```javascript
var leftPartial,
  __slice = [].slice;

leftPartial = function() {
  var args, fn;
  fn = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  return function() {
    var remainingArgs;
    remainingArgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return fn.apply(this, args.concat(remainingArgs));
  };
};
```

These are very handy features. Here's our bogus, made-up attempt to write our own mapper function:

```coffeescript
mapper = (fn, elements...) ->
  elements.map(fn)

mapper ((x) -> x*x), 1, 2, 3
  #=> [1, 4, 9]

squarer = leftPartial mapper, (x) -> x*x

squarer 1, 2, 3
  #=> [1, 4, 9]
```

It's true we can always manipulate the `arguments` thingummy variable by hand every time we want to collect a variable number of arguments into an array, but what if we don't want to constantly inject boilerplate noise into what ought to be simple functions? What if we are concerned that we'll end up making some fencepost error at four in the morning when fixing a critical bug?

It's good to have tools do this for us. So, should we switch to CoffeeScript?

### hell freezes over

It must be the end of days. Or Hell has frozen over, because although I like CoffeeScript and have even written a [book](http://leanpub.com/coffeescript-ristretto) about it, I am not going to say, "switch to CoffeeScript." Nor am I going to say, "Nonsense, `args = 2 <= arguments.length ? __slice.call(arguments, 1) : []` is perfectly readable, kids get off my lawn."

What I say is, let's use JavaScript to implement this feature for us.

Here's how we want to write our functions in JavaScript so that they're a lot more like CoffeeScript:

```javascript
var leftPartial = function (fn, args...) {
  return function (remainingArgs...) {
    return fn.apply(this, args.concat(remainingArgs));
  };
};
```

The missing piece is that JavaScript doesn't support [ellipses](http://en.wikipedia.org/wiki/Ellipsis), those trailing periods CoffeeScript uses to collect arguments into an array. JavaScript is a *functional* language, so let's write a function that collects trailing arguments into an array for us:

```javascript
var __slice = [].slice;  
  
function ellipsis (fn) {
  if (fn.length < 1) return fn;
  
  return function () {
    var args = 1 <= arguments.length ? __slice.call(arguments, 0, fn.length - 1) : [];
    
    args.push(fn.length <= arguments.length ? __slice.call(arguments, fn.length - 1) : []);
    return fn.apply(this, args);
  }
}
```

(This is an extremely simple version. For a more robust implementation, see the [Oscines](http://allong.es) library.)

And now, we have a function that adds an ellipsis to a function. Here's what we write:

```javascript
var leftPartial = ellipsis( function (fn, args) {
  return ellipsis( function (remainingArgs) {
    return fn.apply(this, args.concat(remainingArgs))
  })
})

// Let's try it!

var mapper = ellipsis( function (fn, elements) {
  return elements.map(fn)
});

mapper(function (x) { return x * x }, 1, 2, 3)
  //=> [1, 4, 9]

var squarer = leftPartial(mapper, function (x) { return x * x });

squarer(1, 2, 3)
  //=> [1, 4, 9]
```

Works like a charm! So what have we seen?

1. CoffeeScript has a nice feature.
2. That nice feature can be emulated in JavaScript using JavaScript's existing strength: Programming with first-class functions.
3. When people suggest that you have to choose between JavaScript an expressive code, they are offering a false dichotomy.
4. If today isn't the end of the world, it may instead be the day hell froze over.

Fine print: Of course, `ellipsis` introduces an extra function call and may not be the best choice in a highly performance-critical piece of code. Then again, using `arguments` is considerably slower than directly accessing argument bindings, so if the performance is that critical, maybe you shouldn't be using a variable number of arguments in that section.

You be the judge.

p.s. "Ellipses" and "leftPartial" can be found in the book [JavaScript Allongé](http://leanpub.com/javascript-allonge), a book focused on working with functions in JavaScript, including combinators, constructors, methods, and decorators. You can download a [free sample PDF](http://samples.leanpub.com/javascript-allonge-sample.pdf).

[Feedback welcome](mailto:reg@braythwayt.com). Discuss on [hacker news](http://news.ycombinator.com/item?id=4948606) or [reddit](http://www.reddit.com/r/javascript/comments/1568w0/the_end_of_days_implementing_a_coffeescript/).

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

[andand]: https://github.com/raganwald/andand
[maybe]: https://en.wikipedia.org/wiki/Monad_(functional_programming)#The_Maybe_monad

[Part I]: https://github.com/raganwald/homoiconic/blob/master/2012/12/combinators_1.md

[Underscore]: http://underscorejs.org