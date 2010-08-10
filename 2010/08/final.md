Finality
===

> I am pleased to report that with the passing of time, "Certain informal discussions took place, involving a full and frank exchange of views, out of which there arose a series of proposals, which, on examination, proved to indicate certain promising lines of inquiry, which, when pursued, led to the realization that the alternative courses of action might in fact, in certain circumstances, be susceptible of discreet modification, leading to a reappraisal of the original areas of difference and pointing the way to encouraging possibilities of compromise and cooperation, which, if bilaterally implemented, with appropriate give and take on both sides, might, if the climate were right, have a reasonable possibility, at the end of the day, of leading, rightly or wrongly, to a mutually satisfactory resolution." ([Power to the People][p2p], "Yes, Prime Minister")

Four years ago, Elliott Rusty Harold and I disagreed on the subject of the `final` keyword in Java. At the time, I stated my views in an post entitled [Ready, Aim, Final][raf]. There was some back and forth between my blog and Rusty's. I forgot about the matter until [Wikileaks threatened to leak 5,000 open source Java projects With All That Private/Final Bullshit Removed][leaks]. That got me thinking about `final` again.

three methods
---

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

two conundrums
---

First, consider a project where there is a critical piece of logic that can be expressed simply and directly. The correctness of the program relies on this logic producing the expected outputs and side effects. Which version of the function should we use? The first is the easiest to verify. It appears to do exactly what is specified, and works just fine for small values of `n`. But what if we need to handle large values of `n`? The third function is the fastest of the three, but it might be difficult for someone reading the code to grasp at a glance what it does.

*Which implementation should we choose?*

> I conclude that there are two ways of constructing a software design: One way is to make it so simple that there are obviously no deficiencies, and the other way is make it so complicated that there are no obvious deficiencies. The first method is far more difficult. – C.A.R. Hoare, [The Emperor’s Old Clothes][clothes], Turing Award lecture, 1980

Second, consider a project where we are writing a library and some of its functions that depend on Fibonacci. Like Java, our language permits other programmers to extend the library and override its functionality. We can also declare that a method like Fibonacci cannot be overridden.

Whatever implementation of Fibonacci we choose, there will almost certainly be some client application that has a different set of needs than we anticipate. For example, some clients do not care about memory and would willingly memoize results to trade space for even greater speed. However, permitting other programmers to override Fibonacci will also permit them to accidentally break the functionality of the functions that depend on Fibonacci. Conversely, prohibiting programmers from overriding Fibonacci bars them from improving its suitability for their applications even if they are careful not to break anything.

So: *Do we allow clients to override our choice of implementation?*

At heart, both "conundrums" are the same problem. The "contract" for a function is more than just its method signature. The contract for a function also includes the correctness of its behaviour. Most popular languages provide very little support for statically checking that a function behaves correctly. There is n simple way to write what the Fibonacci function should do and have a compiler enforce this behaviour.

The first "conundrum" presented a choice between implementations that obviously have no deficiencies and have no obvious deficiencies. The second conundrum presented the problem of deficiencies in code that hasn't even been written at the time the author is forced to choose.

severing the gordian knot
---

> Warning: Strawmen Approaching

The "lightweight" approach is to solve the problem with Unit Tests. The programmer translates `n < 2 ? n : self.first(n-1) + self.first(n-2)` into a series of tests that exercise as many cases as possible. The code is initially written as simply as possible. As additional requirements for performance or extended functionality are discovered, the code is rewritten. At each stage, the tests are run to ensure that no rewrite breaks the expected functionality.

The lightweight approach values freedom for the programmer, so language features such as control over which classes can be extended and which methods can be overridden is not valued as much as the power to make changes economically.

With the lightweight approach, it is not strictly necessary to have code that clearly documents its purpose, because the tests are the documentation, not the code. Implementations can change but the tests only change if the fundamental requirements change. It is more important that the tests be clear and readable than the implementation. For this reason, in communities like Ruby, you find implementations that seem at first glance to be unreadable meta-programming "magic" right alongside testing frameworks that emphasize readability.

The implementation code is optimized towards separation of concerns and other goals at the expense of readability by the novice, while the testing code is optimized around readability and understanding at a glance.

The "heavyweight" approach is to solve the problem with the programming language's compiler. The programmer writing the library sets limits on what other programmers can change, override, or extend. The heavyweight approach does not eschew unit testing, of course, however the heavyweight approach does take the view that the programmer writing the library today has the authority to constrain the choices of programmers using the library tomorrow.

Given that the heavyweight programmer can choose an implementation for Fibonacci and then lock it down so that future programmers cannot change or override it, the heavyweight programmer has a much greater responsibility to select an implementation that will "Last for the ages." Fibonacci is a rather simple example, so there is little to consider in terms of changing behaviour. However in more complex domains such as modelling business processes, behaviour may need to be changed or extended without breaking existing code that relies on the original behaviour.

The heavyweight programmer must carefully analyze units of functionality and make sure they are properly decomposed along the lines of responsibility. If functionality is locked down at too coarse a level, things that may need to be changed are locked just as securely as things that should not change. Heavyweight programmers often decompose functionality finely (using patterns such as [template method][template]). There are many claimed benefits of decomposing functionality, however the hallmark of the heavyweight approach is to decompose the functionality even when that decomposition is not needed at the current time. The heavyweight programmer takes the view that it is his responsibility to 

----
  
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald) or [RSS](http://feeds.feedburner.com/raganwald "raganwald's rss feed"). I work with [Unspace](http://unspace.ca), and I like it.

[p2p]: http://www.yes-minister.com/ypmseas2b.htm
[raf]: http://weblog.raganwald.com/2006/05/ready-aim-final.html
[leaks]: http://steve-yegge.blogspot.com/2010/07/wikileaks-to-leak-5000-open-source-java.html
[clothes]: http://scifac.ru.ac.za/cspt/hoare.htm
[template]: http://en.wikipedia.org/wiki/Template_method_pattern "Template method pattern - Wikipedia, the free encyclopedia"