The Hopeless Egocentric Blog Post
===

In Raymond Smullyan's delightful book on Combinatory logic, [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422), Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest.

One of his concepts is the Hopelessly Egocentric bird:

> We call a bird B _hopelessly egocentric_ if for _every_ bird `x`, `Bx = B`. This means that whatever bird `x` you call out to `B` is irrelevant; it only calls `B` back to you! Imagine that the bird's name is Bertrand. When you call out "Arthur," you get the response "Bertrand"; when you call out "Raymond," you get the response "Bertrand"; when you call out "Ann," you get the response "Bertrand." All this bird can ever think about is itself!

**object-oriented egocentricity**

One of the tenets of OO programming is that programs consist of *objects* that respond to *messages* they send each other. A hopelessly egocentric object is easy to imagine: No matter what message you send it, the hopelessly egocentric object responds with itself:

    class HopelesslyEgocentric < BlankSlate

      def method_missing(*arguments); self; end

    end

Now you can create a hopelessly egocentric object with `HopelesslyEgocentric.new` and no matter what message you send it, you will get it back in response. And? What good is this? What can it do? Why should we put it in our Zoo?

In Objective C, `nil` is hopelessly egocentric. As [Learn Objective-C](http://cocoadevcentral.com/d/learn_objectivec/ "Cocoa Dev Central: Learn Objective-C") puts it, _You usually don't need to check for nil before calling a method on an object. If you call a method on nil that returns an object, you will get nil as a return value._

The idea here is that instead of getting a `NoMethodError` when we send a message to `nil`, we get `nil` back. Or in Smullyan's terms, *nil is hopelessly egocentric* (Speaking of egocentricity, I also like to think of it as *baking [andand](https://github.com/raganwald/andand/tree) into the language*). Some people like this so much they've [composed the same semantics for Ruby](http://rubyenrails.nl/articles/2008/02/29/our-daily-method-18-nilclass-method_missing "NilClass#method_missing"):

    class NilClass
    
      def method_missing(*args); nil; end
      
    end

Now instead of writing:

    person && person.name && person.name.upcase

Or:

    person.andand.name.andand.upcase
    
You write `person.name.upcase` and either get the person's name in upper case or `nil` back. Wonderful! Or is it? Let's take a look at what we're trying to accomplish and the limitations of this approach.

**queries**

Hopelessly egocentric nil works reasonably for querying *properties*, in other words sub-entities when an entity is constructed by composition, things like `.name`. I'm quite happy if `person.name` returns `nil` whether we don't have a person or if the person doesn't have a name. And we can extend this to what I would call *purely functional transformations* like `.upcase`. Just as `''.upcase` is `''`, it is reasonable to think of `nil.upcase` as `nil`. 

Now let's look at some things that aren't properties and aren't purely functional transformations. What do we do with methods that are intended to *update* their receiver? Consider a bank account object. Do we really want to write things like:

    person.account = nil
    person.account.increment_balance(100)
      => nil

This makes no sense. If we want to give them a hundred dollars, we had better have their actual account on hand! Clearly there is a huge difference between methods that are *queries* and methods that are *updates*. (Note that `andand` doesn't save us either, except by virtue of being explicit rather than magical so we can eschew it for update methods like `#increment_balance`.)

**updates**

Now that we are talking about methods with side-effects, let's be more specific. Our hopelessly egocentric nil does return `nil` to any method. But it has another property, it has no side-effects. This is sometimes what we want! Let's look at our `nil` account again. What about this code:

    person.account.update_attribute(:primary_email, 'reg@braythwayt.com')

To decide what we think of this, we need to be specific about the meaning of `nil`. Generally, `nil` means one of two things:

1.  `NONE`, meaning "There isn't one of these," or;
2.  `UNKNOWN`, meaning "There *is* one of these, but we don't know what it is."

`person.account.update_attribute(:primary_email, 'reg@braythwayt.com')` is an example of why this difference matters. If `person.account` is an account, we want to update its primary email address, of course. And if `person.account` is `NONE`, we might be very happy not updating its primary email address. Perhaps our code looks like this:

    class Person < ActiveRecord::Base
      belongs_to :account
      
      def update_email(new_email)
        self.class.transaction do
          update_attribute(:primary_email, new_email)
          account.update_attribute(:primary_email, new_email)
        end
      end
      
      # ...
      
    end
    
    Person.find(:first, :conditions => {...}).update_email('reg@braythwayt.com')
    
Meaning, update our person's primary email address, and if they have an account, update it too. If `nil` means `NONE`, this works. But what if `nil` really means `UNKNOWN` rather than `NONE`? **Now it is wrong to silently fail**. Let me give you a very specific way this can happen. When performing a database query, we can specify the exact columns we want returned. In Active Record, we might write something like this:

    person = Person.find(:first, :conditions => {...}, :select => 'id, name')

What this means is that there is an `account_id` column in the `people` table, however we are deliberately not loading it into `person`. ActiveRecord will still supply us with a `#account` method, however it will return `nil`. This absolutely, positively means that `person.account` is `UNKNOWN`, not `NONE`. There could well be an account in our database for this person, and now if we write:

    person.update_email('reg@braythwayt.com')

We do not want it to silently ignore the account email update, because we haven't loaded the `account` associated model. We now have four rules about the semantics of `NONE` and `UNKNOWN`:

1.  Querying `NONE` returns `NONE`;
2.  Updating `NONE` returns `NONE` and has no side effects;
3.  Querying `UNKNOWN` returns `UNKNOWN`;
4.  Attempting to update `UNKNOWN` is an error.

Right away we see a problem with writing a hopelessly egocentric nil to handle `UNKNOWN`: How does it know which methods are queries and which methods are updates? Unknown values are a subtle problem requiring a deep and pervasive approach to typing similar to C++'s `const` keyword.

Can we use a hopelessly egocentric nil to handle `NONE`? Even here we have problems. For example:

    person.name
      => nil
      
    person.name.upcase
      => nil
      
Makes sense. And then we write:
    
    person.name + ", esq."
      => nil

Dubious, but let's go with it. If this makes sense, we ought to be able to write this as well:

    "Mister " + person.name
      => TypeError: can't convert nil into String

[Why is this an error?](http://weblog.raganwald.com/2007/10/too-much-of-good-thing-not-all.html "Too much of a good thing: not all functions should be object methods") Things don't get any better using a hopelessly egocentric `nil` to handle `UNKNOWN`. Even if we can get past the issue of update methods, we have another problem that is much more difficult to resolve. `UNKNOWN` introduces tri-value logic:

    UNKNOWN == Object.new
      => UNKNOWN
    UNKNOWN != Object.new
      => UNKNOWN
    UNKNOWN == UNKNOWN
      => UNKNOWN
    UNKNOWN != UNKNOWN
      => UNKNOWN
    Object.new == UNKNOWN
      => UNKNOWN
    Object.new != UNKNOWN
      => UNKNOWN

When you don't know something's value, it is neither equal to nor not equal to any other value, including another unknown value. And our fifth and sixth examples suffer from the same problem as `nil + ", esq."` vs. `"Mister " + nil`. We would need to patch all sorts of other objects to make equality testing many many other methods work. (What is `42 < UNKNOWN`?) But things get worse:

How does *truthiness* work? In Ruby, you cannot override the way `and`, `or`, `if`, `unless`, `&&`, and `||` work. What are the semantics of `if UNKNOWN`? What do `true && UNKNOWN` or `UNKNOWN or true` return? Before implementing a true `UNKNOWN` in any language, I would want those questions answered.

Finally, there is actually a fifth and sixth rule that we are ignoring because these examples are in Ruby rather than a language with an expressive type system. Consider:

    'Reg Braithwaite'.wealthy?
      => NoMethodError: undefined method `wealthy?' for "Reg Braithwaite":String

And now we write:

    person.name.wealthy?         # or...
    person.name.andand.wealthy?
    
What happens if `person.name` is `NONE`? What happens if `person.name` is `UNKNOWN`? Our problem here is that `#wealthy?` is never a valid message to send to something returned by `person.name`. Our behaviour ought to be:

* Sending an invalid message to `NONE` raises a `NoMethodError`;
* Sending an invalid message to `UNKNOWN` raises a `NoMethodError`.

There is no easy way to do this in Ruby, of course. Not only do we have trouble disambiguating queries from updates, we have trouble disambiguating valid from invalid messages.

For all of these reasons, I am loathe to implement a hopelessly egocentric `nil` and prefer to use an explicit idiom like `#andand` or `#try`. With explicit idioms, I can deal with the ambiguity between `nil` meaning `NONE` and `nil` meaning `UNKNOWN` and make sure my code does not violate the rules given here. But what I like about the *idea* of a hopelessly egocentric nil is that thinking the consequences provokes me to really think about the semantics of my data schemas.

_More on combinators_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md), and [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md).

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

[Hire Reg Braithwaite!](http://reginald.braythwayt.com/RegBraithwaiteGH0109_en_US.pdf "")