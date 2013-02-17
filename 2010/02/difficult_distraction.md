A Difficult Distraction
===

In July of 2008, I was a speaker at the RubyFringe conference. In [my talk][rf], I introduced [rewrite][rewrite], a gem for adding various forms of syntactic meta-programming to the Ruby programming language. Since that time, I've been trying to eat as much of my own dogfood as possible. Here's a brief progress report. Warning: The entire thing is anecdotal, personal opinion.

By the way, the title "A Difficult Distraction" was inspired by [an insightful comment][comment] by davidw on a HN discussion about [Lunascript][ls]:

> If [in house programming languages] aren't that hard, how come so many never seem to be... well, 'finished'? I think they tend to be a fairly large time sink, especially because it's great fun to work on one. It's exactly the kind of thing that could be very distracting for a startup.

Well, guilty as charged on *all* counts. Rewriting Ruby is hard (for me), it has been fun, and certainly it has been a distracting time sink.

**rewrite**

My first crack at it, [the rewrite gem][rewrite], was a mechanism for rewriting existing Ruby code on the fly. It was very generalized: It rewrote blocks of code, so you could just apply rewriters to a single method or block within a method. Its "rewriters" were the equivalent of Lisp macros and were first class entities. You could do things like dynamically decide which rewriters to apply to a block of code or dynamically build a rewriter.

It also had a few batteries included: There was a "prelude" included with implementations of several pseudo-monads like #andand, #please, and #try. Here's an example showing how it was scoped to a block:

    # you can rewrite with more than one rewriter if you want to
    
    with(andand) do 
    	...
    	first_name = Person.find_by_last_name('Braithwaite').andand.first_name
    	...
    end
    
Everything inside the "with(andand) do" block would have what appear to be #andand methods rewritten. Everything outside that block would not. This would solve the global monkey-patch problem: If you rewrote some code with #try, you could also use another implementation of #try (such as the one in ActiveSupport) outside of your block without conflicts.

Although there was no physical file output, the Ruby interpreter would see some code that looked like this:

    first_name = ((__temp1234567__ = Person.find_by_last_name('Braithwaite')) and __temp1234567__.first_name)
    
Thus, I could introduce new features to the Ruby language without having to "monkey-patch" core classes. Rewriting code was also superior to monkey patching for semantic reasons becuase you can add new constructs to the language with short-circuit semantics just Ruby's like built-in operators `&&` or `||`.

My experience with rewrite was that while it worked, it suffered from several problems: First, I never used the more dynamic features like scoping different rewriters to different sections of code, but the syntax for applying rewriting to a block was always in use, so it felt like I was paying for something without any benefits.

My next issue was substantially more painful. Because rewrite was so dynamic, there wasn't a definitive way to look at a ruby file foo.rb and say with certainty how it would be rewritten. This meant I couldn't develop a static translator, which meant in turn that the rewriting needed to be done in development and in production. It also meant that there was no way to walk away from rewrite. Compare this to the [sass gem][haml]: Sass generates .css files from .sass files, so if you ever get sick of it, you can throw the .sass files out and remove the gem.

[![(c) 209, Kevin and Monica Ray](http://farm3.static.flickr.com/2480/3852928587_73bb0765c3.jpg)](http://www.flickr.com/photos/missoularealestate/3852928587/in/set-72157622132820656)

Finally, debugging rewritten code laid a hurting on me. Stack traces were incomprehensible and I would be directed to a line of code that didn't exist anywhere. Ouch.

**rewrite\_rails**

Given the aforementioned pain points, I realized that while the idea was sound, it wasn't a net win for production applications. So I decided to do what any self-respecting tinkerer would do: I rewrote rewrite as [rewrite\_rails][rr], a plugin that performs whole-file rewriting for rails projects.

rewrite\_rails rewrites files with the suffix .rr and generates physical .rb files that are typically placed in a special `rewritten` folder. You can examine these files. You can remove the plugin and your project still runs. You can run in production without the plugin. There are rake tasks for rewriting everything in a project so you can check your syntax statically, prepare a project for production, or bail from rewrite\_rails gracefully.

You can't scope things smaller than a source code file. And there is no way to pick and choose rewriters on a file-by-file basis. Either you're rewriting a file with everything you've got or you aren't.

So far, I haven't missed any of the fancy stuff that the rewrite gem made theoretically possible. A few observations:

First, writing rewriters is painful. You basically translate Ruby into its [Abstract Syntax Tree][ast], manipulate the AST, then it is translated back to Ruby. So you need to know a lot about Ruby and a lot about the AST. For example, [this][source] is the source code for the class that implements the block anaphora or "it" rewriting. I implemented most of the original rewrite gem's prelude and added a few more as I've gone along. I'm not sure if they've saved me enough time to justify the investment, but I am sure I like the peculiar dialect of Ruby that I'm now using to write my own code.

Second, my lack of experience writing language implementations is obvious if you examine the plugin. There's a huge glaring bug in that the order of application of rewriters is significant. I ought to rewrite that so that there is a canonical translation from any .rr file to its rewritten .rb file that is not dependent on the order of application of rewriters. But "the cobbler's children have no shoes," and I basically have learned to live with this very leaky abstraction. If some piece of code that uses two or more rewriters doesn't do what I think it ought to do, I get all cargo cult with it and try something else.

All that being said, I repeat that I like a few things about using rewrite\_rails: For starters, debugging is a little more trouble than plain Ruby, but very doable. I get a reference to a line of Ruby code in the rewritten file. This is a very leaky abstraction, of course, I have to figure out how to change the original .rr file to fix the problem, but that is not impossible.

I've considered fiddling with debugging and stack traces to go right back to the .rr file, but I won't do that unless debugging becomes a nightmare. So far, it's reasonable for someone who understands the translations. That makes it a leaky abstraction, but not a nightmare.

**the rewriters**

How about the rewriters themselves? What's my experience now that I've been at it for more than a year?

First, I really, really like [it][anaphora]. Two random examples from actual code:

    def dead_stones
      self.dead_groupings.map { it.inject([], &:+) }
    end
    
    something.each { other[its.across][its.down].remove }
    
Here's another that could just as easily be written with Symbol#to_proc or [Methodphitamine][mp]. You can decide whether you prefer it, think it's cute, or detest it:

    def alive?
      self.any? { it.has_liberty? } 
    end

I really can't look at any of this and say that it's vastly superior to Ruby without anaphora. I think it's just a matter of personal joy ([rumour][matz] has it that "Joy" is a Ruby Value).

I also use [#andand][ra] a lot, as you might expect. The rewrite version doesn't add any methods to Object and corrects some semantics that so far haven't mattered. So all things being said, if you're happy with the [andand gem][andand], rock on.

    @game = params[:game_id].andand { Game.find(it) }
    
    def go
      Secret.find_by_secret(params[:secret]).andand do
        self.current_user = its.user
        redirect_to :controller => its.target.class.name.underscore,
                    :action => :show,
                    :id => its.target.id
      end or render :status => 404
    end

As you can see, #andand seems to work really well with anaphora. The thing that bothers me in the back of my mind is that if #andand works well with "it," why can't I use the `and` or `&&` operators with "it?" Going down *that* rabbit-hole would probably consume my entire life, so I haven't done it. But this is what happens when you start playing with languages... You come across a lot of thought-provoking questions.

[![(c) 2004 Jason Jones](http://farm4.static.flickr.com/3536/3988449564_28b5f964a4.jpg)](http://www.flickr.com/photos/jjay69/3988449564/)

Getting production code written comes down to knowing when to sharpen your saw and when to carry on cutting. I don't have a good heuristic for this, maybe I'm missing a huge opportunity by not extending the anaphora rewriter to handle operators like `and` and `&&`.

I use [#into][into] a bit, and for the same reasons I use #andand with blocks. #into is the same thing without the nil check. Or if you like, it's a [Thrush Combinator][thrush]:

    options[:handicap].to_i.into do
      if it > 1
        board.handicap(it)
        self.to_play = Board::WHITE_S
      else
        self.to_play = Board::BLACK_S
      end
    end 

I put a lot of work into [extension methods][em], wrote a bunch, and then refactored them out of my current project. I didn't have a problem with the implementation, I just ended up liking another way to get the job done more. I've mused about responsibilities and extension methods [elsewhere][bf]. I personally tend to open classes when I'm extending the Ruby language, not when I'm doing domain-specific stuff.

So if extension methods had been built into Ruby, I might have used them to implement things like #andand and #into instead of rewriting code. So was implementing extension methods a failure for me? Yes, it was a *beautiful failure*.

[String#to\_proc][s2p] has been MIA in production. I think it overlaps with anaphora. Once I had ahold of "it," I found I didn't need the brevity afforded with the string syntax.

I happen to like [#returning][returning] (a/k/a [The Kestrel][kestrel]) from ActiveSupport and use it a lot. I can't remember off the top of my head if I'm currently doing anything where the special semantics built into the rewrite version are necessary, but I'm good with knowing that it will protect me from a subtle bug.

I haven't used [call by name][cbn] at all. Oh well.

**has the jury reached a verdict?**

The big picture observations I make are:

1. All of the stuff I have done has been domain-neutral syntactic meta-programming. None of this stuff is specific to any particular problem space, it's more of a general-purpose Ruby dialect or accent if we push the metaphor.
2. The payback has been personal pleasure, the items I use the most have very little big bang in terms of time saved.

Given that this is the case, I will probably limit future investment to items that speak to my soul. I don't want to spend a lot of time on a rewriter if it doesn't make my code more of a pleasure for me to read. I also want to challenge myself to do something with more of a potential payback in time saved.

**the once and future rewriter**

One possible project that has been gnawing at me is a way to write some code that executes on the server or the client identically. Obviously, I could switch to [Node.js][node] and that would be that. I could also do a rewriter that takes a subset of Ruby code and outputs some JavaScript that is functionally equivalent. This is not the same thing as using Ruby to write JavaScript, the Ruby code would be Ruby code that produces Ruby data, and the JavaScript would be JavaScript code that produces JavaScript output.

The use case for this came up while writing a game of Go in a web client. I obviously need to validate moves to make sure they are legal. I have Ruby code to do this. I'd also like to be able to do it in the browser in JavaScript. Why write the same thing twice? Furthermore, this is a very common problem, there's a lot of form validation that could be extracted from Model validation and pushed down to the browser.

(This isn't a new idea for me. Some time ago I was writing an application where the subject domain involved deriving a decision tree from a set of rules. I wrote a DSL for expressing the rules that output a decision tree in JSON. I wrote a tree walker in JavaScript that validated a set of answers in JSON. And then were able to solve on the client directly in JavaScript or on the server by [running the same JavaScript in Rhino on the JVM][rhino]. And if you want some unsolicted career advice, it is this: Be very, very certain of yourself before you propose any [Mouse Trap Architectures][mousetrap]. Amazingly, a company that runs on the most rickety of integrations between message queues and vendor lock-in products might balk at running JavaScript on the JVM. It simply isn't done, Old Boy. Not a Best Practice, don't you know.)

So overall, I'm ok with rewriting Ruby. Not a failure, not a beautiful failure, more of a "nice but not essential." If I was starting again right now, I might still do it but be very focused on trying to find the simplest, easiest implementation of anaphora and extension methods, then write everything else as extension methods. And I would give a lot more thought to ways that rewriting code can produce a major benefit such as generating functionally equivalent code in another language.

*p.s. This progress report was inspired by a rash of posts describing companies that have done large in-house language projects. If the subject interests you, don't miss [Lunascript][ls], [HipHop][hh], [CoffeeScript][cs], [Haml][haml] and [Wasabi][w].*

*p.p.s. Discuss this post [here][proggit] on programming.reddit.com or [here][hn] on Hacker News.*

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

[anaphora]: http://github.com/raganwald/homoiconic/blob/master/2009-09-22/anaphora.md#readme "Anaphora in Ruby"
[andand]: http://andand.rubyforge.org/ "Object#andand"
[ast]: http://en.wikipedia.org/wiki/Abstract_syntax_tree "Abstract syntax tree - Wikipedia, the free encyclopedia"
[bf]: http://github.com/raganwald/homoiconic/blob/master/2010/01/beautiful_failure.markdown "Beautiful Failure"
[cbn]: http://github.com/raganwald-deprecated/rewrite_rails/blob/master/doc/call_by_name.md#readme
[comment]: http://news.ycombinator.com/item?id=1097422
[cs]: http://jashkenas.github.com/coffee-script/
[em]: http://github.com/raganwald-deprecated/rewrite_rails/blob/master/doc/extension_methods.md#readme
[haml]: http://haml-lang.com/ "Haml and Sass"
[hh]: http://developers.facebook.com/news.php?blog=1&story=358
[hn]: http://news.ycombinator.com/item?id=1098773 "A Difficult Distraction on Hacker News"
[into]: http://github.com/raganwald-deprecated/rewrite_rails/blob/master/doc/into.md#readme
[kestrel]: http://github.com/raganwald/homoiconic/blob/master/2008-10-29/kestrel.markdown "Kestrels"
[ls]: http://www.asana.com/luna
[matz]: http://casperfabricius.com/site/2008/04/02/ruby-fools-matzs-keynote/ "Matz’s keynote"
[mousetrap]: http://raganwald.com/2008/02/mouse-trap.html "The Mouse Trap"
[mp]: http://jicksta.com/posts/the-methodphitamine "The Mthodphitamine"
[node]: http://nodejs.org/
[proggit]: http://www.reddit.com/r/programming/comments/ay2bn/a_difficult_distraction_my_experience_creating_a/
[ra]: http://github.com/raganwald-deprecated/rewrite_rails/blob/master/doc/andand.textile#readme
[returning]: http://github.com/raganwald-deprecated/rewrite_rails/blob/master/doc/returning.md#readme
[rewrite]: http://rewrite.rubyforge.org/
[rf]: http://www.infoq.com/presentations/braithwaite-rewrite-ruby "Video of the Ruby.rewrite(Ruby) presentation"
[rhino]: http://raganwald.com/2007/07/javascript-on-jvm-in-fifteen-minutes.html "How to Run JavaScript on the JVM in Just Fifteen Minutes"
[rr]: http://github.com/raganwald-deprecated/rewrite_rails
[s2p]: http://github.com/raganwald/homoiconic/blob/master/2008-11-28/you_cant_be_serious.md "You Can't be Serious!"
[source]: http://github.com/raganwald-deprecated/rewrite_rails/blob/master/lib/rewrite_rails/block_anaphora.rb "block_anaphora.rb"
[thrush]: http://github.com/raganwald/homoiconic/blob/master/2008-10-30/thrush.markdown#readme "The Thrush"
[w]: http://www.fogcreek.com/FogBugz/blog/post/The-Origin-of-Wasabi.aspx "The Origin of Wasabi"
