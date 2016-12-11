You can't be serious!?
===

In [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), we enhanced `multirec` (a/k/a "Divide and Conquer") and `linrec` ("Linear Recursion") to accept as arguments any object that supports the `#to_proc` method. Today we're going demonstrate why: We will look at how removing the ceremony around lambdas makes using combinators like `multirec` more valuable for code we share with others.

Using [recursive\_combinators.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/recursive_combinators.rb) to define how to sum the squares of a nested list of numbers, we can write:

	require 'recursive_combinators'

	include RecursiveCombinators

	multirec(
	  lambda { |x| x.kind_of?(Numeric) },
	  lambda { |x| x ** 2 },
	  lambda { |x| x },
	  lambda { |x| x.inject { |sum, n| sum + n } }
	)

The trouble with this--to quote [a seasonally appropriate character](http://www.amazon.com/gp/product/B000HA4WDY?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=B000HA4WDY "Amazon.com: Dr. Seuss' How the Grinch Stole Christmas! (50th Birthday Deluxe Remastered Edition)")--is the noise, noise, Noise, NOISE! All those lambdas and parameter declarations outweigh the actual logic we are declaring, so much so that declaring this function using our abstraction is longer and may seem more obscure than declaring it without the abstraction.

This whole thing reminds me of languages where the keywords must be in UPPER CASE. Reading code in such languages is like listening to a poetry reading where the author shouts the punctuation:

> Two roads diverged in a yellow wood COMMA!  
> And sorry I could not travel both  
> And be one traveler COMMA! long I stood  
> And looked down one as far as I could  
> To where it bent in the undergrowth SEMI-COMMA!!

Finding ways to abbreviate our declaration is more than just a little "syntactic sugar:" It's a way of emphasizing what is important, our algorithms, and de-emphasizing what is not important, the scaffolding and ceremony of instantiating `Proc` objects in Ruby. One of those ways is to use [`String#to_proc`](http:string_to_proc.rb).

String#to\_proc
---

`String#to_proc` adds the `#to_proc` method to the `String` class in Ruby. This allows you to write certain simple lambdas as strings instead of using the `lambda` keyword, the `proc` keyword, or `Proc.new`. The reason why you'd bother is that `String#to_proc` provides some shortcuts that get rid of the noise.

**gives**

`String#to_proc` provides several key abbreviations: First,	`->` syntax for lambdas in Ruby 1.8. So instead of `lambda { |x,y| x + y }`, you can write `'x,y -> x + y'`. I read this out loud as "*x and y gives x plus y*." 

This syntax gets rid of the noisy `lambda` keyword and is much closer to Ruby 1.9 syntax. And frankly, reading it out loud makes much more sense than reading lambdas aloud. Our example above could be written:

	require 'string_to_proc'

	multirec(
	  'x -> x.kind_of?(Numeric)',
	  'x -> x ** 2',
	  'x -> x',
	  'x -> x.inject { |sum, n| sum + n }'
	)

This is a lot better than the version with lambdas, and if the `->` seems foreign, it is only because `->` is in keeping with modern functional languages and mathematical notation, while `lambda` is in keeping with Lisp and lambda calculus notation without the ability to use a single lambda character unicode.

**inferred parameters**

Second, `String#to_proc` adds inferred parameters: If you do not use `->`, `String#to_proc` attempts to infer the parameters. So if you write `'x + y'`, `String#to_proc` treats it as `x,y -> x + y`. There are certain expressions where this doesn't work, and you have to use `->`, but for really simple cases it works just fine. And frankly, for really simple cases you don't need the extra scaffolding. Here's our example with the first three lambdas using inferred parameters:

	multirec(
	  'x.kind_of?(Numeric)',
	  'x ** 2',
	  'x',
	  'z -> z.inject { |sum, n| sum + n }'
	)

> I have good news and bad news about inferred parameters and `String#to_proc` in general. It uses regular expressions to do its thing, which means that complicated things often don't work. For example, nesting `->` only works when writing functions that return functions. So `'x -> y -> x + y'` is a function that takes an `x` and returns a function that takes a `y` and returns `x + y`. That works. But `'z -> z.inject(&"sum, n -> sum + n")'` does NOT work.

> I considered fixing this with more sophisticated parsing, however the simple truth is this: `String#to_proc` is not a replacement for `lambda`, it's a tool to be used when what you're doing is so simple that `lambda` is overkill. If `String#to_proc` doesn't work for something, it probably isn't ridiculously simple any more.

**it**

The third abbreviation is a special case. If there is only one parameter, you can use `_` (the underscore) without naming it. This is often called the "hole" or pronounced "it." If you use "it," then `String#to_proc` doesn't try to infer any more parameters, so this can help you write things like:

	multirec(
	  '_.kind_of?(Numeric)',
	  '_ ** 2',
	  '_',
	  '_.inject { |sum, n| sum + n }'
	)	

Admittedly, use of "it"/the hole is very much a matter of taste.

**point-free**

`String#to_proc` has a fourth and even more extreme abbreviation up its sleeve, [point-free style](http://blog.plover.com/prog/haskell/ "The Universe of Discourse : Note on point-free programming style"): "Function points" are what functional programmers usually call parameters. Point-free style consists of describing how functions are composed together rather than describing what happens with their arguments. So, let's say that I want a function that combines `.inject` with `+`. One way to say that is to say that I want a new function that takes its argument and applies an `inject` to it, and the inject takes another function with two arguments and applies a `+` to them:

	lambda { |z| z.inject { |sum, n| sum + n } }
	
The other way is to say that I want to compose `.inject` and `+` together. Without getting into a `compose` function like Haskell's `.` operator, `String#to_proc` has enough magic to let us write the above as:

	".inject(&'+')"
	
Meaning "*I want a new lambda that does an inject using plus*." Point-free style does require a new way of thinking about some things, but it is a clear win for simple cases. Proof positive of this is the fact that Ruby on Rails and Ruby 1.9 have both embraced point-free style with `Symbol#to_proc`. That's exactly how [`(1..100).inject(&:+)`](http://raganwald.com/2008/02/1100inject.html "(1..100).inject(&:+)") works!

`String#to_proc` supports fairly simple cases where you are sending a message or using a binary operator. So if we wanted to go all out, we could write our example as:

	multirec('.kind_of?(Numeric)', '** 2', 'x', ".inject(&'+')")

> There's no point-free magic for the identity function, although this example tempts me to special case the empty string!

**When should we use all these tricks?**

`String#to_proc` provides these options so that you as a programmer can choose your level of ceremony around writing functions. But of course, you have to use the tool wisely. My *personal* rules of thumb are:

1.	Embrace inferred parameters for well-known mathematical or logical operations. For these operations, descriptive parameter names are usually superfluous. Follow the well-known standard and use `x`, `y`, `z`, and `w`;  or `a`, `b` and `c`; or `n`, `i`, `j`, and `k` for the parameters. If whatever it is makes no sense using those variable names, don't used inferred parameters.
1.	Embrace the hole for extremely simple one-parameter lambdas that aren't intrinsically mathematical or logical such as methods that use `.method_name` and for the identity function.
1.	Embrace point-free style for methods that look like operators.
1.	Embrace `->` notation for extremely simple cases where I want to give the parameters a descriptive name.
1.	Use lambdas for everything else.

So I would write:

	multirec( '_.kind_of?(Numeric)', '** 2', '_', "_.inject(&'+')")

I read the parameters out loud as:

*	*it kind\_of? Numeric;*
*	*raise to the power of two;*
*	*it;*
*	*it inject plus*.

And yes, I consider `multirec( '_.kind_of?(Numeric)', '** 2', '_', "_.inject(&'+')")` more succinct and easier to read than: 

	def sum_squares(value)
	  if value.kind_of?(Numeric)
	    value ** 2
	  else
	    value.map do |sub_value|
	      sum_squares(sub_value)
	    end.inject { |x,y| x + y }
	  end
	end
	
If all this is new too you, `String#to_proc` may seem like gibberish and `def sum_squares` may seem reassuringly sensible. But try to remember that combinators like `multirec` are built to disentangle the question of what we are doing from how we are doing it. This is the third straight post about recursive combinators using one of three different examples. So of course we know what `sum_squares` does and how it does it.

But try to imagine you are looking at a piece of code that isn't so simple, that isn't so obvious. Maybe it was written by someone else, maybe you wrote it a while  ago. If you see:

	def rotate(square)
	  return square unless square.kind_of?(Enumerable) && square.size > 1
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
	end

Do you see at once how it works? Do you see at a glance whether the recursive strategy was implemented properly? Can you tell whether there's something buggy about it? For example, this code only works rotating square matrices that have sides which are powers of two. What needs to be changed to fix that? Are you sure you can fix it without breaking the divide and conquer strategy?

For a method like this, I would write:

	multirec(
	  :cond => "!(_.kind_of?(Enumerable) && _.size > 1)",
	  :then => "_",
	  :before => lambda do |square|
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
	  :after => lambda do |list|
		  upper_left, lower_left, upper_right, lower_right = list
		  upper_right.zip(lower_right).map(&'+') + upper_left.zip(lower_left).map(&'+')
	  end
	end

And be assured that months from now if I wanted to support rotating rectangular matrices of arbitrary size, I could modify `:cond`, `:before`, and `:after` with confidence that the basic method was not being broken.

The Message
---

The message here is that taken by themselves, tools like recursive combinators or `String#to_proc` just look strange. But when we use them together, they reinforce each other and the sum becomes much greater than the sum of the parts. In the case of `String#to_proc`, it looks like frivolity to most Ruby programmers, because they don't use that many lambdas: Why should they when the existing syntax makes writing combinators hard to use? But when we have combinators in our hand, we see how `String#to_proc` can make them a win. So two things that look weird on their own are a useful tool when used in conjunction.

Our final example ended up being slightly longer than a naive version, however it is longer in ways that matter rather than longer in a mindless ceremonial way like some languages.

And that's the point of languages like Ruby: **You** have the tools to decide which portions of you code matter more than others, and to make the parts that matter stand out and the parts that don't go away. You may disagree with my choice of what matters for a recursive divide and conquer algorithm, but I hope we can agree that it's valuable to be able to make that choice for yourself or your team.

Seriously.

---

* [recursive\_combinators.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/recursive_combinators.rb)
* [string\_to\_proc.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/string_to_proc.rb)

_More on recursive combinators_: [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), and [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme).

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