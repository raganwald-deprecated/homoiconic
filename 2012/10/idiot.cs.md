Somewhere, a CoffeeScript Village is Missing Its Idiot
======================================================

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the "I Combinator" is charming in its simplicity:

```coffeescript
I = (x) -> x
```

In his rightfully famous [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422), Raymond Smullyan nicknamed it "The Idiot Bird" for its singlemindedness.

`I` has some useful applications in CoffeeScript. Sometimes you have a function or method that takes an optional filter. You can use "an Idiot" to clean things up:

```coffeescript
class FiddleDeeDum
  # ...
  all: (fn = I) ->
    fn(giant) for giant in giants
```

Now you can call either `fiddleDeeDum.all()` or `filldeDeeDum( (x) -> x.name )` or whatever. This is nicer than having an `if` test inside the method or fooling around with a method decorator of some kind.

Another interesting application falls out of the fact that CoffeeScript's evaluation strategy is "strict, left-to-right, and call-by-sharing with loose matching of arguments to parameters." That means that when you write something like:

```coffeescript
foo( expr1, expr2, expr3, expr4 )
```
    
expr1 is evaluated first, then expr2, then expr3, then expr4. Always. Then the arguments are stuffed into the `arguments` pseudo-variable whether they match declared parameters or not. What this means is that we can write something like this:

```coffeescript
begin = (ignored..., value) -> value
```
    
Now, you can write `begin(x = 5, x = x + 1, x * 2)` and get `12`, just as if you used the comma operator in JavaScript, `begin...end` in Ruby, or the `begin` macro in Scheme. `begin` creates a block of expressions to be evaluated, and returns the last one just as if you had the body of an `if` statement or the body of a `do` statement, but deliberately doesn't create a new scope.

Hopefully you never write `begin` like this in CoffeeScript, because there is a simpler way to accomplish the same result:

```coffeescript
( expr1; expr2; expr3; expr4 )
```
  
Same thing. So why do we care about `begin`? Only an idiot would write that! Well, consider this variation:

```coffeescript
begin1 = (value, ignored...) -> value
```
    
That executes a series of statements and returns the value of *the first one*. And yes, Scheme does have a [begin1](http://patricklogan.blogspot.ca/2005/08/when-to-create-syntax-in-lisp.html)  macro (old Lisps called it `PROG1`).

Again, there's a simpler way to write `begin1` in CoffeeScript:

```coffeescript
begin1 = (value) -> value
```

It's our "Idiot" again! Can we use it like `begin`? yes! Compare it to Underscore's  `_.tap(value, fn)`:

```coffeescript
    _.tap expr1, (value) ->
      expr2
      expr3
      # ... 
```

`_.tap` lets you use a function that takes the value of `expr1` as a parameter. That might be what you want, in which case use `_.tap`. But if you don't need it, `begin1( ...; ...; ... )` evaluates everything in the scope of the enclosing function. So you can create normal case variables, return from the enclosing function, and otherwise behave as if you were using `( ..., ..., ... )`.

Here's an example of working with a simple `fluent interface`:

```coffeescript
class Folderol
  # ...
  aFluentMethod: (arg1, arg2)
    begin1 this,
      @set({something: arg1, somethingElse: arg2})
```

The moral of the story? *Every CoffeeScript village ought to have its own idiot*. If yours is missing, write yourself a new one.

---

Recent work:

* "[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)