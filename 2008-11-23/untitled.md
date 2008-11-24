What combinators teach us about refactoring methods
===

<font color="red">This is a work-in-progress</font>

Consider the method `#sum_sqaures`: It sums the squares of a tree of numbers, represented as a nested list.

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

Both of these methods use the [Divide and Conquer](http://www.cs.berkeley.edu/~vazirani/algorithms/chap2.pdf) strategy. As described, there are two parts to each divide and conquer algorithm. We'll start with conquer: you need a way to decide if the problem is simple enough to solve in a trivial manner, and a trivial solution. You'll also need a way to divide the problem into sub-problems if it's too complex for the trivial solution, and a way to recombine the pieces back into the solution. The entire process is carried our recursively.

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

Both rotation and summing the squares of a tree combine the four steps of a divide and conquer strategy: Deciding whether the problem is divisible into smaller pieces or can be solved trivially, a trivial solution, a way to divide a non-trivial problem up, and a way to piece it back together.

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

Let's look at another example, implementing a [merge sort](http://en.wikipedia.org/wiki/Merge_sort "Merge sort - Wikipedia, the free encyclopedia").

The Merge Sort
---

The merge sort algorithm has a distinguished pedigree: It was invented by John Von Neumann in 1945. 

> Von Neumann was a brilliant and fascinating individual. he is most famous amongst Computer Scientists for formalizing the computer architecture which now bears his name. he also worked on game theory, and it was no game to him: He hoped to use math to advise the United States whether an when to launch a thermonuclear war on the USSR. [Prisoner's Dilemma](http://www.amazon.com/gp/product/038541580X?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=038541580X "Amazon.com: Prisoner's Dilemma: William Poundstone: Books")![](http://www.assoc-amazon.com/e/ir?t=raganwald001-20&l=as2&o=1&a=038541580X) is a very fine book about both game theory and one of the great minds of modern times.

Conceptually, a merge sort works as follows:

1.	If the list is of length 0 or 1, then it is already sorted. Otherwise:
1.	Divide the unsorted list into two sublists of about half the size.
1.	Sort each sublist recursively by re-applying merge sort.
1.	Merge the two sublists back into one sorted list.

The merge sort part will be old hat given our `#divide_and_conquer` helper:

	public

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

The interesting part is our `#merge_two_sorted_lists` method. Given two sorted lists, oiur merge algorithm works like this:

1. If either list is of length zero, return the other list. Otherwise:
1. Compare the first item of each list using `<=>`. Take the "firstmost" of the two

Why bother?
---

First, recursive algorithms are sometimes challenging to decipher. Having a method call itself arbitrarily is something like having a GOTO. Consider the progression from GOTO to structured programming. We wanted code that could pursue alternate paths and repeat a computation. We could do that with GOTO, but it is clearer when we use things like for loops. And it is clearer still when we use Enumerable methods like `#map` or `#each`.

With recursive algorithms, when we identify a high-level abstraction like "divide and conquer," our code is much clearer than if we write methods that do the same thing through calling themselves.

My second reason for preferring the refactored version is that it separates the implementation from the specification. We could rewrite `#divide_and_conquer` to use multiple threads if we liked, and there would be no need to rewrite `#rotate_3`. The mechanics of recursing have been separated from the specifics of rotating square matrices.

Let's look some examples supporting a this second argument. In our examples above, there is an assumption that when we divide a problem into sub-problems, the subproblems might be trivial or they might need further subdivision. This general strategy handles all divide and conquer problems. For example, a merge sort:

<font color="red">This is a work-in-progress</font>
