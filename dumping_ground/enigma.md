Coding Enigmas
===

From [TSTTCPW](http://github.com/raganwald/homoiconic/blob/master/2009-06-05/tsttcpw.md#readme):

> Always attempt to keep the working code as minimalist and as simple as possible. People sometimes want to *add the least amount of code* to a program to add new functionality. That isn't the same as changing the program so that it has *the least amount of code that satisfies the test suite*. Prefer the latter to the former.

Hmmm. Does this make sense? Do we always want our program to have the least amount of code that satisfies the test suite, or are there times when having more code than necessary is a good thing?

If anecdote is any guide, many programmers do not care for the shortest possible expression of a program that satisfies a test suite. Leaving aside the controversy around using extremely short identifiers and operators, there is a significant and vocal group of programmers who feel that striving for brevity in a program makes the program more difficult to understand. (By brevity we are not talking about pure character counts, e.g. by using one-letter identifiers: We are talking about something akin to having as few symbols in our programs.)

That's interesting. Why would making a program shorter make it more difficult to understand? Let's look at some possibilities:

**The Enigma**

Humans sometimes work very hard on making things difficult to understand. The field devoted to this science is known as business jargon. No, that was a terrible joke. The actual field devoted to this science is *cryptography*. A desirable property of cryptographic algorithms is that changing just one bit of a plaintext message changes an average of 50% of the bits in the encrypted message, and does so in a way that appears to be random: There appears to be no way to predict *which* 50% of the bits will change.

How does this translate to programs? Consider the a programmer puzzling over a program. Perhaps she has a test suite and just one test is failing. Any time she makes even the smallest change somewhere in the program, 50% of the tests in the test suite immediately flip from pass to fail or from fail to pass. Even if she correctly discerns that making that change would flip the failing test to a passing test, the set of changes required to transform a program with just one failing test into a program with no failing tests could be computationally intractable.

expression to be the plaintext message and consider the test suite results to be the encrypted message. The analogy is not exact because the message is also the algorithm, but imagine a program with the same property: Changing just one symbol anywhere in the program would cause, on average, 50% of the tests to fail. A program with this property would require a lot of effort to understand because any one element of its functionality would depend upon the interaction between approximately 50% of its parts and the programmer cannot reliably know which 50% are affected.

A program has a certain amount of complexity, there's so much it must do. Therefore there can never be less information in the program than its program's Kolmogorov-Chaitin complexity. So how could a longer expression be more readable? A longer expression would seem to require more reading, more comprehension, and include extraneous and unnecessary information. What's going on here?

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

Now we show the program to the programmer and ask them to predict which of the sample tests pass and which fail, just like asking a challenger to validate and invalidate challenge sentences. We can measure the "readability" of the expression in various empirical ways, such as measuring the time required for the programmer to determine the correct answer by inspection. or we can work with statistically significant sample sets of programmers and measure how many answer the challenge correctly within a certain time limit.

Hand waving over the exact procedure, the idea is fairly straightforward: We are claiming that "readability" represents a programmer's ability to predict the behaviour of a program from examining its expression.

**Coupling**

One factor that strongly affects the readability of a program is the amount and style of coupling between its parts. As an anti-example, consider cryptography, the art of making things unreadable. A desirable property of cryptographic algorithms is that changing just one bit of a plaintext message changes an average of 50% of the bits in the encrypted message, and does so in a way that appears to be random: There is no way to predict *which* 50% of the bits will change.

How does this translate to programs? Consider the expression to be the plaintext message and consider the test suite results to be the encrypted message. The analogy is not exact because the message is also the algorithm, but imagine a program with the same property: Changing just one symbol anywhere in the program would cause, on average, 50% of the tests to fail. A program with this property would require a lot of effort to understand because any one element of its functionality would depend upon the interaction between approximately 50% of its parts and the programmer cannot reliably know which 50% are affected.

Although it is not certain that the shortest possible expression of a program would exhibit this kind of coupling between its symbols, I conjecture that it is quite likely that an extremely short expression of a program would be highly coupled. Here is my reasoning.

Consider a program where--on average--changing one symbol changes the behaviour of just one test. One way to construct such a program is to break it up such that each test has its own piece of code entirely independent of the other pieces for the other tests. Such a program has certain maintenance difficulties. And each piece might be easy or difficult to understand based on other factors. But all other things being equivalent, an uncoupled expression would have a big advantage over a highly coupled expression: There would be a fixed and small set of symbols responsible for the behaviour of each test.

Now think about a highly coupled expression of the same program. The highly coupled expression can use one symbol for multiple purposes. On average, each symbol is involved in code for 50% of the tests. My conjecture is that if the program has *N* tests, the size of an uncoupled expression will be on the order of *N* and the size of a highly coupled expression will be on the order of log*N*.

So I conjecture that as the expression of a program approaches its Kolmogorov-Chaitin complexity, its coupling increases. Fine. But how does that affect readability?

**Coupling and **

And as its coupling increases, its readability decreases. Note that I say "As the expression of a program approaches its Kolmogorov-Chaitin complexity." applying DRY or Single responsibility to a program can make it more readable up to a point. But our search for the Kolmogorov-Chaitin complexity of a program ignores that point and ruthlessly seeks out the most compact expression without regard for semantics.

**Mel**

Consider a the most compact expression of a program, the very shortest one that passes the test suite. One conjecture I have for why it might be unreadable is that it might pass the test suite *by coïncidence*. By this, I mean that although the result of the program is correct, the structure of the program is entirely unrelated to the test suite's structure. As a counter-example, consider business applications. Typically, there are entities (customers, products, accounts, addresses, &c.), relationships between the entities, and operations of some kind on the entities.

The test suite for such an application is going to be organized along those lines. For example, you might organize the test suite around operations to create customers, purchase products, deal with overdue accounts, and so forth. But what if the shortest possible expression of the program has no such organization internally?

Although that seems impossible if we think of a human programmer expressing the program, remember that a human didn't express it, we found it by brute force. Maybe instead of entities for customers, addresses, products and accounts there are expressions that put all data into a single key-value dictionary, or into a single undifferentiated list? maybe instead of operations defined in functions or methods there is data-driven logic that looks a little like a Greenspun Von Neumann machine, so there is just a single lookup-and-execute routine trampolining itself repeatedly?

Such a program might be very heard to read