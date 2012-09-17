Actually, YOU don't understand Lexical Scope!
=============================================

Note: *This post was transcribed from the words of my occasional guest and constant critic, [Nickieben Bourbaki]. Therefore, where these words are wise and correct, he deserves the credit and admiration. And where these words are wrong, I deserve the blame for incorrectly transcribing them from an angry voice mail message.*--Reg "raganwald" Braithwaite

[Nickieben Bourbaki]: http://www.dreamsongs.com/Nickieben.html

On Reddit, some folks have noticed that CoffeeScript differs from JavaScript. And they summarize one of the differences thusly:

> Coffeescript devs don't understand lexical scope

By "devs," they appear to mean Jeremy Ashkenas, the language's creator. Although quite frankly, their vitriol is such that they may well mean anyone willingly using the language, for people with closed minds are often quick to assume that anyone who disagrees with them is uneducated or mentally deficient.

They may well be smart, experienced people, but their argument about CoffeeScript is wrong, and their Ad Hominem is both unfounded and [pessimistic].

[pessimistic]: https://github.com/raganwald/homoiconic/blob/master/2009-05-01/optimism.md#optimism

The argument against CoffeeScript
---------------------------------

JavaScript has lexical scoping for a parameters. Let's check it out.

```JavaScript
(function (foo) { 
  foo = 'outer';
  (function (foo) { 
    foo = 'inner'; 
  })();
  return foo;
})();
```

Naturally, the output is "outer." And CoffeeScript works exactly the same way:

```coffeescript
((foo) ->
  foo = 'outer'
  ((foo) ->
    foo = 'inner'
  )()
  foo
)()
```

Or you can simplify it:

```coffeescript
((foo = 'outer') -> 
  ((foo = 'inner') ->
  )()
  foo
)()
```

Or simplify it some more:

```coffeescript
do (foo = 'outer') ->
  do (foo = 'inner') ->
  foo
```

So obviously, both languages have the same kind of lexical scope everyone agrees on: A parameter to a function is its own thing even if the function is nested inside another function with a  parameter that has the same name. So where is the disagreement?

Well, JavaScript has at least four different ways to declare a variable. A parameter is one. Nobody's talking about this one, (even though you'd think that anyone pointing fingers out to be thorough enough to bring it up):

```JavaScript
function howComeNamedFunctionsWereLeftOut (foo) {
  // ...
}
```

The third one is this:

```JavaScript
iAmGlobalToAllFiles = 'global';
```

Or is it? We'll come back to that later. The fourth one is this:

```JavaScript
var iAmLocalToMyEnclosingFunction = 'local';
```

Before we talk about that third declaration, let's trot out the ridiculous argument against CoffeeScript and the Ad Hominem attack against its "devs' whomever they might be. The argument is that the way CoffeeScript treats the third form isn't like the way JavaScript treats the fourth form, therefore CoffeeScript's devs don't understand Lexical Scope.

Why that argument is hogwash
----------------------------

This argument is 98 cents short of a dollar. It boils down to arguing that this CoffeeScript:

```coffeescript
foo = 'bar'
```

Ought to work like this JavaScript does:

```JavaScript
var foo = bar
```

Or, perhaps, the argument is that CoffeeScript needs a `var` keyword. Or that CoffeeScript needs something that works like a var keyword, maybe:

```coffeescript
foo := 'bar'
```

> I once saw a human pyramid. It was very unnecessary--Mitch Hedberg

But that is unnecessary in CoffeeScript, because if you want lexical scope, you already have lexical scope:

```coffeescript
do (foo = 'outer') ->
  do (foo = 'inner') ->
  foo
```

It works just like it does in both JavaScript and in Lisp. Thank you, CoffeeScript has lexical scope, and CoffeeScript's devs understand lexical scope. So what about adding `var` to CoffeeScript? Wouldn't that indicate they understand how to make lexical scope even more wonderful that function parameters make it?

No. And wanting that indicates that you (I am speaking to the CoffeeScript haters) don't understand lexical scope. [Editor's note: Another possibility is that they forget what it is like to learn a new programming language--Reg Braithwaite].

JavaScript's `var` keyword is ridiculously inelegant and confusing. It may not be a steaming turd, but it certainly smells that way when the wind is right on a hot August afternoon. What does this mean?

```JavaScript
localOrGlobal = 'global';

// ... some code I write ...

var localOrGlobal = 'local'

localOrGlobal = 'unsure';
```

After that code executes, is a global variable created or not? And if it is, what is its value? You know the answer, I know the answer, but Jeremy also knows that its not exactly obvious. To be a JavaScript programmer, you have to go out and memorize how stuff like this works.

Here's another wonderful use of var. I think that getting this wrong is a rite-of-passage for JavaScript programmers, and I accuse everyone who wants `var` added to CoffeeScript of trying to impose a sadistic hazing ritual on the people who read their code:

```JavaScript
var methods = ['remove', 'show', 'hide', 'stop'];
for (var i=0; i<methods.length; i++) {
  var method = methods[i];
  Frame.prototype[methods[i]] = function () {
    for (var j=0; j<this.elements.length; j++) {
      this.elements[j][method]();
    };
  };
}
```

[Can you spot the bug][bug]?

[bug]: https://github.com/raganwald/homoiconic/blob/master/2010/10/let.md#lets-make-closures-easy "Let's make closures easy"

The `var` keyword cannot be local to a block in JavaScript, just a function. So it gets hoisted no matter where you declare it. To understand `var`, you have to do some mental backflips related to hoisting. The solution in JavaScript is to write this:

```JavaScript:
var methods = ['remove', 'show', 'hide', 'stop'];
for (var i=0; i<methods.length; i++) {
  (function (method) {
    Frame.prototype[methods[i]] = function () {
      for (var j=0; j<this.elements.length; j++) {
        this.elements[j][method]();
      };
    };
  })(methods[i]);
} 
```

And in CoffeeScript you write:

```coffeescript
do (methods = ['remove', 'show', 'hide', 'stop']) ->
  for method in methods do ->
    Frame.prototype[method] = ->
      for element in elements do ->
        this[element][method]()
```

Life is simpler and easier without `var`! But if you absolutely, positively must have some variables with funny hoisting rules because you're a Big Swinging Dick who likes leaky abstractions where you need to know the funny rules the transpiler follows to convert what you write into a sensible program, Jeremy let's you have something that's *just like var only different*.

Just like `var`, only different
-------------------------------

In CoffeeScript, you can use a variable that hasn't been declared as a parameter to a function or in `do` (which *is* a function any ways). You just use it, like this:

```coffeescript
iAmNotAParameter = 'fubar'
```

Bold. Simple. And different than JavaScript. In JavaScript, it might be a global variable, it might be something local that has been hoisted to the nearest function. You need to look around and see if you can find a `var` declaration to know what it is.

In CoffeeScript, there are no `var` declarations, so the CoffeeScript funny rule is that it is hoisted to the highest function level of use in the current file. If you write this:

```coffeescript
# file starts
iAmNotAParameter = 'fubar'
# ... more code with deep functions
  # ... more code with deep functions
    # ... more code with deep functions
      # ... more code with deep functions
        # ... more code with deep functions
          # ... more code with deep functions
            iAmNotAParameter = 'sanfu'
```

You are working with the same `iAmNotAParameter` declared at the top level of the file. The detractors don't like this, because they think that if you write this JavaScript:

```JavaScript
function (foo) {
  var bar = 'fubar'
  // ...
}
```

That the correct 'translation' to CoffeeScript is:

```coffeescript
(foo) ->
  bar = 'fubar'
  # ...
```

And they're wrong. We've established that the correct translation is:

```coffeescript
(foo) ->
  do (bar = 'fubar') ->
    # ...
```

And the problem is that *they* don't understand Lexical Scope. They complain that if you copy and paste what they wrote, it breaks under certain circumstances. Well of course! **It breaks because they translated it wrong!**

In CoffeeScript, writing `bar = 'fubar'` when `bar` isn't a parameter invokes a leaky abstraction variable hoisting thingie. How are you supposed to know that? Well, if you try that in JavaScript, you know to look up the lexical chain of scopes until you find a `var` keyword or parameter. Failing all of those, it's a global variable. In CoffeeScript, you look up the lexical chain of scopes until you find a parameter. Failing all of those, it's a hoisted wingy-dingy.

So, if you translate `var bar = 'fubar'` to `do (bar = 'fubar') ->`, your translated JavaScript works properly and can be copied and pasted at will.

It's easy once you understand lexical Scoping and let go of weird leaky abstraction variable hoisting thingies. Honestly, it's as if JavaScript devs have [Stockholm Syndrome].

--[Nickieben Bourbaki]

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CS/JS library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[Stockholm Syndrome]: https://en.wikipedia.org/wiki/Stockholm_syndrome