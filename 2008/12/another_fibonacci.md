Another program to compute the nth Fibonacci number
===

It has been few days since I wrote [a program to compute the nth Fibonacci number](http://github.com/raganwald/homoiconic/tree/master/2008-12-12/fibonacci.md#readme). And while I have a ton of stuff on my plate, "All writing is rewriting." So I had another look the Fibonacci program, and I rewrote it.

> Now this is not an advocacy blog, so I will not launch into an essay. But if I can share one little opinion... I think we all agree with Abelson and Sussman that we write programs primarily for humans to read, and secondarily for compilers to execute. Our experience with communicating with people is that we get the best results when we design several alternate approaches and compare them to each other. Designing programs (whether code in the small or architecture in the large) is no different.

> If an Architect is given a problem and comes back with a single design encompassing the "Best Practices," I am immediately suspicious. If the same architect comes back with three approaches and can articulate the advantages and disadvantages of each approach given the specific problem being solved, I am always impressed. A good designer is always able to come up with several good approaches. One will be chosen, but rarely if ever are there no decent alternatives.

> And thus, I consider solving the same problem several different ways to be a useful exercise. Possibly not as immediately rewarding as returning calls from recruiters trying to staff J2EE positions at BigCo, but useful nonetheless.

The second approach still uses the Matrix algorithm for calculating the _nth_ number in the Fibonacci sequence, however there are a number of key differences from the first version:

	module Fibonacci
  
	  Matrix = Struct.new(:a, :b, :c) do
    
	    alias :d :a
	    alias :e :b
	    alias :f :c
    
	    def * other
	      Matrix.new(
	        self.a * other.d + self.b * other.e, 
	        self.a * other.e + self.b * other.f,
	        self.b * other.e + self.c * other.f
	      )
	    end
    
	    def ^ n
	      if n == 1
	        self
	      elsif n == 2
	        self * self
	      elsif n > 2
	        if n % 2 == 0
	          self ^ (n / 2) ^ 2
	        else
	          (self ^ (n / 2) ^ 2) * self
	        end
	      end
	    end
    
	  end
  
	  def self.[] n
	    return n if n < 2
	    (Matrix.new(1,1,0) ^ (n - 1)).a
	  end
  
	end

In this version, `Fibonacci` is an entity in Kernel namespace. You do not call `n.matrix_fib`, you ask for `Fibonacci[n]`. The trade-off there is between naive object-orientation ("Integers should know their own fibonacci watchamacallits") and having a first-class entity. The naive OO interpretation is frankly suspect. If it makes sense for the integer `14` to be responsible for knowing that the fourteenth number of the Fibonacci sequence is `377`, why doesn't it make sense for the integer `14` to also be responsible for knowing which Customer Record has `id = 14`? Why don't we write `14.customer` the way Rails people write `3.days.ago`?

Also, the class `Fibonacci::Matrix` explicitly defines `*` and `^` so that we can write arithmetic operations on matrices the way we write them on integers. This is one of the prime motivations for languages like Ruby to permit operator overloading. A comparison of this point to the first version is inconclusive to my eyes. `*` and `^` are terser than `times` and `power`.

However, defining them as operators means making them methods in Ruby. This is a little suspect because our code isn't truly polymorphic. It's not like we write `x = y * z` and are oblivious to the implementation of `*` that `y` provides at run time. This is a failing of many OO programs: They look like OO, but they are really written procedurally or functionally, however the OO mechanisms hamper rather than support the program. [Not all functions should be object methods](http://raganwald.com/2007/10/too-much-of-good-thing-not-all.html "Too much of a good thing: not all functions should be object methods"). The original version was blatant about its behaviour: `times` and `power` were written as lambdas, and it was very obvious that they did one thing only without presenting the facade of polymorphism.

`Fibonacci::Matrix` also takes advantage of `Struct`. You can read [all about Struct](http://blog.grayproductions.net/articles/all_about_struct) if you are not familiar with this handy tool. Note that `Struct.new` returns a class, not an instance of a Struct. This is a very handy paradigm for Ruby programs.

Share and enjoy!

*	[another\_fibonacci.rb](http:another_fibonacci.rb)

p.s. *Another* post on Fibonacci? *Dude, WTF!?* My response is to paraphrase [Dijkstra](http://thinkexist.com/quotation/computer_science_is_no_more_about_computers_than/334131.html "Edsger Dijkstra quotes"): "This post is no more about Arithmetic than Astronomy is about telescopes." I'm just trying to share with you my appreciation for composing alternate approaches to solving the same problem and for working out what the imperfect trade-offs the approaches may entail.

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
