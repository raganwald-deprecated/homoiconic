Mockingbirds and Simple Recursive Combinators in Ruby
===

In Raymond Smullyan's delightful book on Combinatory logic, [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422), Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. As you can guess from the title, one such bird, the Mockingbird, plays a central role in combinatory logic.

> **What is a Combinator?** One definition of a combinator is a function with no free variables. Another way to put it is that a combinator is a function that takes one or more arguments and produces a result without introducing anything new. In Ruby terms, we are talking about blocks, lambdas or methods that do not call anything except what has been passed in.--[Finding Joy in Combinators][joy]

[joy]: http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme

## Duplicative Combinators

Many combinators "conserve" their arguments. For example, if you pass `xyz` to a [Bluebird][bb], you get one `x`, one `y`, and one `z` back, exactly what you passed in. You get `x(yz)` back, so they have been grouped for you. But nothing has been added and nothing has been taken away. Likewise the [Thrush][th] reverses its arguments, but again it answers back the same number arguments you passed to it. The [Kestrel][k], on the other hand, does not conserve its arguments. It *erases* one. If you pass `xy` to a Kestrel, you only get `x` back. The `y` is erased. Kestrels do not conserve their arguments.

[bb]: https://github.com/raganwald/homoiconic/blob/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown
[th]: https://github.com/raganwald/homoiconic/blob/master/2008-10-30/thrush.markdown
[k]: https://github.com/raganwald/homoiconic/blob/master/2008-10-29/kestrel.markdown

Today we are going to meet another combinator that does not conserve its arguments, the Mockingbird. Where a Kestrel erases one of its arguments, the Mockingbird *duplicates* its argument. In logic notation, `Mx = xx`. Or in Ruby:

	mockingbird.call(x)
		#=> x.call(x)

The Mockingbird is not the only combinator that duplicates one or more of its arguments. Logicians have also found important uses for many other duplicating combinators like the Starling (`Sxyz = xz(yz)`), which is one half of the [SK combinator calculus](http://en.wikipedia.org/wiki/SKI_combinator_calculus "SKI combinator calculus - Wikipedia, the free encyclopedia"), and the Turing Bird (`Uxy = y(xxy)`), which is named after [its discoverer][turing].

[turing]: http://www.alanturing.net/turing_archive/index.html "Alan Turing"

The great benefit of duplicative combinators from a *theoretical* perspective is that combinators that duplicate an argument can be used to introduce recursion without names, scopes, bindings, and other things that clutter things up. Being able to introduce anonymous recursion is very elegant, and [there are times when it is useful in its own right](http://www.eecs.harvard.edu/~cduan/technical/ruby/ycombinator.shtml "A Use of the Y Combinator in Ruby").

## Recursive Lambdas in Ruby

Let's write a simple recursive combinator in Ruby from first principles. To start with, let's pick a recursive algorithm to implement: We'll *sum the numbers of a nested list*. In other words, we're going to traverse a tree of numbers and generate the sum of the leaves, a recursive problem.

> This is a trivial problem in Ruby, `[1, [[2,3], [[[4]]]]].flatten.inject(&:+)` will do the trick. Of course, it does so by calling `.flatten`, a built-in method that is itself recursive. However, by picking a really simple example, it's easy to focus on the recursion rather than by the domain-specific parts of our problem. That will make things look a little over-engineered here, but when you're interested in the engineering, that's a good thing.

So what is our algorithm?

1. If we are given a number, return it.
2. If we are given a list, call ourself for each item of the list and sum the numbers that are returned.

In Ruby:

    sum_of_nested_list = lambda do |arg|
      arg.kind_of?(Numeric) ? arg : arg.map { |item| sum_of_nested_list.call(item) }.inject(&:+)
    end

One reason we don't like this is that it breaks badly if we ever modify the variable `sum_of_nested_list`. Although you may think that's unlikely, it can happen when writing the method combinators you've seen in previous chapters. For example, imagine you wanted to write to the log when calling this function, but only once, you don't want to write to the log when it calls itself.

    old_sum = sum_of_nested_list
    sum_of_nested_list = lambda do |arg|
      puts "sum_of_nested_list(#{arg.inspect})"
      old_sum.call(arg)
    end
  
    sum_of_nested_list.call([[[[[6]]]]])
  
      sum_of_nested_list([[[[[6]]]]])
      sum_of_nested_list([[[[6]]]])
      sum_of_nested_list([[[6]]])
      sum_of_nested_list([[6]])
      sum_of_nested_list([6])
      sum_of_nested_list(6)
        #=> 6 

This doesn't work because inside our original `sum_of_nested_list`, we call `sum_of_nested_list` by name. If that gets redefined by a method combinator or anything else, we're calling the new thing and not the old one.

Another reason to eschew having lambdas call themselves by name is that we won't be able to create anonymous recursive lambdas. Although naming things is an important part of writing readable software, being able to make anonymous things like object literals opens up a world where everything is truly first class and can be created on the fly or passed around like parameters. So by figuring out how to have lambdas call themselves without using their names, we're figuring out how to make all kinds of lambdas anonymous and flexible, not just the non-recursive ones.

## Recursive Combinatorics

The combinator way around this is to find a way to pass a function to itself as a parameter. If a lambda only ever calls its own parameters, it doesn't depend on anything being bound to a name in its environment. Let's start by rewriting our function to take itself as an argument:

  	sum_of_nested_list = lambda do |myself, arg|
      arg.kind_of?(Numeric) ? arg : arg.map { |item| myself.call(myself, item) }.inject(&:+)
  	end

One little problem: How are we going to pass our function to itself? Let's start by *currying* it into a function that takes one argument, itself, and returns a function that takes an item:

    sum_of_nested_list = lambda do |myself|
      lambda do |arg|
        arg.kind_of?(Numeric) ? arg : arg.map { |item| myself.call(myself).call(item) }.inject(&:+)
      end
    end

Notice that we now have `myself` call itself and have the result call an item. To use it, we have to have it call itself:

  	sum_of_nested_list.call(sum_of_nested_list).call([1, [[2,3], [[[4]]]]])
   		#=> 10 

This works, but is annoying. Writing our function to take itself as an argument and return a function is one thing, we can fix that, but having our function call itself by name defeats the very purpose of the exercise. Let's fix it. First thing we'll do, let's get rid of `myself.call(myself).call(item)`. We'll use a new parameter, `recurse` (it's the *last* parameter in an homage to callback-oriented programming style). We'll pass it `myself.call(myself)`, thus removing `myself.call(myself)` from our inner lambda:

    sum_of_nested_list = lambda do |myself|
      lambda do |arg|
        lambda do |arg, recurse|
          arg.kind_of?(Numeric) ? arg : arg.map { |item| recurse.call(item) }.inject(&:+)
        end.call(arg, myself.call(myself))
      end
    end
    
    sum_of_nested_list.call(sum_of_nested_list).call([1, [[2,3], [[[4]]]]])
 		  #=> 10 

Next, we hoist our code out of the middle and make it a parameter. This allows us to get rid of the ` sum_of_nested_list.call(sum_of_nested_list)` by moving it into our lambda:

    sum_of_nested_list = lambda do |fn|
      lambda { |x| x.call(x) }.call(
        lambda do |myself|
          lambda do |arg|
            fn.call(arg, myself.call(myself))
          end
        end
      )
    end.call(
      lambda do |arg, recurse|
        arg.kind_of?(Numeric) ? arg : arg.map { |item| recurse.call(item) }.inject(&:+)
      end
    )

    sum_of_nested_list.call([1, [[2,3], [[[4]]]]])
 		  #=> 10 
 		
Lots of code there, but let's check and see that it works as an anonymous lambda:

    lambda do |fn|
      lambda { |x| x.call(x) }.call(
        lambda do |myself|
          lambda do |arg|
            fn.call(arg, myself.call(myself))
          end
        end
      )
    end.call(
      lambda do |arg, recurse|
        arg.kind_of?(Numeric) ? arg : arg.map { |item| recurse.call(item) }.inject(&:+)
      end
    ).call([1, [[2,3], [[[4]]]]])
 		  #=> 10
 		  
Looking at this final example, we can see it has two cleanly separated parts:

    # The recursive combinator

    lambda do |fn|
      lambda { |x| x.call(x) }.call(
        lambda do |myself|
          lambda do |arg|
            fn.call(arg, myself.call(myself))
          end
        end
      )
    end.call(
      
      # The lambda we wish to make recursive
      
      lambda do |arg, recurse|
        arg.kind_of?(Numeric) ? arg : arg.map { |item| recurse.call(item) }.inject(&:+)
      end
      
    )

## Recursive Combinators in Idiomatic Ruby

We've now managed to separate the mechanism of recursing (the combinator) from what we want to do while recursing. Let's formalize this and make it idiomatic Ruby. We'll make it a method for creating recursive lambdas and call it with a block instead of a lambda:

    def lambda_with_recursive_callback
      lambda { |x| x.call(x) }.call(
        lambda do |myself|
          lambda do |arg|
            yield(arg, myself.call(myself))
          end
        end
      )
    end

    sum_of_nested_list = lambda_with_recursive_callback do |arg, recurse|
      arg.kind_of?(Numeric) ? arg : arg.map { |item| recurse.call(item) }.inject(&:+)
    end

    sum_of_nested_list.call([1, [[2,3], [[[4]]]]])
 		  #=> 10 

Not bad. But hey, let's DRY things up. Aren't `x.call(x)` and `myself.call(myself)` the same thing?

## The Mockingbird

Yes, `x.call(x)` and `myself.call(myself)` *are* the same thing:

    def mockingbird &x
      x.call(x)
    end

    def lambda_with_recursive_callback
      mockingbird do |myself|
        lambda do |arg|
          yield(arg, mockingbird(&myself))
        end
      end
    end

    sum_of_nested_list = lambda_with_recursive_callback do |arg, recurse|
      arg.kind_of?(Numeric) ? arg : arg.map { |item| recurse.call(item) }.inject(&:+)
    end

    sum_of_nested_list.call([1, [[2,3], [[[4]]]]])
 		  #=> 10 
 		  
But does it blend?

    lambda_with_recursive_callback { |arg, recurse| 
      arg.kind_of?(Numeric) ? arg : arg.map { |item| recurse.call(item) }.inject(&:+)
    }.call([1, [[2,3], [[[4]]]]])
 		  #=> 10 
 
Yes!

And now we have our finished recursive combinator. We are able to create recursive lambdas in Ruby without relying on environment variables, just on parameters passed to blocks or lambdas. and our recursive combinator is built on the simplest and most basic of duplicating combinators, the Mockingbird.

## Afterword

This essay is a substantial reworking of a [Template Methods, Double Mockingbirds, and Helpers][dm]. It also appears as a chapter in [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators). Recursive combinators are fleshed out more completely in [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme) and [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme).

[dm]: https://github.com/raganwald/homoiconic/blob/master/2008-11-21/templates_double_mockingbirds_and_helpers.md

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