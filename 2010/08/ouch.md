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

I do think that a language's syntax should support cascades like this, but I also like the idea of [significant whitespace](http://github.com/raganwald/homoiconic/blob/master/2010/03/significant_whitespace.md). There's something sloshing around my hindbrain that thinks this can be combined with combinators to produce [code that resembles the structure of the data it consumes and/or generates](http://weblog.raganwald.com/2007/04/writing-programs-for-people-to-read.html "Writing programs for people to read").

ttfn...

---

Recent work:

* [JavaScript Allonge](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [jQuery Combinators](http://githiub.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)