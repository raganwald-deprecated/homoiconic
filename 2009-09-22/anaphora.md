Anaphora in Ruby
===

> In natural language, an anaphor is an expression which refers back in the conversation. The most common anaphor in English is probably "it," as in "Get the wrench and put it on the table." Anaphora are a great convenience in everyday language--imagine trying to get along without them--but they don't appear much in programming languages. For the most part, this is good. Anaphoric expressions are often genuinely ambiguous, and present-day programming languages are not designed to handle ambiguity.  --Paul Graham, [On Lisp](http://www.paulgraham.com/onlisp.html "On Lisp")

**Block anaphora**

Oliver Steele wrote a nice little Javascript library called [Functional Javascript](http://osteele.com/sources/javascript/functional/ "Functional Javascript"). Javascript is a particularly verbose language descended from Lisp. It's syntax for writing anonymous functions is awkward, especially for the kind of short functions that are passed to higher-level functions like `map` or `select`. Oliver decided that if you wanted to write a lot of anonymous functions, you'd better have a more succinct way to write them. So he added "String Lambdas" to Javascript, a succinct alternate syntax for anonymous functions.

[String#to\_proc](http://github.com/raganwald/homoiconic/blob/master/2008-11-28/you_cant_be_serious.md "You can't be serious!?") is a port of Oliver's String Lambdas to Ruby. One of the things you can do with String#to\_proc is define a block (or a proc) that takes one parameter with an expression containing an underscore instead of explicitly naming a parameter.

For example, instead of `(1..100).map { |x| (1/x)+1 }`, you can write `(1..100).map(&'(1/_)+1')` using String#to\_proc. The underscore is an anaphor, it refers back to the block's parameter just as the word "it" in this sentence refers back to the word "anaphor." The win is brevity: You don't have to define a parameter just to use it once.

String#to\_proc does a lot more than just provide anaphora for single parameters in blocks, of course. But it does provide this specific anaphor in Ruby.

**Methodphitamine: Another implementation of the block anaphor**

[Methodphitamine](http://jicksta.com/posts/the-methodphitamine "The Methodphitamine at Adhearsion Blog by Jay Phillips") provides another implementation of block anaphora, this one inspired by the Groovy language.

Symbol#to\_proc is the standard way to abbreviate blocks that consist of a single method invocation, typically without parameters. For example if you want the first name of a collection of people records, you might use `Person.all(...).map(&:first_name)`.

If you want to do more, such as invoke a method with a parameter, or if you want to chain several methods, you are out of luck. Symbol#to\_proc does not allow you to write `Person.all(...).map(&:first_name[0..3])`. With Methodphitamine you can write:

    Person.all(...).map(&it.first_name[0..3])
    
Likewise with Symbol#to\_proc you can't write `Person.all(...).map(&:first_name.titlecase)`. You have to write `Person.all(...).map(&:first_name).map(&:titlecase)`. With Methodphitamine you can write:

    Person.all(...).map(&it.first_name.titlecase)
    
This is easy to read and does what you expect for simple cases. Methodphitamine uses a proxy object to create the illusion of an anaphor, allowing you to invoke method with parameters and to chain more than one method. Here's some code illustrating the technique:

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

As you might expect from a hack along these lines, there are all sorts of things to trip us up. `(1..10).map(&it * 2 + 1)` works, however what would you expect from:

    (1..10).map(&1 + it * 2) # no!
    
This does not work with Methodphitamine, and neither does something like:

    Person.all(...).select(&it.first_name == it.last_name) # no!
    
Also, unexpected things happen if you try to "record" an invocation of #to\_proc:

    [:foo, :bar, :blitz].map(&it.to_proc.call(some_object)) # no!

So while String#to\_proc allows you to write things like `(1..10).map(&'1 + it * 2')` or `Person.all(...).select(&'_.first_name == _.last_name')`, this approach does not. (The implementation above has been simplified to illustrate the idea. Consult the actual [methodphitamine gem source](http://github.com/jicksta/methodphitamine "jicksta's methodphitamine at master - GitHub") for details on how it is actually implemented: There are performance optimizations as well as a lightweight Maybe Monad hiding under the covers.)

**UPDATE: Block anaphora in rewrite_rails**

[rewrite_rails](http://github.com/raganwald/rewrite_rails "raganwald's rewrite_rails at master - GitHub") supports `it`, `its`, or `_` as block anaphora for blocks taking one argument. Similarly to Methodphitamine, you can write:

    (1..10).map{ it * 2 + 1 } # => [3, 5, 7, 9, 11, 13, 15, 17, 19, 21]
    
You can also write all of the following:

    (1..10).map { 1 + it * 2 }
    Person.all(...).select { its.first_name == its.last_name } # and,
    [:foo, :bar, :blitz].map { it.to_proc.call(some_object) }
    (1..100).map { (1/_)+1 }
    
In comparison to String#to\_proc, block anaphora do less (String#to\_proc also supports point-free blocks and named parameters). However, block anaphora looks a little cleaner, you don't have code inside a string, you just have code.

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

Reading about Lisp's anaphoric macros made me wonder whether anaphora for conditionals would work in Ruby. I find `(it = big_long_calculation()) && it.foo` cluttered and ugly, but perhaps I could live without #andand if I could write things like:

    if big_long_calculation(): it.foo end
    
This is relatively easy to accomplish using [rewrite_rails](http://github.com/raganwald/rewrite_rails "raganwald's rewrite_rails at master - GitHub"). In the most naïve case, you want to rewrite all of your if statements such that:

    if big_long_calculation()
      it.foo
    end
    
Becomes:

    if (it = big_long_calculation())
      it.foo
    end

You can embellish such a hypothetical rewriter with optimizations such as not assigning `it` unless there is a variable reference somewhere in the consequent or alternate clauses and so forth, but the basic implementation is straightforward.

The trouble with this idea is that in Ruby, *There Is More Than One Way To Do It* (for any value of "it"). If we implement anaphora for conditionals, we ought to implement them for all of the ways a Ruby programmer might write a conditional. As discussed, we must support:

    if big_long_calculation()
      it.foo
    end
    
Luckily, that's the exact same thing as:

    if big_long_calculation(): it.foo end
    
They both are parsed into the exact same abstract syntax tree expression. Good. Now what about this case:

    it.foo if big_long_calculation()
    
That doesn't read properly. The anaphor should follow the subject, not precede it. If we want our anaphora to read sensibly, we really want to write:

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
    
This doesn't work as expected because the anaphor would refer forward to its consequent expression `number_of_foobars += 1` rather than backwards to the enclosing test expression `calculation_that_might_return_a_foobar()`. You can try to construct some rules for disambiguating things, but you're going to end up asking programmers to memorize the implementation of how things actually work rather than relying on familiarity with how anaphora work in English.

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

It seems that it is much harder to support anaphora for conditionals in Ruby than it is to support anaphora for conditionals in Lisp. This isn't surprising. Lisp has an extremely regular lack of syntax, so we don't have to concern ourselves with as many cases as we do in Ruby.

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
    
To my eyes, "it" is easier to understand because it is a very general, well-understood anaphor. "It" always matches the test expression. We don't have to worry about whether `$&` is the result of a match or all the text to the left of a match or the command line parameters or what-have-you.

**Summing up**

Anaphora allow us to abbreviate code, hiding parameters and temporary variables for certain special cases. This can be a win for readability for short code snippets where the extra verbiage is almost as long as what you're trying to express. That being said, implementing anaphora in Ruby is a hard design problem, in part because There Is More Than One Way To Do It, and trying to provide complete support leads to ambiguities, inconsistencies, and conflicts. And  old school anaphora? They are clearly an acquired taste.

**More**

* [String#to\_proc](http://github.com/raganwald/homoiconic/blob/master/2008-11-28/you_cant_be_serious.md "You can't be serious!?") and its original [blog post](http://weblog.raganwald.com/2007/10/stringtoproc.html "String#to_proc").
* [Methodphitamine](http://github.com/jicksta/methodphitamine "jicksta's methodphitamine at master - GitHub") and its original [blog post](http://jicksta.com/posts/the-methodphitamine "The Methodphitamine at Adhearsion Blog by Jay Phillips")
* [Anaphoric macros](http://www.bookshelf.jp/texi/onlisp/onlisp_15.html "Onlisp:  Anaphoric Macros")
* [rewrite_rails](http://github.com/raganwald/rewrite_rails "raganwald's rewrite_rails at master - GitHub") contains an improved implementation of String#to\_proc.
* A [usenet discussion](http://groups.google.com/group/ruby-talk-google/browse_thread/thread/26445dcef22f5a5/1772d0c487d4c570?hl=en&amp;lnk=ol&amp; "Introducing the &quot;it&quot; keyword") about anaphora in Ruby.
* [@RobertFischer](http://twitter.com/RobertFischer "Robert Fischer") pointed out that Groovy implements Block Anaphora using exactly the same syntax as rewrite\_rails, as well as mentioning that Groovy provides a special operator, `?.`, for the Maybe Monad.
* Perl has some [anaphora of its own](http://www.wellho.net/mouth/969_Perl-and-.html "Perl - $_ and @_").

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0909_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)