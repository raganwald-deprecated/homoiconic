Beautiful Failure
===

The organizers of [CUSEC 2010](http://2010.cusec.net/ "CUSEC 2010") were kind enough to ask me to give a keynote speech, and I wanted to write out a few of my thoughts that might not be obvious from reviewing the [slides](http://www.flickr.com/photos/raganwald/sets/72157623258073708/ "Beautiful Failure - a set on Flickr"). My thesis was that when you find yourself successfully scratching an itch, don't stop there. Dig a little deeper and see if your "fix" is obscuring a deeper failure. It's possible that some underlying assumption is holding you back. If you challenge that assumption, you may make a breakthrough.

![Beautiful Failure](http://farm5.static.flickr.com/4008/4294285244_caa37c9bef.jpg)

**an old itch**

My first example concerned Ruby's open classes. The accepted Ruby practice is to blithely add methods to core classes. For example, ActiveSupport adds hundreds of methods like [sum][sum] to core classes such as Array.

The irritating problem with this is when two different pieces of code--such as two separate gems--both attempt to add the same method to the same class. Classes are global in Ruby, so we end up with a namespace collision in our code. And note that this can happen even if we are extremely careful to review our own code for problems: Our code depends on gems, which depend on other gems, and if anything in your dependency tree conflicts with anything else, you have a problem.

The obvious solution is to scope changes to core classes. So when the [Classifier gem][classifier] patches Array, no other code has access to the same patch. This would solve the problem of [two different gems that add their own versions of #sum to Array][sick]: each would only see its own patch. If Ruby worked this way, Rails could patch core classes with ActiveSupport for its own purposes, and you could base your application on Rails without automatically "inheriting" all of its patches. You could require the ones you like and ignore the rest.

![Copyright 2008 Emiliano Dominici](http://farm4.static.flickr.com/3014/2712932037_435173fd88.jpg)

Unfortunately, Ruby doesn't work this way. You create [a feature, wrapped in a kludge, inside a hack][em] to provide some limited scope for patches to core classes. But it's still a hack. That being said, it scratches an itch. So in some sense, it is a modest success. Problem solved.

**failure**

Although things like Extension Methods can solve the problem, there's a terrible smell underlying the whole affair. Something stinks. Sure, my actual implementation of Extension Methods has many issues. Given motivation, these can be fixed. Perhaps some future version of Ruby might adopt extension methods as a feature, who knows. But even a beautiful implementation of Extension Methods would just be wallpapering over some serious cracks in OOP.

In short, doesn't all this monkey-patching and DSL-writing and extension methoding violate the [Single Responsibility Principle][srp]? Is everyone doing  this wrong? Or--and I'm leaning this way--does the Single Responsibility Principle need a rethink?

I like small, elegant things with one purpose. It's pretty obvious that arrays that know how to compute their own sum when they happen to contain summable entities are not elegant things with one purpose. Could everything we're doing be wrong? Could the Single Responsibility Principle be wrong? Or perhaps... I am musing here, not dictating... Could the idea of things having single responsibilities be right but in languages like Ruby, those things aren't classes any more?

A Ruby program with extensive metaprogramming is a meta-program that writes a target program. The target program may have classes that groan under the weight of monkey patches and cross-cutting concerns. But the meta-program might be divided up into small, clean entities that each have a single responsibility. We see that in Rails programs. For example, you might write a controller class like this:

    class BafflegabController < ApplicationController
    
      include Authentication
      include EventStreaming
  
      before_filer :ensure_logged_in
      after_filter :update_user_event_stream
      
      # ...
      
      def create
        # ... code that creates more bafflegab without
        # ... any concern for authentication, permission,
        # ... or user event streams
      end
        
    end

[Aspect-oriented programming][aop] has allowed us to write methods that do one simple thing. At run time, invoking BafflegabController#create on the target program also does some authentication stuff and some user event stream stuff, but in the meta-program that is moved out of the method and elsewhere into modules that seem to have a single responsibility. In effect, the target program's classes and methods have many responsibilities, but they are assembled by the meta-program from smaller modules that each have a single responsibility.

**beautiful failure**

This musing leads me to a revelation: Monkey-patching and extension methods are not wrong just because they violate the literal interpretation of the single responsibility principle, but the single responsibility principle should not be followed literally. That being said, it should not be ignored either. Wise choices around opening core classes will be organized into small building blocks that have a single responsibility in the implementation domain, such as behaviours for collections of numerics. Meta-programs will consist of small building blocks that have a single responsibility expressed in the problem domain, such as behaviours for collections of financial transactions. Target programs will be assembled out of all these smaller building blocks. At run time, of course, they will groan under the weight of cross-cutting concerns. But that's the interpreter's problem, not ours.

This revelation is why I consider implementing extension methods for Ruby one of my beautiful failures. Scratching my own itch led me to a better understanding of programs and elegance. And this, ultimately, is what makes for a beautiful failure: One that leads us to a deeper understanding.

Right Under Our Noses: Why Git is a Failure
===

At [Rubyfringe][rf] a few years ago, I suggested that IDE features are language smells. This statement reflects a lot of bias: I spend a lot of time holding a programming language hammer, and thus every problem looks like a language paradigm nail to me. But just because I'm biased doesn't mean I'm wrong. Or more importantly, even if I'm wrong it might be interesting to ask ourselves what would happen if we looked at the tools in our development tool chains and treated them as failures.

![Jenga](http://www.hasbro.com/common/productimages/en_US/92ffa0296d4010148bf09efbf894f9d4/276AE74719B9F369D9B1CE3D54549446.jpg)

You can play this game with IDEs, issue managers, wikis, time trackers, project management applications, even email. They're all sitting in their own silos completely disconnected from the code that is what we actually build and test. Honestly, when you look at the commit hooks and APIs that we use to bind them together, don't you despair? We're using tissue paper, spit, and baling wire to integrate components without any attempt to rethink the entire [jenga pile][jenga] of tools.

But the two obvious points of attack are testing and version control. To our credit, we seem to have figured out that integrating testing with code is important. No serious Ruby project gets started these days without some kind of unit testing framework baked into it from the start. Long after we have moved on, this will be one of Rails' lasting contributions to popular programming culture. I think we can go further, a [lot][dbc] further.

But let's look at version control. Is it just me, or are we so busy congratulating ourselves on our mastery of remote tracking branches that we are completely missing the massive conceptual failure that is as plain as the nose on our face?

**why aren't versions of code like versions of data?**

We have a lot of experience working with distributed data in real time. We build transactional databases that use versions of records to implement [ACID][acid] semantics. We build wikis with revision histories built right into the user interface. Yet when we write code, the tool that manages who changed what and why has no representation in the programming language itself.

One of the things we've learned from Lisp is that code is data is code. So if we can have the notion of data having versions and history and transactions in the language, we ought to have the same notion for code in the language. Think of updating the methods of a class. Isn't it obvious that some bits of code elsewhere in the application are dependent on an older, outdated version of that class's API?

Right now we think of programs as being monolithic. So we change everything all at once, test it extensively, and when everything has been updated to use the new API, we release a new version of the entire program. There's no idea that a single class might have two versions and that some bits of the program depend on the old version and some on the new. Why not? Why isn't live, running code versioned and transactioned so that we can release a patch of a few classes into a running server without taking it down? It should be possible for the old code to handle all of the existing requests and then get garbage collected when it has no further dependencies.

Switching focus, version control histories are full of data that we seem to be ignoring. When I implement a new feature, I might change six files. When I fix a bug, I might change two files. What do the six files have in common that they would all be changed to implement a new feature? What is the relationship between those two files such that I need to change them both to fix a bug?

![Github tells us that our existing idea of a program is flawed](http://farm5.static.flickr.com/4056/4294289164_8f73a17607.jpg)

Should our programs be reorganized? I sometimes wonder if instead of fooling around with ideas like SRP, we should ask ourselves what arrangement of features would produce the same number of commits, but reduce the number of files in each commit and reduce the number of commits in each file. In some weird alternate universe, is there an identical project where ever commit consisted of changes to exactly one file and each commit changed a different file?

We could work towards that through refactoring functionality. And it's valuable to ask ourselves if the architecture and organization of the program reflect how we think it ought to be organized--classical architecture--or whether it reflects how the problem is actually organized, as evidenced by the commit history.

We could also swing for the fences and ask ourselves if there are new ways to think about programs entirely. If changing a method name involves changing all the files that depend on the method... Maybe we need a language where the name of the method for human readable purposes is kept in exactly one place and we [Don't Repeat Ourselves][dry]. We do that all the time with data, a User record has a name but everything else in the program refers to it with a user\_id. Why do our programs use such primitive and coupled ways of representing relationships?

These are just a few of the thoughts I have when I take a moment to look at a tool like version control and think of it as a beautiful failure. You aren't as encumbered by decades of experience thinking that version control is a "best practice." Try thinking of version control as a massive failure. What new ways can you dream up to think of programs and programming that would address the underlying problem rather than papering over the cracks?

p.s. Beautiful Failure on [Hacker News][hn] and [Reddit][r]

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

[sum]: http://github.com/raganwald/homoiconic/blob/master/2009-04-09/my_objection_to_sum.md#readme "My Objection to Array#Sum"
[rc]: http://en.wikipedia.org/wiki/Race_condition "Race condition - Wikipedia, the free encyclopedia"
[classifier]: http://classifier.rubyforge.org/ "Ruby Classifier - Bayesian and LSI classification library"
[sick]: http://github.com/raganwald/homoiconic/blob/master/2009-04-08/sick.md#readme "I'm Sick of This Shit"
[em]: http://github.com/raganwald/homoiconic/blob/master/2009-04-28/extension_methods.md#readme "My Objection to Extension Methods"
[srp]: http://en.wikipedia.org/wiki/Single_responsibility_principle "Single responsibility principle - Wikipedia, the free encyclopedia"
[aop]: http://en.wikipedia.org/wiki/Aspect-oriented_programming "Aspect-oriented programming - Wikipedia, the free encyclopedia"
[rf]: http://www.infoq.com/presentations/braithwaite-rewrite-ruby "Ruby.rewrite(Ruby)"
[jenga]: http://www.slate.com/id/2215988/slideshow/2216140/ "The Jenga Effect"
[dbc]: http://en.wikipedia.org/wiki/Design_by_contract "Design by Contract"
[acid]: http://en.wikipedia.org/wiki/ACID "ACID - Wikipedia, the free encyclopedia"
[dry]: http://en.wikipedia.org/wiki/Don't_repeat_yourself "Don't Repeat Yourself"

[hn]: http://news.ycombinator.com/item?id=1084826 "Discuss on Hacker News"
[r]: http://www.reddit.com/r/programming/comments/avdri/beautiful_failure/ "Discuss on Reddit"