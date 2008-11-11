The obdurate kestrel
---

In [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), we looked at `#tap` from Ruby 1.9. Before we get to an amusing variation of `Object#tap`, here's a brief review of `#tap` along with a trick I've found useful.

**using #tap with Symbol#to\_proc**

As already explained, Ruby 1.9 includes the new method `Object#tap`. It passes the receiver to a block, then returns the receiver no matter what the block contains. The canonical example inserts some logging in the middle of a chain of method invocations:

	address = Person.find(...).tap { |p| logger.log "person #{p} found" }.address

`Object#tap` is also useful when you want to execute several method on the same object but the methods inconveniently return something other than the receiver. This is especially handy when combined either with `Symbol#to_proc` or `String#to_proc`. For example, `Array#pop` returns the object being popped, not the array. So instead of:

	def fizz(arr)
		arr.pop
		arr.map { |n| n * 2 }
	end

We can write:

	def fizz(arr)
	  arr.tap(&:pop).map { |n| n * 2 }
	end

I often use this in production code with array methods that sometimes do what you expect and sometimes don't. My most hated example is [`Array#uniq!`](http://ruby-doc.org/core/classes/Array.html#M002238 "Class: Array"):

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

	[1,2,3,4,5].uniq!
		=> nil

That might be a problem. For example:

	[1,2,3,4,5].uniq!.sort!
		=> NoMethodError: undefined method `sort!' for nil:NilClass

`Object#tap` to the rescue: When using a method like `#uniq!` that modifies the array in place and sometimes returns the modified array but sometimes helpfully returns `nil`, I can use `#tap` to make sure I always get the array:

	[1,2,3,4,5].tap(&:uniq!)
		=> [1,2,3,4,5]
	[1,2,3,4,5].tap(&:uniq!).sort!
		=> [1,2,3,4,5]

So that's the tip: Use `Object#tap` (along with `Symbol#to_proc` for simple cases) when you want to chain several methods to a receiver, but the methods do not return the receiver.

**the obdurate kestrel**

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

If you want to try `Object#dont`, or want to use `Object#tap` with Ruby 1.8, `sudo gem install andand`. Enjoy!

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub")
	
Subscribe here to [a constant stream of updates](http://github.com/feeds/raganwald/commits/homoiconic/master "Recent Commits to homoiconic"), or subscribe here to [new posts and daily links only](http://feeds.feedburner.com/raganwald "raganwald's rss feed").

<a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>