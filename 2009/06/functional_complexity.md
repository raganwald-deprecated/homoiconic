Functional Complexity Modulo a Test Suite (Extensively Revised)
===

I have a question:

What does it mean to discuss the *complexity* of a program? Do we mean the complexity of its representation? The complexity of its run-time behaviour? Or the complexity of its result? For example, here are three Ruby "programs" that appear to have equivalent behaviour (I have written these as methods for simplicity, but the same principle would hold if they were command line programs that wrote to standard out, web services, or just about anything else):

    def simple
      '19620614'
    end
    
    def long
      0b0001.to_s + 0b1001.to_s + 0b0110.to_s + 0b0010.to_s +
      0b0000.to_s + 0b0110.to_s + 0b0001.to_s + 0b0100.to_s
    end
    
    require 'zlib'
    
    def obscure
      Zlib::Inflate.inflate("x\2343\264432034\001\000\aU\001\236")
    end
    
One is very simple. One is very long but not very complex. The third does ridiculously complex things at run time.

**Meaningful programs and tests**

To determine a program's functionality, we will *test* it. We're familiar with tests. A test is a single function that takes a program as input and produces either true (pass) or false (fail) as output. Tests can be *consistent*: When given the same program, a consistent test either always passes or always fails. Tests can also be We will call a test *meaningful* if it is has two pif there exists at least one program that passes the test and at least one program that fails the test.

Pop quiz: Given the proposition that for every test there exists the inversion of the test, a test for which if program, P passes one test it must fail the other, show that every program must pass at least one test and every program must fail at least one test.

For our purposes, we are only considering the behaviour of programs and meaningful tests. Unless we say otherwise, the word "test" implies a meaningful test. Tests and programs outside of this essay may have other properties, but this is what we mean by the words test and program.

Here is an example of a meaningful test:

    def test(program)
      send(program) == '19620614' rescue false
    end
    
    test(:simple)
      => true

A digression: Most programming languages have the notion of an invalid representation, something that is not a program. It could be that a text representation of the program has invalid syntax. It could be that while its syntax is valid, there are other errors that prevent it from running *any* tests. Likewise, most systems have the notion of un-handled runtime errors such as division by zero. If such a thing occurs when running a test, we declare that the test fails, always. Tests are also programs of a sort, so naturally a test that is not valid always fails. By definition above, invalid programs cannot be meaningful, and neither can invalid tests.

That being said, a partially invalid program may be meaningful. The parts of the program that are valid can be tested, so there could be at least one meaningful test for the program.

**Programs, Test Suites, Satisfaction, and Functionality**

Consider every set of one or more meaningful tests. If a program passes all of the tests in the set we say that the program *satisfies* the set of tests. A *test suite* is a finite set of meaningful tests where there exists at least one program that satisfies all of the set's tests.

Here is an example of a test suite:

    def test0(program)
      send(program, 1) == 1 rescue false
    end
    
    def test1(program)
      send(program, 1, 2) == 3 rescue false
    end
    
    def test2(program)
      send(program, 1, 2, 3) == 6 rescue false
    end
    
    def test_suite_alpha(program)
      test0(program) && test1(program) && test2(program)
    end

And here is a program that satisfies the test suite:

    def simple_inject(*list)
      list.inject { |a,b| a + b }
    end
    
    test_suite_alpha(:simple_inject)
      => true
      
Note that we can easily construct a test suite that is not satisfied by our program:

    def test3(program)
      send(program) == 0 rescue false
    end

    def test_suite_beta(program)
      test0(program) && test1(program) && test2(program) && test3(program)
    end
    
    test_suite_beta(:simple_inject)
      => false

**Satisfaction Complexity**

Before we discuss complexity, we need a way to measure the *length* of programs. There are many debates we can have about how to measure program length, the important thing is to pick a reasonable metric and be consistent. For example, we can count the total number of symbols in a program's representation.

Now let's take a test suite and any one program that satisfies it. We shall call the length of the program *M*. Consider the set of all programs that satisfy our test suite. This is obviously an infinitely large set and quite imaginary. Infinite or not, how would we find the *shortest* program in the set? This is straightforward in practice although time consuming and [impossible in theory](http://en.wikipedia.org/wiki/Halting_problem). We simply generate every possible program by brute force, starting with all programs of length 1 and then all programs of length 2, and so forth growing in size. We take each candidate program and feed it to our test suite until one satisfies it. Quite obviously, we need only search the set of all programs from 1 to the *M*, we know it can never be longer than that.

When we have found a program or reached *M*, we know that we have found the length of the shortest possible program that satisfies our test suite. This length is the *satisfaction complexity* of the test suite.

Satisfaction complexity is an important property. A test suite may have an extremely complex representation (especially if written by someone infected with the test framework complexification virus). But regardless of its representation, its *meaning* is the same: Every test suite encodes a description of a program's behaviour. A test suite's satisfaction complexity measures the complexity of the described behaviour.

**Functional Complexity, Congruence, and Equivalence**

To determine satisfaction complexity, we started with a test suite and a program that satisfies it. To determine the functional complexity of a program, we start with a program and a test suite it satisfies. The *functional complexity of a program modulo a test suite* is the satisfaction complexity of that test suite. Obviously, the functional complexity of a program modulo a test suite can never be larger than the program's length.

Every program that satisfies the same test suite has the same functional complexity modulo that test suite. Therefore, we say that if two programs both satisfy the same test suite, they are *congruent modulo a test suite*. Any two or more programs that satisfy the same test suite have the same functional complexity modulo that test suite. As far as we know by observing their behaviour with the test suite, they do the same thing.

And now we can answer the original question. Given:

    def simple
      '19620614'
    end
    
    def long
      0b0001.to_s + 0b1001.to_s + 0b0110.to_s + 0b0010.to_s +
      0b0000.to_s + 0b0110.to_s + 0b0001.to_s + 0b0100.to_s
    end
    
    require 'zlib'
    
    def obscure
      Zlib::Inflate.inflate("x\2343\264432034\001\000\aU\001\236")
    end
    
All three programs are congruent modulo:

    def test(program)
      send(program) == '19620614' rescue false
    end
    
    def test_suite(program)
      test(program)
    end

This is the closest we will come to saying that they are equivalent: Given the observation of our test suite, we observe the same results from them. If they were the only three programs to satisfy our test suite, we would say that the satisfaction complexity of our test suite was equal to the length of `simplest`, and that even though `obscure` has a much more complex representation and a much more elaborate run-time behaviour, its functional complexity modulo our test suite is equal to simplest's length.

**Wrap Up**

This post has introduced some concepts I am using to work out some ideas about readability and maintainability. In a subsequent post, we will look at coupling within a program, at congruence between a program and a test suite, and how these affect program readability. In the mean time, here are a few things to ponder along with me...

* What is the relationship between the length of a program and its functional complexity modulo a test suite? Are longer programs more readable or more maintainable? Why or when is this the case?
* The Kolmogorov-Chaitin complexity of a program is the length of the program's shortest description in some fixed universal description language... Programs whose Kolmogorov-Chaitin complexity is small relative to their length are not considered to be complex (adapted from the introduction to Wikipedia's article on [Kolmogorov complexity](http://en.wikipedia.org/wiki/Kolmogorov_complexity)). What is the relationship between a program's Kolmogorov-Chaitin complexity and it's functional complexity modulo a test suite?
* Test suites are programs too! What is the relationship between a test suite's satisfaction complexity and its own Kolmogorov-Chaitin complexity?

Thanks for your patience with my pedantry!

---

*post scriptum*: Does strong type checking affect our thinking?

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
    
The two programs would have entirely different type systems but both would calculate arithmetic correctly. If the type system was always part of the test suite, there would be no way to determine whether the two programs were congruent modulo a test suite, because each program would fail the other's type system assertions. To compare their arithmetic, we would have to use tests that were independent of the types chosen by the programmer.

In other words, these two programs are by necessity congruent modulo test suites that ignore their type architecture.

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