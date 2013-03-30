I'm Sick of This Shit
===

Yesterday, I wrote on Twitter: "Sick of this shit: [http://tinyurl.com/dmnxhu](http://blog.teksol.info/2009/03/27/argumenterror-on-number-sum-when-using-classifier-bayes.html "ArgumentError on #Sum When Using Classifier")." To paraphrase François, the Classifier gem adds a #sum method to the Array class in Ruby. So does Rails' ActiveSupport. This is a problem which requires some hideous forking and patching to resolve.

[![(c) 2005 Karoly Lorentey, some rights reserved](http://farm1.static.flickr.com/24/43762220_6533e951a6_d.jpg)](http://www.flickr.com/photos/lorentey/43762220/ "(c) 2005 Karoly Lorentey, some rights reserved") 

I ran into the exact same problem when implementing [andand](http://andand.rubyforge.org/ "Object#andand"). I wrote a `BlankSlate` class. Some other gems introduce their own BlankSlate classes. So what does andand do? It checks to see whether a BlankSlate class exists when it is instantiated, and it only defines its own if you don't already have one. It doesn't arrogantly assume that you want its own definitions of everything. (Lest you think I have discovered the solution to the problem, consider what happens if someone defines a BlankSlate class that models writing tablets instead of being a lightweight Object superclass, then loads andand. Interesting.)

James Iry's [response on Twitter](http://twitter.com/jamesiry/statuses/1471207766 "Twitter / James Iry: @raganwald dynamic meta-pr ...") was to suggest that "dynamic meta-programming is a very sharp double edged sword." James, yes. And I like that metaphor, because swords are so two millennia ago. James' metaphor captures the cultural problem beautifully.

Look, overwriting the #sum method on Array is a lot like overwriting the value of a variable. This is a solved problem in other programming domains without abandoning programming. For example, in functional programming you can't mutate variables. I can close my eyes and imagine a language where you can extend classes but not change them. In databases you have transactions with isolation between them. I can close my eyes and imagine a language where the Classifier gem has its version of the Array class, Rails has its version, and the two never conflict with each other.

The problem here, the thing that irritates me, is that we are using these medieval tools for meta-programming. The current Ruby Way is a lot like using GOTO. Sure, it works, and perhaps it ought to exist under the covers. But in my lifetime I have witnessed our ability to progress from GOTO to structured programming to mapreduce. Each step along the way has given us an ability to raise the functionality to maintainability ratio.

Likewise over in La-la-lisp land we have moved from naked recursion to recursive combinators. Combinators make our programs easier to understand and reason about. Naked recursion is GOTO dressed up in a scholar's mortar and gown. Likewise naked monkey-patching is GOTO dressed up in... Well, it isn't really dressed up, it's more baggy pants performing a frontside grab.

[Metaprogramming is beautiful.](http://raganwald.com/2008/07/my-analyst-warned-me-but.html "My analyst warned me, but metaprogramming was so beautiful I got another analyst") Now that we have embraced its beauty, let's invest some time and energy taking it to the next level, finding ways to apply abstractions and constraints to it so that we can benefit from it without falling into these entirely avoidable contretemps. I've taken one swing at the bat: I think many of the extensions people have added to core classes (including #andand) ought to be syntactic abstractions rather than methods, so I wrote [RewriteRails](http://github.com/raganwald-deprecated/rewrite_rails).

Now its your turn. Dazzle me.

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