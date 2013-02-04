TSTTCPW
===

The [Satisfaction Complexity](http://github.com/raganwald/homoiconic/blob/master/2009-06-02/functional_complexity.md#readme) of a test suite is defined as being the length of the shortest program that satisfies the test suite. It's a measure of the amount of information in the test suite. It's not just a theoretical concept: We can use the idea to answer the question *How many tests should we write?* as well as to answer the question *what kind of code should we write to satisfy a test suite?*

[![spiral (1839), Shaker Village, Pleasant Hill, Kentucky (c) 2007 Steve Minor, some rights reserved](http://farm1.static.flickr.com/222/445408457_d31c3d3cd0_d.jpg)](http://www.flickr.com/photos/sminor/445408457/ "spiral (1839), Shaker Village, Pleasant Hill, Kentucky (c) 2007 Steve Minor, some rights reserved") 

Consider a typical CRUD application like a Rails web site. I want to keep the examples really short, so let's imagine we are only testing a model class, and for our examples we won't bother with persistence. Here's our test suite:

    def test_suite(model_class)
      test0(model_class) rescue false
    end

    def test0(model_class)
      model = model_class.new(:name => 'Reginald')
      model.name == 'Reginald'
    end

It's a very simple test suite that tests our ability to initialize a model with an attribute and retrieve it with a method. Given the right ActiveRecord Juju and migration, this is a [doddle](http://en.wiktionary.org/wiki/doddle). And you might see a test something like this (with different syntax and living inside of a test framework) on almost any CRUD application.

But let's think about satisfaction complexity. What is the shortest program that will satisfy our (incredibly small) test suite? How about:

    class Reginald
  
      def initialize(attributes)
      end
  
      def name
        'Reginald'
      end
  
    end

Let's try it:

    test_suite(Reginald) 
      # => true
      
I'm thinking this isn't what we want. Before anyone claims this is a strawman argument, that nobody would write code like this in the "real world," let me point out that there is TONS of code lie this in the real world. I am aware of one "Enterprise" application where significant business logic is tied to fields having specific hard-coded strings in them.

> People sometimes want to *add the least amount of code* to a program to add new functionality. That isn't the same as changing the program so that it has *the least amount of code that satisfies the test suite*. Prefer the latter to the former.

Left to their own devices, programmers faced with a specific bug report or a specific feature request will often write some specific, one-off code. Even if this is rare on your team, such one-offs accumulate over time building up technical debt until you refactor.

The fact that a one-off hard-coded special case satisfies our test suite suggests that we aren't describing what we want in enough detail. By definition, *our test suite is lacking some information*. Let's add another test:

    def test_suite(model_class)
      test0(model_class) && test1(model_class) rescue false
    end

    def test1(model_class)
      model = model_class.new(:name => 'Braythwayt')
      model.name == 'Braythwayt'
    end
    
    test_suite(Reginald) # => false

Now if we were perverse (or perhaps if our software development process was perverse), we might come up with this program that satisfies the test suite:

    class ReginaldBraythwayt
  
      def initialize(attributes)
        @is_first = attributes[:name] == 'Reginald'
      end
      
      def name
        @is_first ? 'Reginald' : 'Braythwayt'
      end
  
    end
    
    test_suite(ReginaldBraythwayt) # => true
    
This is an obvious attempt to patch things up with more "special cases." But let's stop for a moment and think about our updated test suite. What is its satisfaction complexity? What is the shortest program that satisfies our new test suite? How about:

    class AnyName
      
      attr_accessor :name
      
      def initialize(attributes)
        self.name = attributes[:name]
      end
      
    end
    
    test_suite(AnyName) # => true

This class is shorter *and* closer to what we have in mind. The "special case" code is only shorter when our test suite is extremely small. As cases are added to the test suite, adding code to handle special cases quickly becomes longer than writing code that directly implements the desired intent.

**Shaker Built**

> "If it is not useful or necessary, free yourself from imagining that you need to make it.

> "If it is useful and necessary, free yourself from imagining that you need to enhance it by adding what is not an integral part of its usefulness or necessity.

> "And finally: If it is both useful and necessary and you can recognize and eliminate what is not essential, then go ahead and make it as beautifully as you can."

There is a tension between developing test cases and developing software. Neither activity is "free," and we know that while test cases contribute to the software development process, they aren't working software. So we wish to write as few test cases as possible... *But no fewer!*

Our thought experiment suggests how to proceed. First, we wish to write enough test cases such that the satisfaction complexity of the test suite is equal to the actual complexity of the requirements. Writing fewer test cases will lead to special cases. And we know how to do so: Write the cases we think matter and monitor the code. If we discover hard-coded special cases, we know that we need more tests. Add tests that break the special cases and hard-coded bits of cruft.

Second, always attempt to keep the working code as minimalist and as simple as possible. People sometimes want to *add the least amount of code* to a program to add new functionality. That isn't the same as changing the program so that it has *the least amount of code that satisfies the test suite*. Prefer the latter to the former.

If there is more code than necessary to satisfy the test suite, consider the possibility that the special cases and duplicated code aren't just crufty but actually reflect the program not performing the desired intent. Search for test cases that will break the special cases. If you can't think of one, perhaps there test cases reflect the requirements and you were wrong about there being more code than necessary. But if you *can* write a test case that breaks the cruft, do so and then refactor the code to get rid of the excess.

Taken together, these two practices will lead to the correct balance between test cases and working code.

---

NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[Reg Braithwaite](http://braythwayt.com): [CV](http://braythwayt.com/reginald/RegBraithwaite20120423.pdf ""), [Twitter](http://twitter.com/)