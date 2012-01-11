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

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one e-book.
* [What I've Learned From Failure](http://leanpub.com/shippingsoftware), my very best essays about getting software from ideas to shipping products, collected into one e-book.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

[Reg Braithwaite](http://reginald.braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

