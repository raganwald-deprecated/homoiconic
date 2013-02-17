Effectively Final by Default
===

Four years ago, [Elliotte "Rusty" Harold][elharo] and I disagreed on the subject of the `final` keyword in Java. At the time, I stated my views in an post entitled [Ready, Aim, Final][raf]. There was some back and forth between my blog and Rusty's. I forgot about the matter until [Wikileaks threatened to leak 5,000 open source Java projects With All That Private/Final Bullshit Removed][leaks]. That got me thinking about `final` again.

**three methods**

What functions do these three methods compute?

    module ExampleFunctions

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
      
      def self.first n
        n < 2 ? n : self.first(n-1) + self.first(n-2)
      end
      
      def self.second n, current = 0, subsequent = 1
        n == 0 ? current : self.second(n-1, subsequent, current + subsequent)
      end

      def self.third n
        n < 2 ? n : (Matrix.new(1,1,0) ^ (n - 1)).a
      end

    end
    
    (1..10).map { |n| ExampleFunctions.first(n)  } # => ???
    (1..10).map { |n| ExampleFunctions.second(n) } # => ???
    (1..10).map { |n| ExampleFunctions.third(n)  } # => ???

All three compute the Fibonacci sequence. The first is an almost direct translation of the definition: `n` for any value of n that is less than two, otherwise it is the sum of the previous two numbers. The second also computes the Fibonacci sequence, however the definition has been "reworded" to express the first algorithm in "tail recursive" form. The third takes advantage of a completely different definition of the Fibonacci sequence that expresses it as the exponent of a matrix.

**two conundrums**

First, consider a project where there is a critical piece of logic that can be expressed simply and directly. The correctness of the program relies on this logic producing the expected outputs and side effects. Which version of the function should we use? The first is the easiest to verify. It appears to do exactly what is specified, and works just fine for small values of `n`. But what if we need to handle large values of `n`? The third function is the fastest of the three, but it might be difficult for someone reading the code to grasp at a glance what it does.

*Which implementation should we choose?*

Second, consider a project where we are writing a library and some of its functions that depend on Fibonacci. Like Java, our language permits other programmers to extend the library and override its functionality. We can also declare that a method like Fibonacci cannot be overridden.

Whatever implementation of Fibonacci we choose, there will almost certainly be some client application that has a different set of needs than we anticipate. For example, some clients do not care about memory and would willingly memoize results to trade space for even greater speed. However, permitting other programmers to override Fibonacci will also permit them to accidentally break the functionality of the functions that depend on Fibonacci. Conversely, prohibiting programmers from overriding Fibonacci bars them from improving its suitability for their applications even if they are careful not to break anything.

So: *Do we allow clients to override our choice of implementation?*

At heart, both "conundrums" are the same problem. The "contract" for a function is more than just its method signature. The contract for a function also includes the correctness of its behaviour. Most popular languages provide very little support for statically checking that a function behaves correctly. There is no simple way to write what the Fibonacci function should do and have a compiler enforce this behaviour.

> I conclude that there are two ways of constructing a software design: One way is to make it so simple that there are obviously no deficiencies, and the other way is make it so complicated that there are no obvious deficiencies. The first method is far more difficult. – C.A.R. Hoare, [The Emperor’s Old Clothes][clothes], Turing Award lecture, 1980

The first "conundrum" presented a choice between implementations that obviously have no deficiencies and have no obvious deficiencies. The second conundrum presented the problem of deficiencies in code that hasn't even been written at the time the author is forced to choose.

**severing the gordian knot**

> Warning: Strawmen Approaching

The "lightweight" approach is to solve the problem with Unit Tests. The programmer translates `n < 2 ? n : self.first(n-1) + self.first(n-2)` into a series of tests that exercise as many cases as possible. The code is initially written as simply as possible. As additional requirements for performance or extended functionality are discovered, the code is rewritten. At each stage, the tests are run to ensure that no rewrite breaks the expected functionality.

The lightweight approach values freedom for the programmer, so language features such as control over which classes can be extended and which methods can be overridden is not valued as much as the power to make changes economically.

With the lightweight approach, it is not strictly necessary to have code that clearly documents its purpose, because the tests are the documentation, not the code. Implementations can change but the tests only change if the fundamental requirements change. It is more important that the tests be clear and readable than the implementation. For this reason, in communities like Ruby, you find implementations that seem at first glance to be unreadable meta-programming "magic" right alongside testing frameworks that emphasize readability.

The implementation code is optimized towards separation of concerns and other goals at the expense of readability by the novice, while the testing code is optimized around readability and understanding at a glance.

The "heavyweight" approach is to solve the problem with the programming language's compiler. The programmer writing the library sets limits on what other programmers can change, override, or extend. The heavyweight approach does not eschew unit testing, of course, however the heavyweight approach does take the view that the programmer writing the library today has the authority to constrain the choices of programmers using the library tomorrow.

Given that the heavyweight programmer can choose an implementation for Fibonacci and then lock it down so that future programmers cannot change or override it, the heavyweight programmer has a much greater responsibility to select an implementation that will "Last for the ages." Fibonacci is a rather simple example, so there is little to consider in terms of changing behaviour. However in more complex domains such as modelling business processes, behaviour may need to be changed or extended without breaking existing code that relies on the original behaviour. Heavyweight programmers are often very concerned with carefully decomposing functionality into fine grained units that can be individually locked or overridden.

**and yet...**

Both the lightweight and heavyweight approaches do nothing about the basic problem that:

      def self.first n
        n < 2 ? n : self.first(n-1) + self.first(n-2)
      end

Is functionally equivalent to:

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

      def self.third n
        n < 2 ? n : (Matrix.new(1,1,0) ^ (n - 1)).a
      end

Without being *obviously* equivalent. This is the way with code that grows and extends, for example. Additional cases are added or additional functionality is added and the original, basic purpose of the code becomes obscured. Test suites grow in length until their ability to document the original, basic purpose of the code degrades.

**bondage and discipline**

I am a proponent of [Strict Liskov Substitutability][liskov]. My original definition for Strict Liskov Substitutability is that for any two objects `A` and `B`, if `B is-an A`, then any test written for `A` will have the exact same result for `B`.

So if you say that: `Manager is-an Employee`, you should be able to take some pseudo-unit test-code like this:

    e = Employee.new(:foo => ..., :bar => ...)
    assert(e.foo())
    assert(e.bar())
    assert_nil(e.blitz())

And rewrite it like this:

    e = Manager.new(:foo => ..., :bar => ...)
    assert(e.foo())
    assert(e.bar())
    assert_nil(e.blitz())

And everything will work. Always.

This rarely works even when you're trying your best. For one thing, Managers may need additional initialization. So if you want to do this kind of testing, you are going to need to set up your test factories so that Manager objects get the right default values if you initialize them in an employee test case. Perhaps like this:

    e = TestInstance.of(Employee, :foo => ..., :bar => ...)
    assert(e.foo())
    assert(e.bar())
    assert_nil(e.blitz())

You also want your test suite to do this automatically for every subclass of employee:

    ClassTester.for_every_kind_of(Employee) do |employee_class|
      e = TestInstance.of(employee_class, :foo => ..., :bar => ...)
      assert(e.foo())
      assert(e.bar())
      assert_nil(e.blitz())
    end

What does this get us? It gets us that we are guaranteed that when we write a Manager class, we can override whatever we like, secure in the knowledge that we won't accidentally break the Manager's behaviour as an employee because all of our employee tests are automagically applied to managers.

If that doesn't work in our domain, we are alerted to the need to refactor. For example, who is the CEO's manager? Nobody? Perhaps the `Employee` class needs to be split up. Some of its functionality should be part of a `Subordinate` module, some of its functionality should be an `Employee` class, and `Manager` should be a module as well. Some Employees are Managers, some Subordinates, and ever Manager except the CEO is both a Manager and a Subordinate. Strict Liskov Substitutability forced us to organize our inheritance properly

Ok, fine. Maybe you like Strict Liskov Substitutability, maybe you don't. Let's play along and say that we do just to see what happens. What about Fibonacci and the conundrums we listed above?

In my [blog post][liskov], I described Strict Liskov Substitutability in terms of tests. I was holding a testing hammer at the time, and it looked like a nail. But there are other tools. Isn't the `final` keyword a fine-grained tool that attempts to enforce this? If we declare that a method is final, we are declaring that every subclass has exactly the same implementation, so as far as the behaviour of that method is concerned, they are exactly substitutable.

So, there are two approaches to preventing someone from breaking the functionality encoded in an implementation. First, write tests for it and enforce those tests on subclasses. Second, prevent subclasses from overriding the implementation. These are the lightweight (with a little of my own speculative proposals added to spice things up) and the heavyweight approaches described above.

Is there another way forward?

**duck correctness**

Strongly typed languages work by statically analyzing a program and "proving" that its use of operators and methods is consistent with its assignment of typed values. Languages like ML and Haskell use [type inference][inference], where declarations are minimized but the compiler searches for possible inconsistencies.

Languages like Ruby are formally untyped. As far as the interpreter is concerned, if it walks like a duck and talks like a duck, it's a duck. This is also true of ML, however Ruby only finds an inconsistency when it runs into one a runtime.

Could we do this with Strict Liskov Substitutability? Yes.

Consider the following code:

    class ReadableButSlow

      # ...
      
      def fib n
        n < 2 ? n : fib(n-1) + fib(n-2)
      end

    end
    
    class FasterButTooCleverByHalf < ReadableButSlow

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

      def fib n
        n < 2 ? n : (Matrix.new(1,1,0) ^ (n - 1)).a
      end
    
    end
    
There are no tests written. None. But imagine we write:

    o = FasterButTooCleverByHalf.new(...)
    o.fib(5)
    
We get a result. How do we know whether it is correct? We don't, but we know it must be *consistent* with:

    o = ReadableButSlow.new(...)
    o.fib(5)

This, we can test. In fact, our test suite doesn't need to assert anything. If it sets objects up and calls methods, we perform the substitutions and check that overriding a method never produces a different result than the original. In effect, methods behave as if they're final. Always.

And therefore, the "readable but slow" method becomes the standard way to document what a function does. If you are writing a Math library and need to rewrite a method to optimize its performance, you could do this:

    FastMathLibrary
    
      include CanonicalImplementations # readable but slow
      
      def fib n
        # blisteringly fast
      end
      
    end

The Canonical Implementations are your documentation *and* your tests.

This is remarkably simple for pure functions. For methods with side effects, some care would need to be given. You want to be able to extend a method with side effects in such a way that all of the original side effects are there plus new ones. The testing framework that compares a parent and its child for side effects would need to have a protocol for deciding whether one set of side effects was or was not an extension of another's. Such side effects would have to go beyond the receiver to include other objects it might modify.

This idea is obviously incomplete. And yet... It seems to me that it would make programs far more readable if you could use implementations as a kind of method contract: "All implementations of this method will behave just like this." Then, optimizing code or extending methods wouldn't be obscuring the original intent because it would still be right there in a module or superclass.

> "Certain informal discussions took place, involving a full and frank exchange of views, out of which there arose a series of proposals, which, on examination, proved to indicate certain promising lines of inquiry, which, when pursued, led to the realization that the alternative courses of action might in fact, in certain circumstances, be susceptible of discreet modification, leading to a reappraisal of the original areas of difference and pointing the way to encouraging possibilities of compromise and cooperation, which, if bilaterally implemented, with appropriate give and take on both sides, might, if the climate were right, have a reasonable possibility, at the end of the day, of leading, rightly or wrongly, to a mutually satisfactory resolution." ([Power to the People][p2p], "Yes, Prime Minister")

**seek what he sought**

Four years ago, [Rusty][elharo] claimed that methods should be *final by default*. I will not put words into Rusty's mouth, but he may have suggested that all methods be final by default so as to effectively impose the rule that "When you write a method, you are defining the implementation contract for the behaviour of this class and all of its subclasses."

> Do not follow in the footsteps of the Sages. Seek what they sought.

If this is what he was seeking to accomplish, I admit that <u>Rusty was right all along</u>. All methods should be *effectively* final by default.

----

Discuss on [Hacker News][hn] and [reddit.com][reddit].
  
NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[p2p]: http://www.yes-minister.com/ypmseas2b.htm
[raf]: http://raganwald.com/2006/05/ready-aim-final.html
[leaks]: http://steve-yegge.blogspot.com/2010/07/wikileaks-to-leak-5000-open-source-java.html
[clothes]: http://scifac.ru.ac.za/cspt/hoare.htm
[template]: http://en.wikipedia.org/wiki/Template_method_pattern "Template method pattern - Wikipedia, the free encyclopedia"
[liskov]: http://raganwald.com/2008/04/is-strictly-equivalent-to.html "IS-STRICTLY-EQUIVALENT-TO-A"
[inference]: http://en.wikipedia.org/wiki/Type_inference "Type inference - Wikipedia, the free encyclopedia"
[elharo]: http://www.elharo.com/ "Elliotte Rusty Harold"
[hn]: http://news.ycombinator.com/item?id=1592556
[reddit]: http://www.reddit.com/r/programming/comments/czlll/final_by_default/