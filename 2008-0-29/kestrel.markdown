Kestrels
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic "Combinatory logic - Wikipedia, the free encyclopedia"), a Kestrel is a function that returns a constant function:

	# for *any* x,
	kestrel.call(:foo).call(x)
	  => :foo

Although this was originally called the "K Combinator," it is more popularly named a Kestrel following the lead established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.

Kestrels are to be found in Ruby. You may be more familiar with their Ruby 1.9 name, `#tap`. Let's say you have a line like `address = Person.find(...).address` and you wish to log the person instance. With `tap`, you can inject some logging into the expression without messy temporary variables:

	address = Person.find(...).tap { |p| logger.log "person #{p} found" }.address

`tap` is a method in all objects that passes `self` to a block and returns self, ignoring whatever the last item of the block happens to be. Ruby on Rails programmers will recognize the Kestrel in slightly different form:

	address = returning Person.find(...) do |p| 
	  logger.log "person #{p} found"
	end.address

Again, the result of the block is discarded, it is only there for side effects. This behaviour is the same as a Kestrel. Remember `kestrel.call(:foo).call(x)`? If I rewrite it like this, you can see the similarity:

	Kestrel.call(:foo) do
	  x
	end
	  => :foo

Both `returning` and `tap` are handy for grouping side effects together. Methods that look like this:

	def registered_person(params = {})
	  person = Person.new(params.merge(:registered => true))
	  Registry.register(person)
	  person.send_email_notification
	  person
	end

Can be rewritten using `returning`:

	def registered_person(params = {})
	  returning Person.new(params.merge(:registered => true)) do |person|
	    Registry.register(person)
	    person.send_email_notification
	  end
	end
	
It is obvious from the first line what will be returned and it eliminates an annoying error when the programmer neglects to make `person` the last line of the method.

The Kestrel has also been sighted in the form of *initializer blocks*. Consider this example using [Struct](http://blog.grayproductions.net/articles/all_about_struct"All about Struct"):

	Contact = Struct.new(:first, :last, :email) do
	  def to_hash
	    Hash[*members.zip(values).flatten]
	  end
	end

The method `Struct#new` creates a new class. It also accepts an optional block, evaluating the block for side effects only. It returns the new class regardless of what happens to be in the block (it happens to evaluate the block in class scope, a small refinement).

You can use this technique when writing your own classes:

	class Bird < Creature
	  def initialize(*params)
	    # do something with the params
	    yield self if block_given?
	  end
	end

	Forest.add(
		Bird.new(:name => 'Kestrel) { |k| combinators << k }
	)

The pattern of wanting a Kestrel/returning/tap when you create a new object is so common that building it into object initialization is useful. And in fact, it's built into `ActiveRecord`. Methods like `new` and `create` take optional blocks, so you can write:

	class Person < ActiveRecord::Base
	  # ...
	end
	
	def registered_person(params = {})
	  Person.new(params.merge(:registered => true) do |person|
	    Registry.register(person)
	    person.send_email_notification
	  end
	end

In Rails, `returning` is not necessary when creating ActiveRecord instances.

So what have we learned?

1. `tap` and `returning` are useful;
2. "Impractical" Computer Science isn't, and;
2. [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422) belongs on your bookshelf if it isn't there already. The Kestrel is just one bird. Imagine what code you could write with a forest of them at your fingertips!

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub") <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>