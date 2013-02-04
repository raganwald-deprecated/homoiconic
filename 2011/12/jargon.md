#CoffeeScript is not a language worth learning

> A language that doesn't change the way you think about programming is not worth learning.—Alan Perlis

[CoffeeScript][c] is a program that takes some text you write using a special set of rules and transforms it into some other text, which happens to be a JavaScript program. It is often described as a programming language that "compiles" to JavaScript much as other programming languages compile to assembler or JVM byte codes.
Like many new ideas, CoffeeScript has inspired some enthusiasm from early adopters, some diffidence from pragmatists, and disdain from conservative laggards.

In [A Case Against Using CoffeeScript][against], Ryan Florence argues that people who write bad CoffeeScript will wind up with even worse JavaScript programs. Quite honestly, he's right that there will be plenty of terrible generated JavaScript in the wild. As Sturgeon remarked, "90% of everything is crud." But will the 90% of crud be worse for having been generated in CoffeeScript? I don't think so.

Mind you, I don't think the 90% will magically be transformed from crud to gold.  Crud is crud. But I do think it will be better than the crud that would have been written in "pure" JavaScript. And I think the 10% of good JavaScript will be *better* by virtue of having been transformed from CoffeeScript.

And the reason I think so is the reason that CoffeeScript is "not a language worth learning:"

[c]: http://jashkenas.github.com/coffee-script/
[against]: http://ryanflorence.com/2011/2012/case-against-coffeescript/

##CoffeeScript is JavaScript

My argument is that CoffeeScript is not a language worth learning because **CoffeeScript is not a language**. CoffeeScript is JavaScript. You don't "Think in CoffeeScript," you "Think in JavaScript." Only you think in well-crafted JavaScript.

Obviously, CoffeeScript has a different syntax, but only in the most superficial way. If JavaScript was English, CoffeeScript wouldn't be another language like French, it wouldn't be a dialect like Jamaican Patois, it would be technical jargon like the conversation one programmer might have with another.

CoffeeScript doesn't introduce dramatic new ways to organize programs like continuations, promises, or monads. All of the transformations it produces are local: If you look at a small snippet of CoffeeScript, you know that it translates to a small snippet of JavaScript without dramatically affecting anything else in any other part of the program. There are no back-flips to get "compiled" CoffeeScript to talk to compiled JavaScript.

So you write `@render()` instead of `this.render()`. Big whoop! That's a shorthand notation, not a language. Or you write:

		if foo and @get('bar')
		  doThis()
		  doThat()
			
Instead of:

		if (foo && this.get('bar')) {
		  doThis();
		  doThat();
		}
		
How can we get worked up over this? CoffeeScript has lots of more subtle transformations up its sleeve, like comprehensions, destructuring assignment, splats, or the "fat arrow" some rail against. Here's the secret to understand: None of these things are "language features" that compile from a language that has them—CoffeeScript—into a language that doesn't have them—JavaScript.

I have another way of looking at these features: They're *JavaScript Design Patterns*. Instead of thinking of CoffeeScript as a language that compiles into some inscrutable JavaScript, I think of the javaScript it generates as code written with a large set of standard design patterns. *This* is how I write loop code. *This* is how I write functions that take default arguments. *This* is how I write functions that have a fixed value for `this`. *This* is how I write class-oriented OO. *This* is how I call `super()` in a method.

The JavaScript CoffeeScript generates is JavaScript, The Good Parts. Using consistent, standard ways to solve common problems that JavaScript throws in my way. And best of all, everyone else using CoffeeScript solves those exact problems the exact same way. 

Imagine, if you will, that the Java people took over JavaScript. What would they do? Well, they'd agree on a set of Design Patterns. They'd then build an IDE that generates a skeleton of a design pattern for you automagically. So you'd write something like this code from the [Katy][katy] combinators library:

		class OneTimeWrapper
		  constructor: (@what) ->
		  K: (fn, args...) ->
		    functionalize(fn)(@what, args...)
		    @what
		  T: (fn, args...) ->
		    functionalize(fn)(@what, args...)
		  chain: -> new MonadicWrapper(@what)
		  value: -> @what

And the IDE would automagically expand it into:

		OneTimeWrapper = (function() {

		function OneTimeWrapper(what) {
		  this.what = what;
		}

		OneTimeWrapper.prototype.K = function() {
		  var args, fn;
		  fn = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
		  functionalize(fn).apply(null, [this.what].concat(__slice.call(args)));
		  return this.what;
		};

		OneTimeWrapper.prototype.T = function() {
		  var args, fn;
		  fn = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
		  return functionalize(fn).apply(null, [this.what].concat(__slice.call(args)));
		};

		OneTimeWrapper.prototype.chain = function() {
		  return new MonadicWrapper(this.what);
		};

		OneTimeWrapper.prototype.value = function() {
		  return this.what;
		};

		return OneTimeWrapper;

		})();

This isn't inscrutable, it's the JavaScript I ought to have written in the first place. Much as writing structured programs in the 1970s was like writing programs with GOTOs, only using them wisely and eschewing error-prone constructions.

> I treat CoffeeScript as a big TextMate snippet that's always editable.—[@topfunky][topfunky]

[katy]: http://github.com/raganwald/katy
[topfunky]: http://twitter.com/topfunky

So for me, writing CoffeeScript is writing JavaScript, only with a tool that helps me denote some standard design patterns with an abbreviated notation. And unlike the IDE, I can go back and modify the CoffeeScript itself any time, and the tool will generate another JavaScript file for me.

And of course, I could choose to throw the CoffeeScript away. I'd be left with well-written javaScript. Sure, if I wrote some terrible CoffeeScript I'd end up with terrible JavaScript. Only, it would be terrible in standardized Design Patterned ways.

I might, for example, get OOP [back-to-front][poo]. But at least I would be doing the wrong thing in the right way.

[poo]: https://github.com/raganwald/homoiconic/blob/master/2010/12/oop.md "OOP practiced backwards is 'POO'"

##CoffeeScript is not a language, it's a coding standard for JavaScript

To summarize my view, "CoffeeScript" isn't a new programming language, it's a set of abbreviations for writing JavaScript using a standard set of Design Patterns. The generated JavaScript isn't hyper-optimized spaghetti, it's JavaScript, The Good Parts.

Now, the code it generates isn't the code I would have written reflexively. And perhaps that stings. Why can't I exercise my right as an artist to express myself as I see fit?

The answer is that this is not a bad thing, it's a good thing. By standardizing how classes are generated, how loops are expressed, and so on, CoffeeScript makes it easier for me to read code written by anybody on my team or for that matter anyone anywhere in the world. All CoffeeScript users write loops the same way, we write classes the same way, we use the same patterns because we use CoffeeScript to generate them for us.

It's the same argument behind Python's significant whitespace, or behind enforcing lint on code that's checked into a team project, or having a pre-commit hook wired up to a code beautifier. It's a statement that writing all of these little things in different ways is a net loss, and that standard indentations, standard OOP, standard loops, and so on make the resulting JavaScript easier to read, understand, and maintain.

That leaves us free to express our creativity on the stuff that matters, the stuff that makes a difference.

## CoffeeScript a damn fine tool

If you want to write your JavaScript code such that you generate much the same code that CoffeeScript generates, I say go for it. *Do what you do when you do what you do so well*. But please don't start arguing about whether CoffeeScript is readable or maintainable or debuggable. Really. CoffeeScript isn't a language, it's a jargon for writing standard JavaScript using standard Design Patterns for dealing with common JavaScript problems.

If  you value making that JavaScript easier to *write* by virtue of having a tool that generates well-written JavaScript, CoffeeScript is a good tool to help you write good JavaScript.

And if you value making JavaScript easier to *read* by virtue of getting everyone to solve the same problems the same way with the same Design Patterns, CoffeeScript is a good tool for getting *everyone else* to write good JavaScript.

CoffeeScript isn't a language worth learning because it isn't a language. It doesn't make you think about programming in a new way. It's a tool for writing programs in a language you already know, JavaScript. And considered in that light, it's a damn fine tool.

([discuss][d])

## Afterwords

Here are a few observations about this essay I'd like to make based on the feedback I've received.

### About the Title

Quite obviously, the title is a bit of legerdemain. It holds out the promise of a critique of CoffeeScript, then reverses itself sharply to praise it. I apologize to anyone who felt I was trying to trick them into reading the essay, that was not my intent. My purpose was actually to challenge myself.

What happened was this. In a somewhat unrelated exchange on twitter, [@jashkenas][jashkenas] expressed surprise that there was a CoffeeScript-specific subreddit:

> Huh. Shouldn't it just go into /r/JavaScript or /r/programming?

That got me thinking. Isn't CoffeeScript programming really just JavaScript programming? It's not like there are CoffeeScript-specific libraries. Sure, you can write a book about reading and writing CoffeeScript's syntax, but ultimately, you're writing JavaScript.

Thanks to Paul Graham, I look upon essay-writing as a tool for working out my own thoughts. So I set out to dash off an essay about this. One of the ways to trick yourself into thoroughly exploring a subject is to pick an extreme position and try to explore it, to ask yourself what happens if you turn the dial up to eleven. For example, if code reviews are good, extreme code reviews becomes pair programming. Or if objects are good, extreme OOP is a language where everything, even control flow constructs and numbers, are really objects. (This last bit seems obvious, but it was an unusual idea when SmallTalk was created.)

Of course, such an "extreme" essay is useful for working out ideas, but the real world is more complex than an essay can capture. *I really do think CoffeeScript is a little language*. It definitely changes the way you think about JavaScript programming idioms. One person commented that the JavaScript created by CoffeeScript is more functional than the JavaScript he writes by hand, because "It is just too much hassle to write and nest so many anonymous functions."

So: Is CoffeeScript really a little language? Yes. Is CoffeeScript really a dialect of JavaScript? Also yes. Is CoffeeScript programming its own thing? Yes. Is CoffeeScript programming really JavaScript programming? Also yes. Next time, I'll write a challenging title, answer the title in an essay, and then change the title to something less controversial.

Thanks to everyone who provided feedback about this.

### Transpilers

As noted on [Hacker News][d], there is a special name for compiling a language into another language: *Transpiling*, an abbreviation of "[Transcompiling][trans]."

The strict definition is any conversion from one language to another, and Wikipedia gives conversion from one ASM to another, including optimizations. Current usage seems to focus on translation from one high-level language to another, using only local transformations, so for example many people would not call the original Haskell-to-C implementation a transpiler, because the process involved many global transformations and greenspunning features like lazy evaluation that aren't part of C's semantics.

CoffeeScript is implemented as a transpiler, not a compiler.

### Patterns or Idioms?

As noted on [reddit][reddit], many of the coding conventions that CoffeeScript produces should be more properly called [programming idioms][idioms] rather than [design patterns][patterns]. The distinction between an idiom and a design pattern is mostly one of scale: Idioms are mostly about how to implement something, while design patterns are mostly about how to organize something.

### So is CoffeeScript really a different language?

> It depends entirely on whether you consider syntax or semantics to be what defines a language.—[Luke VanderHart][levanderhart]

[d]: http://news.ycombinator.com/item?id=3370428 "Discuss on Hacker News"
[standards]: http://xkcd.com/927/ "Standards"
[reddit]: http://www.reddit.com/r/javascript/comments/niqup/coffeescript_is_not_a_language_worth_learning/
[trans]: http://en.wikipedia.org/wiki/Transcompiler
[idioms]: http://en.wikipedia.org/wiki/Programming_idiom
[patterns]: http://en.wikipedia.org/wiki/Design_pattern_(computer_science)
[jashkenas]: http://twitter.com/jashkenas
[levanderhart]: https://twitter.com/#!/levanderhart/status/149502899247001600

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