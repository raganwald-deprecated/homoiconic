The Thrush
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the thrush is a _permuting_ combinator, it alters the normal order of evaluation.

> As explained in [Kestrels], the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.  

The Thrush is written `Txy = yx`. It _reverses_ evaluation. In Ruby terms,

	thrush.call(a_value, a_proc)
	  => a.proc.call(a_value)

In [No Detail Too Small](http://weblog.raganwald.com/2008/01/no-detail-too-small.html), I defined `Object#into`, an implementation of the Thrush as a Ruby method:

	class Object
	  def into expr = nil
	    expr.nil? ? yield(self) : expr.to_proc.call(self)
	  end
	end

If you are in the habit of violating the [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter), you can use `#into` to make an expression read consistently from left to right. For example, this code:

	lambda { |x| x * x }.call((1..100).select(&:odd?).inject(&:+))
	
Reads "Square (take the numbers from 1 to 100, select the odd ones, and take the sum of those)." Confusing. Whereas with `#into`, you can write:

	(1..100).select(&:odd?).inject(&:+).into { |x| x * x }

Which reads "Take the numbers from 1 to 100, keep the odd ones, take the sum of those, and then answer the square of that number."

A permuting combinator like `#into` is not strictly necessary when you have parentheses or local variables. Which is kind of interesting, because it shows that if you have permuting combinators, you can model parentheses and local variables.

But we are not interested in theory. `#into` may be equivalent to what we can accomplish with other means, but it is useful to us if we feel it makes the code clearer and easier to understand. Sometimes a longer expression should be broken into multiple small expressions to make it easier to understand. Sometimes it can be reordered using tools like `#into`.

**another thrush**

`Object#into` defines the Thrush as a method that takes a block, lambda, or anything that can become a block or lambda as its argument. There is another way to formulate a Thrush:

	def let it
	  yield it
	end

It's remarkably simple, so simple that it appears to be less useful than `#into`. The example above would look like this if we used `let`:

	let (1..100).select(&:odd?).inject(&:+) do |x| 
		x * x
	end

How does that help? I'll let you in on a secret: Ruby 1.9 changes the game. In Ruby 1.8, `x` is local to the surrounding method, so it doesn't help. But in Ruby 1.9, `x` is a *block local variable*, meaning that it does not clobber an existing variable. So in Ruby 1.8:

	def say_the_sum_of_the_odd_squares(x)
		sotos = let (1..x).select(&:odd?).inject(&:+) do |x| 
			x * x
		end
		"The sum of the odd squares from 1..#{x} is #{sotos}"
	end
	
	say_the_sum_of_the_odd_squares(10)
	 => "The sum of the odd squares from 1..25 is 625"
	
`1..25`!? What happened here is that the `x` inside the block clobbered the value of the `x` parameter. Not good. In Ruby 1.9:

	say_the_sum_of_the_odd_squares(10)
	 => "The sum of the odd squares from 1..10 is 625"

Much better, Ruby 1.9 creates a new scope inside the block and `x` is local to that block, _shadowing_ the `x` parameter. Now we see a use for `let`:

	let(some_expression) do |my_block_local_variable|
		# ...
	end

`let` creates a new scope and defines your block local variable inside the block. This [signals](http://weblog.raganwald.com/2007/11/programming-conventions-as-signals.html"Programming conventions as signals") that the block local variable is not used elsewhere. Imperative methods can be easier to understand when they are composed of smaller blocks with well-defined dependencies between them. A variable local to the entire method creates a dependency across the entire method. A variable local to a block only creates dependencies within that block.

Although Ruby 1.8 does not enforce this behaviour, it can be useful to write code in this style as a signal to make the code easier to read.

**summary**

We have seen two formulations of the Thrush combinator, `#into` and `let`. One is useful for making expressions more consistent and easier to read, the other for signaling the scope of block-local variables.

* [into.rb](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/into.rb)
* [let.rb](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/let.rb)

If you are using Rails, drop these in config/initializers to make them available in your project. `let` is also available as part of the [ick](http://ick.rubyforge.org/) gem, along with a more powerful variation, `lets`.

`sudo gem install ick`