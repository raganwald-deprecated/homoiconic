Could RewriteRails Make ActiveRecord Mundane?
===

A thought crossed my mind: Many people complain about [Ruby on Rails](http://rubyonrails.org/ "Ruby on Rails")' use of "magic," things like all of the automatically generated methods and so forth. The most obvious cases are controllers and [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html "Class: ActiveRecord::Base") models (from here in I'll call these "models" even though we both know you can have models that are not ActiveRecord instances).

Consider model classes. A few declarations... `acts_as_inscrutable`, `acts_as_magical`... And the model class gains a whole bunch of class and instance methods, plus often a whole bunch of `method_missing` behaviours that "behave like" methods. Some people complain it is hard to figure out what methods a model really has.

What if [RewriteRails](http://github.com/raganwald-deprecated/rewrite_rails "raganwald's rewrite_rails at master &mdash; GitHub") were to rewrite ActiveRecord model class declarations to "mundane-ify" these magical methods? In other words, after a class has been loaded and all of the magic performed, RewriteRails writes out a `.rb` file that has the source code for all of the magic methods as if the programmer had written them in by hand.

This `.rb` file can be placed somewhere that Rails can't find it, this is a case of documentation. Now a programmer can read the mundane-ified `.rb` file to get an idea of what methods the model class actually has.

Just a thought...

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