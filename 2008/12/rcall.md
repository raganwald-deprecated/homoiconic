A Really Simple Recursive Combinator
===

In [Recursive Lambdas in Ruby using Object#tap](http://ciaranm.wordpress.com/2008/11/30/recursive-lambdas-in-ruby-using-objecttap/ ""), Ciaran McCreesh explained how he used `#tap` to write a recursive function without cluttering the scope up with an unneeded variable. (If you would like a refresher, `Object#tap` is explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme)).

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

We could use one of our existing [recursive combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme) like `linrec`:

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

And that's it, we've accomplished recursion without using any untyped lambda calculus constructs. It may look at first glance like we're using an anonymous recursive combinator like [Y](http://www.ece.uc.edu/~franco/C511/html/Scheme/ycomb.html "The Y Combinator"), but we aren't. We're actually taking advantage of Ruby's `self` variable, so `#rcall` does not really implement anonymous recursion, it just lets us write recursive lambdas without explicitly binding them to a variable.

And our new method, `#rcall`, returns a value from our recursion and doesn't force us to remember to pass our lambda to itself when making a recursive call.

Cheers!

*	[proc\_rcall.rb](http:proc_rcall.rb)

Post Scriptum
---

If you've been following along with the techniques in [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme) and [Keep Your Privates To Yourself](http://github.com/raganwald/homoiconic/tree/master/2008-12-1/keep_your_privates_to_yourself.md#readme), you may have noticed that our implementation of `#rcall` naively creates a new lambda every time it is called. There are ways to fix this. Why not fork homoiconic and optimize `Proc#rcall` for yourself? Send me a pull request when you're done!

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