Ouch
===

I found myself writing this JavaScript today:

		framework.use(Sammy.Haml);
		framework.element_selector = '#main'; 
		framework.get('#/', application.controllers.home);
		
After working on [jQuery Combinators](http://github.com/raganwald/JQuery-Combinators/), it physically *hurts* to deal with Plain Old JavaScript Objects that don't support chaining or even `tap`. I can't allow myself to get sidetracked right now, but I am convinced that plugins and programming conventions are not the right place to solve this.

SmallTalk had a syntax for this in the *Last Freakin' Century*:

		framework
		  use: (Sammy at: 'Haml');
		  elementSelector: '#main'; 
		  get: '#/' handledWith: ((application at: 'controllers') at: 'home').

I do think that a language's syntax should support cascades like this, but I also like the idea of [significant whitespace](http://github.com/raganwald/homoiconic/blob/master/2010/03/significant_whitespace.md). There's something sloshing around my hindbrain that thinks this can be combined with combinators to produce [code that resembles the structure of the data it consumes and/or generates](http://raganwald.com/2007/04/writing-programs-for-people-to-read.html "Writing programs for people to read").

ttfn...

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