Cardinals and Queer Birds
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the cardinal is one of the most basic _permuting_ combinators, it alters the normal order of evaluation. The [thrush](???) is easily derived from a cardinal and an identity bird.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.

_picture of a cardinal_

The cardinal is written `Cxyz = xzy` In Ruby:

	cardinal.call(proc_over_proc).call(a_value).call(a_proc)
	  => proc_over_proc.call(a_proc).call(a_value)

What does this mean? Let's compare it to the thrush. The thrush is written `Txy = yx`. In Ruby terms,

	thrush.call(a_value).call(a_proc)
	  => a_proc.call(a_value)
	
The salient difference is that a cardinal doesn't just pass `a_value` to `a_proc`. What it does is first passes `a_proc` to `proc_over_proc` and then passes `a_value` to the result. This implies that `proc_over_proc` is a function that takes a function as its argument and returns a function.

Or in plainer terms, you want a cardinal when you would like to modify what a function does. Now you can see why we can derive a thrush from a cardinal. If we write:

	identity = lambda { |f| f }

Then we can write:

	thrush = cardinal.call(identity)

Note to ornithologists and ontologists. This is not object orientation: a thrush is not a kind of cardinal. The correct relationship between them in this Ruby code is that a cardinal creates a thrush. Or in Smullyan's songbird metaphor, if you call out the name of an identity bird to a cardinal, it will call out the name of a thrush back to you.

What else can we do with a cardinal? How about this:

_to be continued..._