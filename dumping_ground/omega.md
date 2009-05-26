Untitled (so far)
===

> In algorithmic information theory (a subfield of computer science), the Kolmogorov-Chaitin complexity (also known as descriptive complexity, Kolmogorov complexity, stochastic complexity, algorithmic entropy, or program-size complexity) of an object such as a piece of text is a measure of the computational resources needed to specify the object... More formally, the complexity of a string is the length of the string's shortest description in some fixed universal description language... Strings whose Kolmogorov-Chaitin complexity is small relative to the string's size are not considered to be complex.  --Adapted from the introduction to Wikipedia's article on [Kolmogorov complexity](http://en.wikipedia.org/wiki/Kolmogorov_complexity)

&nbsp;
    
> At age 15 I had the idea--anticipated by Leibniz in 1686--of looking at the size of computer programs and of defining a random string of bits to be one for which there is no program for calculating it that is substantially smaller than it is. --Gregory Chaiten, [Meta Math! The Quest for Omega](http://www.amazon.com/gp/product/1400077974?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=1400077974)

When writing programs, we do (at least) two things: We think of what the program must do, and we look for the right way to express the program using our tools. "The Right Way" is an awfully slippery concept, it seems that given *N* programmers arguing about the right way to write a given program, the only guarantee is that there will be at least *N* + 1 opinions expressed about the right way to proceed.

**Complexification**

For a moment, let's cast aside all soft considerations and think about program complexity. To be specific, when talking about programs we shall mean the set of all notations or expression that produce the same observable result. Trivially, here are three different expressions that are actually the same program:

    puts '19620614'
    puts %w(1962 06 14).join
    puts 2**1 * 13**1 * 754639**1

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

**Digression: Balance and Tension in Jazz Music**

> Try to vary the rhythms somewhat and add or delete notes here and there, to maintain a balance between the expected and the unexpected.--[Elements of the Jazz Language for the Developing Improvisor](http://www.amazon.com/gp/product/157623875X?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=157623875X), Jerry Coker

Jerry Coker is talking about the elusive balance between the expected and the unexpected in music. His model is that as a musician plays, the active listener "plays along" mentally, predicting what will happen next. If the music is too predictable, the listener grows bored. If the music is too unpredictable, the listener is confused and frustrated. But when the correct balance is achieved, the listener will be correct some of the time and surprised some of the time. This produces a pleasant sensation of being fully engaged in the music while being surprised some of the time keeps the listener interested and learning.

The balance between "expected" and "unexpected" is relative to the listener, of course. Most listeners gradually expand their "comprehension" of music just as a musician expands her "vocabulary" with practice and study. Thus, they learn to anticipate a wider variety of styles and devices, and what may be surprising or even chaotic to a less experienced listener may be pleasing or even banal to the highly experienced listener.

**Readability**

In general, human programmers do not care for the shortest possible expression of a program. Two of the reasons given for dislike are that such programs are unmaintainable and unreadable.

"Unmaintainability" carries some weight with me. It expresses a requirement for software that our current test suite practices and tools do not capture: Given the statistically most likely changes we expect in the test suite, which expressions of a program are easiest to modify to satisfy the updated test suite?

But for now, let's focus on "unreadability" as a motivation for disliking extremely short expressions of programs. Why would extremely short programs be difficult to read? Although empirically this appears to be true for many programmers, it is not obviously true to me. In other words, my intuition is that it shouldn't be true. Why am I wrong?

After all, a program has a certain amount of complexity, there's so much it must do. Therefore there can never be less information in an expression than its program's Kolmogorov-Chaitin complexity. So how could a longer expression be more readable? A longer expression would seem to require more reading, more comprehension, and include extraneous and unnecessary information. What's going on here?

Well, let's start by defining what we mean by "readability."

**Queries, Theories, and Understanding**

I own a charming game called "Queries and Theories." It's a game based on linguistics. A vastly simplified version of Queries and Theories called "Mastermind" was a game craze in the 1970s. Queries and Theories was based on the idea of a language expressed as "sentences" of "words." The words were colored chips, and the sentences were simple strings of chips. A language would have a "vocabulary" consisting of the possible colours of chips, and a "grammar" which would be rules for determining a valid sentence in the language. You can imagine how the game might work by thinking of BNF grammar rules.

One player would compose a language with a strict limit on the vocabulary and complexity of rules. The other players would then issue queries in the form of candidate sentences. The composer never reveals the rules but indicates whether each sentence is valid or invalid. Eventually, one of the queriers ("a challenger") develops some confidence that they understand the language and issues a challenge.

The composer then puts three sentences forth and the challenger must correctly determine whether the sentences are valid or invalid. The challenger need not guess the exact rule formation, but rather must simply understand the behaviour of the language well enough to interpret it.

This is, of course, very much like learning a language in real life. Many, many people speak a language excellently while being entirely unable to write out a formal grammar for it.

Now let's consider a variation on Queries and Theories. In this variation, the composer composes a language and reveals the grammar to the players. They study it without being able to pose queries, and when a player is confident of his ability to understand the language, he issues a challenge and the composer puts three sentences to the challenger for validation as usual.

In our variation, the players are attempting to deduce the "behaviour" of the language from examining its rules alone. This is very similar to trying to read the expression of a program. And thus, we have a crude mechanism for measuring the readability of a program's expression for a given programmer.

**Measuring Readability Empirically**

We start with a full test suite and an expression passing the entire test suite. Neither have been shown to our subject programmer. We now select a small number of tests, say ten tests. We are permitted to permute zero or more of the tests such that they fail instead of pass, and we do so. We show our sample tests to the programmer and we presume that the programmer understands them. (In other words, we are hand-waving and saying the test suite is readable! Fortunately, this is not a dissertation and I need not fear disqualification for such a gaping logical hole). The sample tests are just like the challenge sentences in Queries and Theories.

Now we show the program expression to the programmer and ask them to predict which of the sample tests pass and which fail, just like asking a challenger to validate and invalidate challenge sentences. We can measure the "readability" of the expression in various empirical ways, such as measuring the time required for the programmer to determine the correct answer by inspection. or we can work with statistically significant sample sets of programmers and measure how many answer the challenge correctly within a certain time limit.

Hand waving over the exact procedure, the idea is fairly straightforward: We are claiming that "readability" represents a programmer's ability to predict the behaviour of a program from examining its expression.

**Mel**

Consider a the most compact expression of a program, the very shortest one that passes the test suite. One conjecture I have for why it might be unreadable is that it might pass the test suite *by coïncidence*. By this, I mean that although the result of the program is correct, the structure of the program is entirely unrelated to the test suite's structure. As a counter=example, consider business applications. Typically, there are entities (customers, products, accounts, addresses, &c.), relationships between the entities, and operations of some kind on the entities.

The test suite for such an application is going to be organized along those lines. For example, you might organize the test suite around operations to create customers, purchase products, deal with overdue accounts, and so forth. But what if the shortest possible expression of the program has no such organization internally?

Although that seems impossible if we think of a human programmer expressing the program, remember that a human didn't express it, we found it by brute force. Maybe instead of entities for customers, addresses, products and accounts there are expressions that put all data into a single key-value dictionary, or into a single undifferentiated list? maybe instead of operations defined in functions or methods there is data-driven logic that looks a little like a Greenspun Von Neumann machine, so there is just a single lookup-and-execute routine trampolining itself repeatedly?

Such a program might be very heard to read