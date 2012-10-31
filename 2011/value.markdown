˝Pass by Reference isn't one of Java's Values
===

On the interwebs, I noticed some discussions (e.g. [proggit][p] and [hacker news][hn]) about another discussion ([serverside][ss]) about whether Java the language uses [Pass by Reference or Pass by Value][es]. It's an [old, old argument][arg], and the `tl;dr` is that Java and most other modern languages pass references to objects by value, which means it uses Pass by Value. It is absolutely wrong to assert that Java uses Pass by Reference.

While it's tempting to bash Java programmers for the misconceptions, I think that's just confirmation bias. I have absolutely no faith that a statistically significant sample of Ruby or JavaScript programmers would contain a larger proportion of people who get the terms right.

Which, for the most part, probably demonstrates that the issue just isn't that important. If it were, nobody would be able to write code without figuring the names out. The fact is, if you understand what your language *does*, knowing the correct names is only important when talking to another programmer.

I doubt this comes up much, since two programmers talking about Ruby or Java or javascript would both have the same understanding of what happens with parameters passed to functions/methods.

In my opinion, trouble over terms is more important when moving from a language with one set of semantics to another. For example, when moving from Java to JavaScript, not understanding closures would make for some error-laden conversations with experienced JavaScript programmers.

![Duke Mom](http://silveiraneto.net/wp-content/uploads/2008/05/duke_mom.png)

But for those of you who haven't seen any of the [Aleph-0][a] explanations, here is the Aleph-One-th explanation of why Java (and Ruby and JavaScript and most other modern programming languages) is Pass by Value.

**explanation**

Java passes a reference to a mutable object by value. This means:

1. There is only one instance of the original object, it is not copied, and;
2. There are *two* reference to it. One in the original method's environment and one in the called method's environment. Since Java passed the reference by value, there is a copy of the reference in the called method.

Illustration:

    public void some_method () {
      String first_ref = "original string";
      // ...
    }

So `first_ref` is a reference to the string "original string" in some_method.

Somewhere else we write:

    public void called_method (String second_ref) {
      second_ref = "brand new string";
    }

In `called_method`, `second_ref` will be a copy of a reference to a String. When `called_method` is called, `second_ref` will point to some original String (which is an object, obviously). But it's a brand new reference.

What happens when `second_ref = "brand new string";` is executed? Well, first we evaluate the RHS of the assignment. This creates a brand new string with the value "brand new string". Then we change the reference `second_ref` to point to the brand new string and throw away its original value, which was a reference to the original string.

Let's flesh out `some_method`:

    public void some_method () {
      String first_ref = "original string";
      called_method(first_ref);
      System.out.println(first_ref);
    }

What is output?

As above, `second_ref` inside of `called_method` now contains a reference to "brand new string". But `first_ref` hasn't changed, it still points to "original string," and that's what gets printed.

Thus, Java passes references to objects, but it does so by making a brand new reference to the original object. If Java used pass by reference, this program would output "brand new string."

**post scriptum**

Pass by Reference is rare in modern languages, but consider this line of ancient FORTRAN:

    2 = 3

FORTRAN was originally Pass by Reference for *everything*. To make matters more interesting, integer constants in a program were references to the integers, not some kind of special primitive. Therefore, the above line of code changes the reference `2` to become the reference `3`, and everywhere in the program that uses `2`, you actually get `3`.

Legend has it that this code was used to fix a bug without search and replace, a very expensive operation in the days of paper tape and/or punch cards.

And this just in:

> pass by value (of refs) is just so plain better that "by name" and "by reference" are mostly of historic/scientific interest&#8212;[@axeolotl][tw]

True, but every now and then [some idiot][r] ventures into the tomb and awakens a [long dead monster][name].

---

Recent work:

* "[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[a]: http://www.amazon.com/gp/product/0192861611?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0192861611 "Satan, Cantor and Infinity at Amazon.com"
[hn]: http://news.ycombinator.com/item?id=2100507
[es]: https://secure.wikimedia.org/wikipedia/en/wiki/Evaluation_strategy 
[arg]: http://stackoverflow.com/questions/40480/is-java-pass-by-reference
[ss]: http://www.theserverside.com/news/thread.tss?track=NL-461&ad=808081&thread_id=61622&asrc=EM_NLN_13145929&uid=2780877
[tw]: https://twitter.com/#!/axeolotl/statuses/25634042510581760
[r]: http://github.com/raganwald
[name]: https://github.com/raganwald-deprecated/rewrite_rails/blob/master/doc/call_by_name.md#readme "Call by Name in RewriteRails"
[p]: http://www.reddit.com/r/programming/comments/f1d7r/huge_war_over_whether_java_is_pass_by_reference/