Actually, YOU don't understand lexical scope!
=============================================

*Or more realistically, you don't understand how CoffeeScript implements it, and that's why you think it doesn't work.*

---

Note: In this post, I permitted my occasional guest and constant critic [Nickieben Bourbaki] to write a post about CoffeeScript. Although he meant well, his tone and candid appraisal of the behaviour of others was not in the best traditions of this blog. I apologize for allowing my admiration for his intellect to overcome my better judgment. In the Tour de France, there is an award every day for the "Most Combative Rider." This award is handed out to recognize that while being combative makes for a more entertaining race, it rarely results in a win for the rider in question. Hopefully, both Nickie and I will take this lesson to heart for the future.--Reg "raganwald" Braithwaite

[Nickieben Bourbaki]: http://www.dreamsongs.com/Nickieben.html

I have written [a far better post explaining CoffeeScript's lexical scoping][lex]. I recommend it. I'm leaving this post up as a caution to others.

[lex]: https://github.com/raganwald/homoiconic/blob/master/2012/09/lexical-scope-in-coffeescript.md "Lexical Scope in CoffeeScript"

---

Introduction
------------

On Reddit, some folks have noticed that CoffeeScript differs from JavaScript. And they summarize one of the differences thusly:

> Coffeescript devs don't understand lexical scope--[proggit](http://www.reddit.com/r/programming/comments/zx137/coffeescript_devs_dont_understand_lexical_scope/)


By "devs," they appear to mean Jeremy Ashkenas, the language's creator. Although quite frankly, their vitriol is such that they may well mean anyone willingly using the language, for people with closed minds are often quick to assume that anyone who disagrees with them is uneducated or mentally deficient.

They may well be smart, experienced people, but their argument about CoffeeScript is mistaken, and their Ad Hominem is both unfounded and [pessimistic].

[pessimistic]: https://github.com/raganwald/homoiconic/blob/master/2009-05-01/optimism.md#optimism

The argument against CoffeeScript
---------------------------------

JavaScript has lexical scoping for parameters:

```JavaScript
(function (foo) { 
  foo = 'outer';
  (function (foo) { 
    foo = 'inner'; 
  })();
  return foo;
})();

// => 'outer'
```

CoffeeScript works exactly the same way:

```coffeescript
((foo) ->
  foo = 'outer'
  ((foo) ->
    foo = 'inner'
  )()
  foo
)()

# => 'outer'
```

Or you can simplify it:

```coffeescript
((foo = 'outer') -> 
  ((foo = 'inner') ->
  )()
  foo
)()

# => 'outer'
```

Or simplify it some more:

```coffeescript
do (foo = 'outer') ->
  do (foo = 'inner') ->
  foo

# => 'outer'
```

Both languages have the same kind of lexical scope everyone agrees on: A parameter to a function is its own thing even if the function is nested inside another function with a parameter that has the same name. So where is the disagreement?

Well, JavaScript has at least four different ways to declare a variable. A parameter is one. A function declaration (as opposed to anonymous function expression) is another:

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

Before we talk about that third declaration, let's trot out the argument against CoffeeScript and the Ad Hominem attack against its "devs" (whomever they might be). The argument is that *the way CoffeeScript treats the third form isn't like the way JavaScript treats the fourth form, therefore CoffeeScript's devs don't understand lexical scope*.

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

> A parameter to a function is its own thing even if the function is nested inside another function with a parameter that has the same name.

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
  for method in methods then do ->
    Frame.prototype[method] = ->
      for element in elements then do ->
        this[element][method]()
```

Life is simpler and easier without `var`! But if you absolutely, positively must have some variables with funny hoisting rules because you're a Big Swinging Dick who likes leaky abstractions where you need to know the funny rules the transpiler follows to convert what you write into a sensible program, CoffeeScript let's you have something that's *just like var only different*.

Just like `var`, only different
-------------------------------

In CoffeeScript, you can use a variable that hasn't been declared as a parameter to a function or in `do` (which *is* a function any ways). You just use it, like this:

```coffeescript
iAmNotAParameter = 'fubar'
```

Bold. Simple to write. And different than JavaScript. In JavaScript, it might be a global variable, it might be something local that has been hoisted to the nearest function. You need to look around and see if you can find a `var` declaration or a parameter to know what it is.

In CoffeeScript, there are no `var` declarations, so in CoffeeScript you have to look around to see if you can find a parameter declaration. If not, the CoffeeScript funny rule is that it is hoisted to the highest function level of use in the current file. If you write this:

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

You are working with the same `iAmNotAParameter` declared at the top level of the file. So what we have is one sound way to use lexical scope--parameters--that works the same in JavaScript, CoffeeScript, Lisp, and just about every other serious language. And another way that is quirky.

JavaScript has two flavours of quirky: global variables and `var` declarations, and you have to look around to figure out which is which and where the `var` really goes. CoffeeScript has one flavour of quirky and you have to look around to figure out what is what, only the CoffeeScript quirky is different from both of the JavaScript quirkies. The haters don't like this, because they think that if you write this JavaScript:

```JavaScript
function blitz (foo) {
  var bar = 'fubar'
  // ...
}
```

That the correct 'translation' to CoffeeScript ought to be:

```coffeescript
blitz = (foo) ->
  bar = 'fubar'
  # ...
```

And they're wrong. We've established that the semantically correct translation is actually[1](#notes):

```coffeescript
blitz = (foo) ->
  do (bar = 'fubar') ->
    # ...
```

And the problem is that *they* don't understand CoffeeScript's lexical scope. They complain that if you copy and paste what they wrote, it breaks under certain circumstances. Well of course! **It breaks because they translated it wrong!**

So, if you translate `var bar = 'fubar'` to `do (bar = 'fubar') ->`, your translated JavaScript works properly and can be copied and pasted at will.

It's easy to use CoffeeScript once you understand The-One-True-Lexical-Scope and let go of weird leaky-abstraction-variable-hoisting-thingies. But some people love that kind of arbitrary accidental complexity. It's almost as if JavaScript devs have [Stockholm Syndrome], and it isn't enough to love their prison, they have to hate anyone who tries to leave the [village].

--[Nickieben Bourbaki]

[village]: https://en.wikipedia.org/wiki/The_Village_(The_Prisoner)

([discuss][hn])

[hn]: http://news.ycombinator.com/item?id=4534408

---

Notes
---

1. Sharp-eyed readers have pointed out that this code is expensive in CoffeeScript. For PL wonks, `do` is equivalent to Scheme's `let`. The difference between CoffeeScript and Scheme is that any Scheme implementation longer than a single page of code will optimize the extra closure away when it is not needed for semantic purposes.

  Clever programmers can substitute this form in many cases:

  ```coffeescript
  blitz = do (bar = 'fubar') ->
    (foo) ->
      # ...
  ```

  Same effect and much cheaper!

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

[Stockholm Syndrome]: https://en.wikipedia.org/wiki/Stockholm_syndrome