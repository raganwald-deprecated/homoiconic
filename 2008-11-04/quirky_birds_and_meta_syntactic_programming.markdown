Quirky Birds and Meta-Syntactic Programming
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the Queer Birds are a family of combinators which both parenthesize and permute. One member of the family, the *Quirky Bird*, has interesting implications for Ruby.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.


[![Crazy Birds (c) 2008 Ross Lauderdale, some rights reserved](http://farm4.static.flickr.com/3164/2394551333_f0d5ce2e35.jpg)](http://www.flickr.com/photos/rosslauderdale/2394551333/ "Crazy Birds (c) 2008 Ross Lauderdale, some rights reserved")  


The quirky bird is written `Q`<sub>`3`</sub>`xyz = z(xy)`. In Ruby:

	quirky.call(value_proc).call(a_value).call(a_proc)
	  => a_proc.call(value_proc.call(a_value))
	
Like the [cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/cardinal.rb "Songs of the Cardinal"), the quirky bird reverses the order of application. But where the cardinal modifies the function that is applied to a value, the quirky bird modifies the value itself. Let's compare how cardinals and quirky birds work.

**a cardinals refresher**

The cardinal is defined in its simplest Ruby form as:

	cardinal.call(proc_over_proc).call(a_value).call(a_proc)
	  => proc_over_proc.call(a_proc).call(a_value)
	
From that definition, we wrote a method called `cardinal_define` that writes methods in idiomatic Ruby. For example, here's how we used `cardinal_define` to generate the `maybe` method:

	cardinal_define(:maybe) do |a_proc|
	  lambda { |a_value|
	    a_proc.call(a_value) unless a_value.nil?
	  }
	end

	maybe(1) { |x| x + 1 }
	  => 2
	maybe(nil) { |x| x + 1 }
	  => nil

Now we are not looking at the source code for `maybe`, but from the definition of a cardinal above we know that any method defined by `cardinal_define` will look roughly like:

	def defined_by_a_cardinal(a_value, &a_proc)
		proc_over_proc.call(a_proc).call(a_value)
	end

Or in our case:

	def maybe(a_value, &a_proc)
		lambda do |a_proc|
		  lambda { |a_value|
		    a_proc.call(a_value) unless a_value.nil?
		  }
		end.call(a_proc).call(a_value)
	end

**and now to the quirky bird**

From the definition for the quirky bird, we expect that if we write `quirky_bird_define`, the methods it generates will look roughly like:

	def defined_by_a_quirky_bird(a_value, &a_proc)
		a_proc.call(value_proc.call(a_value))
	end

So, are we ready to write `quirky_bird_define`? This seems too easy. Just copy the `cardinal_define` code, make a few changes, and we're done:

	def quirky_bird_define(name, &value_proc)
	  define_method_taking_block(name) do |a_value, a_proc|
	    a_proc.call(value_proc.call(a_value))
	  end
	end

	# method_body_proc should expect (a_value, a_proc)
	# see http://coderrr.wordpress.com/2008/10/29/using-define_method-with-blocks-in-ruby-18/
	def define_method_taking_block(name, &method_body_proc)
	  self.class.send :define_method, "__quirky_bird_helper_#{name}__", method_body_proc
	  eval <<-EOM
	    def #{name}(a_value, &a_proc)
	      __quirky_bird_helper_#{name}__(a_value, a_proc)
	    end
	  EOM
	end

Ok, let's try it out on something really trivial:

	quirky_bird_define(:square_first) do |a_value|
		a value * a_value
	end
	
	square_first(1) { |n| n + 1 }
		=> 2
	
	square_first(2) { |n| n + 1 }
		=> 5
	
It works, good. Now let's define `maybe` using the quirky bird we just wrote. Just so we're clear, I want to write:

	quirky_bird_define(:maybe) do |a_value|
		# ... something goes here ...
	end
	
	maybe(1) { |n| n + 1 }
		=> 2
	
	maybe(nil) { |n| n + 1 }
		=> nil

Scheisse! Figuring out what to put in the block to make `maybe` work is indeed queer and quirky!!

Now, the simple truth is, I know of no way to use a quirky bird to cover all of the possible blocks you could use with `maybe` so that it works exactly like the version of `maybe` we built with a cardinal. However, I have found that sometimes it is interesting to push an incomplete idea along if it is incomplete in interesting ways. "Maybe" we can learn something in the process.

**a limited interpretation of the quirky bird in Ruby**

Let's solve `maybe` any-which-way-we-can and see how it goes. When we used a cardinal, we wanted a proc that would modify another proc to such that if it was passed `nil`, it would answer `nil` without evaluating its contents.

Now we want to modify a value such that if it is `nil`, it responds `nil` to the method `+`. This is doable, with the help of the `BlankSlate` class, also called a `BasicObject`. You'll find `BlankSlate` and `BasicObject` classes in various frameworks and Ruby 1.9, and there's one at [blank\_slate.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/blank_slate.rb "2008-11-04/blank_slate.rb at master from raganwald's homoiconic &mdash; GitHub") you can use.

`BlankSlate` is a class with no methods, which is very different from the base class `Object`. That's because `Object` in Ruby is *heavyweight*, it has lots of useful stuff.  But we don't want useful stuff, because our mission is to answer a value that responds `nil` to any method you send it.

The Ruby way to handle any method is with `method_missing`. Here's a really simple expression that answers an object that responds `nil` to any method:

    returning(BlankSlate.new) do |it|
      def it.method_missing(*args)
        nil
      end
    end

Hmmm. What about:

	quirky_bird_define(:maybe) do |value|
	  if value.nil?
	    returning(BlankSlate.new) do |it|
	      def it.method_missing(*args)
	        nil
	      end
	    end
	  else
	    value
	  end
	end

This is saying, "Let's define a quirky bird method based on a `value_proc` as usual. Our `value_proc` will take a value, and if the value is `nil` we will return an object that responds with `nil` to any method. But if the value is not nil, our `value_proc` will respond with the object."

Let's try it:
	
	maybe(1) { |n| n + 1 }
		=> 2
	
	maybe(nil) { |n| n + 1 }
		=> nil

Now, I admit this is *very* flawed:

	maybe(nil) { |n| n + 1 + 1 }
  		=> NoMethodError: undefined method `+' for nil:NilClass

	maybe(nil) { |n| 1 + n }
  		=> TypeError: coerce must return [x, y]

The basic problem here is that we only control the value we pass in. We cant modify how other objects respond to it, nor can we control what happens to any objects we return from methods called on it. So, the quirky bird turns out to be useful in the case where (a) the value is the receiver of a method, and (b) there is only one method being called, not a chain of methods.

Hmmm again.

**embracing the quirky bird's nature**

Maybe we shouldn't be generating methods that deal with arbitrary blocks and procedures. One way to scale this down is to deal only with single method invocations. For example, what if instead of designing our new version of `maybe` so that we invoke it by writing `maybe(nil) { |n| n + 1 }` or `maybe(1) { |n| n + 1 }`, we design it so that we write `nil.maybe + 1` or `1.maybe + 1` instead?

In that case, `maybe` becomes a method on the object class that applies `value_proc` to its receiver rather than being a method that takes a value and a block. Getting down to business, we are going to open the core `Object` class and add a new method to it. The body of that method will be our `value_proc`:

	def quirky_bird_extend(name, &value_proc)
	  Object.send(:define_method, name) do
	    value_proc.call(self)
	  end
	end

Just as we said, we are defining a new method in the `Object` class.

> We are using `define_method` and a block rather than the `def` keyword. The reason is that when we use `define_method` and a block, the body of the method executes in the context of the block, not the context of the object itself. Blocks are closures in Ruby, which means that the block has access to `value_proc`, the parameter from our `quirky_bird_extend` method. 

> Had we used `def`, Ruby would try to evaluate `value_proc` in the context of the object itself. So our parameter would be lost forever. Performance wonks and compiler junkies will be interested in this behaviour, as it has very serious implications for garbage collection and memory leaks.

Now let's use it with exactly the same block we used with `quirky_bird_define`:

	require 'quirky_bird'
	require 'blank_slate'
	require 'returning'

	quirky_bird_extend(:maybe) do |value|
	  if value.nil?
	    returning(BlankSlate.new) do |it|
	      def it.method_missing(*args)
	        nil
	      end
	    end
	  else
	    value
	  end
	end
	
	nil.maybe + 1
	  => nil

	1.maybe + 1
	  => 2

It works. And it looks familiar! We have defined our own version of [andand](http://github.com/raganwald/andand/tree "sudo gem install andand"), only this is much more **interesting**. Instead of a one-off handy-dandy, we have created a method that creates similar methods.

Let's try it again, this time emulating Chris Wanstrath's [try](http://ozmm.org/posts/try.html):

	quirky_bird_extend(:try) do |value|
	  returning(BlankSlate.new) do |it|
	    def it.__value__=(arg)
	       @value = arg
	    end
	    def it.method_missing(name, *args)
	      if @value.respond_to?(name)
	        @value.send(name, *args)
	      end
	    end
	    it.__value__ = value
	  end
	end
	
	nil.try + 1
	  => nil

	1.try + 1
	  => 2

	1.try.ordinalize
	  => nil

As you can see, we can used the quirky bird to create a whole family of methods that modify the receiver in some way to produce new semantics. I can't show you the source code, but here is something from a proprietary Rails application:

	Account.without_requiring_authorization.create!(...)
	
In this case, `without_requiring_authorization` follows the quirky bird pattern, only instead of taking an instance and producing a version that handles certain methods specially, this one takes a class and produces a version that doesn't enforce authorization for use in test cases.

**so what have we learned?**

The quirky bird is superficially similar to the cardinal, however it can be used to generate syntax that is a little more method-oriented rather than function-oriented. And what's better than a handy method like andand? A method for defining such methods, of course.

* [blank_slate.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/blank_slate.rb "")
* [returning.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/returning.rb "")
* [quirky_bird.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_bird.rb "")
* [quirky_songs.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_songs.rb "")

_More on combinators_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), [The Hopelessly Egocentric Blog Post](http://github.com/raganwald/homoiconic/tree/master/2009-02-02/hopeless_egocentricity.md#readme), [Wrapping Combinators](http://github.com/raganwald/homoiconic/tree/master/2009-06-29/wrapping_combinators.md#readme), and [Mockingbirds and Simple Recursive Combinators in Ruby](https://github.com/raganwald/homoiconic/blob/master/2011/11/mockingbirds.md#readme). By the way, did anybody spot the [Kestrel]((http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme) in today's post?

p.s. Please vote for this post on [ruby.reddit.com](http://www.reddit.com/r/ruby/comments/7bhsh/quirky_birds_and_metasyntactic_programming/) and [hacker news](http://news.ycombinator.com/item?id=354660)!

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