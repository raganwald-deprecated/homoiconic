## Weak Binding in JavaScript

Imagine we wished to write our own `bind` function that emulated `Function.prototype.bind` (When we say "bind" and "re-bind," we mean, "create new functions that act like the old function, but with a  particular context bound to it." None of the techniques discussed here actually mutate functions.):

```javascript
function bind (fn, context) {
  return function () {
    return fn.apply(context, arguments)
  }
}

function myName () { return this.name }

var harpo   = { name: 'Harpo' },
    chico   = { name: 'Chico' },
    groucho = { name: 'Groucho' };
    
var fh = bind(myName, harpo);
fh()
  //=> 'Harpo'

var fc = bind(myName, chico);
fc()
  //=> 'Chico'
```

This looks great. But what happens if we **re**-bind a bound function, either with `bind` or `.call`?

```javascript
    var fhg = bind(fh, groucho);
    fhg()
      //=> 'Harpo'
      
    fc.call(groucho)
      //=> 'Chico'
      
    fh.apply(groucho, [])
      //=> 'Harpo'
```
      
Bzzt! You cannot bind a context to a function that has already been bound. Well, you can, but our 'bound' function is just a wrapper around the original function, and binding the wrapper doesn't change its behaviour. In essence, a bound function cannot be re-bound.

Now, this implementation could be fixed. But if you try to do the same experiment with `Function.prototype.bind`, you discover it behaves the exact same way! So if we "fix" our `bind` function to allow rebinding, we're breaking he implied contract of behaving like `Function.prototype.bind`.

That's a bad idea, we'd be creating a [walled garden] where all of our code would have to work one way--where functions could be rebound--while anyone else writing code with us might expect it to work another way.

### the recipe

If we want to create a way to bind and rebind functions, we can use a new set of semantics that are sufficiently different from `bind` that we won't confuse the two:

```javascript
function weaklyBind (fn, context) {
  var thisContext = this;

  return function () {
    if (this === thisContext) {
      return fn.apply(context, arguments)
    }
    else return fn.apply(this, arguments)
  }
}
```
   
`weaklyBind` only binds its argument if it's evaluated in the same context where `weaklyBind` was evaluated. That's usually the global or window context. If you strongly or weakly bind the function it returns, you override its context. Thus, a weakly bound function can be "rebound."

```javascript
var fh = weaklyBind(myName, harpo);
fh()
  //=> 'Harpo'

var fc = weaklyBind(myName, chico);
fc()
  //=> 'Chico'

var fhg = weaklyBind(fh, groucho);
fhg()
  //=> 'Groucho'
  
fc.call(groucho)
  //=> 'Groucho'
  
fh.apply(groucho, [])
  //=> 'Groucho'
```
      
### applications

In many cases, a strongly bound function is just fine. For example, when we want to use a method on an object as a callback, a strongly bound function is exactly what we want: We want a function that acts like a method on a particular object, period, full-stop. We would not rebind that same function.

However, there might be some other circumstances where a weak binding is more appropriate. When building small combinators that compose, we might bind a function but want that function to be weakly bound just in case we compose it in the future with another function that rebinds it to something else.

Strong binding is more appropriate when working directly on "business logic" where we know the intent of every function, and weak binding is more appropriate when working on combinators or library functions that are designed to be composed into larger solutions.

(Discuss on [reddit/r/javascript](http://www.reddit.com/r/javascript/comments/15ix7s/weak_binding_in_javascript/))

p.s. "weaklyBind" and many more combinators and function decorators can be found in [JavaScript Allongé](http://leanpub.com/javascript-allonge), a book focused on working with functions in JavaScript, including combinators, constructors, methods, and decorators. You can download a [free sample PDF](http://samples.leanpub.com/javascript-allonge-sample.pdf).

[walled garden]: https://github.com/raganwald/homoiconic/blob/master/2012/12/walled-gardens.md#programmings-walled-gardens

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

[mock]: http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422
[Lisp Flavors]: https://en.wikipedia.org/wiki/Flavors_(programming_language)