Anaphora in Ruby
===

> In natural language, an anaphor is an expression which refers back in the conversation. The most common anaphor in English is probably "it," as in "Get the wrench and put it on the table." Anaphora are a great convenience in everyday language--imagine trying to get along without them--but they don't appear much in programming languages. For the most part, this is good. Anaphoric expressions are often genuinely ambiguous, and present-day programming languages are not designed to handle ambiguity.  --Paul Graham, [On Lisp](http://www.paulgraham.com/onlisp.html "On Lisp")

**The anaphoric parameter**

Oliver Steele wrote a nice little Javascript library called [Functional Javascript](http://osteele.com/sources/javascript/functional/ "Functional Javascript"). Javascript is a particularly verbose language descended from Lisp. It's syntax for writing anonymous functions is particularly verbose, and Oliver decided that if you wanted to write a lot of anonymous functions, you'd better have a more succinct way to write them. So he added "String Lambdas" to Javascript, and alternate syntax for anonymous functions.

[String#to\_proc](http://github.com/raganwald/homoiconic/blob/master/2008-11-28/you_cant_be_serious.md "You can't be serious!?") is a port of Oliver's String Lambdas to Ruby. One of the things you can do with String#to\_proc is define a block (or a proc) that takes one parameter with an expression containing an underscore instead of explicitly naming a parameter.

For example, instead of `(1..100).map { |x| (1/x)+1 }`, you can write `(1..100).map(&'(1/_)+1')`. The underscore is an anaphor, it refers back to the block's parameter just as the word "it" in this sentence refers back to the word "anaphor." The win is brevity: You don't have to define a parameter just to use it once.

String#to\_proc does a lot more than just provide anaphors for single parameters in blocks, of course. But it does provide this specific form of anaphora in Ruby.

**Another implementation of the anaphoric parameter**

(I read the following idea in a blog post a few years ago. I can't find the original to cite and praise the author's ingenuity. If you recognize it, please email me or fork homoiconic and add the appropriate citation, Thanks!)

Symbol#to\_proc is the standard way to abbreviate blocks that consist of a single method invocation, typically without parameters. For example if you want the first name of a collection of people records, you might use `Person.all(...).map(&:first_name)`.

If you want to do more, such as invoke a method with a parameter, or if you want to chain several methods, you are out of luck. Symbol#to\_proc does not allow you to write `Person.all(...).map(&:first_name[0..3])`. One hack creates the illusion of an anaphor, allowing you to invoke method with parameters and to chain more than one method. Here's some code illustrating the technique:

    class AnaphorProxy < BlankSlate
  
      def initialize(proc = lambda { |x| x })
        @proc = proc
      end
  
      def to_proc
        @proc 
      end
  
      def method_missing(symbol, *arguments, &block)
        AnaphorProxy.new(
          lambda { |x| self.to_proc.call(x).send(symbol, *arguments, &block) }
        )
      end
  
    end

    class Object
  
      def it
        AnaphorProxy.new
      end
  
    end

    (1..10).map(&it * 2 + 1) # => [3, 5, 7, 9, 11, 13, 15, 17, 19, 21]
    
What happens is that "it" is a method that returns an AnaphorProxy. The default proxy is an object that answers the Identity function in response to #to\_proc. Think about out how `(1..10).map(&it) => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]` works: "it" is a method that returns the default AnaphorProxy; using &it calls AnaphorProxy#to\_proc and receives `lambda { |x| x }` in return; #map now applies this to `1..10` and you get `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]`.

If you send messages to an AnaphorProxy, you get another AnaphorProxy that "records" the messages you send. So `it * 2 + 1` evaluates to an AnaphorProxy that returns `lambda { |x| lambda { |x| lambda { |x| x }.call(x) * 2 }.call(x) + 1 }`. This is equivalent to `lambda { |x| x * 2 + 1}` but more expensive to compute and dragging with it some closed over variables.

As you might expect from a hack along these lines, there are all sorts of things to trip us up. `(1..10).map(&it * 2 + 1)` works, but `(1..10).map(&1 + it * 2)` does not. Unexpected things happen if you try to "record" an invocation of #to\_proc. And because of the way parameters are "recorded" when the AnaphorProxy is created rather than looked up when the messages are sent, you might be surprised by its behaviour when side effects are involved.

So while String#to\_proc allows you to write things like `(1..10).map(&'1 + it * 2')`, this hack does not.

**Anaphors for conditionals**

Many people are familiar with the [andand gem](http://github.com/raganwald/andand "raganwald's andand at master - GitHub"). Say you want to write some code like this:

    big_long_calculation() && big_long_calculation().foo

Most of the time you ought to "cache" the big long calculation in a temporary variable like this:

    (it = big_long_calculation()) && it.foo

That's such a common idiom, #andand gives you a much more succinct way to write it:

    big_long_calculation().andand.foo

So the idea behind #andand is to express a test for nil and doing something with the result if it is not nil in a very compact way. This is not a new idea. Paul Graham gives this very example when describing the rationale for [anaphoric macros](http://www.bookshelf.jp/texi/onlisp/onlisp_15.html "Onlisp:  Anaphoric Macros"):

> It's not uncommon in a Lisp program to want to test whether an expression returns a non-nil value, and if so, to do something with the value. If the expression is costly to evaluate, then one must normally do something like this:

    (let ((result (big-long-calculation)))
      (if result
          (foo result)))

> Wouldn't it be easier if we could just say, as we would in English:

    (if (big-long-calculation)
        (foo it))

> In natural language, an anaphor is an expression which refers back in the conversation. The most common anaphor in English is probably "it," as in "Get the wrench and put it on the table." Anaphora are a great convenience in everyday language--imagine trying to get along without them--but they don't appear much in programming languages. For the most part, this is good. Anaphoric expressions are often genuinely ambiguous, and present-day programming languages are not designed to handle ambiguity.

WIth an anaphoric macro, the anaphor "it" is bound to the result of the if expression's test clause, so you can express "test for nil and do something with the result if it is not nil" in a compact way.

**Anaphors for conditionals in Ruby?**

Reading about Lisp's anaphoric macros made me wonder whether anaphors for conditionals would work in Ruby. I find `(it = big_long_calculation()) && it.foo` cluttered and ugly, but perhaps I could live without #andand if I could write things like:

    if big_long_calculation(): it.foo end
    
This is relatively easy to accomplish using [rewrite_rails](http://github.com/raganwald/rewrite_rails "raganwald's rewrite_rails at master - GitHub"). In the most naïve case, you want to rewrite all of your if statements such that:

    if big_long_calculation() then
      it.foo
    end
    
Becomes:

    if (it = big_long_calculation()) then
      it.foo
    end

You can embellish such a hypothetical rewriter with optimizations such as not assigning `it` unless there is a variable reference somewhere in the consequent or alternate clauses and so forth, but the basic implementation is straightforward.

The trouble with this idea is that in Ruby, *There Is More Than One Way To Do It* (for any value of "it"). If we implement anaphors for conditionals, we ought to implement them for all of the ways a Ruby programmer might write a conditional. As discussed, we must support:

    if big_long_calculation() then
      it.foo
    end
    
Luckily, that's the exact same thing as:

    if big_long_calculation(): it.foo end
    
They both are parsed into the exact same abstract syntax tree expression. Good. Now what about this case:

    it.foo if big_long_calculation()
    
That doesn't read properly. The anaphor should follow the subject, not precede it. If we want our anaphors to read sensibly, we really want to write:

    big_long_calculation().foo if it           # or
    big_long_calculation().foo unless it.nil?
    
These read more naturally, but supporting these expressions would invite Yellow Edge Case Cranial Headache or "YECCH." Behind the scenes, Ruby parses both of the following expressions identically:

    big_long_calculation().foo unless it.nil? # and
    unless it.nil?
      big_long_calculation().foo
    end

So you would have to have a rule that if the anaphor appears in the test expression, it refers to something from the consequent expression, not from any preceding test expression. But if you tried that rule, how would you handle this code?

    if calculation_that_might_return_a_foobar()
      if it.kind_of?(:Foobar)
        number_of_foobars += 1
      end
    end
    
This doesn't work as expected because the anaphor would refer forward to its consequent expression `number_of_foobars += 1` rather than backwards to the enclosing test expression `calculation_that_might_return_a_foobar()`. You can try to construct some rules for disambiguating things, but you're going to end up asking programmers to memorize the implementation of how things actually work rather than relying on familiarity with how anaphors work in English.

Another problem with supporting `big_long_calculation().foo unless it.nil?` is that we now need some rules to figure out that the anaphor refers to `big_long_calculation()` and not to `big_long_calculation().foo`. Whatever arbitrary rules we pick are going to introduce ambiguity. What shall we do about:

    big_long_calculation().foo       unless it.nil?
    big_long_calculation().foo.bar   unless it.nil?
    big_long_calculation() + 3       unless it.nil?
    3 + big_long_calculation()       unless it.nil?
    big_long_calculation(3)          unless it.nil?
    big_long_calculation(foo())      unless it.nil?
    big_long_calculation(foo(bar())) unless it.nil?

In my opinion, if we can't find clean and easy to understand support for writing conditionals as suffixes, we aren't supporting Ruby conditionals. To underscore the difficulty, let's also remember that Ruby programmers idiomatically use operators to express conditional expressions. Given:

    big_long_calculation() && big_long_calculation().foo

We want to write:

    big_long_calculation() && it.foo

This is near and dear to my heart: The name "andand" comes from this exact formulation. #andand doesn't enhance an if expression, it enhances the double ampersand operator. One can see at a glance that implementing support for `big_long_calculation() && it.foo` is fraught with perils. What about `big_long_calculation() + it.foo`? What about `big_long_calculation().bar && it.foo`?

It seems on the face of it that it is much harder to write anaphors for conditionals in Ruby than for conditionals Lisp. This isn't so surprising. Lisp has an extremely regular lack of syntax, so we don't have to concern ourselves with as many cases as we do in Ruby.

**Old school anaphora**

Anaphora have actually been baked into Ruby from its earliest days. Thanks to its Perl heritage, a number of global variables act like anaphora. For example, `$&` is a global variable containing the last successful regular expression match, or nil if the last attempt to match failed. So instead of writing something like:

    if match_data = /reg(inald)?/.match(full_name) then puts match_data[0] end
    
You can use $& as an anaphor and avoid creating another explicit temporary variable, just like the anaphor in a conditional:

    if /reg(inald)?/.match(full_name) then puts $& end 
    
These 'anaphoric' global variables have a couple of advantages. Since they are tied to the use of things like regular expression matching rather than a specific syntactic construct like an if expression, they are more flexible and can be used in more ways. Their behaviour is very well defined.

The disadvantage is that there is a complete hodge-podge of them. Some are read only, some read-write, and none have descriptive names. They look like line noise to the typical programmer, and as a result many people (myself included) simply don't use them outside of writing extremely short shell scripts in Ruby.

Anaphors like the underscore or a special variable called "it" have the advantage of providing a smaller surface area for understanding. Consider Lisp's anaphoric macro where "it" refers to the value of the test expression and nothing more (we ignore the special cases and other ways Ruby expresses conditionals). Compare:

    if /reg(inald)?/.match(full_name) then puts $& end
    
To:

    if /reg(inald)?/.match(full_name) then puts it[0] end
    
To my eyes, "it" is easier to understand because it is a very general, well-understood anaphora, matching the test expression, always. We don't have to worry about whether $& is the result of a match or all the text to the left of a match or the command line parameters or what-have-you.

**Summing up**

Anaphora allow us to abbreviate code, hiding parameters and temporary variables for certain special cases. This can be a win for readability for short code snippets where the extra verbiage is almost as long as what you're trying to express. That being said, implementing anaphora in Ruby is a hard design problem, in part because There Is More Than One Way To Do It, and trying to provide complete support leads to ambiguities, inconsistencies, and conflicts. And  old school anaphora? They are clearly an acquired taste.

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0909_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)