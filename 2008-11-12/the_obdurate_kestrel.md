The Enchaining and Obdurate Kestrels
===

Wherein we look at an interesting way to implement method chaining and meet a new Ruby kestrel.

The Enchaining Kestrel
---

In [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), we looked at `#tap` from Ruby 1.9 and `returning` from Ruby on Rails. Today we're going to look at another use for `tap`.

[![Kestrel Composite (c) 2007 Mark Kilner](http://farm3.static.flickr.com/2165/1902016010_6f007bf3f0.jpg)](http://flickr.com/photos/markkilner/1902016010/ "Kestrel Composite (c) 2007 Mark Kilner")

As already explained, Ruby 1.9 includes the new method `Object#tap`. It passes the receiver to a block, then returns the receiver no matter what the block contains. The canonical example inserts some logging in the middle of a chain of method invocations:

	address = Person.find(...).tap { |p| logger.log "person #{p} found" }.address

`Object#tap` is also useful when you want to execute several method on the same object without having to create a lot of temporary variables, a practice Martin Fowler calls [Method Chaining](http://martinfowler.com/dslwip/MethodChaining.html ""). Typically, you design such an object so that it returns itself in response to every modifier message. This allows you to write things like:

	HardDrive.new.capacity(150).external.speed(7200)

Instead of:

	hd = HardDrive.new
	hd.capacity = 150
	hd.external = true
	hd.speed = 7200

And if you are a real fan of the Kestrel, you would design your class with an object initializer block so you could write:

	hd = HardDrive.new do
		@capacity = 150
		@external = true
		@speed = 7200
	end

But what do you do when handed a class that was not designed with method chaining in mind? For example, `Array#pop` returns the object being popped, not the array. Before you validate every criticism leveled against Ruby for allowing programmers to rewrite methods in core classes, consider using `#tap` with `Symbol#to_proc` or `String#to_proc` to chain methods without rewriting them.

So instead of

	def fizz(arr)
		arr.pop
		arr.map! { |n| n * 2 }
	end

We can write:

	def fizz(arr)
	  arr.tap(&:pop).map! { |n| n * 2 }
	end

I often use `#tap` to enchain methods for those pesky array methods that sometimes do what you expect and sometimes don't. My most hated example is [`Array#uniq!`](http://ruby-doc.org/core/classes/Array.html#M002238 "Class: Array"):

	arr = [1,2,3,3,4,5]
	arr.uniq, arr
		=> [1,2,3,4,5], [1,2,3,3,4,5]
	arr = [1,2,3,3,4,5]
	arr.uniq!, arr
		=> [1,2,3,4,5], [1,2,3,4,5]
	arr = [1,2,3,4,5]
	arr.uniq, arr
		=> [1,2,3,4,5], [1,2,3,4,5]
	arr = [1,2,3,4,5]
	arr.uniq!, arr
		=> nil, [1,2,3,4,5]

Let's replay that last one in slow motion:

	[  1,  2,  3,  4,  5  ].uniq!
		=> nil

That might be a problem. For example:

	[1,2,3,4,5].uniq!.sort!
		=> NoMethodError: undefined method `sort!' for nil:NilClass

`Object#tap` to the rescue: When using a method like `#uniq!` that modifies the array in place and sometimes returns the modified array but sometimes helpfully returns `nil`, I can use `#tap` to make sure I always get the array, which allows me to enchain methods:

	[1,2,3,4,5].tap(&:uniq!).sort!
		=> [1,2,3,4,5]

So there's another use for `#tap` (along with `Symbol#to_proc` for simple cases): We can use it when we want to enchain methods, but the methods do not return the receiver.

> In Ruby 1.9, `#tap` works exactly as described above. Ruby 1.8 does not have `#tap`, but you can obtain it by installing the andand gem. This version of `#tap` also works like a [quirky bird](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown ""), so you can write things like `HardDrive.new.tap.capacity(150)` for enchaining methods that take parameters and/or blocks. To get andand, `sudo gem install andand`. Rails users can also drop [andand.rb](http:andand.rb) in `config/initializers`.

The Obdurate Kestrel
---

[![Kestrel (c) 2007 The Hounds of Shadow](http://farm3.static.flickr.com/2402/2115973156_f4fcfca811.jpg)](http://flickr.com/photos/thehoundsofshadow/2115973156/ "Kestrel (c) 2007 The Hounds of Shadow")

The [andand gem](http://github.com/raganwald/andand/tree "raganwald's andand") includes `Object#tap` for Ruby 1.8. It also includes another kestrel called `#dont`. Which does what it says, or rather *doesn't* do what it says.

	:foo.tap { p 'bar' }
	bar
		=> :foo # printed 'bar' before returning a value!
		
	:foo.dont { p 'bar' }
		=> :foo # without printing 'bar'!

`Object#dont` simply ignores the block passed to it. So what is it good for? Well, remember our logging example for `#tap`?

	address = Person.find(...).tap { |p| logger.log "person #{p} found" }.address

Let's turn the logging off for a moment:

	address = Person.find(...).dont { |p| logger.log "person #{p} found" }.address
	
And back on:

	address = Person.find(...).tap { |p| logger.log "person #{p} found" }.address

I typically use it when doing certain kinds of primitive debugging. And it has another trick up its sleeve:

	arr.dont.sort!

Look at that, it works with method calls like a quirky bird! So you can use it to `NOOP` methods. Now, you could have done that with `Symbol#to_proc`:

	arr.dont(&:sort!)
	
But what about methods that take parameters and blocks?

	JoinBetweenTwoModels.dont.create!(...) do |new_join|
		# ...
	end

`Object#dont` is the Ruby-semantic equivalent of commenting out a method call, only it can be inserted inside of an existing expression. That's why it's called the *obdurate kestrel*. It refuses to do anything!

If you want to try `Object#dont`, or want to use `Object#tap` with Ruby 1.8, `sudo gem install andand`. Rails users can also drop [andand.rb](http:andand.rb) in `config/initializers` as mentioned above. Enjoy!

_More on combinators_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), [The Hopelessly Egocentric Blog Post](http://github.com/raganwald/homoiconic/tree/master/2009-02-02/hopeless_egocentricity.md#readme), [Wrapping Combinators](http://github.com/raganwald/homoiconic/tree/master/2009-06-29/wrapping_combinators.md#readme), and [Mockingbirds and Simple Recursive Combinators in Ruby](https://github.com/raganwald/homoiconic/blob/master/2011/11/mockingbirds.md#readme).

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