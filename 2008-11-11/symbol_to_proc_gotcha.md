Symbol#to_proc gotcha
---

In Ruby on Rails and in Ruby 1.9, `Symbol#to_proc` is defined as:

	class Symbol
	  def to_proc
	    proc { |o, *a| o.send(self, *a) }
	  end
	end

Notice how it can handle more than one parameter? This can be useful when you want to write something like:

	(1..100).inject(&:+)
	  => 5050

`#inject` passes two parameters to the block, the accumulated total and each item in the enumerable. For example, that could have been written thusly:

	(1..100).inject { |acc, n| acc + n }
	  => 5050

So, the above formulation for `Symbol#to_proc` elegantly allows you to use symbols for methods that take more than one parameter. Alas, things get murky when you combine arrays with `Symbol#to_proc`. Let's write something simple:

	[ [1,2,2], [3,3,4] ].map { |a| a.uniq }
		=> [[1, 2], [3, 4]]

Cool. So let's replace it with `Symbol#to_proc`:

	[ [1,2,2], [3,3,4] ].map(&:uniq)
		=> NoMethodError: undefined method ‘uniq’ for 1:Fixnum

What just happened!?

The answer is that `Symbol#to_proc` converted `:uniq` to:

	proc { |o, *a| o.send(:uniq, *a) }

Which was then converted to a block. Essentially, our code became:

	[ [1,2,2], [3,3,4] ].map { |o, *a| o.send(:uniq, *a) }
		=> NoMethodError: undefined method ‘uniq’ for 1:Fixnum

Ruby helpfully assumes that when you pass an array as a single parameter to a method with an arity that accepts multiple parameters, you must want to deconstruct the array and send each element as a a separate parameter. n other words, you tried to call:

	proc { |o, *a| o.send(:uniq, *a) }.call(1, 2, 2)
		=> NoMethodError: undefined method ‘uniq’ for 1:Fixnum

Which is not what you want. You really wanted:

	proc { |o, *a| o.send(:uniq, *a) }.call([1, 2, 2])
		=> [1, 2]
		
And I don't know how to do that with the way `Symbol#to_proc` is currently written. You just have to live with it. Forewarned is forearmed!

**String#to_proc**

Adventurous readers may want to try [`String#to_proc`](http://weblog.raganwald.com/2007/10/stringtoproc.html "String#to_proc") instead. `String#to_proc` uses a completely different way to disambiguate methods that take one and two parameters, so you can write:

	[ [1,2,2], [3,3,4] ].map(&'.uniq')
		=> [[1, 2], [3, 4]]

As well as:

	(1..100).inject(&'+')
		=> 5050

Not to mention:

	(1..10).map(&'* 5')
		=> [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]

And even:

	(1..100).select(&'8923630195 % _ == 1')
		=> [2, 3, 6, 9, 18, 27, 29, 54, 58, 81, 87]

To use it, grab [`string_to_proc.rb`](http://github.com/raganwald/homoiconic/tree/master/2008-11-11/string_to_proc.rb ""). Rails users can place it in `config/initializers` and it will just work.

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub")
	
Subscribe here to [a constant stream of updates](http://github.com/feeds/raganwald/commits/homoiconic/master "Recent Commits to homoiconic"), or subscribe here to [new posts and daily links only](http://feeds.feedburner.com/raganwald "raganwald's rss feed").

<a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>