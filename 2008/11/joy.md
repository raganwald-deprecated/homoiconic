Finding Joy in Combinators
===

In previous posts, we have looked at a few interesting combinators and some Ruby code inspired by them. Today we'll review the definition of a combinator, and from there we'll learn something intriguing about an entire family of programming languages, the [concatenative languages](http://en.wikipedia.org/wiki/Concatenative_programming_language "Concatenative programming language - Wikipedia, the free encyclopedia").

Let's start at the beginning: What is a combinator? 

One definition of a combinator is *a function with no free variables*. Another way to put it is that a combinator is a function that takes one or more arguments and produces a result without introducing anything new. In Ruby terms, we are talking about blocks, lambdas or methods that do not call anything except what has been passed in.

So if I tell you that:

	finch.call(a).call(b).call(c)
		=> c.call(b).call(a)

Then you know that `finch` is a combinator because the effect it produces is made up solely of combining the effects of the things it takes as parameters.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.  

Easy, and yet... Where is our vaunted simplicity? Working with Ruby's lambdas and braces and calls gets in our way. We can learn a lot from combinatorial logic to help our Ruby programming, but Ruby is a terrible language for actually learning about combinatorial logic.

Languages for combinatorial logic
---

[![Double-barred Finches (c) 2008 aaardvaark, some rights reserved](http://farm2.static.flickr.com/1341/1353993093_57128dd3ab.jpg)](http://flickr.com/photos/ozjulian/1353993093// "Double-barred Finches (c) 2008 aaardvaark, some rights reserved") 

Combinatorial logicians use a much simpler, direct syntax for writing expressions:

	Fabc => cba

Whenever a logician writes `abc`, he means the same thing as when a Rubyist writes `a.call(b).call(c)`. Note that like Ruby, the precedence in combinatorial logic is to the left, so `abc` is equivalent to `(ab)c` just as in Ruby `a.call(b).call(c)` is equivalent to `(a.call(b)).call(c)`.

I think you'll agree that `abc` is much simpler than `a.call(b).call(c)`. Here's another look at the combinators we've met in this series, using the simpler syntax:

	Kxy => x
	Txy => yx
	Cxyz => xzy
	Q3xyz => z(xy) # Q3 is shorthand for the Quirky bird
	Bxyz = x(yz)
	Qxyz = y(xz) # Q is shorthand for the Queer bird

There are many, many more combinators, of course. Infinitely more, in fact. We only have names for some of the most useful. For example, the Warbler Twice Removed, or `W**` is written:

	W**xyzw => xyzww

(Warblers are actually in a whole 'nother family of birds that introduce *duplication*. Other members of that family include the Mockingbird and Starling. They're incredibly useful for introducing ideas like iteration and recursion.)

You could say that combinators take a string of symbols (like x, y, z, w, and so forth), then they introduce some erasing, some duplication, some permutation, and add some parentheses. That they work to rearrange our string of symbols.

We have seen that parentheses are allowed, and that some combinators introduce parentheses. Before you say that the combinators introduce new symbols, remember that parentheses are *punctuation*. If you think of the symbols as words and the parentheses as punctuation, you see that the combinators simply rearrange the words and change the punctuation without introducing new words.

Now I said that combinators work with strings of symbols. This was a terrible analogy, because it made us talk about punctuation and why parentheses are not symbols. Another thing you could say is that combinator work with *lists* of symbols, then they re-arrange the symbols, including removing symbols, introducing sub-lists, and duplicating symbols.

This is more interesting! Now we can see that in our notation, adding parentheses is a way of introducing a sub list. Let's revisit the bluebird:

	Bxyz = x(yz)

Now what we can say is this: The bluebird takes a list of three symbols and answers a list of one symbol and a sublist of two symbols. In Ruby:

	bluebird = lambda { |*args|
		x, y, z = args
		[x, [y, z]]
	}
	
	bluebird.call(:x, :y, :z)
		=> [:x, [:y, :z]]

This is easy. What about the Thrush?

	thrush = lambda { |*args|
		x, y = args
		[y, x]
	}
	
	thrush.call(:x, :y)
		=> [:y, :x]

Now let's pause for a moment. Imagine we had an entire programming language devoted to this style of programming. The primary thing it does is define combinators that take a list of symbols and recombine them. Since it works with lists and we are thinking about combinatory logic, we will represent our expressions as lists:

	idiot :x
		=> :x

	mockingbird :x
		=> :x :x

	bluebird :x :y :z
		=> :x [:y :z]

	thrush :x :y
		=> :y :x

Wait! Do not shout Lisp! Just because we have lists of things does not mean we are programming in Lisp!! Let's keep going, and you will see in the next example that I do not mean Lisp:

	bluebird thrush :x :y :z
		=> thrush [:x :y] :z
		=> :z [:x :y]

And therefore in our fictitious language we can write:

	quirky = bluebird thrush

And thus:

	quirky :x :y :z
		=> :z [:x :y]

This looks familiar. Have you ever written a program in [Postscript](http://en.wikipedia.org/wiki/PostScript "PostScript - Wikipedia, the free encyclopedia")? Or [Forth](http://en.wikipedia.org/wiki/Forth_(programming_language)? What if instead of using a thrush we used a word called `swap`? Or instead of a mockingbird we used a word called `dup`?

Concatenative languages
---
	
[![Hooded Warbler (c) 2008 birdfreak.com, some rights reserved](http://farm3.static.flickr.com/2095/2490084287_06e4ac8380_d.jpg)](http://flickr.com/photos/birdfreak/2490084287/ "Hooded Warbler (c) 2008 birdfreak.com, some rights reserved")  

Concatenative (or stack-based) programming languages--like Postscript, Forth, [Factor](http://www.factorcode.org/ "Factor programming language"), and [Joy](http://www.latrobe.edu.au/philosophy/phimvt/joy/j00ovr.htmll)--are almost direct representations of combinatorial logic. There is a list of things, words or combinators permute the list of things, and the things can be anything: data, other combinators, or even programs. These languages are called concatenative languages because the primary way to compose programs and combinators with each other is to concatenate them together, like we did with the bluebird and thrush above.

> For me the purpose of life is partly to have joy. Programmers often feel joy when they can concentrate on the creative side of programming, So Ruby is designed to make programmers happy.
--Yukihiro Matsumoto

You have probably heard that it is a good idea to learn a new programming language every year. Is a concatenative language on your list of languages to learn? No? Well, here is the reason to learn a concatenative language: *You will learn to think using combinatorial logic*. For example, the Y Combinator is expressed in Joy as:

	[dup cons] swap concat dup cons i
	
Where `dup` is a mockingbird, `swap` is a thrush, `i` is an idiot bird, and `cons` and `concat` are likewise two other combinators. Writing in Joy is writing directly in combinators.

In other programming languages, combinatorial logic is an underpinning. It helps us explain and prove certain things, It inspires us to invent certain things. It is behind everything we do. That's good. But in a concatenative language, it is not an underpinning or behind a curtain. It is right out there in front of you. And learning to program in a concatenative language means learning to think in combinators.

The combinators we've discussed in depth so far are all fascinating, however as a basis for writing programs they are incomplete. You cannot represent every possible program using kestrels, thrushes, cardinals, quirky birds, bluebirds, and queer birds. To represent all possible programs, we need to have at least one combinator that duplicates symbols, like a mockingbird or another from its family.

In an upcoming post, we'll look at duplicative birds and we'll look at a very practical example of a recursive combinator taken from Joy.

> If you are interested in the ideas behind sets of combinators that form a basis for reasoning about programs, I can't recommend [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422) too highly. There you will find explanations of why using B,T, M, and I as a basis (bluebirds, thrushes, mockingbirds, and idiots) is equivalent to using B, C, W and I (bluebirds, cardinals, warblers, and idiots), and of course why S and K (starlings and kestrels) make for the smallest possible basis.

_More on combinators_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), [The Hopelessly Egocentric Blog Post](http://github.com/raganwald/homoiconic/tree/master/2009-02-02/hopeless_egocentricity.md#readme), [Wrapping Combinators](http://github.com/raganwald/homoiconic/tree/master/2009-06-29/wrapping_combinators.md#readme), and [Mockingbirds and Simple Recursive Combinators in Ruby](https://github.com/raganwald/homoiconic/blob/master/2011/11/mockingbirds.md#readme).

p.s. Just published: [Combinatory Logic](http://plato.stanford.edu/entries/logic-combinatory/) in the Stanford Encyclopedia of Philosophy.

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