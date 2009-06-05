TSTTCPW
===

The [Satisfaction Complexity](http://github.com/raganwald/homoiconic/blob/master/2009-06-02/functional_complexity.md#readme) of a test suite is defined as being the length of the shortest program that satisfies the test suite. It's a measure of the amount of information in the test suite. It's not just a theoretical concept: We can use the idea to answer the question *How many tests should we write?* as well as to answer the question *what kind of code should we write to satisfy a test suite?*

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

Left to their own devices, programmers faced with a specific bug report or a specific feature request will often write some specific, one-off code. Even if this is rare on your team, such one-offs accumulate over time building up technical debt until you refactor.

The fact that a one-off hard-coded special case satisfies our test suite suggests that we aren't describing what we want in enough detail. Let's add another test:

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
      
      attr_accessor :first_not_last
  
      def initialize(attributes)
        self.first_not_last = attributes[:name] == 'Reginald'
      end
      
      def name
        self.first_not_last ? 'Reginald' : 'Braythwayt'
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

**Shaker Style**

> "If it is not useful or necessary, free yourself from imagining that you need to make it.

> "If it is useful and necessary, free yourself from imagining that you need to enhance it by adding what is not an integral part of its usefulness or necessity.

> "And finally: If it is both useful and necessary and you can recognize and eliminate what is not essential, then go ahead and make it as beautifully as you can."

There is a tension between developing test cases and developing software. Neither activity is "free," and we know that while test cases contribute to the software development process, they aren't working software. So we wish to write as few test cases as possible... *But no fewer!*

Our thought experiment suggests how to proceed. First, write enough test cases such that the satisfaction complexity of the test suite is equal to the actual complexity of the requirements. Writing fewer test cases will lead to special cases. If we discover hard-coded special cases, add test suites that break them.

Second, always attempt to keep the code as minimalist and as simple as possible. People sometimes want to *add the least amount of code* to a program to add new functionality. That isn't the same as changing the program so that it has *the least amount of code that satisfies the test suite*.

If there is more code than necessary to satisfy the test suite, consider the possibility that the special cases and duplicated code aren't just crufty but actually reflect the program not performing the desired intent. Search for test cases that will break the special cases. If you can't think of one, perhaps there test cases reflect the requirements and you were wrong about there being more code than necessary. But if you *can* write a test case that breaks the cruft, do so and then refactor the code to get rid of the excess.

---

Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0109_en_US.pdf ""), [Twitter](http://twitter.com/)