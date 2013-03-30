unfold
---

Here's a little something from my old blog that I found myself using again. If you want the background, you might like my old posts [Really simple anamorphisms in Ruby](http://raganwald.com/2007/11/really-simple-anamorphisms-in-ruby.html) and [Really useful anamorphisms in Ruby](http://raganwald.com/2007/11/really-useful-anamorphisms-in-ruby.html).

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

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)](http://leanpub.com/javascript-allonge "JavaScript Allongé")![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

