Functional Complexity Modulo a Test Suite (Very Rough Draft)
===

*I have been thinking about empirical metrics for readability and maintainability. The concept of functional complexity seems very integral to thinking about the properties of programs, so I thought I'd document my definition.*

**Functionality and Functional Equivalence**

What does it mean for two programs to be *equivalent* to each other? For example, here are three Ruby "programs" that appear to be equivalent:

    def cstr; '19620614';                      end
    def arry; %w(1962 06 14).join;             end
    def calc; (2**1 * 13**1 * 754639**1).to_s; end
    
(I have written these as methods for simplicity, but the same principle would hold if they were command line programs that wrote to standard out, web services, or just about anything else.)
    
How do we know that  these three are equivalent? Is there a precise way we can define "equivalence?" Is there an algorithm for determining whether any two (or more) programs are equivalent? The answer is *yes*, provided that we start by defining the *functionality* of each program. Given a program's functionality, we can then define *functional equivalence*.

For any program, we shall define a *test suite* that inspects the program's behaviour. Each test suite shall have one or more tests in it.

* A test is a function that takes a program as input and produces either a 1 (pass) or 0 (fail).
* Tests are *consistent*: given the same program, a test always produces 1 or always produces 0.
* A test suite contains an ordered set of *n* tests.
* A test suite is a function that takes a program as input and passes the program to each of its *n* tests. This produces an ordered set of 1s and 0s, which we shall take to be a binary number from 0 (all fail) to 2^*n*-1 (all pass).

Imagine the set of all possible tests. It's infinitely large, so we won't try to give an example. If we had to write it out, we might write a program that methodically generates tests, perhaps by generating every possible representation of a test and throwing out the ones that are syntactically invalid.

There is a test suite that contains the set of all possible tests with some ordering. The ordering could be the order that our program generates tests. It's an infinitely large test suite, of course, but let's carry on. We will call this test suite the Aleph One Test Suite. If we give any program to Aleph One, we will get a number as a result. We will call that number the *absolute functionality* of a program. Any two programs with the exact same absolute functionality are *absolute functionally equivalent*.

Unfortunately, Aleph One is only theoretical. For practical reasoning about programs we need finite test suites. What happens if we work with a test suite containing a finite set of tests? If we pass a program to a finite test suite, we will get a finite number. This is not the absolute functionality of the program, it is the *the functionality of the program modulo the test suite*. Any two programs that have the identical functionality modulo a test suite are *functionally equivalent modulo the test suite*.

For the above three programs, if we imagine a test suite consisting of a single test that inspects the output for the string `19620614`, all three programs are functionally equivalent modulo that test suite because they all produce the number "1":

    def test(program)
      send(program) == '19620614' ? 1 : 0 rescue 0
    end
    
    def test_suite(program)
      test(program)
    end
    
    test_suite(:cstr)
      => 1
    test_suite(:arry)
      => 1
    test_suite(:calc)
      => 1

**Invalidity**

Most programming languages have the notion of an invalid representation, something that is not a program. It could be that a text representation of the program has invalid syntax. It could be that while its syntax is valid, there are other errors that prevent it from even running tests. In a language like Ruby, there could be semantic errors such as:

    class Foo < Bar
      # ...
    end
      => NameError: uninitialized constant Bar

We can consider all such invalid programs to produce the number 0 when fed to any test suite. In other words, if the program is not valid, all tests always fail. Likewise, most systems have the notion of un-handled runtime errors such as division by zero. If such a thing occurs when running a test, we declare that the test returns a zero, always. 

**Why is functional equivalence modulo a test suite useful?**

At first glance, functional equivalence modulo a test suite may seem to have little value. Imagine selecting a program at random and a test suite at random. My conjecture is that the functionality of a random program modulo a random test suite is nearly always going to be 0, meaning that a randomly selected test will nearly always fail for any program. Therefore, nearly every pair of randomly selected programs will be functionally equivalent modulo almost every test suite. So what good is this concept?

My suggestion is that the fact that an infinite number of tests fail for any one program is no more troublesome than the observation that nearly every randomly constructed string of characters is "noise." When reasoning about things that humans deliberately construct, it is useful to restrict ourselves to observing properties that are semantically meaningful to humans.

In the case of test suites, the finite set of tests represents a set of observations we can choose to make about a program. We choose to make observations that reflect our understanding of what the program is intended to do. Of course, our understanding is imperfect. We might construct tests for a program that ignore certain edge cases. For example, consider this test suite:

    def test0(program)
      send(program, 1) == 1 ? 1 : 0 rescue 0
    end
    
    def test1(program)
      send(program, 1,2) == 3 ? 1 : 0 rescue 0
    end
    
    def test2(program)
      send(program, 1, 2, 3) == 6 ? 1 : 0 rescue 0
    end
    
    def test_suite_alpha(program)
      test0(program) + test1(program) * 2 + test2(program) * 4 
    end
    
For this program, the functionality modulo test\_suite\_alpha is 7:

    def simple_inject(*list)
      list.inject { |a,b| a + b }
    end
    
    test_suite_alpha(:simple_inject)
      => 7
      
And this program produces the same result:

    def inject_with_default(*list)
      list.inject(0) { |a,b| a + b }
    end
    
    test_suite_alpha(:inject_with_default)
      => 7

Therefore, `simple_inject` and `inject_with_default` are functionally equivalent modulo test\_suite\_alpha. We can add a new test and create a new test suite:
    
    def test3(program)
      send(program) == 0 ? 1 : 0 rescue 0
    end
    
    def test_suite_beta(program)
      test0(program) + test1(program) * 2 + test2(program) * 4 + test3(program) * 8
    end
    
Now we get:

    test_suite_beta(:simple_inject)
      => 7

    test_suite_beta(:inject_with_default)
      => 15

While our two programs are functionally equivalent modulo test\_suite\_alpha, they are *not* functionally equivalent modulo test\_suite\_beta. If we draw conclusions about the relationship between `simple_inject` and `inject_with_default` based on test\_suite\_alpha, we may be gravely disappointed to discover that they are not absolutely functionally equivalent.

This error comes from imagining that functional equivalence modulo a test suite is an approximation of absolute functional equivalence. Functional equivalence modulo a test suite is no more an approximation of absolute functional equivalence than equality modulo a number is an arithmetic approximation of equality.

Given finite space and time, we will always be forced to make a finite number of observations of a program. My thesis is that we do not observe has no meaning. Our notion of functionality modulo a test suite simply formalizes this limit.

**Does strong type checking affect our thinking?**

Consider using a programming language with strong type checking instead of Ruby. The type checker is a kind of test, and one that appears to be far more general than the tests in our test suites. For example, test\_suite\_alpha did not test the empty list case. However, the compiler for a language such as Haskell or OCaml would insist that our program include code to handle the empty list case. What this means in the context of functionality modulo a test case is that Haskell or OCaml programs failing to handle the empty list fail every test because they are invalid.

The notion of a compiler performing type checking, or design-by-contract checking, or any other form of static analysis can be very useful for humans, but there is no need to establish a separate model for reasoning about them. Consider two Haskell programs, one of which can sum any list and will not accept an empty list as input, the other of which can sum any list including the empty list. Provided that the compiler accepts both programs, they are functionally equivalent modulo test\_suite\_alpha. 

There is the strawman argument that the one program is superior to the other because the type checker has eliminated the possibility of a program failing to handle the empty list. If you ever want to pass in an empty list, you must write code that handles it properly. This seems vastly superior to a language where it is possible to pass an empty list to code that cannot handle it. That has practical value. But does it affect our reasoning about functionality modulo a test suite? No.

It is superior in practice because we make a certain assumption that the type system is a form of test suite. We say that the type system forms a set of assertions about the implementation of the program. So for the strong typing programmer, there are actually two test suites, the runtime tests and also the assertions enforced by the typing system. Both say something about the behaviour of the implementation.

However, we will not necessarily treat the assertions in the typing system as tests for the purpose of calculating functionality modulo a test suite. If we always include the type system in our notion of a test suite, we could only compare two programs with the same type system architecture. Consider two different programmers independently implementing mathematics from first principles in a strongly typed language.

One uses the following encoding:

    ZERO = []
    ONE  = [ZERO]
    TWO  = [ONE]
    
While the other uses [this encoding](http://github.com/raganwald/homoiconic/blob/master/2009-03-07/surreal.md#readme "Elegance and the Surreals"):

    Array.class_eval do

      def ^ numbers_to_the_right
        Number.new(self, numbers_to_the_right.kind_of?(Array) ? numbers_to_the_right : [numbers_to_the_right])
      end

    end

    class Number < Struct.new(:numbers_to_my_left, :numbers_to_my_right)

      # ...
  
    end
    
    ZERO = []   ^ []
    ONE  = ZERO ^ []
    TWO  = ONE  ^ []
    
The two programs would have entirely different type systems but both would calculate arithmetic correctly. If the type system was always part of the test suite, there would be no way to determine whether the two programs were functionally equivalent modulo a test suite, because each program would fail the other's type system assertions. To compare their arithmetic, we would have to use tests that were independent of the types chosen by the programmer.

That being said, it is possible to imagine the type systems becoming part of a test suite. Given a sufficiently introspective language, you could write tests that assert the existence of types with certain properties. While you might have two programs that are functionally equivalent modulo a test suite that says nothing about types, those same two programs might not be functionally equivalent when types are part of the tests.

As long as we do not require the type system to be part of the tests but treat it as something which may or not be a part of any particular test suite, we can use the same reasoning for untyped and typed languages.

**Functional Complexity Modulo a Test Suite**

Before we discuss complexity, we need a way to measure the *length* of programs. There are many debates we can have about how to measure program length, the important thing is to pick a reasonable metric and be consistent. For example, we can count the total number of symbols in a program's representation.

Now let's take a "program of interest" and a test suite. We can determine program of interest's functionality modulo the test suite using the method above. Consider the set of all programs functionally equivalent to our program of interest modulo our test suite, the set of all programs that produce the same number when passed to the test suite. (Although it is not necessary that our program satisfy the test suite, it can be helpful to think of the program satisfying the test suite, in which case we would be considering the set of all programs that satisfy the test suite.)

This is obviously an infinitely large set and quite imaginary. Infinite or not, how would we find the *shortest* program in the set? This is straightforward in practice although time consuming and [impossible in theory](http://en.wikipedia.org/wiki/Halting_problem). We simply generate every possible program by brute force, starting with all programs of length 1 and then all programs of length 2, and so forth growing in size. We take each candidate program and feed it to our test suite until one produces the same number as our program of interest. Quite obviously, we need only search the set of all programs from 1 to the length of our candidate program.

When we have found a program or reached the length of our program of interest, we know that no shorter program is functionally equivalent to our program of interest. The length we have reached is particularly interesting: it is the length of the shortest possible program that is functionally equivalent to our program of interest.

This length is the *functional complexity of our program modulo the test suite*. The functional complexity modulo some particular test suite is not a general-purpose metric of complexity for a program's representation, just its behaviour. From above:

    def cstr; '19620614';                      end
    def arry; %w(1962 06 14).join;             end
    def calc; (2**1 * 13**1 * 754639**1).to_s; end
    
All three programs have the exact same functional complexity modulo:

    def test(program)
      send(program) == '19620614' ? 1 : 0 rescue 0
    end
    
    def test_suite(program)
      test(program)
    end

But their representations vary substantially.

**Input Complexity**

A program's functional complexity modulo a test suite does not actually depend on the number produced by the test suite. It is simply the length of the shortest program producing the same number. For a really degenerate case, consider a program that fails all tests in a suite. What is it's functional complexity modulo that test suite? What is the shortest program that also fails all tests?

But let's take the case where a program satisfies a test suite. It's functional complexity modulo that test suite is the length of the shortest program that also satisfies all tests in the test suite. This is a very interesting measure of complexity, because we can reverse the relationship as follows: Given a test suite, the *satisfaction complexity of the test suite* is the length of the shortest program that satisfies the test suite.

Given a program that satisfies a test suite, we obviously know the satisfaction complexity of that test suite, it's the functional complexity of the program. However, we cannot necessarily find the satisfaction complexity of an arbitrary test suite without a program known to satisfy it. What satisfaction complexity does this test suite have?

    def truthy(program)
      !!send(program) ? 1 : 0 rescue 0
    end

    def falsy(program)
      !send(program) ? 1 : 0 rescue 0
    end
    
    def test_suite(program)
      truthy(program) * 2 + falsy(program)
    end

**Wrap Up**

This post has introduced some concepts I am using to work out some ideas about readability and maintainability. In a subsequent post, we will look at coupling within a program, at congruence between a program and a test suite, and how these affect program readability. In the mean time, here are a few things to ponder along with me...

* What is the relationship between the length of a program and its functional complexity modulo a test suite? Are longer programs more readable or more maintainable?
* The Kolmogorov-Chaitin complexity of a program is the length of the program's shortest description in some fixed universal description language... Programs whose Kolmogorov-Chaitin complexity is small relative to their length are not considered to be complex (adapted from the introduction to Wikipedia's article on [Kolmogorov complexity](http://en.wikipedia.org/wiki/Kolmogorov_complexity)). What is the relationship between a program's Kolmogorov-Chaitin complexity and it's functional complexity modulo a test suite?
* Test suites are programs too! What is the relationship between a test suite's satisfaction complexity and its own Kolmogorov-Chaitin complexity?

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0109_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)