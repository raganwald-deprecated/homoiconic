Template Methods, Double Mockingbirds, and Helpers
===

<font color="red">NOTE: The material from this post is being extensively revised and appears in [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme).</font>

In previous commits, we have met some of [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic)'s most interesting combinators like the [Kestrel](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown "Songs of the Cardinal"), [Quirky Bird](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown "Quirky Birds and Meta-Syntactic Programming"), and [Bluebird](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown "Aspect-Oriented Programming in Ruby using Combinator Birds"). Today we are going to learn how combinators can help us separate the general form of an algorithm like "divide and conquer" from its specific concrete steps.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.

One popular pattern in object-oriented programming is the [Template Method](http://en.wikipedia.org/wiki/Template_method_pattern "Template method pattern - Wikipedia, the free encyclopedia"):

> In object-oriented programming, first a class is created that provides the basic steps of an algorithm design. These steps are implemented using abstract methods. Later on, subclasses change the abstract methods to implement real actions. Thus the general algorithm is saved in one place but the concrete steps may be changed by the subclasses.

Template methods help us separate the basic steps of a general algorithm from the concrete steps of a specific algorithm. With a template method, we build a template or framework method with holes in it, then "fill in the blanks" by implementing methods for concrete steps.

Let's whistle up an example. The template we're going to use is called [Divide and Conquer](http://www.cs.berkeley.edu/~vazirani/algorithms/chap2.pdf). It's a general algorithm for solving problems by breaking them up into sub-problems. In Ruby, we might write:
  
	def process_list(value)
	  if divisible?(value)
	    recombine(
	      divide(value).map { |sub_value| divide_and_conquer(sub_value) }
	    )
	  else
	    conquer(value)
	  end
	end

	private

	def divisible?(value)
	  raise 'implement me'
	end

	def conquer(value)
	  raise 'implement me'
	end

	def divide(value)
	  raise 'implement me'
	end

	def recombine(list)
	  raise 'implement me'
	end

The general form of the algorithm is laid out to see. When given a value, we first check to see if it is divisible using the abstract method `#divisible?`. If it is, we use `#divide` to divide it into smaller pieces, then call `#divide_and_conquer` on the pieces. We then use `#recombine` to put the pieces back together again. If the value is not divisible, we use `#conquer` to directly compute a value.

This allows us to use various divide and conquer algorithms. It's easiest to see it in action on a problem where the data being processed closely resembles the form of the algorithm, like summing the squares of a nested list of numbers:

	def divisible?(value)
	  value.kind_of?(Enumerable)
	end

	def conquer(value)
	  value ** 2
	end

	def divide(value)
	  value
	end

	def recombine(list)
	  list.inject() { |x,y| x + y }
	end

	process_list([1, 2, 3, [[4,5], 6], [[[7]]]])
		=> 140

Or rotating a square matrix:

	def divisible?(value)
	  value.kind_of?(Enumerable) && value.size > 1
	end

	def conquer(value)
	  value
	end

	def divide(square)
	  half_sz = square.size / 2
	  sub_square = lambda do |row, col|
	    square.slice(row, half_sz).map { |a_row|a_row.slice(col, half_sz) }
	  end
	  upper_left = sub_square.call(0,0)
	  lower_left = sub_square.call(half_sz,0)
	  upper_right = sub_square.call(0,half_sz)
	  lower_right = sub_square.call(half_sz,half_sz)
	  [upper_left, lower_left, upper_right, lower_right]
	end

	def recombine(list)
	  upper_left, lower_left, upper_right, lower_right = list
	  upper_right.zip(lower_right).map { |l,r| l + r } +
	  upper_left.zip(lower_left).map { |l,r| l + r }
	end

	process_list([[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,16]])
		=> [[4, 8, 12, 16], [3, 7, 11, 15], [2, 6, 10, 14], [1, 5, 9, 13]]

Let's look at what the rotation does. The basic algorithm is this: To rotate a square matrix of size 2**n, divide the square into four smaller squares and rotate each of them. When recombining the rotated squares, move each into a new, rotated place:

	UL | UR      UR | LR
	-------  =>  -------
	LL | LR      UL | LL

The example starts with a square matrix of size 4:

	[
		[  1,  2,  3,  4], 
		[  5,  6,  7,  8], 
		[  9, 10, 11, 12], 
		[ 13, 14, 15, 16]
	]

And divides it into four smaller matrixes:

	[            [
		[  1,  2],   [  3,  4], 
		[  5,  6]    [  7,  8]
	]            ]

	[            [
		[  9, 10],   [ 11, 12], 
		[ 13, 14]    [ 15, 16]
	]            ]

Then it divides those into sixteen smaller matrices. I won't bother to show them, because each is just one number. It can't subdivide those, and rotating them is a simple identity operation, so it then starts to recombine them. And that's where the rotation takes place. Each of the squares is rotated ninety degrees counter-clockwise:

	[            [
		[  2,  6],   [  4,  8], 
		[  1,  5]    [  3,  7]
	]            ]

	[            [
		[ 10, 14],   [ 12, 16], 
		[  9, 13]    [ 11, 15]
	]            ]
	
Then the entire square is rotated:

	[            [
		[  4,  8],   [ 12, 16], 
		[  3,  7]    [ 11, 15]
	]            ]

	[            [
		[  2,  6],   [ 10, 14],
		[  1,  5]    [  9, 13]
	]

And smooshed (that is the technical term) back together:

	[
		[  4,  8,  12, 16], 
		[  3,  7,  11, 15],
		[  2,  6,  10, 14],
		[  1,  5,   9, 13]
	]

Okay, that was fun, now we completely "get" the concept of a divide and conquer algorithm. How does a template method help us?

First, when you are using polymorphism, the template method comes into its own. When you want a subclass to have slightly different semantics, you override just the concrete steps that matter for that subclass. In ActiveRecord, you can think of implementing callback methods like [`#validate`](http://api.rubyonrails.com/classes/ActiveRecord/Validations.html#M001629 "") or [`#before_save`](http://api.rubyonrails.com/classes/ActiveRecord/Callbacks.html#M001610 "") as writing concrete steps for a larger template method.

However, it is not as useful when you want to DRY up your code by separating a common algorithm like divide and conquer from several different implementations. If you happened to need rotating matrices and summing elements of nested lists in the same application, you would have to write out two different templates. To DRY it up, you might have to do some Java-esque push-ups by making a `DivideAndConquerStrategy` class.

Naturally, there's an easier way in Ruby, and once again it involves a combinator.

Double Mockingbirds
---

Almost all of the combinators we've seen so far conserve their arguments. For example, if you pass `xyz` to a bluebird, you get one `x`, one `y`, and one `z` back, exactly what you passed in. You get `x(yz)` back, so they have been grouped for you. But nothing has been added and nothing has been taken away. Likewise the thrush reverses its arguments, but again it answers back the same number arguments you passed to it.

Alone amongst the combinators we've examined, the kestrel does not conserve its arguments. It *erases* one. If you pass `xy` to a kestrel, you only get `x` back. The `y` is erased. Kestrels do not conserve their arguments. Today we are going to meet another combinator that does not conserve its arguments, the Double Mockingbird. Where a kestrel erases one of its arguments, the double mockingbird *duplicates* both of its arguments. In logic notation, `M`<sub>2</sub>`xy = xy(xy)`. Or in Ruby:

	double_mockingbird.call(x).call(y)
		=> x.call(y).call(x.call(y))

The double mockingbird is not the only combinator that duplicates one or more of its arguments. Logicians have also found important uses for many other duplicating combinators like the ordinary Mockingbird (`Mx = xx`), which is the simplest duplicating combinator, the Starling (`Sxyz = xz(yz)`), which is one half of the [SK combinator calculus](http://en.wikipedia.org/wiki/SKI_combinator_calculus "SKI combinator calculus - Wikipedia, the free encyclopedia"), and the Turing Bird (`Uxy = y(xxy)`), which is named after [its discoverer](http://www.alanturing.net/turing_archive/index.html "Alan Turing (1912-1954)").

> The great benefit of duplicative combinators from a *theoretical* perspective is that combinators that duplicate an argument can be used to introduce recursion without names, scopes, bindings, and other things that clutter things up. Being able to introduce anonymous recursion is very elegant, and [there are times when it is useful in its own right](http://www.eecs.harvard.edu/~cduan/technical/ruby/ycombinator.shtml "A Use of the Y Combinator in Ruby").

Let's write a double mockingbird in Ruby:

	m2 = lambda do |x|
	  lambda do |y|
	    x.call(y).call(x.call(y))
	  end
	end

We'll use it to sum the squares of a nested list. We're going to construct an algorithm using a divide and conquer strategy, but to keep the code clear we'll make things a little simpler than the template method example above. Instead of four separate concrete steps, we'll use just two: One to "conquer" a value if possible and another to divide the value up, recursively attempt to conquer the sub-values, and recombine them together.

Here's the first of our two steps, `conquer_if_divisible`:

	conquer_if_divisible = lambda do |value|
	  value ** 2 unless value.kind_of?(Enumerable)
	end

And here's the second of our two steps, a function that incorporates the rest of our divide and conquer strategy: `divide` and `recombine` along with some ceremony for recursion:

	conquer_or_divide_and_try_again = lambda do |conquer_if_divisible|
	  lambda do |myself|
	    lambda do |value|
	      conquer_if_divisible.call(value) or begin
	        value.map { |sub_value| myself.call(myself).call(sub_value) }.inject { |a, b| a + b }
	      end
	    end
	  end
	end

	sum_the_squares = m2.call(conquer_or_divide_and_try_again).call(conquer_if_divisible)

You can work this out one line at a time. But the result is pleasing:

	sum_the_squares.call([1, 2, 3, [[4,5], 6], [[[7]]]])
		=> 140

The double mocking bird does two things: First, because it incorporates `x.call(y)`, it allows us to break an algorithm into two separate concrete steps. Second, because it takes the resulting function and calls the function with itself, the function can call itself recursively.

There are more elegant ways to accomplish recursion, but for our purposes, the important thing is that we can accomplish it without cluttering up the namespace. The double mockingbird provides a simple way of building divide and conquer algorithms out of one function that handles division, recursion, and recombination, and another function that handles conquering.

Helpers
---

Building a recursive function like a divide and conquer algorithm is feasible with combinators, but that making it recurse anonymously adds some accidental complexity we do not need for things like summing squares or rotating matrices. But there's something there worth using on a day-to-day basis: What if instead of building a template method from the top down by specializing the concrete steps, we construct the method from the bottom up using a helper method that works like a combinator?

	def divide_and_conquer(value, steps)
	  if steps[:divisible?].call(value)
	    steps[:recombine].call(
	      steps[:divide].call(value).map { |sub_value| divide_and_conquer(sub_value, steps) }
	    )
	  else
	    steps[:conquer].call(value)
	  end
	end
	
Now you can build any method you like using it:

	def sum_squares(list)
	  divide_and_conquer(
	    list,
	    :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	    :conquer    => lambda { |value| value ** 2 },
	    :divide     => lambda { |value| value },
	    :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	  )
	end
	
	sum_squares([1, 2, 3, [[4,5], 6], [[[7]]]])
		=> 140
	
	def rotate(square)
	  divide_and_conquer(
	    square,
	    :divisible? => lambda { |value| value.kind_of?(Enumerable) && value.size > 1 },
	    :conquer => lambda { |value| value },
	    :divide => lambda do |square|
	  	  half_sz = square.size / 2
	  	  sub_square = lambda do |row, col|
	  	    square.slice(row, half_sz).map { |a_row|a_row.slice(col, half_sz) }
	  	  end
	  	  upper_left = sub_square.call(0,0)
	  	  lower_left = sub_square.call(half_sz,0)
	  	  upper_right = sub_square.call(0,half_sz)
	  	  lower_right = sub_square.call(half_sz,half_sz)
	  	  [upper_left, lower_left, upper_right, lower_right]
	    end,
	    :recombine => lambda do |list|
	  	  upper_left, lower_left, upper_right, lower_right = list
	  	  upper_right.zip(lower_right).map { |l,r| l + r } +
	  	  upper_left.zip(lower_left).map { |l,r| l + r }
	    end
	  )
	end

	rotate([[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,16]])
		=> [[4, 8, 12, 16], [3, 7, 11, 15], [2, 6, 10, 14], [1, 5, 9, 13]]

Neat-o. But all this work just to suggest using helper methods? Honestly?? Well, if you're enthusiastic about meta-programming, by all means use some of the techniques discussed in posts like [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme) so that instead of writing a `#rotate` method and calling a helper, you can write something like:
	
	def_divide_and_conquer(
		:rotate,
	  :divisible? => lambda { |value| value.kind_of?(Enumerable) && value.size > 1 },
	  :conquer => lambda { |value| value },
	  :divide => lambda do |square|
		  half_sz = square.size / 2
		  sub_square = lambda do |row, col|
		    square.slice(row, half_sz).map { |a_row|a_row.slice(col, half_sz) }
		  end
		  upper_left = sub_square.call(0,0)
		  lower_left = sub_square.call(half_sz,0)
		  upper_right = sub_square.call(0,half_sz)
		  lower_right = sub_square.call(half_sz,half_sz)
		  [upper_left, lower_left, upper_right, lower_right]
	  end,
	  :recombine => lambda do |list|
		  upper_left, lower_left, upper_right, lower_right = list
		  upper_right.zip(lower_right).map { |l,r| l + r } +
		  upper_left.zip(lower_left).map { |l,r| l + r }
	  end
	)

But if you're looking for an insight about helper methods, it's this: *Parameterizing a helper method with functions lets us re-use the general form of algorithms and specialize the concrete steps without a lot of extra inheritance baggage*.

You get another win as well: When we wrote our generic template method, we only knew it was a divide and conquer algorithm because we said it was. In an actual code base, its name would bear very little resemblance to its form, because we try to name things by what they do, not how they work. Furthermore, developers would have to deduce that it is a divide and conquer algorithm through examination and painstaking review. This is sometimes difficult with a recursive algorithm. By creating a `divide_and_conquer` helper method, we document every method that uses it, whether they be called `sum_squares` or `rotate`. And furthermore, the most difficult part to understand, the recursion mechanism, is clearly separated from the specific concrete steps. It is an example of abstraction.

Given a general-purpose algorithm like divide and conquer, both template methods and paramaterizing helper methods with functions allow us to separate the re-usable general form of the algorithm from the specific concrete steps. The template method does not give us re-use of the general form for each method sharing the same general algorithm, but it does make it easy to specialize the concrete steps in a polymorphic way. Paramaterizing a helper method with functions does allow us to abstract and re-use the same general algorithm across multiple methods but does not support specializing the concrete steps in a polymorphic way.

Have fun!

<font color="red">NOTE: The material from this post is being extensively revised and appears in [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme).</font>

*p.s. Recursive combinators are definitely found in the wild: Eugene Lazutkin's article on [Using recursion combinators in JavaScript](http://lazutkin.com/blog/2008/jun/30/using-recursion-combinators-javascript/ "") shows how to use combinators to build divide and conquer algorithms in JavaScript:*

	var fib0 = function(n){
	    return n <= 1 ? 1 :
	        arguments.callee.call(this, n - 1) +
	            arguments.callee.call(this, n - 2);
	};

	var fib1 = binrec("<= 1", "1", "[[n - 1], [n - 2]]", "+");

*`binrec` is a version of the divide and conquer general algorithm specialized to divide its argument into two values rather than an arbitrary list.*

---

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