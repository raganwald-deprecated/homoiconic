Keywords
===

I am going to talk about *if*, *unless*, *and*, and *or*. Given:

    name = ...
    identity = ...
    who = Who.find_or_create_by_name(name)
    tagging_params = {
      :tagger_id => identity.id, :tagger_type => identity.class.name,
      :taggee_id => identity.id, :taggee_type => identity.class.name,
      :tagger_id => identity.id, :tagger_type => identity.class.name,
      :tag_id    => who.id,      :tag_type    => who.class.name
    }

You could write:

    Tagging.first(:conditions => tagging_params) or Tagging.create!(tagging_params)

Or you could write:

    Tagging.create!(tagging_params) unless Tagging.first(:conditions => tagging_params)

As far as side-effects are concerned, they both have the same result: Create a new instance of Tagging unless there is already one with the same values. But while the side-effects are the same, the evaluations are different: If an instance already exists, the version using *unless* evaluates to *nil* while the version using *or* evaluates to the instance found.

Likewise, you can write:

    foo if bar

Or write:

    bar and foo

Once again, the difference is in the negative case: *foo if bar* evaluates to nil if bar is falsy.

**&& and ||**

You will also sometimes see people using *&&* and *||* instead of *if* for terseness:

    is_blackguard? && release!(the_hounds)

Such things are just like using *and* and *or*, the only difference is that the keywords have a vastly lower precedence when Ruby parses your expressions. I saw a good rule of thumb the other day: When choosing between *&&* and *and* or between *||* and *or*, choose the version that conserves parentheses.

**Anything else?**

Yes. It's a personal thing, but I dislike placing side-effects in the conditional of an *if* or *unless* expression, so instead of:

    if mankind.save
      joy.to { |the_world|
        ...
      }
    end

I will usually write:

    mankind.save and joy.to { |the_world|
      ...
    }

It reads like it sounds: "Do this and then do that." The if statement sounds too much like you are just checking on something: "If such-and-such is the case, do this." But that's a personal choice. If my colleagues start muttering that Home Depot has a sale on torches and pitchforks, I will rewrite it:

    saved = mankind.save
    if saved
      joy.to { |the_world|
        ...
      }
    end

---

Recent work:

* "[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)