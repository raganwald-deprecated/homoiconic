Starlings and Template Methods
===

In previous commits, we have met some of [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic)'s most interesting combinators like the [Kestrel](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), [Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown), [Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown "Songs of the Cardinal"), [Quirky Bird](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown "Quirky Birds and Meta-Syntactic Programming"), and [Bluebird](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown "Aspect-Oriented Programming in Ruby using Combinator Birds").

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.

The thrush, cardinal, quirky bird and bluebird all either permute or group their arguments. Although they do change the structure of their arguments, they conserve them: if you pass `xyz` to a bluebird, you get one `x`, one `y`, and one `z` back, exactly what you passed in. The only difference is, you get `x(yz)` back, so they have been grouped for you. But nothing has been added and nothing has been taken away. Alone amongst the combinators we've examined, the kestrel does not conserve its arguments. It *erases* one. If you pass `xy` to a kestrel, you only get `x` back. The `y` is erased. The kestrel comes from a different family of combinators than the others.

Today we are going to meet another combinator that does not conserve its arguments, the Starling. But where a kestrel erases one of its arguments, a starling *duplicates* one of its arguments. In logic notation, `Sxyz = xz(yz)`. Or in Ruby:

	starling.call(x).call(y).call(z)
		=> x.call(z).call(y.call(z))

The starling is not the only combinator that duplicates one or more of its arguments. Logicians have also found important uses for many other duplicating combinators like the Mockingbird (`Mx = xx`), which is the simplest duplicating combinator, the Lark (`Lxy = x(yy)`), and the Turing Bird (`Uxy = y(xxy)`), which is named after [its discoverer](http://www.alanturing.net/turing_archive/index.html "Alan Turing (1912-1954)").

Before we have a close look at starlings, let's review a popular object-oriented "pattern:"

Template Methods
---

One popular pattern in object-oriented programming is the [Template Method](http://en.wikipedia.org/wiki/Template_method_pattern "Template method pattern - Wikipedia, the free encyclopedia"):

> In object-oriented programming, first a class is created that provides the basic steps of an algorithm design. These steps are implemented using abstract methods. Later on, subclasses change the abstract methods to implement real actions. Thus the general algorithm is saved in one place but the concrete steps may be changed by the subclasses.

So there you have it: Template methods help us separate the basic steps of a general algorithm from the concrete steps of a specific algorithm. With a template method, we build a template or framework method with holes in it, then "fill in the blanks" by implementing methods for concrete steps.

Let's whistle up an example. The template we're going to use is called [Divide and Conquer](http://www.cs.berkeley.edu/~vazirani/algorithms/chap2.pdf). It's a general algorithm for solving problems by breaking them up into sub-problems. In Ruby, we might write:

	module TemplateMethod
  
	  def divide_and_conquer(value)
	    if divisible?(value)
	      recombine(
	        divide(value).map { |sub_value| divide_and_conquer(sub_value) }
	      )
	    else
	      conquer(value)
	    end
	  end
  
	  private
  
	  def divisible?(value)
	    raise 'implement me'
	  end
  
	  def conquer(value)
	    raise 'implement me'
	  end
  
	  def divide(value)
	    raise 'implement me'
	  end
  
	  def recombine(list)
	    raise 'implement me'
	  end
  
	end

The general form of the algorithm is laid out to see. When given a value, we first check to see if it is divisible using the abstract method `#divisible?`. If it is, we use `#divide` to divide it into smaller pieces, then call `#divide_and_conquer` on the pieces. We then use `#recombine` to put the pieces back together again. If the value is not divisible, we use `#conquer` to directly compute a value.

This allows us to use various divide and conquer algorithms. It's easiest to see it in action on a problem where the data being processed closely resembles the form of the algorithm, like summing the squares of a nested list of numbers:

	include TemplateMethod

	def divisible?(value)
	  value.kind_of?(Enumerable)
	end

	def conquer(value)
	  value ** 2
	end

	def divide(value)
	  value
	end

	def recombine(list)
	  list.inject() { |x,y| x + y }
	end

	divide_and_conquer([1, 2, 3, [[4,5], 6], [[[7]]]])
		=> 140

Or rotating a square matrix:

	def divisible?(value)
	  value.kind_of?(Enumerable) && value.size > 1
	end

	def conquer(value)
	  value
	end

	def divide(square)
	  half_sz = square.size / 2
	  sub_square = lambda do |row, col|
	    square.slice(row, half_sz).map { |a_row|a_row.slice(col, half_sz) }
	  end
	  upper_left = sub_square.call(0,0)
	  lower_left = sub_square.call(half_sz,0)
	  upper_right = sub_square.call(0,half_sz)
	  lower_right = sub_square.call(half_sz,half_sz)
	  [upper_left, lower_left, upper_right, lower_right]
	end

	def recombine(list)
	  upper_left, lower_left, upper_right, lower_right = list
	  upper_right.zip(lower_right).map { |l,r| l + r } +
	  upper_left.zip(lower_left).map { |l,r| l + r }
	end

	divide_and_conquer([[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,16]])
		=> 
