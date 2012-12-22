unfold
---

Here's a little something from my old blog that I found myself using again. If you want the background, you might like my old posts [Really simple anamorphisms in Ruby](http://weblog.raganwald.com/2007/11/really-simple-anamorphisms-in-ruby.html) and [Really useful anamorphisms in Ruby](http://weblog.raganwald.com/2007/11/really-useful-anamorphisms-in-ruby.html).

This week-end, I found myself thinking about `#unfold` in a new way: it's a way of turning an iteration into a collection. So anywhere you might use `for` or `while` or `until`, you can use `#unfold` to create an ordered collection instead. This allows you to use all of your existing collection methods like `#select`, `#reject`, `#map`, and of course `#inject` instead of writing out literal code to accomplish the same thing.

For example, given a class, here are all of the classes and superclasses that implement the class method `#foo`:

	class Foo
	  
	  def self.foo_handlers
	    self.unfold(&:superclass).select { |klass| klass.respond_to?(:foo) }
	  end
	
	end

The little idea here is that you don't have to write a loop of some sort climbing the class tree and accumulating an array of classes that respond to `#foo` as you go. This expresses the same idea in terms of operations on a collection.

**Git it**

The code for unfold is at [unfold.rb](unfold.rb). To use it in a Rails project, drop unfold.rb in config/initializers. 

---

Recent work:

* [JavaScript Allonge](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [jQuery Combinators](http://githiub.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

