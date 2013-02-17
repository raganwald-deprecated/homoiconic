Macros, Hygiene, and Call By Name in Ruby (Repost)
===

> Never send a macro to do a function's job.

Sound advice, however just because functions (or methods) are better than macros for the things they both can do, that doesn't mean functions can do everything macros can do. Let's look at `andand` for a moment. When you write:

	foo().andand.bar(blitz())

Using the [andand gem](https://github.com/raganwald/andand/tree), Ruby treats this something like:

	temp1 = foo()
	temp2 = temp1.andand
	temp3 = blitz()
	temp2.bar(temp3)

As it happens, if you call `nil.andand.bar(blitz())`, it will return `nil`. But it will still evaluate `blitz()` before returning `nil`. What I would expect from something named `andand` is that if `foo()` is nil, Ruby will never evaluate `blitz()`. Something like:

	temp1 = foo()
	if temp1.nil?
	    nil
	else
	    temp2 = blitz()
	    temp1.bar(temp2)
	end

What we want is that when we pass `blitz()` to `andand`, it is not evaluated unless the `andand` function uses it. The trouble is, you cannot write an `andand` method in Ruby that delivers these semantics.

Let's hand wave over the difference between methods and functions for a moment and just look at calling functions. We'll consider writing "our\_and," a function that emulates the short-circuit evaluation behaviour of Ruby's "&&" and "and" operators. Ruby (and most other languages in use these days) uses [call-by-value](http://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_value) when it passes parameters to functions. In other words, when you write:

	our_and(foo(), blitz())

Ruby turns that into something that looks like this:

	var temp1 = foo()
	var temp2 = blitz()
	our_and(temp1, temp2)

It doesn't matter if the function `our_and` uses `blitz()` internally or not, it is evaluated before `our_and` is called and its value is passed to `our_and`. Whereas our "if" statement in the previous example does not evaluate "blitz()" unless "foo().andand" is not nil.

Well, well, well. The inescapable conclusion is that **there are some sequences of expressions in Ruby that cannot be represented as functions or methods**. That's right, functions and methods can't do everything that Ruby code can do.

Macros and code rewriting can do an awful lot. The implementation of `andand` in the rewrite gem does rewrite code. When you write:

	with(andand) do
	    # ...
	    foo().andand.bar(blitz())
	    # ...
	end

Rewrite rewrites your code in place to look something like:

	# ...
	lambda do |__121414053598468__|
	    if __121414053598468__.nil?
	        nil
	    else
	        __121414053598468__.bar(blitz())
	    end
	end.call(foo)
	#...

And for that reason when you write `foo().andand.bar(blitz())` using the rewrite gem instead of the andand gem, `blitz()` is not evaluated if `foo()` is `nil`. Big difference!! So it looks like one way to get around call-by-value is to rewrite your Ruby code. Excellent. Or is it?

What's wrong with rewrite
---

Right now, the rewrite gem supports writing sexp processors. These are objects that encapsulate a way of transforming sexps. For example, here is the code that transforms expressions like "foo().andand.bar(blitz()):"

	def process_call(exp)
	  exp.shift
	  receiver_sexp = exp.first
	  if matches_andand_invocation(receiver_sexp)
	    exp.shift
	    mono_parameter = Rewrite.gensym()
	    s(:call, 
	      s(:iter, 
	        s(:fcall, :lambda), 
	        s(:dasgn_curr, mono_parameter), 
	        s(:if, 
	          s(:call, s(:dvar, mono_parameter), :nil?), 
	          s(:nil), 
	          begin
	            s(:call, 
	              s(:dvar, mono_parameter), 
	              *(exp.map { |inner| process_inner_expr inner })
	            )
	          ensure
	            exp.clear
	          end
	        )
	      ), 
	      :call, 
	      s(:array, 
	        process_inner_expr(receiver_sexp[1])
	      )
	    )
	  else
	    begin
	      s(:call,
	        *(exp.map { |inner| process_inner_expr inner })
	      )
	    ensure
	      exp.clear
	    end
	  end
	end

And that's just a third of andand: There is another method that handles expressions like "foo().andand { |x| x.bar(blitz()) }" and a third that handles "foo().andand(&bar_proc)." Brutal.

Now, rewriting code has many other uses. One on my wish list is a rewriter that transforms expressions like: "foo.select { |x| ... }.map { |y| ... }.inject { |z| ... }" into one big inject as an optimization. So I'm not ready to throw rewrite in the trash can just yet. But there's no way I want to be writing all that out by hand every time I want to implement a function but work around call-by-value semantics.

What about macros?
---

Why can't I write:

	def_macro our_and(x,y)
	    ((temp = x) ? (y) : (temp))
	end

...And have it automatically expand my code such that when I write:

	# ...
	foo = our_and(bar(), blitz())
	# ...

The macro expander rewrites it as:

	# ...
	foo = ((temp = bar() ? blitz() : temp)
	# ...

Wouldn't that work? Maybe. Then again, maybe not.

The problem given above--working around call-by-value--is just one small problem. A macro implementation would solve that problem, but there's an awful lot of overhead required to make the implementation work, and whatever you do ends up being an incredibly leaky abstraction.

Take our example above. What happens if we have our own variable named `temp`? Does it get clobbered by expanding `our_and`? Or do we rename `temp`? Or do some automagic jigger-pokery with scopes?

Getting macros right is very tricky. I don't personally plan to try my hand at implementing macros until I'm an expert on the subject of [variable capture](http://www.bookshelf.jp/texi/onlisp/onlisp_10.html) and can hold forth on the design trade-offs inherent in different schemes for implementing [hygienic macros](http://en.wikipedia.org/wiki/Hygienic_macro). But that's just me.

Perhaps there are other ways to solve it without diving into a full-blown macro facility?

Lambdas and blocks
---

Indeed there are other ways. Ruby already has one-and-a-half of them: blocks and lambdas. Using blocks and lambdas, you can control evaluation precisely. The andand gem actually does support short-circuit semantics using a block. When you write:

	nil.andand { |x| x.foo(blitz()) }

It does not evaluate blitz(). This alternate way of using andand supports the semantics we want by explicitly placing the code that should not be eagerly evaluated in a block. Given patience and a taste for squiggly braces, you can create non-standard evaluation without resorting to macros.

We said at the beginning that the reason we cannot use functions and methods to represent everything we can write in code is because Ruby uses call-by-value to pass parameters to functions. One way to work around that is this: instead of passing the value of each expression to a function, we can pass the expression itself, wrapped up in its own lambda.

Then, when the function needs the value, it can call the lambda. This technique has a name: it is called [thunking](http://en.wikipedia.org/wiki/Thunk).

We could implement `our_and` as follows:

	our_and = lambda { |x,y|
	    if temp = x.call
	        y.call
	    else
	        temp
	    end
	end

Then when we call it, we could wrap our parameters in lambdas:

	our_and.call(
	    lambda { a() },
	    lambda { b() }
	)

Verify for yourself that this produces the behaviour we want, without the worry of our local variables messing things up for the calling code. Let's go further: we can implement functions with a variable number of arguments using an enumeration of thunks. For example, we could write:

	def try_these(*clauses)
	    clauses.each { |clause| return clause.call rescue nil }
	    nil
	end

And call our function like this:

	try_these(
	    lambda { http_util.fetch(url, :login_as => :anonymous) },
	    lambda { http_util.fetch(url, :login_as => ['user', 'password']) },
	    lambda { default_value() }
	)

We have just implemented the [Try.these](http://www.prototypejs.org/api/utility/try-these "Prototype JavaScript framework:  Utility Methods.Try.these") function from the Prototype JavaScript library.

This technique gets us almost all of what we want for this common case of wanting to work around call-by-value semantics. As you can surmise from the fact that it has a name, it is not some newfangled shiny toy idea, it goes back to ALGOL 60, where it was known as call-by-name. (PHP has something called "Call By Name," but it has a lot more in common with C++ references than it does with ALGOL parameter passing.)

The application of call-by-name as a substitute for full-blown macros isn't novel either. Joel Klein pointed out that [Call by need is a poor man's macro](http://jfkbits.blogspot.com/2008/05/call-by-need-lambda-poor-mans-macro.html "JFKBits: Call by Need Lambda a Poor Man's Macro?"). Another suggestion along similar lines is to [rethink macros in Arc](http://arclanguage.org/item?id=7216 "Arc Forum | Rethinking macros").

Thunks: ugly name, ugly code
---

Our thunking approach solves a lot of our problems, but the implementation severely protrudes into the interface! We could argue that since our call-by-name functions have different behaviour than ordinary functions or methods, they ought to have different syntax.

That's a reasonable point of view, and that's exactly how languages like Smalltalk work: everything that involves delaying evaluation in some way uses blocks, even the if statements, which are methods that take blocks as arguments. So in Smalltalk, everything is consistent.

Ruby, OTOH, is not consistent. Operators like "&" and "|" are actually methods with call-by-value semantics, while operators like "&&" and "||" are special forms with call-by-value semantics. Likewise if you only need to delay one expression you can use a block, but if you need to delay two or more, you need at least one lambda. So another reasonable point of view is that we should follow Ruby's philosophy of making the common case easy to use and not become reductionists trying to build everything out of five axiomatic forms.

So we have one approach--rewriting--that is crazy-hard to write but produces nicely readable code. And we have another approach--thunking--that is easy to write but produces unsightly boilerplate.

Maybe what we want is a rewriter, but we want an easier way to write rewriters for this simple case?

Called by name
---

Here's how we could define and use a call-by-name function:

	with (
	    called_by_name(:our_and) { |x,y|
	        if temp = x
	            y
	        else
	            temp
	        end
	    }
	) do
	    # ...
	    foo = our_and(bar(), blitz()) # method-like syntactic sugar
	    # ...
	end

What we just did is manufacture a rewriter without any sexps. Instead of getting rid of sexps, we're treating them like assembler and using a declarative language to write the assembler for us. Our rewriter dutifully rewrites our code to look something like:

	our_and = lambda { |x,y|
	    if temp = x.call
	        y.call
	    else
	        temp
	    end
	end
	# ...
	foo = our_and.call(
	    lambda { bar() },
	    lambda { blitz() }
	)
	# ...

We can define a rewriter for functions with splatted parameters too:

	with(
	    called_by_name(:try_these) { |*clauses|
	        clauses.each { |clause| return clause rescue nil }
	        nil
	    }
	) do
	    # ...
	    try_these(
	        http_util.fetch(url, :login_as => :anonymous),
	        http_util.fetch(url, :login_as => ['user', 'password']),
	        default_value()
	    )
	    # ...
	end

Becomes something like:

	try_these = lambda { |*clauses|
	    clauses.each { |clause| return clause.call rescue nil }
	    nil
	}
	# ...
	try_these.call(
	    lambda { http_util.fetch(url, :login_as => :anonymous) },
	    lambda { http_util.fetch(url, :login_as => ['user', 'password']) },
	    lambda { default_value() }
	)
	# ...


As of now, the rewrite gem supports `called_by_name`. You can write your own functions with call-by-name semantics using `called_by_name` just as you see here. As is standard with the rewrite gem, only the code in the do... end block is affected by your change.

call-by-name, in summary
---

To summarize, with the rewrite gem you can write functions that have call-by-name semantics without wrestling sexps into submission or encumbering your code with a lot of superfluous lambdas and calls:

	with(
	    called_by_name(:try_these) { |*clauses|
	        clauses.each { |clause| return clause rescue nil }
	        nil
	    },
	    called_by_name(:our_and) { |x,y|
	        if temp = x
	            y
	        else
	            temp
	        end
	    }
	) do
	    # ...
	    try_these(
	        http_util.fetch(url, :login_as => :anonymous),
	        http_util.fetch(url, :login_as => ['user', 'password']),
	        default_value()
	    )
	    # ...
	    foo = our_and(bar(), blitz())
	    # ...
	end

This is a win when you don't want your code encumbered with more lambdas than business logic. It may be a matter of taste, but part of what I like about Ruby having a special case for blocks is that they act as a huge hint that an expression is temporary: a block after `#map` suggests we are only using that expression in one place. Whereas when I see `Proc.new` or `lambda`,"I expect that the expression will be passed around and used elsewhere.

Functions with call-by-name semantics communicate the same thing as blocks: The expressions are to be consumed by the function. When I see a lambda being passed to a function, I automatically expect it to be saved and possibly used elsewhere. For that reason, I prefer call-by-name semantics when an expression is not meant to be persisted beyond the function invocation.

Now, `called_by_name` is not a replacement for macros. There are lots of things macros can do that `called_by_name` cannot do (not to mention that there are lots of things code rewriting can do that macros cannot do). But just as Ruby's blocks are a deliberate attempt to make a common case for anonymous functions easy to write, `called_by_name` makes a common case for macros easy to write and safe from variable capture problems.

Of course, `called_by_name` does so with lots of anonymous functions, and that is a much more expensive implementation than using a hygienic macro to rewrite code inline. But it feels like a move in an interesting direction: if it is a win to sometimes meta-program Ruby's syntax with DSLs, it ought to also be a win to sometimes meta-program Ruby's semantics with call-by-name functions.

*(This material was originally published [June, 2008](http://raganwald.com/2008/06/macros-hygiene-and-call-by-name-in-ruby.html "Macros, Hygiene, and Call By Name in Ruby on raganwald.com"))*

Update (December 18, 2008)
---

I recently discovered that [rewrite](http://github.com/raganwald-deprecated/rewrite/tree "raganwald's rewrite at master &mdash; GitHub") does not work with the latest versions of [ParseTree](http://rubyforge.org/projects/parsetree/ "RubyForge: ParseTree - ruby parse tree tools: Project Info"), Ruby2Ruby and their dependencies. The underlying representation of ruby code seems to have changed. For example, there are no longer any `:dvar` nodes, just `:lvar` nodes. What fun!

I am fixing this, and my first priority is to make `called_by_name` work again.

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