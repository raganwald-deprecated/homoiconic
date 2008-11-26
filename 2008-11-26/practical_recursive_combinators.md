Practical Recursive Combinators
===

THIS IS A WORK-IN-PROGRESS!

In [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md), we saw how recursive combinators like `#divide_and_conquer` and `#linear_recursion` are abstraction wins. They make recursive code much easier to read, because you know the general form of the algorithm and don't need to pick through it to discover the individual steps.

We also saw that by separating the recursion implementation from the declaration of how to perform the steps of an algorithm like `#rotate`, we leave ourselves the opportunity to improve the performance of our implementation without the risk of adding bugs to our declaration. And today we're going to do just that, along with a few tweaks for usability.

First, a little organization. Here are the [original examples](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.rb). I've placed them in a module and named the combinators `multirec` and `linrec` in conformance with common practice. And since they are also module functions, you can include them in a class or call them using `RecursiveCombinators.multirec` or `RecursiveCombinators.linrec`:

	module RecursiveCombinators

	  def multirec(value, steps)
	    if steps[:divisible?].call(value)
	      steps[:recombine].call(
	        steps[:divide].call(value).map { |sub_value| multirec(sub_value, steps) }
	      )
	    else
	      steps[:conquer].call(value)
	    end
	  end

	  def linrec(value, steps)
	    if steps[:divisible?].call(value)
	      trivial_part, sub_problem = steps[:divide].call(value)
	      steps[:recombine].call(
	        trivial_part, linrec(sub_problem, steps)
	      )
	    else
	      steps[:conquer].call(value)
	    end
	  end

	  module_function :multirec, :linrec

	end

	def merge_sort(list)
	  RecursiveCombinators.multirec(
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

	def merge_two_sorted_lists(*pair)
	  RecursiveCombinators.linrec(
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

	merge_sort([8, 3, 10, 1, 9, 5, 7, 4, 6, 2])
		=> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
		
Now these were fine for illustration, but I have a few questions for the author(!) First, note that every single time we call a method like `merge_sort`, we create four new lambdas from scratch. This seems wasteful, especially since the lambdas never change. Why create some objects just to throw them away?

Second, `linrec` ...

THIS IS A WORK-IN-PROGRESS!