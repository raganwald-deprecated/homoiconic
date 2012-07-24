Could RewriteRails Make ActiveRecord Mundane?
===

A thought crossed my mind: Many people complain about [Ruby on Rails](http://rubyonrails.org/ "Ruby on Rails")' use of "magic," things like all of the automatically generated methods and so forth. The most obvious cases are controllers and [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html "Class: ActiveRecord::Base") models (from here in I'll call these "models" even though we both know you can have models that are not ActiveRecord instances).

Consider model classes. A few declarations... `acts_as_inscrutable`, `acts_as_magical`... And the model class gains a whole bunch of class and instance methods, plus often a whole bunch of `method_missing` behaviours that "behave like" methods. Some people complain it is hard to figure out what methods a model really has.

What if [RewriteRails](http://github.com/raganwald-deprecated/rewrite_rails "raganwald's rewrite_rails at master &mdash; GitHub") were to rewrite ActiveRecord model class declarations to "mundane-ify" these magical methods? In other words, after a class has been loaded and all of the magic performed, RewriteRails writes out a `.rb` file that has the source code for all of the magic methods as if the programmer had written them in by hand.

This `.rb` file can be placed somewhere that Rails can't find it, this is a case of documentation. Now a programmer can read the mundane-ified `.rb` file to get an idea of what methods the model class actually has.

Just a thought...

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)