A Really Simple Recursive Combinator
===

In [Recursive Lambdas in Ruby using Object#tap](http://ciaranm.wordpress.com/2008/11/30/recursive-lambdas-in-ruby-using-objecttap/ ""), Ciaran McCreesh explained how he used `#tap` to write a recursive function without cluttering the scope up with an unneeded variable. (If you would like a refresher, `Object#tap` is explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown)).

Ciaran's final solution was:

	lambda do | recurse, spec |
		case spec
			when AllDepSpec, ConditionalDepSpec
				spec.each { | child | recurse.call(recurse, child) }
			when SimpleURIDepSpec
				puts spec
		end
	end.tap { | r | r.call(r, id.homepage_key.value) } if id.homepage_key

There are two great things about this solution. First, Ciaran doesn't need to calculate a result, he is just performing this computation for its side-effect, `puts`. Therefore, using a kestrel like `#tap` signals that he is not interested in the result. Second, he is using an off-the-shelf component and not writing a "horrid untyped lambda calculus construct" to get the job done. Fewer moving parts is a laudable goal.

That being said, when solving other problems, this solution may not meet our needs:

*	Since it doesn't return a result, we cannot use it for functions that compute values and not just generate side effects;
*	Within the lambda, our `recurse` function must be called with itself as a parameter. This mixes the mechanics of our recursive implementation up with the semantics of what we're trying to accomplish.

If we find ourselves needing to work around these limitations, we'll need to go a bit further. Let's use a brutally trivial example, factorial. (The naive implementation of factorial is a *terrible* piece of programming, but it's simple enough that we can focus on how we're implementing recursion and not what we are computing).

We could use one of our existing [recursive combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md) like `linrec`:

	include 'string-to_proc'
	
	linrec('< 2', '1', 'n -> [n, n - 1]', '*').call(5)
		=> 120
		
	# or perhaps you prefer...
	
	linrec(
		lambda { |n| n < 2 },
		lambda { |n| 1 },
		lambda { |n| [n, n - 1] },
		lambda { |n, m| n * m }
	).call(5)
		=> 120
	
That gets us what we want without using a untyped lambda calculus construct, because it uses a combinatorial logic construct instead. But let's work something out that is closer to the spirit of Ciaran's approach. For starters, we can't use `#tap` because we need the result of the computation, so we'll imagine we have a new method, `#rcall`. Our first cut will look like this:

	class Proc
  
	  def rcall(*args)
	    call(self, *args)
	  end
  
	end

	lambda { |r, n| n < 2 ? 1 : n * r.call(r, n-1) }.rcall(5)

That solves our first problem very nicely: we can call a lambda with a value and it knows to pass itself to itself. Now what about our second problem? We are still cluttering up the inside of our function with passing itself to itself. Instead of calling `r.call(r, n-1)`, can we just call `r.call(n-1)`?

That would make our function look a lot simpler.

Well, we start with `lambda { |r, *args| ... }`. But if we are to call `r.call(n)`, we need to pass in a function like `lambda { |*args| ... }`. What does that function do? Send the message `#rcall` to our original function, of course. So we can write:

	class Proc
  
	  def rcall(*args)
	    call(lambda { |*args| self.rcall(*args) }, *args)
	  end
  
	end

	lambda { |r, n| n < 2 ? 1 : n * r.call(n-1) }.rcall(5)
		=> 120

And that's it, we've accomplished recursion without using any untyped lambda calculus constructs. It may look at first glance like we're using a recursive combinator, but we aren't. We're actually taking advantage of Ruby's `self` variable, so `#rcall` does not really implement anonymous recursion, it just lets us write recursive lambdas without explicitly binding them to a variable.

And our new method, `#rcall`, returns a value from our recursion and doesn't force us to remember to pass our lambda to itself when making a recursive call.

Cheers!

*	[proc\_rcall.rb](http:proc_rcall.rb)

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

**NEW: [Hire Reg Braithwaite!](http://reginald.braythwayt.com/RegBraithwaiteGH1208_en_US.pdf)**