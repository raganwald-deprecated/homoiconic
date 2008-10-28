Here's a little something from my old blog that I found myself using again. If you want the background, you might like my old posts [Really simple anamorphisms in Ruby](http://weblog.raganwald.com/2007/11/really-simple-anamorphisms-in-ruby.html) and [Really useful anamorphisms in Ruby](http://weblog.raganwald.com/2007/11/really-useful-anamorphisms-in-ruby.html).

This week-end, I found myself thinking about `#unfold` in a new way: it's a way of turning an iteration into a collection. So anywhere you might use `for` or `while` or `until`, you can use `#unfold` to create an ordered collection instead. This allows you to use all of your existing collection methods like `#select`, `#reject`, `#map`, and of course `#inject` instead of writing out literal code to accomplish the same thing.

For example, given a class, here are all of the classes and superclasses that implement the class method `#foo`:

	class Foo
	  
	  def foo_handlers
	    self.unfold(&:superclass).select { |klass| klass.respond_to?(:foo) }
	  end
	
	end

[unfold.rb](unfold.rb)