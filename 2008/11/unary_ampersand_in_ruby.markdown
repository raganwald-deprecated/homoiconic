The unary ampersand in Ruby
---

A marshmallow toasting dragon slayer from Montr&eacute;al [asked about the unary &.](http://lovehateubuntu.blogspot.com/2008/06/some-neat-things-in-ruby.html "Ubuntu: A Love/Hate Relationship: Some Neat Things in Ruby")

I like this question, because when I saw it, I realized immediately that although I've figured out how to use it to accomplish certain things, writing an answer serves the excellent purpose of forcing myself to learn more.

Let's start with what I do know, and what everyone can figure out from grepping source code: It has something to do with converting things to and from blocks. If you take nothing else away from this, remember that when you see a unary "&" in Ruby, you are looking at making something into a block, or making a block into something.

Now, blocks in Ruby are not first-class entities. You cannot store them in variables. They are not objects. There is no `Block.new` expression. The only way to make a block in Ruby syntax is to write one as part of a method call, like this:


	[1, 2, 3, 4, 5].map { |x| x * x  }
	    => [1, 4, 9, 16, 25]

As we said above, you cannot assign a block to a variable:


	square_block = { |x| x * x  }
	    => syntax error, unexpected '}', expecting $end

What do we do with these blocks? Well, inside of a method, we can yield to a block. Yielding to a block is something very much like calling a function. The value of an expression yielding to a block is the value of the expression in the block, paramaterized by anything you pass in the `yield` expression.

Oh heck, an example is much better:


	def take_a_guess(range) # expects a block testing a guess
	    guess = range.begin + rand(range.end - range.begin)
	    if yield(guess)
	        "Yay, I guessed correctly"
	    else
	        "Boo hoo, my guess was wrong"
	    end
	end

	take_a_guess(1..10) { |x| x == 6 }
	    => "Boo hoo, my guess was wrong"
	take_a_guess(1..10) { |x| x == 6 }
	    => "Boo hoo, my guess was wrong"
	take_a_guess(1..10) { |x| x == 6 }
	    => "Yay, I guessed correctly"

This method plays a guessing game with you: it takes a range ("guess a number from one to ten") and a block for testing whether the guess was correct. It takes a guess and yields the guess to the block. It then exclaims its joy to the world if it guesses correctly.

Notice that there is nothing in the method signature saying it expects a block. There is no name for the block. You have to look for the `yield` keyword to figure out what is going on if the programmer doesn't add a comment.

**converting blocks to procs**

So... Let's talk conversions. If you want to do anything besides invoke a block with `yield`, you really want a `Proc`, not a block. For example:


	class Guesser
	    attr_reader :range, :tester
	    def initialize(range, &tester)
	        @range, @tester = range, tester
	    end
	    def take_a_guess
	        guess = range.begin + rand(range.end - range.begin)
	        if tester.call(guess)
	            "Yay, I guessed #{guess} correctly"
	        else
	            "Boo hoo, my guess of #{guess} was wrong"
	        end
	    end
	end

	foo = Guesser.new(1..10) { |n| n == 6 }
	foo.take_a_guess
	    => "Boo hoo, my guess of 2 was wrong"
	foo.take_a_guess
	    => "Boo hoo, my guess of 8 was wrong"
	foo.take_a_guess
	    => "Yay, I guessed 6 correctly"

We want to store the tester block as an instance variable. So what we do is add a parameter at the very end with an ampersand, and what Ruby does is take the block and convert it to a `Proc`, which you can pass around as an object. And when you want to use it, you send it the `#call` method.

Now if you think about this for a second or two, you'll realize that almost every `Proc` you ever create works this way: We pass a block to a method, and the method turns it into a Proc by having a parameter with an `&`. Let's try writing another one:


	def our_proc(&proc)
	    proc
	end

	double = our_proc { |n| n * 2}
	double.call(7)
	    => 14

Not much to it, is there? When you want a `Proc`, you can create one by calling a method with a block and using `&parameter` to convert the block to a `Proc`. There is no other way to convert a block to a `Proc` because the only place blocks exist is in method invocations.

**converting procs to blocks**

Okay, we know how to make a `Proc` out of a block. What about going the other way? What if we want to make a block out of a `Proc`?

Let's reopen our Guesser class:


	class Guesser
	    def three_guesses
	        guesses = Array.new(3) { range.begin + rand(range.end - range.begin) }
	        if guesses.any?(&tester)
	            "Yay, #{guesses.join(', ')} includes a correct guess"
	        else
	            "Boo hoo, my guesses of #{guesses.join(', ')} were wrong"
	        end
	    end
	end

	bar = Guesser.new(1..10) { |x| x == 3 }
	bar.three_guesses
	    => "Yay, 5, 9, 3 includes a correct guess"

**What just happened?**

For starters, we made an array with three guesses in it. That line of code includes a block, but let's ignore that as being irrelevant to this particular discussion. The next part is what we're after:

We then want to call [Enumerable#any?](http://www.ruby-doc.org/core/classes/Enumerable.html#M001153 "Module: Enumerable") to ask the array if any of its members are the correct guess. Now, `#any?` expects a block. But we don't have a block, we have a `Proc`. So now we do the reverse of what we did when we wanted to convert a block to a `Proc`: instead of a method having an extra parameter with an ampersand, we pass a parameter to the method and apply the ampersand to the parameter we are passing.

So "&tester" says to Ruby: "Take this object and pass it to a method as a block." The `#any?` method gets a block, it has no idea we are doing any `Proc` to block conversion shenanigans. We can prove that:


	def did_you_pass_me_a_block?
	    if block_given?
	        yield
	    else
	        "NO BLOCK"
	    end
	end

	did_you_pass_me_a_block?
	    => "NO BLOCK"
	did_you_pass_me_a_block? { 'I passed you a block' }
	    => "I passed you a block"
	proc = Proc.new { 'I passed you a proc' }
	did_you_pass_me_a_block?(&proc)
	    => "I passed you a proc"

As you can see, our methods don't really know whether they get a block or a `Proc` passed as a block. They just `yield` and all is well. (And yes, you can convert a block to a `Proc` and then the method can convert it right back into another `Proc`.)

**to\_proc shakur**

Which leads us to the final piece of the puzzle. How does Ruby convert whatever you pass with "&" into a block? The answer is that if it is not already a `Proc`, it tries to convert the object to a `Proc` by calling the object's `#to_proc` method, and from there it converts the `Proc` into a block.

So you can do fun stuff like convert strings into blocks by defining a method that converts a string to a `Proc`:


	(1..5).map &'*2'
	    => [2, 4, 6, 8, 10]

Note that this conversion only happens when you try to pass a string as a block to a method with "&." It is not correct to say that "&" converts an object to a `Proc`, the `#to_proc` method does that. It is correct to say that when passing an object to a method, the "&" unary operator tries to convert the object to a block, using the Object's `#to_proc` method if need be.

We'll close with an example, where we decide that a Guesser can be converted to a Proc:

	class Guesser
	    def to_proc
	        Proc.new { |guess|
	            "Yay, I guessed #{guess} correctly" if tester.call(guess)
	        }
	    end
	end

	foo = Guesser.new(1..10) { |n| n == 8 }
	&foo
	    => syntax error, unexpected tAMPER
	foo.to_proc
	    => #<Proc:0x0008cc08@-:26>
	(1..100).map(foo).compact.first
	    => ArgumentError: wrong number of arguments (1 for 0)
	(1..100).map(&foo).compact.first
	    => "Yay, I guessed 8 correctly"

So that's it: When you want to convert a block to a `Proc`, define an extra parameter for your method and preface it with an ampersand. When the method is called, the parameter will hold a `Proc`.

When you want to convert any object to a block, pass it to a method expecting a block and preface it with an ampersand. Ruby will call the `#to_proc` method if need be, then convert the `Proc` into a block.

p.s. *This post originally appeared on [raganwald.com](http://raganwald.com/2008/06/what-does-do-when-used-as-unary.html "The unary ampersand in Ruby")*

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