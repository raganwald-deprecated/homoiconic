Refactoring Methods with Recursive Combinators
===

In previous commits, we have met some of [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic)'s most interesting combinators like the [Kestrel](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown "Songs of the Cardinal"), [Quirky Bird](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown "Quirky Birds and Meta-Syntactic Programming"), and [Bluebird](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown "Aspect-Oriented Programming in Ruby using Combinator Birds"). Today we are going to learn how combinators can help us separate the general form of an algorithm like "divide and conquer" from its specific concrete steps.

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.

Consider the method `#sum_squares`: It sums the squares of a tree of numbers, represented as a nested list.

	def sum_squares(value)
	  if value.kind_of?(Enumerable)
	    value.map do |sub_value|
	      sum_squares(sub_value)
	    end.inject() { |x,y| x + y }
	  else
	    value ** 2
	  end
	end

	p sum_squares([1, 2, 3, [[4,5], 6], [[[7]]]])
		=> 140

And the method `#rotate`: It rotates a square matrix, provided the length of each side is a power of two:

	def rotate(square)
	  if square.kind_of?(Enumerable) && square.size > 1
		  half_sz = square.size / 2
		  sub_square = lambda do |row, col|
		    square.slice(row, half_sz).map { |a_row| a_row.slice(col, half_sz) }
		  end
		  upper_left = rotate(sub_square.call(0,0))
		  lower_left = rotate(sub_square.call(half_sz,0))
		  upper_right = rotate(sub_square.call(0,half_sz))
		  lower_right = rotate(sub_square.call(half_sz,half_sz))
		  upper_right.zip(lower_right).map { |l,r| l + r } +
		  	upper_left.zip(lower_left).map { |l,r| l + r }
	  else
	    square
	  end
	end

	p rotate([[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,16]])
		=> [[4, 8, 12, 16], [3, 7, 11, 15], [2, 6, 10, 14], [1, 5, 9, 13]]

Our challenge is to refactor them. You could change `sub_square` from a closure to a private method (and in languages like Java, you have to do that in the first place). What else? Is there any common behaviour we can extract from these two methods?

Looking at the two methods, there are no lines of code that are so obviously identical that we could mechanically extract them into a private helper. Automatic refactoring tools fall down given these two methods. And yet, there is a really, really important refactoring that should be performed here.

Divide and Conquer
---

Both of these methods use the [Divide and Conquer](http://www.cs.berkeley.edu/~vazirani/algorithms/chap2.pdf) strategy.

As described, there are two parts to each divide and conquer algorithm. We'll start with conquer: you need a way to decide if the problem is simple enough to solve in a trivial manner, and a trivial solution. You'll also need a way to divide the problem into sub-problems if it's too complex for the trivial solution, and a way to recombine the pieces back into the solution. The entire process is carried our recursively.

For example, here's how `#rotate` rotated the square. We started with a square matrix of size 4:

	[
		[  1,  2,  3,  4], 
		[  5,  6,  7,  8], 
		[  9, 10, 11, 12], 
		[ 13, 14, 15, 16]
	]

That cannot be rotated trivially, so we divided it into four smaller sub-squares:

	[            [
		[  1,  2],   [  3,  4], 
		[  5,  6]    [  7,  8]
	]            ]

	[            [
		[  9, 10],   [ 11, 12], 
		[ 13, 14]    [ 15, 16]
	]            ]

Those couldn't be rotated trivially either, so our algorithm divide each of them into four smaller squares again, giving us sixteen squares of one number each. Those are small enough to rotate trivially (they do not change), so the algorithm could stop subdividing.

We said there was a recombination step. For `#rotate`, four sub-squares are recombined into one square by moving them counter-clockwise 90 degrees. The sixteen smallest squares were recombined into four sub-squares like this:

	[            [
		[  2,  6],   [  4,  8], 
		[  1,  5]    [  3,  7]
	]            ]

	[            [
		[ 10, 14],   [ 12, 16], 
		[  9, 13]    [ 11, 15]
	]            ]
	
Then those four squares were recombined into the final result like this:

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

And Voila! There is your rotated square matrix.

Both rotation and summing the squares of a tree combine the four steps of a divide and conquer strategy:

1.	Deciding whether the problem is divisible into smaller pieces or can be solved trivially,
1.	A solution fro the trivial case,
1.	A way to divide a non-trivial problem up,
1.	And a way to piece it back together.

Here are the two methods re-written to highlight the common strategy. First, `#sum_squares_2`:

	public
	
	def sum_squares_2(value)
	  if sum_squares_divisible?(value)
	    sum_squares_recombine(
	      sum_squares_divide(value).map { |sub_value| sum_squares_2(sub_value) }
	    )
	  else
	    sum_squares_conquer(value)
	  end
	end
	
	private

	def sum_squares_divisible?(value)
	  value.kind_of?(Enumerable)
	end

	def sum_squares_conquer(value)
	  value ** 2
	end

	def sum_squares_divide(value)
	  value
	end

	def sum_squares_recombine(values)
	  values.inject() { |x,y| x + y }
	end

And `#rotate_2`:

	public

	def rotate_2(value)
	  if rotate_divisible?(value)
	    rotate_recombine(
	      rotate_divide(value).map { |sub_value| rotate_2(sub_value) }
	    )
	  else
	    rotate_conquer(value)
	  end
	end

	private

	def rotate_divisible?(value)
	  value.kind_of?(Enumerable) && value.size > 1
	end

	def rotate_conquer(value)
	  value
	end

	def rotate_divide(value)
	  half_sz = value.size / 2
	  sub_square = lambda do |row, col|
	    value.slice(row, half_sz).map { |a_row| a_row.slice(col, half_sz) }
	  end
	  upper_left = sub_square.call(0,0)
	  lower_left = sub_square.call(half_sz,0)
	  upper_right = sub_square.call(0,half_sz)
	  lower_right = sub_square.call(half_sz,half_sz)
	  [upper_left, lower_left, upper_right, lower_right]
	end

	def rotate_recombine(values)
	  upper_left, lower_left, upper_right, lower_right = values
	  upper_right.zip(lower_right).map { |l,r| l + r } +
	  upper_left.zip(lower_left).map { |l,r| l + r }
	end

Now the common code is glaringly obvious. The main challenge in factoring it into a helper is deciding whether you want to represent methods like `#rotate_divide` as lambdas or want to fool around specifying method names as symbols. Let's go with lambdas for the sake of writing a clear example:

	public

	def sum_squares_3(list)
	  divide_and_conquer(
	    list,
	    :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	    :conquer    => lambda { |value| value ** 2 },
	    :divide     => lambda { |value| value },
	    :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	  )
	end

	def rotate_3(square)
	  divide_and_conquer(
	    square,
	    :divisible? => lambda { |value| value.kind_of?(Enumerable) && value.size > 1 },
	    :conquer => lambda { |value| value },
	    :divide => lambda do |square|
	  	  half_sz = square.size / 2
	  	  sub_square = lambda do |row, col|
	  	    square.slice(row, half_sz).map { |a_row| a_row.slice(col, half_sz) }
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

	private

	def divide_and_conquer(value, steps)
	  if steps[:divisible?].call(value)
	    steps[:recombine].call(
	      steps[:divide].call(value).map { |sub_value| divide_and_conquer(sub_value, steps) }
	    )
	  else
	    steps[:conquer].call(value)
	  end
	end

Now we have refactored the common algorithm out. Typically, something like divide and conquer is treated as a "pattern," a recipe for writing methods. We have changed it into an *abstraction* by writing a `#divide_and_conquer` method and passing it our own functions which it combines to form the final algorithm. That ought to sound familiar: `#divide_and_conquer` is a *combinator* that creates recursive methods for us.

You can also find recursive combinators in other languages like Joy, Factor, and even JavaScript (the recursive combinator presented here as `#divide_and_conquer` is normally called `multirec`). Eugene Lazutkin's article on [Using recursion combinators in JavaScript](http://lazutkin.com/blog/2008/jun/30/using-recursion-combinators-javascript/ "") shows how to use combinators to build divide and conquer algorithms in JavaScript with the Dojo libraries. This example uses `binrec`, a recursive combinator for algorithms that always divide their problems in two:

	var fib0 = function(n){
	    return n <= 1 ? 1 :
	        arguments.callee.call(this, n - 1) +
	            arguments.callee.call(this, n - 2);
	};

	var fib1 = binrec("<= 1", "1", "[[n - 1], [n - 2]]", "+");

The Merge Sort
---

Let's look at another example, implementing a [merge sort](http://en.wikipedia.org/wiki/Merge_sort "Merge sort - Wikipedia, the free encyclopedia"). This algorithm has a distinguished pedigree: It was invented by John Von Neumann in 1945. 

> Von Neumann was a brilliant and fascinating individual. he is most famous amongst Computer Scientists for formalizing the computer architecture which now bears his name. he also worked on game theory, and it was no game to him: He hoped to use math to advise the United States whether an when to launch a thermonuclear war on the USSR. If you are interested in reading more, [Prisoner's Dilemma](http://www.amazon.com/gp/product/038541580X?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=038541580X "Amazon.com: Prisoner's Dilemma: William Poundstone: Books")![amazon](http://www.assoc-amazon.com/e/ir?t=raganwald001-20&l=as2&o=1&a=038541580X) is a very fine book about both game theory and one of the great minds of modern times.

Conceptually, a merge sort works as follows:

*	If the list is of length 0 or 1, then it is already sorted.
*	Otherwise:
	1.	Divide the unsorted list into two sublists of about half the size.
	1.	Sort each sublist recursively by re-applying merge sort.
	1.	Merge the two sublists back into one sorted list.

The merge sort part will be old hat given our `#divide_and_conquer` helper:

	def merge_sort(list)
	  divide_and_conquer(
	    list,
	    :divisible? => lambda { |list| list.length > 1 },
	    :conquer    => lambda { |list| list },
	    :divide     => lambda do |list|
	      half_index = (list.length / 2) - 1
	      [ list[0..half_index], list[(half_index + 1)..-1] ]
	    end,
	    :recombine  => lambda { |pair| merge_two_sorted_lists(pair.first, pair.last) }
	  )
	end

The interesting part is our `#merge_two_sorted_lists` method. Given two sorted lists, our merge algorithm works like this:

*	If either list is of length zero, return the other list.
*	Otherwise:
	1. Compare the first item of each list using `<=>`. Let's call the list which has the "preceding" first item the preceding list and the list which has the "following" first item the following list.
	1. Create a pair of lists consisting of the preceding item and an empty list, and another pair of lists consisting of the remainder of the preceding list and the entire following list.
	1.	Merge each pair of lists recursively by applying merge two sorted lists.
	1.	Catenate the results together.

As you can tell from the description, this is another divide and conquer algorithm:

	def merge_two_sorted_lists(*pair)
	  divide_and_conquer(
	    pair,
	    :divisible? => lambda { |pair| !pair.first.empty? && !pair.last.empty? },
	    :conquer => lambda do |pair|
	      if pair.first.empty? && pair.last.empty?
	        []
	      elsif pair.first.empty?
	        pair.last
	      else
	        pair.first
	      end
	    end,
	    :divide => lambda do |pair|
	      preceding, following = case pair.first.first <=> pair.last.first
	        when -1: [pair.first, pair.last]
	        when 0:  [pair.first, pair.last]
	        when 1:  [pair.last, pair.first]
	      end
	      [
	        [[preceding.first], []],
	        [preceding[1..-1], following]
	      ]
	    end,
	    :recombine => lambda { |pair| pair.first + pair.last }
	  )
	end
	
That's great. Well, that's barely ok, actually. The problem is that when doing our merge sort, when we decide which item is the preceding item (least most, front most, whatever you want to call it), we already know that it is a trivial item and that it doesn't need any further merging. The only reason we bundle it up in `[[preceding.first], []]` is because our `#divide_and_conquer` method expects to recursively attempt to solve all of the sub-problems we generate.

In this case, `#merge_two_sorted_lists` does not really divide a problem into a list of one or more sub-problems, some of which may or may not be trivially solvable. Instead, it divides a problem into a part of the solution and a single sub-problem which may or may not be trivially solvable. This common strategy also has a name, [linear recursion](http://www.csse.monash.edu.au/~lloyd/tildeAlgDS/Recn/Linear/ "Linear Recursion").

Let's write another version of `#merge_two_sorted_lists`, but his time instead of using `#divide_and_conquer`, we'll write a linear recursion combinator:

	def merge_two_sorted_lists(*pair)
	  linear_recursion(
	    pair,
	    :divisible? => lambda { |pair| !pair.first.empty? && !pair.last.empty? },
	    :conquer => lambda do |pair|
	      if pair.first.empty? && pair.last.empty?
	        []
	      elsif pair.first.empty?
	        pair.last
	      else
	        pair.first
	      end
	    end,
	    :divide => lambda do |pair|
	      preceding, following = case pair.first.first <=> pair.last.first
	        when -1: [pair.first, pair.last]
	        when 0:  [pair.first, pair.last]
	        when 1:  [pair.last, pair.first]
	      end
	      [ preceding.first, [preceding[1..-1], following] ]
	    end,
	    :recombine => lambda { |trivial_bit, divisible_bit| [trivial_bit] + divisible_bit }
	  )
	end

	def linear_recursion(value, steps)
	  if steps[:divisible?].call(value)
	    trivial_part, sub_problem = steps[:divide].call(value)
	    steps[:recombine].call(
	      trivial_part, linear_recursion(sub_problem, steps)
	    )
	  else
	    steps[:conquer].call(value)
	  end
	end
	
You may think this is even better, and it is.

Separating Declaration from Implementation
---

Using recursive combinators like `#divide_and_conquer` and `#linear_recursion` are abstraction wins. They make recursive code much easier to read, because you know the general form of the algorithm and don't need to pick through it to discover the individual steps. But there's another benefit we should consider: *Recursive combinators separate declaration from implementation.*

Consider `#linear_recursion` again. This is *not* the fastest possible implementation. There is a long and tedious argument that arises when one programmer argues it should be implemented with iteration for performance, and the other argues it should be implemented with recursion for clarity, and a third programmer who never uses recursion claims the iterative solution is easier to understand...

Imagine a huge code base full of `#linear_recursion` and `#divide_and_conquer` calls. What happens if you decide that each one of these algorithms should be implemented with iteration? Hmmm... How about we modify `#linear_recursion` and `#divide_and_conquer`, and all of the methods that call them switch from recursion to iteration for free?

Or perhaps we decide that we really should take advantage of multiple threads... Do you see where this is going? You can write a new implementation and again, all of the existing methods are upgraded.

Even if you do not plan to change the implementation, let's face a simple fact: when writing a brand new recursive or iterative method, you really have two possible sources of bugs: you may not have declared the solution correctly, and you may not implement it correctly.

Using combinators like `#divide_and_conquer` simplifies things: You only need to get your declaration of the solution correct, the implementation is taken care of for you. This is a tremendous win when writing recursive functions.

For these reasons, I strongly encourage the use of recursion combinators, either those supplied here or ones you write for yourself.

**Update**: [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme) explains how to improve these naive implementations. Or you can just grab the [updated source code](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/recursive_combinators.rb "2008-11-26/recursive_combinators.rb") for yourself.

And a [dissenting opinion](http://leonardo-m.livejournal.com/73087.html "leonardo_m:  A recursive combinator").

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