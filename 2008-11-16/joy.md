Finding Joy in Combinators
===

> For me the purpose of life is partly to have joy. Programmers often feel joy when they can concentrate on the creative side of programming, So Ruby is designed to make programmers happy.
--Yukihiro Matsumoto

In previous commits, I have written about various combinators and shared some Ruby code inspired by them. Let's take a step back for a moment and look at combinators, and from there we'll see something surprising about an entire family of programming languages, the [concatenative languages](http://en.wikipedia.org/wiki/Concatenative_programming_language "Concatenative programming language - Wikipedia, the free encyclopedia").

What is a combinator?
---

[![Double-barred Finches (c) 2008 aaardvaark, some rights reserved](http://farm2.static.flickr.com/1341/1353993093_57128dd3ab.jpg)](http://flickr.com/photos/ozjulian/1353993093// "Double-barred Finches (c) 2008 aaardvaark, some rights reserved")  

One definition of a combinator is *a function with no free variables*. Another way to put it is that a combinator is a function that takes one or more arguments and produces a result without introducing anything new. In Ruby terms, we are talking about blocks, lambdas or methods that do not call anything except what has been passed in.

So if I tell you that:

	finch.call(a).call(b).call(c)
		=> c.call(b).call(a)

Then you know that `finch` is a combinator because the effect it produces is made up solely of combining the effects of the things it takes as parameters.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.  

Easy, and yet... Where is our vaunted simplicity? Working with lambdas and braces and calls gets in the way. Combinatorial logicians use a much simpler syntax:

	Fabc => abc

That's it! Whenever you write `abc`, you mean `a.call(b).call(c)`. Note that like Ruby, precedence is to the left, so `a.call(b).call(c)` is equivalent to `(a.call(b)).call(c)`.

This is much simpler. And much easier to work with. Here's another look at the combinators we've met in this series:

	Kxy => x
	Txy => yx
	Cxyz => xzy
	Q3xyz => z(xy) # Q3 is shorthand for the Quirky bird
	Bxyz = x(yz)
	Qxyz = y(xz) # Q is shorthand for the Queer bird

There are many, many more. Infinitely more, in fact. We only have names for some of the most useful. For example, the Warbler Twice Removed, or `W**` is written:

	W**xyzw => xyzww

(Warblers are actually in a whole 'nother family of birds that introduce *duplication*. Other members of that family include the Mockingbird and Starling. They're incredibly useful for introducing ideas like iteration and recursion.)

You could say that combinators take a string of symbols (like x, y, z, w, and so forth), then they introduce some erasing, some duplication, some permutation, and add some parentheses. That they work to rearrange our string of symbols.

We have seen that parentheses are allowed, and that some combinators introduce parentheses. Before you say that the combinators introduce new symbols, remember that parentheses are *punctuation*. If you think of the symbols as words and the parentheses as punctuation, you see that the combinators simply rearrange the words and change the punctuation without introducing new words.

Now I said that combinators work with strings of symbols. This was a terrible analogy, because it made us talk about punctuation and why parentheses are not symbols. Another thing you could say is that combinator work with *lists* of symbols, then they re-arrange the symbols, including removing symbols, introducing sub-lists, and duplicating symbols.

This is more interesting! Now we can see that in our notation, adding parentheses is a way of introducing a sub list. Let's revisit the bluebird:

	Bxyz = x(yz)

Now what we can say is this: The bluebird takes a list of three symbols and answers a list of one symbol and a sublist of two symbols. In Ruby:

	def bluebird = lambda { |*args|
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

	mockingbird :x
		=> :x :x

and:

	bluebird :x :y :z
		=> :x [:y :z]

and:

	thrush :x :y
		=> :y :x

Wait! Do not shout Lisp! Just because we have lists of things does not mean we are programming in Lisp!! Let's keep going, and you will see in the next example that I do not mean Lisp:

	bluebird thrush :x :y :z
		=> thrush [:x :y] :z
		=> :z [:x :y]

And therefore in our fictitious language we can write:

	quirky = bluebird thrush

This looks familiar. Have you ever written a program in [Postscript](http://en.wikipedia.org/wiki/PostScript "PostScript - Wikipedia, the free encyclopedia")? Or [Forth](http://en.wikipedia.org/wiki/Forth_(programming_language)? What if instead of using a thrush we used a word called `swap`? Or instead of a mockingbird we used a word called `dup`?

Concatenative (or stack-based) programming languages--like Postscript, Forth, [Factor](http://www.factorcode.org/ "Factor programming language"), and [Joy](http://www.latrobe.edu.au/philosophy/phimvt/joy/j00ovr.htmll)--are almost direct representations of combinatorial logic. There is a list of things, words or combinators permute the list of things, and the things can be anything: data, other combinators, or even programs. These languages care called concatenative languages because the primary way to compose programs and combinators with each other is to concatenate them together, like we did with the bluebird and thrush above.

You have probably heard that it is a good idea to learn a new programming language every year. Is a concatenative language on your list of languages to learn? No? Well, here is the reason to learn a concatenative language: *You will learn to think using combinatorial logic*. For example, the Y Combinator is expressed in Joy as:

	[dup cons] swap concat dup cons i
	
Where `dup` is a mockingbird, `swap` is a thrush, `i` is an idiot bird, and `cons` and `concat` are likewise two other combinators. Writing in Joy is writing directly in combinators.

In other programming languages, combinatorial logic is an underpinning. It helps us explain and prove certain things, It inspires us to invent certain things. It is behind everything we do. That's good. But in a concatenative language, it is not an underpinning or behind a curtain. It is right out there in front of you. And learning to program in a concatenative language means learning to think in combinators.

What's next?
---
	
[![Hooded Warbler (c) 2008 birdfreak.com, some rights reserved](http://farm3.static.flickr.com/2095/2490084287_06e4ac8380_d.jpg)](http://flickr.com/photos/birdfreak/2490084287/ "Hooded Warbler (c) 2008 birdfreak.com, some rights reserved")  

The combinators we've discussed in depth so far are all fascinating, however as a basis for writing programs they are incomplete. You cannot represent every possible program using kestrels, thrushes, cardinals, quirky birds, bluebirds, and queer birds. To represent all possible programs, we need to have at least one combinator that duplicates symbols, like a mockingbird or another from its family.

If you are interested in the ideas behind complete sets of combinators, I can't recommend [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422) too highly. There you will find explanations of why using B,T, M, and I as a basis (bluebirds, thrushes, mockingbirds, and idiots) is equivalent to using B, C, W and I (bluebirds, cardinals, warblers, and idiots), and of course why S and K (starlings and kestrels) make for the smallest possible basis.

In an upcoming post, we'll look at duplicative birds and we'll look at a very practical example of a recursive combinator taken from Joy.

_Our aviary so far_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown), and [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md). And an observation: [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md)

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub")
	
Subscribe here to [a constant stream of updates](http://github.com/feeds/raganwald/commits/homoiconic/master "Recent Commits to homoiconic"), or subscribe here to [new posts and daily links only](http://feeds.feedburner.com/raganwald "raganwald's rss feed").

<a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>