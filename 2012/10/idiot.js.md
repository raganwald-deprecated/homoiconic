# Somewhere, a JavaScript Village is Missing Its Idiot

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the "I Combinator" is charming in its simplicity:

```javascript
var I = function (x) { return x }
```

In his rightfully famous [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422), Raymond Smullyan nicknamed it "The Idiot Bird" for its singlemindedness.

`I` has some useful applications in JavaScript. Sometimes you have a function or method that takes an optional filter. You can use an "idiot" to clean things up:

```javascript
FiddleDeeDum.prototype.all = function (fn) {
  this.giants.map(fn || I)
}
```

Now you can call either `fiddleDeeDum.all()` or `filldeDeeDum( function (x) { return x.name })` or whatever. This is nicer than having an `if` test inside the method or fooling around with a method decorator of some kind.

Another interesting application falls out of the fact that JavaScript's evaluation strategy is "strict, left-to-right, and call-by-sharing with loose matching of arguments to parameters." That means that when you write something like:

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

Here's an example where we use the idiot to implement a simple `fluent interface`:

```javascript
Folderol.prototype.aFluentMethod = function (arg1, arg2) {
  return begin1( this,
      this.set({something: arg1, somethingElse: arg2})
  )
}
```

The moral of the story? *Every JavaScript village ought to have its own idiot*. If yours is missing, write yourself a new one.

p.s. It seems that [CoffeeScript villages have idiots too](https://github.com/raganwald/homoiconic/blob/master/2012/10/idiot.cs.md). And if you like this article about functions and combinators, you'll love my book [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto). You can check out a free sample PDF *and* there's a no-questions-asked money-back guarantee!

---

Recent work:

* "[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)