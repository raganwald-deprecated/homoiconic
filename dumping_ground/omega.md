Untitled (so far)
===

> In algorithmic information theory (a subfield of computer science), the Kolmogorov-Chaitin complexity (also known as descriptive complexity, Kolmogorov complexity, stochastic complexity, algorithmic entropy, or program-size complexity) of an object such as a piece of text is a measure of the computational resources needed to specify the object... More formally, the complexity of a string is the length of the string's shortest description in some fixed universal description language... Strings whose Kolmogorov-Chaitin complexity is small relative to the string's size are not considered to be complex.  --Adapted from the introduction to Wikipedia's article on [Kolmogorov complexity](http://en.wikipedia.org/wiki/Kolmogorov_complexity)

&nbsp;
    
> At age 15 I had the idea--anticipated by Leibniz in 1686--of looking at the size of computer programs and of defining a random string of bits to be one for which there is no program for calculating it that is substantially smaller than it is. --Gregory Chaiten, [Meta Math! The Quest for Omega](http://www.amazon.com/gp/product/1400077974?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=1400077974)

**Introduction**

Let's talk about program complexity. To be specific, when talking about programs we shall mean the set of *all* notations or expression that produce the same observable result, not just one unique expression. And expression is the statement or collection of statements

Trivially, here are three different expressions that are actually the same program:

    puts '19620614'
    puts %w(1962 06 14).join
    puts 2**1 * 13**1 * 754639**1
    
How do we know they all produce the same result? Let's use an empirical method. For any program, we shall define a *test suite* that inspects the program's behaviour. Each test suite shall have one or more tests in it, and if we feed a

Every program has a certain amount of Kolmogorov-Chaitin complexity. Using the definition given above, the Kolmogorov-Chaitin complexity for a program is the size of the most concise expression of the program. Some expressions of a program will be much larger than its Kolmogorov-Chaitin complexity, some only a little larger, and perhaps as few as one will be exactly the Kolmogorov-Chaitin complexity length.

Now many of the expressions for a given program will be in different "languages" or systems of notation. For the moment, let us assume that we are only working with one human-readable system of notation. For example, if we choose "Ruby" as the system of notation, when we think about a program we are thinking of all of the different ways to express that program in Ruby.

And we are only considering the primary human-readable expression of the program. If we are thinking "C++," we are not thinking of the binary code its compiler produces. For our purposes, the Kolmogorov-Chaitin complexity of a C++ program is the most concise expression of that program in C++.

Finding the Kolmogorov-Chaitin complexity of a program is easy in practice although [impossible in theory](http://en.wikipedia.org/wiki/Halting_problem). You need at least one expression of the program and a means of demonstrating that your expression is correct. Any one expression of the program and an automated test suite will do.

Let's say your expression is of length *L*. What do we mean by length *L*? Characters? Lines of code?? I am going to say no, we do not mean characters or lines of code. These measures lead us down pathways that are annoying to debate and unenlightening to ponder. Let us say instead that we mean something like symbols excluding separators, white space, and punctuation. So these two expressions have the same length:

    class A; def b; 3.times { p 'c' } end end
    class MyTestClass
      def do_something_nice
        3.times do
          p 'c'
        end
      end
    end

Now we can proceed. Count the length of your expression and perform an exhaustive brute-force search of all expressions from 1..(*L*-1) in length. Generate all the possible expressions and feed each one to your test suite. The length of the shortest expression that passes the test suite is the Kolmogorov-Chaitin complexity of your program.

I bring up the complexity for a specific purpose: When looking at different expressions of the same program, we know that they have the exact same amount of complexity. One is not more or less complex than the other. That being said, one expression amy be more readable than the other.

**Readability**

In general, human programmers do not care for the shortest possible expression of a program. Two of the reasons given for dislike are that such programs are unmaintainable and unreadable.

"Unmaintainability" carries some weight with me. It expresses a requirement for software that our current test suite practices and tools do not capture: Given the statistically most likely changes we expect in the test suite, which expressions of a program are easiest to modify to satisfy the updated test suite?

But for now, let's focus on "unreadability" as a motivation for disliking extremely short expressions of programs. Why would extremely short programs be difficult to read? Although empirically this appears to be true for many programmers, it is not obviously true to me. In other words, my intuition is that it shouldn't be true. Why am I wrong?

After all, a program has a certain amount of complexity, there's so much it must do. Therefore there can never be less information in an expression than its program's Kolmogorov-Chaitin complexity. So how could a longer expression be more readable? A longer expression would seem to require more reading, more comprehension, and include extraneous and unnecessary information. What's going on here?

Well, let's start by defining what we mean by "readability."

**Queries, Theories, and Understanding**

I own a charming game called [Queries and Theories](http://wffnproof.com/inc/sdetail/123 "QUERIES 'N THEORIES: The Game of Science and Language"). It's a game based on linguistics (a related game called [Mastermind](http://tinyurl.com/master-mind-game "Mastermind on Wikipedia") was a game craze in the 1970s). Queries and Theories was based on the idea of a language expressed as "sentences" of "words." The words were colored chips, and the sentences were simple strings of chips. A language would have a "vocabulary" consisting of the possible colours of chips, and a "grammar" which would be rules for determining a valid sentence in the language. You can imagine how the game might work by thinking of BNF grammar rules.

One player--the Native--would compose a language with a strict limit on the vocabulary and complexity of rules. The other players would then issue queries in the form of candidate sentences. The Native never reveals the rules but indicates whether each sentence is valid or invalid. Eventually, one of the queriers ("a challenger") develops some confidence that they understand the language and issues a challenge.

The Native then puts three sentences forth and the challenger must correctly determine whether the sentences are valid or invalid. The challenger need not guess the exact rule formation, but rather must simply understand the behaviour of the language well enough to interpret it.

This is, of course, very much like learning a language in real life. Many, many people speak a language excellently while being entirely unable to write out a formal grammar for it.

Now let's consider a variation on Queries and Theories. In this variation, the Native composes a language and reveals the grammar to the players. They study it without being able to pose queries, and when a player is confident of his ability to understand the language, he issues a challenge and the Native puts three sentences to the challenger for validation as usual.

In our variation, the players are attempting to deduce the "behaviour" of the language from examining its rules alone. This is very similar to trying to read the expression of a program. And thus, we have a crude mechanism for measuring the readability of a program's expression for a given programmer.

**Measuring Readability Empirically**

We start with a full test suite and an expression passing the entire test suite. Neither have been shown to our subject programmer. We now select a small number of tests, say ten tests. We are permitted to permute zero or more of the tests such that they fail instead of pass, and we do so. We show our sample tests to the programmer and we presume that the programmer understands them. (In other words, we are hand-waving and saying the test suite is readable! Fortunately, this is not a dissertation and I need not fear disqualification for such a gaping logical hole). The sample tests are just like the challenge sentences in Queries and Theories.

Now we show the program expression to the programmer and ask them to predict which of the sample tests pass and which fail, just like asking a challenger to validate and invalidate challenge sentences. We can measure the "readability" of the expression in various empirical ways, such as measuring the time required for the programmer to determine the correct answer by inspection. or we can work with statistically significant sample sets of programmers and measure how many answer the challenge correctly within a certain time limit.

Hand waving over the exact procedure, the idea is fairly straightforward: We are claiming that "readability" represents a programmer's ability to predict the behaviour of a program from examining its expression.

**Coupling**

One factor that strongly affects the readability of a program is the amount and style of coupling between its parts. As an anti-example, consider cryptography, the art of making things unreadable. A desirable property of cryptographic algorithms is that changing just one bit of a plaintext message changes an average of 50% of the bits in the encrypted message, and does so in a way that appears to be random: There is no way to predict *which* 50% of the bits will change.

How does this translate to program expressions? Consider the expression to be the plaintext message and consider the test suite results to be the encrypted message. The analogy is not exact because the message is also the algorithm, but imagine a program with the same property: Changing just one symbol anywhere in the program would cause, on average, 50% of the tests to fail. A program with this property would require a lot of effort to understand because any one element of its functionality would depend upon the interaction between approximately 50% of its parts and the programmer cannot reliably know which 50% are affected.

Although it is not certain that the shortest possible expression of a program would exhibit this kind of coupling between its symbols, I conjecture that it is quite likely that an extremely short expression of a program would be highly coupled. Here is my reasoning.

Consider a program where--on average--changing one symbol changes the behaviour of just one test. One way to construct such a program is to break it up such that each test has its own piece of code entirely independent of the other pieces for the other tests. Such a program has certain maintenance difficulties. And each piece might be easy or difficult to understand based on other factors. But all other things being equivalent, an uncoupled expression would have a big advantage over a highly coupled expression: There would be a fixed and small set of symbols responsible for the behaviour of each test.

Now think about a highly coupled expression of the same program. The highly coupled expression can use one symbol for multiple purposes. On average, each symbol is involved in code for 50% of the tests. My conjecture is that if the program has *N* tests, the size of an uncoupled expression will be on the order of *N* and the size of a highly coupled expression will be on the order of log*N*.

So I conjecture that as the expression of a program approaches its Kolmogorov-Chaitin complexity, its coupling increases. Fine. But how does that affect readability?

**Coupling and **

And as its coupling increases, its readability decreases. Note that I say "As the expression of a program approaches its Kolmogorov-Chaitin complexity." applying DRY or Single responsibility to a program expression can make it more readable up to a point. But our search for the Kolmogorov-Chaitin complexity of a program ignores that point and ruthlessly seeks out the most compact expression without regard for semantics.

**Mel**

Consider a the most compact expression of a program, the very shortest one that passes the test suite. One conjecture I have for why it might be unreadable is that it might pass the test suite *by coïncidence*. By this, I mean that although the result of the program is correct, the structure of the program is entirely unrelated to the test suite's structure. As a counter-example, consider business applications. Typically, there are entities (customers, products, accounts, addresses, &c.), relationships between the entities, and operations of some kind on the entities.

The test suite for such an application is going to be organized along those lines. For example, you might organize the test suite around operations to create customers, purchase products, deal with overdue accounts, and so forth. But what if the shortest possible expression of the program has no such organization internally?

Although that seems impossible if we think of a human programmer expressing the program, remember that a human didn't express it, we found it by brute force. Maybe instead of entities for customers, addresses, products and accounts there are expressions that put all data into a single key-value dictionary, or into a single undifferentiated list? maybe instead of operations defined in functions or methods there is data-driven logic that looks a little like a Greenspun Von Neumann machine, so there is just a single lookup-and-execute routine trampolining itself repeatedly?

Such a program might be very heard to read