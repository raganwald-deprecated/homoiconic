The Thrush
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the thrush is an extremely simple _permuting_ combinator; it reverses the normal order of evaluation.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.  


[![Spotted Laughing Thrush (c) 2008 Jim Frazee, some rights reserved](http://farm4.static.flickr.com/3064/2639231972_261d092e5a.jpg)](http://flickr.com/photos/12530381@N07/2639231972/ "Spotted Laughing Thrush (c) 2008 Jim Frazee, some rights reserved")  
  

The thrush is written `Txy = yx`. It _reverses_ evaluation. In Ruby terms,

	thrush.call(a_value).call(a_proc)
	  => a_proc.call(a_value)

In [No Detail Too Small](http://raganwald.com/2008/01/no-detail-too-small.html), I defined `Object#into`, an implementation of the thrush as a Ruby method:

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

`Object#into` defines the thrush as a method that takes a block, lambda, or anything that can become a block or lambda as its argument. There is another way to formulate a Thrush:

	class Kernel
	  def let it
	    yield it
	  end
	end

It's remarkably simple, so simple that it appears to be less useful than `#into`. The example above would look like this if we used `let`:

	let (1..100).select(&:odd?).inject(&:+) do |x| 
		x * x
	end

How does that help? I'll let you in on a secret: Ruby 1.9 changes the game. In Ruby 1.8, `x` is local to the surrounding method, so it doesn't help. But in Ruby 1.9, `x` is a *block local variable*, meaning that it does not clobber an existing variable. So in Ruby 1.8:

	def say_the_square_of_the_sum_of_the_odd_numbers(x)
		sotos = let (1..x).select(&:odd?).inject(&:+) do |x| 
			x * x
		end
		"The square of the sum of the odd numbers from 1..#{x} is #{sotos}"
	end
	
	say_the_square_of_the_sum_of_the_odd_numbers(10)
	 => "The square of the sum of the odd numbers from 1..25 is 625"
	
`1..25`!? What happened here is that the `x` inside the block clobbered the value of the `x` parameter. Not good. In Ruby 1.9:

	say_the_square_of_the_sum_of_the_odd_numbers(10)
	 => "The square of the sum of the odd numbers from 1..10 is 625"

Much better, Ruby 1.9 creates a new scope inside the block and `x` is local to that block, _shadowing_ the `x` parameter. Now we see a use for `let`:

	let(some_expression) do |my_block_local_variable|
		# ...
	end

`let` creates a new scope and defines your block local variable inside the block. This [signals](http://raganwald.com/2007/11/programming-conventions-as-signals.html "Programming conventions as signals") that the block local variable is not used elsewhere. Imperative methods can be easier to understand when they are composed of smaller blocks with well-defined dependencies between them. A variable local to the entire method creates a dependency across the entire method. A variable local to a block only creates dependencies within that block.

Although Ruby 1.8 does not enforce this behaviour, it can be useful to write code in this style as a signal to make the code easier to read.

**summary**

We have seen two formulations of the thrush combinator, `#into` and `let`. One is useful for making expressions more consistent and easier to read, the other for signaling the scope of block-local variables.

* [into.rb](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/into.rb)
* [let.rb](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/let.rb)

If you are using Rails, drop these in config/initializers to make them available in your project. `let` is also available as part of the [ick](http://ick.rubyforge.org/) gem, along with a more powerful variation, `lets`. To get it, simply `sudo gem install ick`.

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