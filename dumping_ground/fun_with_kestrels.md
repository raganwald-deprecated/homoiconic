In [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), we looked at `#tap` from Ruby 1.9 and `returning` from Ruby on Rails. Here are a few more tips for working with kestrels in Ruby.

**tap**

As already explained, Ruby 1.9 includes the new method `Object#tap`. It passes the receiver to a block, then returns the receiver no matter what the block contains. The canonical example inserts some logging in the middle of a chain of method invocations:

	address = Person.find(...).tap { |p| logger.log "person #{p} found" }.address

Tap is also useful when you want to execute several method on the same object but the methods inconveniently return something other than the receiver. This is especially handy when combined either with `Symbol#to_proc` or `String#to_proc`. For example, `Array#pop` returns the object being popped, not the array. So instead of:

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

When using a method like `#uniq!` that modifies the array in place and sometimes returns the modified array but sometimes helpfully returns `nil`, I can use `#tap` to make sure I always get the array: