The Flight of the Phoenix
===

I am working on a new nano-project, the [RewriteRails](https://github.com/raganwald-deprecated/rewrite_rails/tree) plug-in. RewriteRails applies some of my old [Rewrite Gem](https://github.com/raganwald-deprecated/rewrite/tree)'s code rewriting to Ruby projects.

Turning Back the Hands of Time
---

(You can skip this bit if you've heard it before.)

Pete Forde and Meghann Millard of [Unspace Interactive](http://www.unspace.ca/ "Unspace") decided to organize the [RubyFringe](http://rubyfringe.com/ "RubyFringe: Deep nerd tech with punk rock spirit.") conference (and a whole bunch of other people, please forgive me for not making a comprehensive list). I pinged Pete the moment I heard about it and asked what I could do to help, with an offer to speak if he cared to have his audience bored to tears.

Pete said go ahead and gave me a "blank cheque" to present on any topic of my choosing. Pete, thanks for the trust.

At that time I had already reached certain decisions about the role blogging (or as I like to call it, *writing about code instead of creating code*) would be taking in my life. I had the same feelings about presenting, and so I made the decision that if I were to present something, it would have to be code. Furthermore, I decided that I would create something new for the conference. There's nothing like a deadline to spur creativity!

So, I decided to create some form of code rewriting or macro facility for Ruby. I already had certain opinions about  the value of syntactic abstractions, and I had some experience writing tools that write Java code, so I figured I had a fair shot of actually finishing something worth discussing. At the very least, I figured the adventure of trying would provide grist for a presentation even if I failed.

As things turned out, I did make something that worked, the [Rewrite Gem](https://github.com/raganwald-deprecated/rewrite/tree). In perverse celebration I decided to make my presentation in the form of code only. Okay, there was one little bit of Marx Brothers to kick it off, but everything else was code, and working code at that. (My presentation is on line at [InfoQ](http://www.infoq.com/presentations/braithwaite-rewrite-ruby). As you can see, I was seriously short of sleep. That's my excuse for giggling so much!)

And then I put the Rewrite Gem aside for some little time. And last month, I picked it up again and discovered that it was broken. It seems that in my haste to put it out there, I failed to take some hygienic precautions like carefully documenting the version dependencies, and when [ParseTree](http://rubyforge.org/projects/parsetree/ "RubyForge: ParseTree - ruby parse tree tools: Project Info") and [Ruby2Ruby](http://seattlerb.rubyforge.org/ruby2ruby/ "seattlerb's ruby2ruby-1.2.1 Documentation") got some upgrades, Rewrite broke.

That brings us up to date. Those of you who don't give a [rat's ass](http://en.wikipedia.org/wiki/Ratfor "Ratfor - Wikipedia, the free encyclopedia") about my life's story can rejoin us here.

Whither Rewrite?
---

So, the Rewrite Gem broke when ParseTree and Ruby2Ruby changed some of their representations. I thought about either freezing the versions Rewrite needed or upgrading the gem, but then I had a remarkably stupid idea: Why not try to make it a little more useful than a proof-of-concept?

So, I started [RewriteRails](https://github.com/raganwald-deprecated/rewrite_rails/tree). The idea is remarkably simple: You are writing a Rails project. You want to use things like [`andand`](http://raganwald.com/2008/01/objectandand-objectme-in-ruby.html "Object#andand & Object#me in Ruby") and [`String#to_proc`](http://raganwald.com/2007/10/stringtoproc.html "String#to_proc"). But you either have a fastidious disdain for opening core classes and slinging proxy objects around, a fanatical need for speed, or you want to be able to rip all that stuff out if you grow bored with it.

RewriteRails solves all of these problems I invented that nobody is complaining about.

What is RewriteRails?
---

RewriteRails rewrites `.rr` files on the fly and produces `.rb` files with standard ruby code in them. If you pull it out of the project, the generated files are all there for you to use as you wish. What's a `.rr` file? A Ruby file with constructs RewriteRails knows how to process. You can inspect the rewriting it does to see what's actually going on. For example, if you create a file called `test.rr` that looks like this:

	class Test < ActiveRecord::Base

	  def fizz(buzz)
	    buzz.andand.to_s || 'nada!'
	  end

	  def bar
	    [1..5, 6..10].map(&".inject(&'+')")
	  end

	end

RewriteRails helpfully creates a `test.rb` file that looks like this:

	class Test < ActiveRecord::Base
	  def fizz(buzz)
	    ((buzz and buzz.to_s) or "nada!")
	  end
	  def bar
	    [(1..5), (6..10)].map { |_0| _0.inject { |_0, _1| (_0 + _1) } }
	  end
	end
	
(Yes, I just ran rewrite and it did this conversion for real). Note that there are no strings being converted to procs or #andands in the resulting code. Also note that you can set it up to convert on the fly in development and then do a big conversion batch job before deploying into production.

RewriteRails knows about where Rails puts files, so it keeps all of the files it writes organized in a hierarchy just like yours, with `test.rb` under `rewritten/models` and so forth. It respects your module namespaces and everything else you do to keep sane track of a working project.

Nice Things
---

Although RewriteRails needs ParseTree and Ruby2Ruby, the files it creates don't need anything. They're future-proof. If I create a rewriter named `#try` and someone adds a `#try` method to `Object` in Rails 2.3, your code won't crash. (I swear I did **not** write this in a rage when I discovered that my own version of `#try` will break when Rails 2.3 and `ActiveSupport` helpfully stuffs yet another method into `Object`.)

Status
---

This is not ready for prime time, it's just something I'm toying with. I'm using it on a project to force myself to eat my own dog food, so it moves forward when I discover something else I need or something that is broken. It has a version of `#andand` and--new today--a version of `String#to_proc` called `StringToBlock`. I'll document  that soon, the basic idea is that you write your code as if you are using `String#to_proc` and RewriteRails 'compiles' it to ordinary Ruby. This is a huge performance gain and once again it future proofs your code.

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
