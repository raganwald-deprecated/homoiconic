Elegance and the Surreals
===

Last Friday I joined Joey DeVilla for his third [Coffee and Code](http://www.joeydevilla.com/2009/03/06/coffee-and-code-today-in-toronto-and-irvine-california/ "Coffee and Code Today in Toronto and Irvine, California!") day. Joey recently went to work for an extremely large, highly competitive organization known for its ruthless business practices. He also recently donated an actual Lisp Machine he owned to [hacklab.to](http://hacklab.to/). Hopefully, the two events are unrelated and his new job has not killed the part of his brain that thinks hacking on a Lisp Machine is interesting. When he mentioned the Lisp Machine, I immediately thought that somehow, a dedicated Lisp Machine ought to be extraordinarily elegant. Which got me thinking about *elegance*. What is "elegance"? How do you know if something is "elegant"?

[![(c) 2008 el benjamin, some rights reserved](http://farm4.static.flickr.com/3099/2921981507_ec9443db22.jpg?v=0)](http://www.flickr.com/photos/thesubstars/2921981507/ "(c) 2008 el benjamin, some rights reserved") 

The Scheme dialect of Lisp is noted for its elegance. Lisp started as an almost direct implementation of the [Lambda Calculus](http://en.wikipedia.org/wiki/Lambda_calculus), and while Common Lisp programming can be extraordinarily pragmatic, Lisp and the Lisp culture both encourage elegant solutions to problems. Scheme implementations *must* implement [tail call optimization](http://en.wikipedia.org/wiki/Tail_recursion "Tail recursion"). This in turn means that you can often write a recursive solution to a problem that runs as fast as an iterative solution. And that means you don't have to choose between elegance and performance: You can have your cake and eat it too.

But "Being more elegant than C++" is a very low bar to clear. As Paul Graham [noted](http://www.paulgraham.com/hundred.html "The Hundred-Year Language"):

> The Lisp that McCarthy described in 1960, for example, didn't have numbers. Logically, you don't need to have a separate notion of numbers, because you can represent them as lists: the integer n could be represented as a list of n elements. You can do math this way. It's just unbearably inefficient.

Wow. A language where numbers were represented as lists of *n* elements. The "lists of length n" implementation of numbers is really based on two things: The empty list or `[]`, and the operation of adding an element to it, an operation we could call `succ`, `next`, or `++` depending on your preferred programming language. Since we only have one kind of thing, the thing we can add to an empty list is an empty list. Therefore, the number "six" would be represented as `[[], [], [], [], [], []]`, a list of six empty lists.

Is that elegance? I think it does have one component of elegance: It has fewer "things" in it, because you just have lists rather than having lists and integers. Having a smaller set of core things is definitely part of elegance. Just ask anyone who struggles with Java's object/primitive dichotomy if you don't believe me.

But there's another component of elegance that must be considered, the question of *scale*. To see this in action, let's compare "lists of length n" to another representation, [Surreal Numbers](http://en.wikipedia.org/wiki/Surreal_number).

**Surreal Numbers**

In the "lists of length n" representation, numbers know how many times you've incremented the empty list. What if we pick a representation where numbers know something about how they compare to other numbers?

    class SurrealNumber < Struct.new(:numbers_to_my_left, :numbers_to_my_right)
    end

If you line up all the numbers in order, each `SurrealNumber` knows of zero or numbers to its *left* and zero or more numbers to its *right*. But its knowledge can be incomplete! Any finite number is greater than an infinite number of numbers and also less than an infinite number of numbers, so our representation could not fit in a finite space if each number actually enumerated *all* of the numbers to its left or its right.

If we are going to write out some examples, we will need a simple notation. This being Ruby, we'll blithely monkey-patch core classes to make a kind of DSL:

    class SurrealNumber < Struct.new(:numbers_to_my_left, :numbers_to_my_right)
  
      def inspect
        "(#{numbers_to_my_left.inspect}^#{numbers_to_my_right.inspect})"
      end
  
    end

    Array.class_eval do
  
      def ^ numbers_to_the_right
        SurrealNumber.new(self, numbers_to_the_right.kind_of?(Array) ? numbers_to_the_right : [numbers_to_the_right])
      end
  
    end
    
So you can create a new SurrealNumber by writing out using the `^` operation to join two arrays of numbers.
    
**Consistency and Inconsistency**

Now right away we can see some potential problems. We haven't figured out how to write a `SurrealNumber` that is equivalent to the integers we are comfortable discussing, but imagining that we can do that, what happens if we write something like `[2] ^ [1, 3]`? Were trying to write a `SurrealNumber` that thinks it is to the right of `2` but also to the left of both `1` and `3`. This doesn't make any sense. Or what about `[6] ^ [6]`? What kind of number is to the left and right of six at the same time?

To sort this out, we'll need a precise definition of the expressions "to the right of" and "to the left of." We've already had plenty of words, so let's express ourselves in Ruby. We start with a single definition:

    def not_to_the_left_of?(other)
      !numbers_to_my_right.any? { |right| other.not_to_the_left_of?(right) } and
        !other.numbers_to_my_left.any { |left| left.not_to_the_left_of?(self) }
    end

Meaning, one number is *not to the left of another number* if and only if:

* If `x` is not to the left of `y`, there is no number `z`  such that `z` is to the right of `x` but `y` is not to the left of `z`
* If `x` is not to the left of `y`, there is also no number `w` such that `w` is to the left of `y` but `w` is not to the left of `x`.
  
You can now write a simple validation for our `SurrealNumber` class:

    def valid?
      numbers_to_my_left.all? { |left| left.valid? } and
      numbers_to_my_right.all? { |right| right.valid? } and
      numbers_to_my_left.all? do |left|
        !numbers_to_my_right.any? do |right|
          left.not_to_the_left_of?(right)
        end
      end
    end

Meaning, a number is valid provided that all the numbers to its left are valid, all the numbers to its right are valid, and for every number to its left, there is no number to its right such that the number to its left is not to the left of the number to its right.

**The degenerate case**

For convenience, let's define `#not_to_the_right_of?`:

    def not_to_the_right_of?(other)
      other.not_to_the_left_of?(self)
    end

Recursive things and elegant things almost always start with a base or degenerate case and work from there. The "lists of length n" implementation of numbers started with an empty list. We have a similarly spartan base case, `[] ^ []`. We will call it *Naught*:

    NAUGHT = [] ^ []

Let's ask ourselves this question: *Is `NAUGHT` valid?*

This is a really interesting question. The very way it is phrased hints at something deep about the way we think about things and the way we can discover new things. We're asking whether `NAUGHT` is valid, which implies that there is some positive characteristic of numbers we are seeking. But there isn't.

> Having a smaller set of core things is definitely part of elegance. Just ask anyone who struggles with Java's object/primitive dichotomy if you don't believe me. But there's another component of elegance that must be considered, the question of *scale*.

Our rule of validity is really a rule of *invalidity*. If you look at the `#valid?` method, you see that at its heart we have really defined that a number is invalid if any number to its left is not to the left of any number to its right. But `NAUGHT` doesn't have *any* numbers to its left or its right, so it passes this test.

One might be inclined to patch over this case, to declare--for example--that `NAUGHT` is invalid, and what we really need is a number `ZERO` where negative one is to its left and one is to its right. However, one might also shrug and continue in the spirit of finding out what happens if we treat `NAUGHT` as a legitimate number.

This is the kind of thinking that allegedly led Einstein to discover Special Relativity. If the speed of light *always* appeared to be constant for any observer, then things appeared to be bad when considering the rate of change in time for various observers. But he shrugged and carried on, wondering if it would all work out in the end. It did all work out in the end, but he learned something shocking about time and observers in motion relative to each other.

This teaches us that like programming languages, theories of physics constrain us to certain ways of thinking about things. Sometimes you need a new approach to provoke fresh thinking.

So by our rules `NAUGHT` *is* a valid number, even though it appears nonsensical, a number with no numbers to its left or right. And indeed, as we carry on we discover that things to work out in the end, but we must abandon certain ideas we think we have about numbers.

Let's see what we get if we ask a few more questions.

**A few more relationships**

What is `NAUGHT.not_to_the_left_of?(NAUGHT)`? What is `NAUGHT.not_to_the_right_of?(NAUGHT)`? What do you infer from this? Correct! Given two numbers `x` and `y`, if `x.not_to_the_left_of?(y) && x.not_to_the_right_of?(y)`, we know that `x == y`!

    def == (other)
      other.kind_of?(SurrealNumber) && not_to_the_left_of?(other) && not_to_the_right_of?(other)
    end

Note that equality is a *defined relationship*. There is no monkeying around with comparing the identities of our representations in our language's implementation. Two instances of `SurrealNumber` in Ruby can be `==` each other even if they are not the same instance in memory. Furthermore, two instances of `SurrealNumber` in Ruby can be `==` each other even if they don't have the exact same representation!

`NAUGHT` or `[] ^ []` is the simplest possible number to represent. What is the next simplest number? How about `([([]^[])] ^ [])`? Or to put it more simply: `NAUGHT ^ []`. What do we know about this number?

    (NAUGHT ^ []).not_to_the_left_of?(NAUGHT) # => true
    (NAUGHT ^ []) == NAUGHT # => false

Well, if `(NAUGHT ^ [])` is not to the left of `NAUGHT` and it is not equal to `NAUGHT`... It must be to the *right* of naught. Now we have a new relationship we can define, along with its symmetrical twin:
  
    def to_the_right_of?(other)
      not_to_the_left_of?(other) && !not_to_the_right_of?(other)
    end
  
    def to_the_left_of?(other)
      not_to_the_right_of?(other) && !not_to_the_left_of?(other)
    end

**Integers and arithmetic**

We can name our new number:

    ONE = NAUGHT ^ []

    ONE.to_the_right_of?(NAUGHT) # => true
    ONE.to_the_left_of?(NAUGHT)  # => false
    NAUGHT.to_the_left_of?(ONE)  # => true
    NAUGHT.to_the_right_of?(ONE) # => false
    
If `ONE` is `NAUGHT ^ []`, what is `ONE ^ []`? Correct!

    TWO = ONE ^ []
    
Verify for yourself that the relationships we have defined work for `NAUGHT`, `ONE`, and `TWO`. Make `THREE`, `FOUR`, and `FIVE` if you are so inclined. And what happens if we go the other way? Do we get negative numbers? Yes we do:

    MINUS_ONE = [] ^ NAUGHT
    MINUS_TWO = [] ^ MINUS_ONE

Now we come to an interesting question: *Does the operation `^ []` mean plus one?*. We could just declare that it does, but in doing so we ought to check our results. Let's try it and see:

    MINUS_TWO ^ [] == MINUS_ONE # => false
    MINUS_TWO ^ [] == NAUGHT    # => true
    
Bzzzzzzzzzt! Wrong!! If `^ []` meant plus one, `MINUS_TWO ^ []` should equal `MINUS_ONE` and it should not equal `FALSE`. `^ []` obviously does not equate to adding one to a number, even though it does help us generate numbers.

Let's work things out from first principles. Our concept of a number works off defining a set of numbers to its left and a set of numbers to its right. If we imagine the relationship `x = y + z`, how can we work out `x` given `y` and `z`? Here are some conclusions we can form:

1.  If some number `y_left` is to the left of `y`, then `y_left + z` is to the left of `x`;
2.  If some number `z_left` is to the left of `z`, then `z_left + y` is to the left of `x`;
3.  If some number `y_right` is to the right of `y`, then `y_right + z` is to the right of `x`;
4.  If some number `z_right` is to the right of `z`, then `z_right + y` is to the right of `x`.

Hmmmmm. Defining `+` in terms of `+`. Will this work? Taken in isolation, *no*. If this were written as a recursive method, how would it ever terminate? But if you take it in combination with basing our number system on `NAUGHT`, we see that as we decompose numbers, we eventually reach numbers that have no numbers to their left, no numbers to their right, or in  the case of `NAUGHT`, no numbers to the left or right. Try working out `NAUGHT` + `NAUGHT`, `NAUGHT + ONE`, `ONE + NAUGHT`, and `ONE + ONE` to see how it works.

Of course, we like to automate things. Now that we are comfortable the algorithm terminates for our test numbers, we can write a method for our `SurrealNumber` class:

    def + (other)
      (numbers_to_my_left.map { |left| left + other } | other.numbers_to_my_left.map { |left| left + self }) ^
        (numbers_to_my_right.map { |right| right + other } | other.numbers_to_my_right.map { |right| right + self })
    end

Let's try our `+` operator:

    MINUS_TWO + ONE == MINUS_ONE # => true
    MINUS_TWO + ONE == NAUGHT # => false

Much better! You can verify for yourself that addition works just as you'd expect it for `TWO + TWO == FOUR` and everything else you can try. Let's implement another operator. How does negation work? If we imagine the relationship `x = -y`, we conclude:

1.  If some number `y_left` is to the left of `y`, then `-y_left` is to the *right* of `x`;
2.  If some number `y_right` is to the right of `y`, then `-y_right` is to the *left* of `x`.

Try it out for yourself, or just use the obvious implementation:

    def -@
      numbers_to_my_right.map { |r| -r } ^ numbers_to_my_left.map { |l| -l }
    end
    
I won't write everything out here, but with a little thought you can work out how to perform multiplication, division and every other operation on our numbers. Although the representation looks weird to someone used to thinking in binary or decimal representations, our numbers can do everything a familiar number can do.

And more.

**What lies between and beyond?**

What is the number `NAUGHT ^ ONE`? Let me give you a hint: `(NAUGHT ^ ONE) + (NAUGHT ^ ONE) == ONE`! You can experiment with `NAUGHT ^ ONE`, `-(NAUGHT ^ ONE)`, and various combinations of this number and our existing integers. You will come to the conclusion that `NAUGHT ^ ONE` is the number `1/2` or `HALF`.

And if you do some more experimenting, you can derive `1/4`, `3/8`, and so on. These fractions automatically work for the operations we've already defined for integers. That's a bonus!

Amazingly, our number representation goes much further. You can use it to represent the infinities, reals, transfinite ordinals, infinitesimals, and more. So clearly, this representation is much, much more powerful than either "lists of length n" or binary numbers.

Sweet candy!

**Elegance: "Some Representations Scale, Some Don't"**

Let's think back to the "lists of length n" implementation of numbers. It has a very simple implementation, so simple that I haven't even bothered to write it out in Ruby for comparison. And it clearly works for counting things. In fact, it maps directly to our mental model of counting things, so not only is its implementation simple, but when you are counting things, it has very little baggage.

If you desire, you can define addition and subtraction and multiplication and division and so forth with "lists of length n." But now the simplicity starts to fall down. Although its base, core case is simple, as you start to do even a little more with it, the result is no longer simple. And it falls down completely when we try to talk about negative numbers, or reals, or just about anything else. We paste special cases onto it and if we dared to try anything ambitious, we end up greenspunning some other representation on top of it.

> Elegance consist of building something out of a small core of representations *that scale well*. It is not enough that they be simple, the complexity of what you build must not grow uncontrollably as you try to solve bigger and more complex problems.

When we talk about algorithmic complexity, we talk about how the cost of deriving the solution grows with the magnitude of the problem. We say things like "That algorithm is Oh En Squared" to say that when the size of the problem doubles, the cost of solving it quadruples. We also know there is some constant, base cost as well. But we rarely talk about it, because we know that if the cost of deriving a solution grows faster than the size of the problem grows, the constant base cost quickly becomes irrelevant. We only care about it for very trivial problems or for algorithms where the cost of deriving a solution grows extremely slowly (sometimes more slowly than the size of the problem grows).

If we think about representations and complexity, we see the same thing in action. As the complexity of what we want to do grows, the complexity of our implementation grows as well. A good representation is one where the complexity of the implementation grows very slowly as the complexity of what we want to do grows.

So comparing our `SurrealNumber` class to "lists of length n," we see that although "lists of length n" has a much simpler base complexity, its complexity grows very quickly as we try to do more complex things with it. "Lists of length n" is like one of those exponential algorithms that cannot scale in any meaningful way. Our `SurrealNumber` class is different. It scales to handle much more complex problems effortlessly. Its initial implementation is less simple, but this is like the constant cost of an algorithm that is "Oh One:" This is irrelevant for all but the trivial cases.

Taking a whack at a long-deceased horse, we see how to respond when people tell us that Java code is easier to read or the equivalent approach of banning "advanced" idioms from a more expressive language leads to easier to understand programs. They are asserting that if you start with a very simple base representation and build up from that, the result will be simple.

This is absolutely true if the simple representation you start with scales well, if the complexity of your implementation grows slowly with  the complexity of the problem you are trying to solve. In the case of Java, we have discovered that it does not scale well to solving more complex problems. The complexity of the implementation grows much faster than the complexity of the problem being solved, and thus the resulting program is much more complex than the requirements would suggest.

This leads me to my personal definition of elegance. Elegance consist of building something out of a small core of representations *that scale well*. It is not enough that they be simple, the complexity of what you build must not grow uncontrollably as you try to solve bigger and more complex problems.

*(Is that everything we need to know about choosing representations? That they be maximally elegant? No! I hope to discuss the question of how well representations should or shouldn't map to our mental models in a future post.)*

---

[Surreal Numbers](http://mathworld.wolfram.com/SurrealNumber.html) were discovered by [John Horton Conway](http://en.wikipedia.org/wiki/John_Horton_Conway). In addition to representing almost anything we think of as a number, if you drop the validation requirement they generalize to represent games. The term "Surreal Number" was actually coined by Donald Knuth. After Conway explained the concept to Knuth in 1972, Knuth actually published it first in the form of a novel, *Numbers: How Two Ex-Students Turned on to Pure Mathematics and Found Total Happiness*, now simply titled [Surreal Numbers](http://www.amazon.com/gp/product/0201038129?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0201038129 "Amazon.com"). Knuth's book is a classic, entertaining and instructive at the same time.

> "...It is an astonishing feat of legerdemain. An empty hat rests on a table made of a few axioms of standard set theory. Conway waves two simple rules in the air, then reaches into almost nothing and pulls out an infinitely rich tapestry of numbers that form a real and closed field. Every real number is surrounded by a host of new numbers that lie closer to it than any other "real" value does. The system is truly "surreal." --Martin Gardner

Conway adopted Knuth's term and published [On Numbers and Games](http://www.amazon.com/gp/product/1568811276?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=1568811276 "Amazon.com"), the definitive incredible (although very technical) treatise on the subject. Reading it is like drinking from a fire hose: Everything in this post is found on the first three pages of the book.

If you would like to read more on line, I strongly suggest Mark Chu-Carroll's [Introducing the Surreal Numbers](http://scienceblogs.com/goodmath/2007/03/introducing_the_surreal_number_2.php). In a post of roughly the same length as this, he describes integers, arithmetic, the birthdays of the numbers, infinities, and more.

So... If you want a readable and entertaining exposition, read [Knuth](http://www.amazon.com/gp/product/0201038129?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0201038129 "Surreal Numbers"). If you want all of the glory of numbers and games, read [Conway](http://www.amazon.com/gp/product/1568811276?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=1568811276 "On Numbers and Games"). If you want a readable but highly provocative exploration, read [Chu-Carroll](http://scienceblogs.com/goodmath/2007/03/introducing_the_surreal_number_2.php "Introducing the Surreal Numbers"). And of course, these are not mutually exclusive. Read them all!

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

[Hire Reg Braithwaite!](http://reginald.braythwayt.com/RegBraithwaiteGH0109_en_US.pdf "")