Songs of the Cardinal
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the cardinal is one of the most basic _permuting_ combinators, it alters the normal order of evaluation.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.


[![Cirque du Northern Cardinal (c) 2008 Ehpien, some rights reserved](http://farm3.static.flickr.com/2118/2306152102_388638b008.jpg)](http://flickr.com/photos/91499534@N00/2306152102/ "Cirque du Northern Cardinal (c) 2008 Ehpien, some rights reserved")  


The cardinal is written `Cxyz = xzy`. In Ruby:

	cardinal.call(proc_over_proc).call(a_value).call(a_proc)
	  => proc_over_proc.call(a_proc).call(a_value)

What does this mean? Let's compare it to the [thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown). The thrush is written `Txy = yx`. In Ruby terms,

	thrush.call(a_value).call(a_proc)
	  => a_proc.call(a_value)
	
The salient difference is that a cardinal doesn't just pass `a_value` to `a_proc`. What it does is first passes `a_proc` to `proc_over_proc` and then passes `a_value` to the result. This implies that `proc_over_proc` is a function that takes a function as its argument and returns a function.

Or in plainer terms, you want a cardinal when you would like to modify what a function does. Now you can see why we can derive a thrush from a cardinal. If we write:

	identity = lambda { |f| f }

Then we can write:

	thrush = cardinal.call(identity)

> *Note to ornithologists and ontologists*:

> This is not object orientation: a thrush is not a kind of cardinal. The correct relationship between them in Ruby is that a cardinal creates a thrush. Or in Smullyan's songbird metaphor, if you call out the name of an identity bird to a cardinal, it will call out the name of a thrush back to you.

Now, this bizarre syntactic convention of writing `foo.call(bar).call(bash)` is not very helpful for actually writing software. It is great for explaining what's going on, but if we are going to use Ruby for the examples, we need to lift our game up a level and make some idiomatic Ruby.

Let's build a cardinal in Ruby!

Warning: There's going to be some ugly stuff here, some accidental complexity to work around the fact that Ruby 1.8 can't define a proc that takes a block and also doesn't allow `define_method` to define a method that takes a block. So for Ruby 1.8, we will start by making a utility method that defines methods that can take a block, based on [an idea from coderr](http://coderrr.wordpress.com/2008/10/29/using-define_method-with-blocks-in-ruby-18/"Using define_method with blocks in Ruby 1.8"):

	def define_method_taking_block(name, method_body_proc)
	  self.class.send :define_method, "__cardinal_helper_#{name}__", &method_body_proc
	  eval <<-EOM
	    def #{name}(a_value, &a_proc)
	      __cardinal_helper_#{name}__(a_value, a_proc)
	    end
	  EOM
	end

(Note that for Ruby 1.9 this is not necessary. With Ruby 1.9 imminent and with Rubinius looking so promising, I see working on improving this somewhat like building a vomitorium out of marble).

Now we can write our cardinal:

	def cardinal_define name, &proc_over_proc
	  define_method_taking_block(
	    name,
	    lambda { |a_value, a_proc|
	      proc_over_proc.call(a_proc).call(a_value)
	    }
	  )
	end

Ready to try it? Here's a familiar example. We'll need a `proc_over_proc`, our proc that modifies another proc. Because we're trying to be Ruby-ish, we'll write it out as a block:

	do |a_proc|
  	lambda { |a_value|
			a_proc.call(a_value) unless a_value.nil?
		}
	end

This takes a `a_proc` and returns a brand new proc that only calls `a_proc` if the value you pass it is not nil. Now let's use our cardinal to define a new method:

	cardinal_define(:maybe) do |a_proc|
  	lambda { |a_value|
			a_proc.call(a_value) unless a_value.nil?
		}
	end

Let's try it out:

	maybe(1) { |x| x + 1 }
	  => 2
	maybe(nil) { |x| x + 1 }
	  => nil

If we're using Rails, we can make a more idiomatic version of `maybe`:

	cardinal_define(:unless_blank) do |a_proc|
  	lambda { |a_value|
			a_proc.call(a_value) unless a_value.blank?
		}
	end

	unless_blank(Person.find(...).name) do |name|
		register_name_on_title(name)
	end
	
Remember we said the cardinal can be used to define a thrush? Let's try our Ruby cardinal out to do the same thing. Recall that expressing the identity bird as a block is:

	do |a_proc|
		a_proc
	end

Therefore we can define a thrush with:

	cardinal_define(:let) do |a_proc|
		a_proc
	end
	
	let((1..10).select { |n| n % 2 == 1 }.inject { |mem, var| mem + var }) do |x| 
		x * x
	end
	  => 625

As you can see, once you have a defined a cardinal, you can create an infinite variety of methods that have thrush-like syntax--a method that applies a value to a block--but you can modify or augment the _semantics_ of the block in any you want.

In Ruby terms, you are meta-programming. In Smullyan's terms, you are *Listening to the Songs of the Cardinal*.

* [cardinal.rb](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/cardinal.rb)
* [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown)

p.s. There's more to come: Next time we'll look at the role of combinatorial logic's _Queer Bird_ in constructing methods like [andand](http://andand.rubyforge.org).

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