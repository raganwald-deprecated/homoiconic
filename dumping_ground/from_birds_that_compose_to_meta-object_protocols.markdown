From Birds that Compose to Meta-Object Protocols
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the bluebird is one of the most important and fundamental combinators, because the bluebird *composes* two other combinators. Almost all of the reasoning we can do about programs is based on the axiom that if `x` and `y` are meaningful operations, the composition of `x` and `y` is also meaningful. The existence of a bluebird guarantees this axiom.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.


[![happy pride (c) 2008 penguincakes, some rights reserved reserved](http://farm4.static.flickr.com/3035/2891197379_556f528536.jpg)](http://www.flickr.com/photos/penguincakes/2891197379/ "happy pride (c) 2008 penguincakes, some rights reserved")  

The bluebird is written `Bxyz = x(yz)`. In Ruby, we could express the Bluebird like this:

	bluebird.call(proc1).call(proc2).call(value)
		=> proc1.call(proc2.call(value))

This seems a little arcane if you do not habitually work at a higher abstraction, if you do not think in terms of composing lambdas and procs. So let's stop being so pseudo-intellectual and consider a simple Ruby expression `(x * 2) + 1`.

This expression composes multiplication and addition. Composition is so pervasive in programming languages that it becomes part of the syntax, something we take for granted. We don't have to think about it until someone like Oliver Steele writes a library like [functional javascript](???) that introduces a _compose_ function, then we have to ask what it does.

Before we start using bluebirds, let's be clear about something. We wrote that `bluebird.call(proc1).call(proc2).call(value)` is equivalent to `proc1.call(proc2.call(value))`. We want to be very careful that we understand what is special about `proc1.call(proc2.call(value))`. How is it different from `proc1.call(proc2).call(value)`?

The answer is:

	proc1.call(proc2.call(value))
		=> puts value into proc2, then puts the result of that into proc1
	
	proc1.call(proc2).call(value)
		=> puts proc2 into proc1, then puts value into the result of that.
	
So with a bluebird you can chain functions together in series, while if you didn't have a bluebird all you could do is write functions that transform other functions. Not that there's anything wrong with that, we used that to great effect with [cardinals](???) and [quirky birds](???).

**meta-object protocols**

A meta-object protocol or MOP is a fancy word for the way objects and classes work together in an object-oriented program. In some languages, like Java and Ruby, the MOP is built in. You can layer a few 
	

**so what have we learned?**



* [blank_slate.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/blank_slate.rb "")
* [returning.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/returning.rb "")
* [quirky_bird.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_bird.rb "")
* [quirky_songs.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_songs.rb "")

_Our aviary so far_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown), and [From Birds that Compose to Meta-Object Protocols](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_meta-object_protocols.markdown).

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub") <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a><script src="http://feeds.feedburner.com/~s/raganwald?i=http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown" type="text/javascript" charset="utf-8"></script>
		<script language="JavaScript" type="text/javascript" src="http://pub44.bravenet.com/counter/code.php?id=382140&usernum=3754613835&cpv=2">
		</script>
		<script type="text/javascript" src="http://www.assoc-amazon.com/s/link-enhancer?tag=raganwald001-20">
		</script>
		<noscript>
			<img src="http://www.assoc-amazon.com/s/noscript?tag=raganwald001-20" alt="" />
		</noscript>
	</div>