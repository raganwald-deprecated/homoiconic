Lexical Scope in CoffeeScript
=============================

---

Note: Recently, I permitted my occasional guest and constant critic [Nickieben Bourbaki] to write a post about CoffeeScript. Although he meant well, his tone and candid appraisal of the behaviour of others was not in the best traditions of this blog. I apologize for allowing my admiration for his intellect to overcome my better judgment. In the Tour de France, there is an award every day for the "Most Combative Rider." This award is handed out to recognize that while being combative makes for a more entertaining race, it rarely results in a win for the rider in question. Hopefully, both Nickie and I will take this lesson to heart for the future.--Reg "raganwald" Braithwaite

[Nickieben Bourbaki]: http://www.dreamsongs.com/Nickieben.html

---

Lexical Scope
-------------

CoffeeScript and JavaScript are lexically scoped languages. Meaning, you can determine the scope of a variable by examining the source code of the program. You may need to run the program to determine the actual value, but you can look at any variable reference--say an `i`--and say "That's the same as this other `i` over here, and that one over there, and that one over there."

There are lots of ways to have lexical scope. I recall an ancient dialect of BASIC on my high school's Nova 1220 that only had global variables. This was lexically scoped in the most obvious degenerate sense. JavaScript is lexically scoped. There are interesting cases around what happens with things like variables bound when catching a throwable, but by and large variables are bound in the global scope, variables are bound in a scope by a function declaration, variables are bound in a scope using the `var` keyword, and variables are bound in a scope by dint of being parameters.

Besides the global scope, what other scopes are there in JavaScript? Eschewing edge cases again, the scopes are function bodies. `for` loops are not scopes. If statements are not scopes. Just function bodies. `var` and function declarations bind variables to the scope of the most immediately enclosing function body, or the global scope if none encloses them.

I think most people agree on this, and the term most people agree on is that JavaScript has *function-level lexical scoping*. Other languages have "block-level" lexical scoping, you can bind a variable inside of an if statement or a for loop or create an entirely new block just for some variables. JavaScript does not work this way.

Faking Block Scope
------------------

JavaScript permits you to fake block-level lexical scope using an idiom that goes all the way back to Lisp and the lambda calculus: You can create a function and invoke it immediately just to manufacture a scope with some parameters:

```javascript
var x = 'global';

(function (x) {
  console.log(x);  // => 'function'
})('function');

console.log(x);    // => 'global'
```

You can do this with `var` as well:

```javascript
var x = 'global';

(function () {
  var x = 'function'
  console.log(x);  // => 'function'
})();

console.log(x);    // => 'global'
```

Creating new scopes this way has a cost, and that cost may be significant in current JavaScript implementations.

Let
---

You may have heard of `let`, it's a Lisp construct that is in JavaScript 1.7 (currently supported in Mozilla only). In Lisp, `let` is a macro that actually creates code that works just like the JavaScript code above. The JavaScript implementation of `let` looks like this:

```javascript
var x = 'global';

let x = 'function' {
  console.log(x);  // => 'function'
};

console.log(x);    // => 'global'
```

My understanding is that it works just like the scoping trick of creating a function and invoking it immediately, with similar performance.  This idiom is so prevalent in languages like Lisp that their implementations use many clever tricks to optimize that cost away. But to my knowledge, these optimizations haven't made it into JavaScript or CoffeeScript [yet][hoist].

[hoist]: https://github.com/jashkenas/coffee-script/issues/2552 "Hoist variables declared with do"

Non-Local Effects
-----------------

Function-level lexical scope as implemented with parameters and JavaScript's `var` keyword are resilient to non-local effects. Meaning, that variables declared as parameters or with `var` always have the same scope regardless of what you write elsewhere in the program.

Take our example from above:

```javascript
var x = 'global';

(function () {
  var x = 'function'
  console.log(x);  // => 'function'
})();

console.log(x);    // => 'global'
```

Let's remove the outer `x`:

```javascript
(function () {
  var x = 'function'
  console.log(x);  // => 'function'
})();

console.log(x);    // => ReferenceError: x is not defined=
```

We get a reference error for attempting to access `x` outside our little function scope, but the meaning of `x` inside it remains the same. No matter what we do with `x` elsewhere in our file or program, the meaning of `x` inside our little faked block--or any function--remains the same as long as we declare it as a parameter or with `var`.

The scope of parameters, variables declared with `var`, and function declarations has this pleasant property of being resistant to non-local changes in the code. Most programmers value this property, as it avoids a problem where an edit in one part of a file can inadvertently change the meaning of another construct in the file. Like most design features, some programmers value it more than others when considering language design tradeoffs.

Arguments against `var`
-----------------------

There are some disadvantages to JavaScript's approach. The most obvious is that using a variable without declaring it with `var` creates and/or clobbers a global variable. The feature isn't the problem so much as the default case. Some other languages reverse this, providing a mechanism when you wish to access the global environment and/or declare a new variable.

Another is that variables can be declared anywhere within a scope. This can create the illusion of block scope even when the reality is otherwise. JavaScript programmers develop a habit of being free with declarations and use tools like JSLint that identify suspect references.

CoffeeScript
------------

So far we have discussed JavaScript's behaviour. What about CoffeeScript? Like JavaScript, CoffeeScript has function-level lexical scope. Our first example translates directly to CoffeeScript:

```coffeescript
x = 'global'

((x) ->
  console.log x  # => 'function'
)('function')

console.log x    # => 'global'
```

[try it][1]

[1]: http://coffeescript.org/#try:%0Ax%20%3D%20'global'%0A%0A((x)%20-%3E%0A%20%20console.log%20x%20%20%23%20%3D%3E%20'function'%0A)('function')%0A%0Aconsole.log%20x%20%20%20%20%23%20%3D%3E%20'global'

CoffeeScript doesn't provide `let`, but it has another construct that can be used in almost exactly the same way:

```coffeescript
x = 'global'

do (x = 'function') ->
  console.log x        # => 'function'

console.log x          # => 'global'
```

[try it][2]

[2]: http://coffeescript.org/#try:x%20%3D%20'global'%0A%0Ado%20(x%20%3D%20'function')%20-%3E%0A%20%20console.log%20x%20%20%20%20%20%20%20%20%23%20%3D%3E%20'function'%0A%0Aconsole.log%20x%20%20%20%20%20%20%20%20%20%20%23%20%3D%3E%20'global'

So is CoffeeScript equivalent to JavaScript? No.

Global vs. Normal Case Variables
--------------------------------

In JavaScript, variables that are not bound in a function (as a parameter, using `var`, or by a function declaration) are bound in the global scope. This is not the case with CoffeeScript. Variables that are not bound in a function as parameters are called "Normal Case" variables, and CoffeeScript binds them to the highest enclosing scope where they are used.

Whew. Meaning?

```coffeescript
x = 'global'

do ->
  console.log x        # => 'global'
```

[try it][3]

[3]: http://coffeescript.org/#try:x%20%3D%20'global'%0A%0Ado%20-%3E%0A%20%20console.log%20x%20%20%20%20%20%20%20%20%23%20%3D%3E%20'global'

In this case, both variables called `x` are the same thing because we didn't declare a new `x` as a parameter. Here's another case:

```coffeescript
x = 'global'

do ->
  x = 'labolg'
  do (x = 'function') ->
    console.log x          # => 'function'
    do ->
      console.log x        # => 'function'
      
console.log x              # => 'labolg'
```

[try it][4]

[4]: http://coffeescript.org/#try:x%20%3D%20'global'%0A%0Ado%20-%3E%0A%20%20x%20%3D%20'labolg'%0A%20%20do%20(x%20%3D%20'function')%20-%3E%0A%20%20%20%20console.log%20x%20%20%20%20%20%20%20%20%20%20%23%20%3D%3E%20'function'%0A%20%20%20%20do%20-%3E%0A%20%20%20%20%20%20console.log%20x%20%20%20%20%20%20%20%20%23%20%3D%3E%20'function'%0A%20%20%20%20%20%20%0Aconsole.log%20x%20%20%20%20%20%20%20%20%20%20%20%20%20%20%23%20%3D%3E%20'labolg'

Now the outer two `x`es are the same variable, but the inner two are a different variable, thanks to the declaration as a parameter.

Non-Local Effects Revisited
---------------------------

CoffeeScript does not have a `var` parameter. Therefore, variables not declared as parameters are subject to changes in scope based on what happens in scopes that enclose them. To whit:

```coffeescript
do ->
  x || x = 'thing 1'
  console.log x       # => 'thing 1'
```

[try it][5]

[5]: http://coffeescript.org/#try:do%20-%3E%0A%20%20x%20%7C%7C%20x%20%3D%20'thing%201'%0A%20%20console.log%20x%20%20%20%20%20%20%20%23%20%3D%3E%20'thing%201'

Now let's write:

```coffeescript
x = 'thing 2'

do ->
  x || x = 'thing 1'
  console.log x      # => 'thing 2'
```

[try it][6]

[6]:http://coffeescript.org/#try:x%20%3D%20'thing%202'%0A%0Ado%20-%3E%0A%20%20x%20%7C%7C%20x%20%3D%20'thing%201'%0A%20%20console.log%20x%20%20%20%20%20%20%23%20%3D%3E%20'thing%202'

Writing something outside of our `do` changes what happens to `x` inside it. In JavaScript, if we didn't want that to happen, we'd use the `var` keyword:

```javascript
var x = 'thing 2';

(function () {
  var x = x || 'thing 1'
  console.log(x);        // => 'thing 1'
})();
```

But there is no `var` keyword in CoffeeScript, therefore it is possible for code written in one place to affect the meaning of "Normal Case" variables written in an enclosed scope. And vice-versa.

Shadowing
---------

Non-local effects are not necessarily a bad thing, sometimes the programmer wishes for a variable in an outer scope to be the same variable as the one in an inner scope. But when the programmer wishes them to have the same name but be different variables, this is called 'shadowing:' The programmer wants the inner variable to 'shadow' the outer one.

In that case, a scoping construct must be used to enforce the separation of scope. In both JavaScript and CoffeeScript, a parameter will do the trick. In JavaScript, the `var` key word will also do the trick.

Conclusion
----------

JavaScript and CoffeeScript have function-level lexical scope. Both allow the programmer to enforce scope using functions, and to 'fake' block-level lexical scope using let-like function creation and immediate invocation. CoffeeScript provides the `do` notation that can be used to write a cleaner-let-like construct than JavaScript.

JavaScript also provides the `var` keyword. The var keyword permits the programmer to bind additional variables within a function's scope without creating and invoking additional functions. Some programmers prefer this style for visual reasons. There is a performance implication of using functions to fake block scope in current JavaScript implementations, so `var` is a performance win for cases where it is necessary to enforce shadowing.

CoffeeScript's "normal case" variables are lexically scoped, however they are subject to non-local effects, something that does not affect variables scoped with parameters, `var` keywords, or function declarations. CoffeeScript variables cannot shadow each other unless parameters are used.

On the other hand, CoffeeScript's lack of a `var` keyword can be seen as simplifying the language in one respect: Programmers cannot accidentally create variables in global scope, as CoffeeScript automatically binds every variable reference within a local scope (the top-level scope of the file or the highest functional scope containing a variable with the same name).

CoffeeScript and JavaScript thus have designs that value slightly different use cases. Programmers choosing between the two on the basis of their handling of scope must evaluate their respective advantages and disadvantages and exercise judgment.

([discuss](http://www.reddit.com/r/programming/comments/1039qh/lexical_scope_in_coffeescript/))

---

(**addenda**)

With respect to working around the lack of a `var` keyword, it is possible to nest a `do` within a function. So whereas in JavaScript you might write:

```javascript
var plusOne = function (x) {
  var one = 1;
  return x + one;
}
```

In CoffeeScript you can write:

```coffeescript
plusOne = (x) ->
  do (one = 1) ->
    x + one
}
```

The disadvantage is that you need to create and invoke the inner `do` every time the function is called. There is a workaround when performance is an issue:

```coffeescript
plusOne = do (one = undefined) ->
  (x) ->
    one = 1
    x + one

console.log plusOne(42)
```

[try it][7]

[7]: http://coffeescript.org/#try:plusOne%20%3D%20do%20(one%20%3D%20undefined)%20-%3E%0A%20%20(x)%20-%3E%0A%20%20%20%20one%20%3D%201%0A%20%20%20%20x%20%2B%20one%0A%0Aconsole.log%20plusOne(42)

Also, folks will refer to non-local effects sometimes as dynamic scope. Neither CoffeeScript nor JavaScript have dynamic scope, as can easily be tested with this code:

```coffeescript
x = 'lexical'

acid = ->
  alert "#{x}ly scoped"

test = (x) ->
  acid()

test('dynamic')
```

[try it][8]

[8]: http://coffeescript.org/#try:x%20%3D%20'lexical'%0A%0Aacid%20%3D%20-%3E%0A%20%20alert%20%22%23%7Bx%7Dly%20scoped%22%0A%0Atest%20%3D%20(x)%20-%3E%0A%20%20acid()%0A%0Atest('dynamic')

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

