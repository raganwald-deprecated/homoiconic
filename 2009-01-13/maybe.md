Maybe
===

I thoroughly enjoyed reading [Try() as you might](http://blog.lawrencepit.com/2009/01/11/try-as-you-might/ ""). The essay and the follow-on comments provoked a couple of quick thoughts. (Please presume I am responding to this post and/or quoting it unless I say otherwise).

What's wrong with `responds_to?`
---

Q: Should `try()` check for `nil`? Or `responds_to?`  
A: Maybe...

Here's an implementation of `try()`:

    class Object
      ##
      #   @person ? @person.name : nil
      # vs
      #   @person.try(:name)
      def try(method)
        send method if responds_to? method
      end
    end

There is a problem here, and the problem is that the implementation and the documentation do not agree with each other. If `@person` does not respond to the message `:warranty_period`, then:

    @person.try(:warranty_period)
      # => nil
    @person ? @person.warranty_period : nil
      # => NoMethodError: undefined method `warranty_period' for #<Person:0x21d467c>
      
That being said, there are two ways to fix this. First, as the essay suggests, we can fix the implementation such that it reproduces the semantics implied by the documentation. In other words, we can make it behave like andand. However, we can also correct the documentation:

    class Object
      ##
      #   @person.responds_to?(:name) ? @person.name : nil
      # vs
      #   @person.try(:name)
      def try(method)
        send method if responds_to? method
      end
    end

I think there's a legitimate use for both versions of `try()`, which is why I use both andand for nil-checking and an analogous method called `please` for the odd time that I want `responds_to?` semantics.

Also, I reject the argument that `responds_to?` checking is buggy because some people write `method_missing` magic that breaks it. I reject the argument because I reject as buggy any code such that object `o` responds to method `m` but `o.responds_to?(:m) => false`. **If you implement your own method\_missing for a class, you should almost always implement your own responds\_to? as well.**

A flaw in andand's ointment
---

Here's a version of `try()` enhanced to handle arguments:

    class Object
      def try(method, *args, &blk)
        send(method, *args, &blk) if responds_to? method
      end
    end

At RubyFringe, I discussed andand's most annoying flaw, a flaw shared by versions of `try()` like this that handles method arguments. With the above implementation, the following is now possible:

     1.try(:+, 1)
        => 2

Looking good. So this should come as no surprise:

    1.try(:+, (1..1000000).inject(&:+))
      => 500000500001

Now, what does the following snippet of code do?

    nil.try(:+, (1..1000000).inject(&:+))

Yeah, yeah, you are going to say that it returns `nil`. I know that. The question is, what does the computer *do*? The answer is, it sums the numbers from one to a million before returning `nil`. Therefore, `nil.try(:+, (1..1000000).inject(&:+))` is **not** the same thing as:

    nil.responds_to?(:+) ? nil + (1..1000000).inject(&:+) : nil

Try it for yourself if you aren't sure. This is exactly why RewriteRails implements andand with rewriting rather than with monkey-patching. You can't use a method to replicate the functionality of a conditional like `?:`, `&&`, `||`, `and`, `or`, `if`, or `unless`. Period. Although, it's good enough if you keep it extremely simple.

Which is why, to be honest, I prefer the version of `try()` that doesn't have the bells and whistles of handling arguments and blocks. It does one small thing and does it well. Paradoxically, adding more functionality is actually creating more ways to be wrong. Too bad the author of andand didn't figure that out.

Why NULL is not for me
---

One of the most provocative implementations suggested for handling `nil` objects is to give `nil` special semantics, something like `nil` in Objective C or `NULL` in SQL. Here's a particularly naive Ruby implementation:

    class NilClass
      def method_missing(*args)
        nil
      end
    end

Now you can write things like `@person.name` and know that if `@person` is `nil`, you will always get `nil`. Always. Everywhere. Interesting! In fact, it's another implementation of the Maybe Monad, only in a very clever, OO way. That being said, here's why it doesn't work for me.

Right off the bat, [semantics like this really should not be implemented as methods](http://raganwald.com/2007/10/too-much-of-good-thing-not-all.html "Too much of a good thing: not all functions should be object methods"). Why does `nil + 1` produce `nil`, but `1 + nil` produce `TypeError: coerce must return [x, y]`? There's a real problem trying to make anything involving `nil` commutative.

In fact, I would go so far as to say that `:foo == nil` should be `nil`, as should `:foo != nil`. That makes sense, because as given:

    nil == :foo
      => nil
    nil != :foo
      => nil
    nil == nil
      => nil
    nil != nil
      => nil

If you subscribe to the idea of `nil` being its own Maybe, you cannot and should not test for `nil` with equality. SQL's `NULL` works that way, you need the special conditions `IS NULL` and `IS NOT NULL` to test for `NULL`. (If you are going to implement a `nil` that responds `nil` to everything, you probably want to add an `is_nil?` keyword to the language, or perhaps test something for falsiness and then test to make sure it is not false.)

Another thing that troubles me is trying to eliminate corner cases. If `nil.foo` is `nil`, shouldn't `nil.to_s` also be `nil`? And `nil.to_i`? Seriously, if we are going to make `nil` respond `nil` to any method, let's make it respond `nil` to every method. And especially `nil.class`, which should also respond `nil`, not `NilClass`. The latter could really bite you if you are replying on `nil` to return `nil` to every method in your code and you are doing anything with object classes.

Truthfully, if using `method_missing` to turn `nil` into a lightweight Maybe Monad with leaky semantics works for your application, I say do it and that's great. I just wanted to point out a few reasons why I am not rushing down that road myself: Once I start to consider the implications, it becomes obvious to me that making such a thing consistent and "turtles all the way down" is actually a lot of work.

Nevertheless, it's a really provocative idea. And now I'm going to make myself some espresso and spend a few moments thinking about the relationship between `NULL` and hopelessly egocentric combinator birds :-)

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