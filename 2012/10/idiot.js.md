# Somewhere, a JavaScript Village is Missing Its Idiot

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the "I Combinator" is charming in its simplicity:

```javascript
var I = function (x) { return x }
```

In his rightfully famous [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422), Raymond Smullyan nicknamed it "The Idiot Bird" for its singlemindedness.

`I`--so named because mathematicians (and many programmers) call it the [Identity Function](https://en.wikipedia.org/wiki/Identity_function)--has some useful applications in JavaScript. Sometimes you have a function or method that takes an optional mapping function, like this:

```javascript
TheyMightBeGiants.prototype.all = function (fn) {
  if (fn) {
    return this.giantCollection.map(fn)
  }
  else {
    this.giantCollection
  }
}
```

Given:

```javascript
var band = new TheyMightBeGiants(...)
```

You can call either `band.all()` or to get all the band members or `band( (x) -> x.name )` to get their names. An "idiot" will clean things up and get rid of the `if`:

```javascript
TheyMightBeGiants.prototype.all = function (fn) {
  return this.giantCollection.map(fn || I)
}
```

Idiots can be used as default arguments in many different places. Another interesting application falls out of the fact that JavaScript's evaluation strategy is "strict, left-to-right, and call-by-sharing with loose matching of arguments to parameters." That means that when you write something like:

```javascript
foo( expr1, expr2, expr3, expr4 )
```
    
`expr1` is evaluated first, then `expr2`, then `expr3`, then `expr4`. Always. Then the arguments are stuffed into the `arguments` pseudo-variable whether they match declared parameters or not. What this means is that we can write something like this:

```javascript
var begin = function () { return arguments[arguments.length - 1] }
```
    
Now, you can write:

```javascript
var x = 5
begin(
  x = 5,
  x = x + 1,
  x * 2
)
  //=> 12
```

This is just the same as if you used `begin... end` in Ruby, or the `begin` macro in Scheme. `begin` creates a block of expressions to be evaluated, and returns the last one, but deliberately doesn't create a new scope.

Hopefully you never write `begin` like this in JavaScript, because there is a simpler way to accomplish the same result:

```javascript
( expr1, expr2, expr3, expr4 )
```
  
Same thing. So why do we care about `begin`? Only an idiot would write that! Well, consider this variation:

```javascript
var begin1 = function () { return arguments[0] }
```
    
That executes a series of statements and returns the value of *the first one*. And yes, Scheme does have a [begin1](http://patricklogan.blogspot.ca/2005/08/when-to-create-syntax-in-lisp.html) macro (old Lisps called it `PROG1`).

Again, there's a simpler way to write `begin1` in JavaScript:

```javascript
begin1 = function (value) { return value }
```

It's our "idiot" again! Can we use it like `begin`? yes! Compare it to Underscore's  `_.tap(value, fn)`:

```javascript
    _.tap(expr1, function (value) {
      expr2;
      expr3;
      // ... 
    })
```

`_.tap` lets you use a function that takes the value of `expr1` as a parameter. That might be what you want, in which case use `_.tap`. But if you don't need it, `begin1( ..., ..., ... )` evaluates everything in the scope of the enclosing function. So you can return from the enclosing function or otherwise behave as if you were using `( ..., ..., ... )`.

Here's an example where we use the idiot to implement a simple [fluent interface](https://en.wikipedia.org/wiki/Fluent_interface):

```javascript
Folderol.prototype.aFluentMethod = function (arg1, arg2) {
  return begin1( this,
    doSomethingImportant(),
    this.set({something: arg1, somethingElse: arg2}),
    doSomethingElse(arg1),
    finishWithThis(arg2)
  )
}
```

Why might you need this idiom? There are two answers. The first is that identifying that a function returns `this` but is being executed for side effects is nice to have at the top of the function rather than the bottom. And you won't forget to include `return this` and accidentally return `undefined`. 

Other times, you want to do something after calculating a return value, and you end up with some awkward code and an extra variable:

```javascript
Folderol.prototype.aFluentMethod = function (arg1, arg2) {
  var value = ...some calculation...
  // do something
  // and something
  // and something else
  return value;
}
```

`begin1` can make that go away as well. If you're using underscore, use `_.tap`, it's an idiot in upscale clothes. But if not, `I` or `begin1` is an easy one-liner you can pull out.

The moral of the story? *Every JavaScript village ought to have its own idiot*. If yours is missing, write yourself a new one. The I Combinator isn't exactly a go-to function in the toolbox, but one to keep in mind for the odd time it can make things a little simpler.

(discuss on [/r/javascript](http://www.reddit.com/r/javascript/comments/12eq0n/somewhere_a_javascript_village_is_missing_its/))

p.s. It seems that [CoffeeScript villages have idiots too](https://github.com/raganwald/homoiconic/blob/master/2012/10/idiot.cs.md). And if you like this article about functions and combinators, you'll love my book [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto). You can check out a free sample PDF *and* there's a no-questions-asked money-back guarantee!

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