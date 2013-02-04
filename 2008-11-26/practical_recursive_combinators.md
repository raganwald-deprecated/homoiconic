Practical Recursive Combinators
===

In [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), we saw how recursive combinators like `#divide_and_conquer` and `#linear_recursion` are abstraction wins. They make recursive code much easier to read, because you know the general form of the algorithm and don't need to pick through it to discover the individual steps.

We also saw that by separating the recursion implementation from the declaration of how to perform the steps of an algorithm like `#rotate`, we leave ourselves the opportunity to improve the performance of our implementation without the risk of adding bugs to our declaration. And today we're going to do just that, along with a few tweaks for usability.

In this post, we're going to optimize our combinators' performance and make them a little easier to use with goodies like `string_to_proc`. To do that, we're going to work with closures, defining methods with `define_method`, and implement functional programming's partial application. We'll wrap up by converting `linrec` from a recursive to an iterative implementation.

First, a little organization. Here are the [original examples](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.rb). I've placed them in a module and named the combinators `multirec` and `linrec` in conformance with common practice:

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

Since they are also module functions, call them by sending a message to the module:

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

Or you can include the `RecursiveCombinators` module and call either method directly:

	include RecursiveCombinators

	def merge_two_sorted_lists(*pair)
	  linrec(
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
		
Ok, we're ready for some slightly more substantial work. These methods were fine for illustration, but I have a few questions for the author(!)

Spicing things up
---

First, note that every single time we call a method like `merge_sort`, we create four new lambdas from scratch. This seems wasteful, especially since the lambdas never change. Why create some objects just to throw them away?

On the other hand, it's nice to be able to use create algorithms without having to define a method by name. Although I probably wouldn't do a merge sort anonymously, when I need a one-off quickie, I might like to write something like:

	RecursiveCombinators.multirec(
	  [1, 2, 3, [[4,5], 6], [[[7]]]],
	  :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	  :conquer    => lambda { |value| value ** 2 },
	  :divide     => lambda { |value| value },
	  :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	)
		=> 140

But when I want a permanent sum of the squares method, I **don't** want to write:

	def sum_squares(list)
	  RecursiveCombinators.multirec(
	    list,
	    :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	    :conquer    => lambda { |value| value ** 2 },
	    :divide     => lambda { |value| value },
	    :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	  )
	end

...because that would create four lambdas every time I call the function. There are a couple of ways around this problem. First, our "recipe" for summing squares is a simple hash. We could extract that from the method into a constant:

	SUM_SQUARES_RECIPE = {
	   :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	   :conquer    => lambda { |value| value ** 2 },
	   :divide     => lambda { |value| value },
	   :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	}
	
	def sum_squares(list)
	  RecursiveCombinators.multirec(list, SUM_SQUARES_RECIPE)
	end

That (and the isomorphic solution where the constant `SUM_SQUARES_RECIPE` is instead a private helper method `#sum_squares_recipe`) is nice if you have some reason you wish to re-use the recipe elsewhere. But we don't, so this merely clutters our class up and separates the method definition from its logic.

I have something in mind. To see what it is, let's start by transforming our method definition from using the `def` keyword to using the `define_method` private class method. This obviously needs a module or class to work:

	class Practicum
  
	  include RecursiveCombinators
  
	  define_method :sum_squares do |list|
	    multirec(
	      list, 
		   :divisible? => lambda { |value| value.kind_of?(Enumerable) },
		   :conquer    => lambda { |value| value ** 2 },
		   :divide     => lambda { |value| value },
		   :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
		  )
	  end
  
	end

	Practicum.new.sum_squares([1, 2, 3, [[4,5], 6], [[[7]]]])
	
As you probably know, any method taking a block can take a lambda using the `&` operator, so:

	define_method :sum_squares, &(lambda do |list|
	  multirec(
	    list, 
	  :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	  :conquer    => lambda { |value| value ** 2 },
	  :divide     => lambda { |value| value },
	  :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	 )
	end)

This is useful, because now we can express what we want: a lambda taking one argument that in turn calls `multirec` with the other arguments filled in. Functional programmers call this [Partial Application](http://ejohn.org/blog/partial-functions-in-javascript/ "Partial Application in JavaScript"). The idea is that if you have a function or method taking two arguments, if you only give it one argument you get a function back that takes the other. So:

	multirec(x).call(y)
		=> multirec(x,y)

Now the drawback with this "standard" implementation of partial application is that we would pass a list to `multirec` and get back a function taking a hash of declarations. That isn't what we want. We could partially apply things *backwards* so that `multirec(x).call(y) => multirec(y,x)` (if Ruby was a concatenative language, we would be concatenating the multirec combinator with a thrush). The trouble with that is it is the reverse of how partial application works in every other [programming language](http://www.haskell.org/ "HaskellWiki") and [functional programming library](https://github.com/osteele/functional-javascript/tree).

Instead, we will switch the arguments to `multirec` ourselves, so it now works like this:

	multirec(
		{
			:divisible? => lambda { |value| value.kind_of?(Enumerable) },
			:conquer    => lambda { |value| value ** 2 },
			:divide     => lambda { |value| value },
			:recombine  => lambda { |list| list.inject() { |x,y| x + y } }
		},
		list
	)

The drawback with this approach is that we lose a little of Ruby's syntactic sugar, the ability to fake named parameters by passing hash arguments without `{}` if they are the last parameter. And now, let's give it the ability to partially apply itself. You can do some stuff with allowing multiple arguments and counting the number of arguments, but we're going to make the wild assumption that you never attempt a recursive combinator on `nil`. Here's `multirec`, you can infer the implementation for `linrec`:

	def multirec(steps, optional_value = nil)
	  worker_proc = lambda do |value|
	    if steps[:divisible?].call(value)
	      steps[:recombine].call(
	        steps[:divide].call(value).map { |sub_value| worker_proc.call(sub_value) }
	      )
	    else
	      steps[:conquer].call(value)
	    end
	  end
	  if optional_value.nil?
	    worker_proc
	  else
	    worker_proc.call(optional_value)
	  end
	end

Notice that you get the same correct result whether you write:

	RecursiveCombinators.multirec(
	  :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	  :conquer    => lambda { |value| value ** 2 },
	  :divide     => lambda { |value| value },
	  :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	).call([1, 2, 3, [[4,5], 6], [[[7]]]])
		=> 140

Or:

	RecursiveCombinators.multirec(
		{
		   :divisible? => lambda { |value| value.kind_of?(Enumerable) },
		   :conquer    => lambda { |value| value ** 2 },
		   :divide     => lambda { |value| value },
		   :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
		},
		[1, 2, 3, [[4,5], 6], [[[7]]]]
	)
		=> 140

Let's go back to what we were trying to do with `&`:

	define_method :sum_squares, &(lambda do |list|
	  multirec(
	    list, 
	  :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	  :conquer    => lambda { |value| value ** 2 },
	  :divide     => lambda { |value| value },
	  :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	 )
	end)

Now we know how to build our lambda:

	require 'partial_application_recursive_combinators'

	class Practicum
  
	  extend PartialApplicationRecursiveCombinators   # so we can call multirec in class scope
  
	  define_method :sum_squares, &multirec(
	   :divisible? => lambda { |value| value.kind_of?(Enumerable) },
	   :conquer    => lambda { |value| value ** 2 },
	   :divide     => lambda { |value| value },
	   :recombine  => lambda { |list| list.inject() { |x,y| x + y } }
	  )
  
	end

	Practicum.new.sum_squares([1, 2, 3, [[4,5], 6], [[[7]]]])
		=> 140

You can verify for yourself that no matter how many times you call `sum_squares`, you do not build those lambdas again. What we have just done is added partial application to `multirec` and `linrec`, which in turn allows us to ensure that he cost of constructing lambdas for our methods is only done when the method is defined, not every time it is called.

Building on a legacy
---

We have already renamed `divide_and_conquer` and `linear_recursion` to bring them into line with standard practice and other programming languages. Now it's time for us to bring the parameters--the declarative lambdas--into line with standard practice.

The four arguments to both methods are normally called `cond`, `then`, `before`, and `after`:

*	`cond` is the logical inverse of `divisible?` So if `cond(value)` evaluates to true, then we do not need to subdivide the problem.
*	`then` is exactly the same as `conquer`, *if* cond *then* then. That's the way I think of it.
*	`before` is the same as `divide`.
*	`after` is the same as `recombine`.

Things look very similar with the new scheme for now:

	require 'legacy_recursive_combinators'

	class Practicum
  
	  extend LegacyRecursiveCombinators   # so we can call multirec in class scope
  
	  define_method :sum_squares, &multirec(
	   :cond   => lambda { |value| value.kind_of?(Numeric) }, # the only change right now
	   :then   => lambda { |value| value ** 2 },
	   :before => lambda { |value| value },
	   :after  => lambda { |list| list.inject() { |x,y| x + y } }
	  )
  
	end

All right, now our combinators will look familiar to functional programmers, and even better when we look at functional programs using recursive combinators we will understand them at a glance. Okay, let's get serious and work on making our combinators easy to use and our code easy to read.

Seriously
---

As long as you're writing these lambdas out, writing `:cond =>` isn't a hardship. And in an explanatory article like this, it can help at first. However, what if you find a way to abbreviate things? For example, you might [alias `lambda` to `L`](http://github.com/gilesbowkett/archaeopteryx/tree/master "gilesbowkett's archaeopteryx"). Or you might want to use [string\_to\_proc](http:string_to_proc.rb).

So we should support passing the declarative arguments by position as well as by 'name.' And with a final twist, if any of the declarative arguments aren't already lambdas, we'll try to create lambdas by sending them the message `to_proc`. So our goal is to write what we wrote above or either of the following and have it "just work:"

	define_method :sum_squares, &multirec(
		lambda { |value| value.kind_of?(Numeric) }, # the only change right now
		lambda { |value| value ** 2 },
		lambda { |value| value },
		lambda { |list| list.inject() { |x,y| x + y } }
	)
	
	include 'string-to_proc'

	define_method :sum_squares, &multirec("value.kind_of?(Numeric)", "value ** 2","value","value.inject(&'+')")

And here is [the code that makes it work](http:recursive_combinators.rb):

	module RecursiveCombinators
  
	  separate_args = lambda do |args|
	    if ![1,2,4,5].include?(args.length)
	      raise ArgumentError
	    elsif args.length <= 2
	      steps = [:cond, :then, :before, :after].map { |k| args.first[k].to_proc }
	      steps.push(args[1]) unless args[1].nil?
	      steps
	    else
	      steps = args[0..3].map { |arg| arg.to_proc }
	      steps.push(args[4]) unless args[4].nil?
	      steps
	    end
	  end

	  define_method :multirec do |*args|
	    cond_proc, then_proc, before_proc, after_proc, optional_value = separate_args.call(args)
	    worker_proc = lambda do |value|
	      if cond_proc.call(value)
	        then_proc.call(value)
	      else
	        after_proc.call(
	          before_proc.call(value).map { |sub_value| worker_proc.call(sub_value) }
	        )
	      end
	    end
	    if optional_value.nil?
	      worker_proc
	    else
	      worker_proc.call(optional_value)
	    end
	  end

	  define_method :linrec do |*args|
	    cond_proc, then_proc, before_proc, after_proc, optional_value = separate_args.call(args)
	    worker_proc = lambda do |value|
	      if cond_proc.call(value)
	        then_proc.call(value)
	      else
	        trivial_part, sub_problem = before_proc.call(value)
	        after_proc.call(
	          trivial_part, worker_proc.call(sub_problem)
	        )
	      end
	    end
	    if optional_value.nil?
	      worker_proc
	    else
	      worker_proc.call(optional_value)
	    end
	  end

	  module_function :multirec, :linrec

	end

Now when we have trivial lambdas, we can use nice syntactic sugar to express them. `string_to_proc` is **not** part of our recursive combinators, but making recursive combinators flexible, we make it "play well with others," which is a win for our code.	

Separating Implementation from Declaration
---

In [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), we read the claim that by separating the recursion implementation from the declaration of how to perform the steps of an algorithm like `#rotate`, we leave ourselves the opportunity to improve the performance of our implementation without the risk of adding bugs to our declaration.

In other words, we can optimize `linrec` if we want to. Well, we want to. So what we're going to do is optimize its performance by trading time for space. Let's have a quick look at the `worker_proc` lambda inside of `linrec`:

	worker_proc = lambda do |value|
	  if cond_proc.call(value)
	    then_proc.call(value)
	  else
	    trivial_part, sub_problem = before_proc.call(value)
	    after_proc.call(
	      trivial_part, worker_proc.call(sub_problem)
	    )
	  end
	end

As you can see, it is recursive, it calls itself to solve each sub-problem. And here is an iterative replacement:

	worker_proc = lambda do |value|
	  trivial_parts, sub_problem = [], value
	  while !cond_proc.call(sub_problem)
	    trivial_part, sub_problem = before_proc.call(sub_problem)
	    trivial_parts.unshift(trivial_part)
	  end
	  trivial_parts.unshift(then_proc.call(sub_problem))
	  trivial_parts.inject do |recombined, trivial_part|
	    after_proc.call(trivial_part, recombined)
	  end
	end

This version doesn't call itself. Instead, it uses an old-fashioned loop, accumulating the results in an array. In a certain sense, this uses more explicit memory than the recursive implementation. However, we both know that the recursive version uses memory for its stack, so that's a bit of a wash. However, the Ruby stack is limited while arrays can be much larger, so this version can handle much larger data sets.

If you drop the new version of `worker_proc` into the `linrec` definition, each and every method you define using `linrec` gets the new implementation, for free. This works because we separated the implementation of recursive divide and conquer algorithms from the declaration of the steps each particular algorithm. Here's our new version of `linrec`:

	define_method :linrec do |*args|
	  cond_proc, then_proc, before_proc, after_proc, optional_value = separate_args.call(args)
	  worker_proc = lambda do |value|
	    trivial_parts, sub_problem = [], value
	    while !cond_proc.call(sub_problem)
	      trivial_part, sub_problem = before_proc.call(sub_problem)
	      trivial_parts.unshift(trivial_part)
	    end
	    trivial_parts.unshift(then_proc.call(sub_problem))
	    trivial_parts.inject do |recombined, trivial_part|
	      after_proc.call(trivial_part, recombined)
	    end
	  end
	  if optional_value.nil?
	    worker_proc
	  else
	    worker_proc.call(optional_value)
	  end
	end
	
Summary
---

[recursive\_combinators.rb](http:recursive_combinators.rb) contains the final, practical implementation of `multirec` and `linrec`. It's leaner and faster than the naive implementations shown in [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme). Rails users can drop it into `config/initializers` and use it in their projects.
	
p.s. In an upcoming post, we'll talk about why `multirec` and `linrec` are implemented using `define_method` instead of the `def` keyword.

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