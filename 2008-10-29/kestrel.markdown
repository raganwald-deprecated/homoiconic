Kestrels
---

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), a Kestrel is a function that returns a constant function, normally written `Kxy = x`. In Ruby, it might look like this:

	# for *any* x,
	kestrel.call(:foo).call(x)
	  => :foo

Although its formal name is the "K Combinator," it is more popularly named a Kestrel following the lead established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.  
  

[![Kestrel (c) 2006 Ian Turk, some rights reserved](http://farm1.static.flickr.com/99/298991569_911a900738.jpg)](http://www.flickr.com/photos/ianturk/298991569/ "Kestrel (c) 2006 Ian Turk, some rights reserved")  
  

Kestrels are to be found in Ruby. You may be familiar with their Ruby 1.9 name, `#tap`. Let's say you have a line like `address = Person.find(...).address` and you wish to log the person instance. With `tap`, you can inject some logging into the expression without messy temporary variables:

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

**object initializer blocks**

The Kestrel has also been sighted in the form of *object initializer blocks*. Consider this example using [Struct](http://blog.grayproductions.net/articles/all_about_struct "All about Struct"):

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
	  Person.new(params.merge(:registered => true)) do |person|
	    Registry.register(person)
	    person.send_email_notification
	  end
	end

In Rails, `returning` is not necessary when creating instances of your model classes, thanks to ActiveRecord's built-in object initializer blocks.

**a variation on the kestrel**

When we discussed `Struct` above, we noted that its initializer block has a slightly different behaviour than `tap` or `returning`. It takes an initializer block, but it doesn't pass the new class to the block as a parameter, it evaluates the block in the context of the new class.

Putting this into implementation terms, it evaluates the block with `self` set to the new class. This is not the same as `returning` or `tap`, both of which leave `self` untouched. We can write our own version of `returning` with the same semantics. We will call it `inside`:

	module Kernel
  
	  def inside(value, &block)
	    value.instance_eval(&block)
	    value
	  end
  
	end
	
You can use this variation on a Kestrel just like `returning`, only you do not need to specify a parameter:

	inside [1, 2, 3] do
	  uniq!
	end
	  => [1, 2, 3]

This isn't particularly noteworthy. Of more interest is your access to private methods and instance variables:

	sna = Struct.new('Fubar') do
	  attr_reader :fu
	end.new

	inside(sna) do
	  @fu = 'bar'
	end
	  => <struct Struct::Fubar >

	sna.fu
	  => 'bar'

`inside` is a Kestrel just like `returning`. No matter what value its block generates, it returns its primary argument. The only difference between the two is the evaluation environment of the block.

So what have we learned?

1. `tap`, `returning`, and `inside` are useful;
2. "Impractical" Computer Science isn't, and;
3. [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422) belongs on your bookshelf if it isn't there already. The Kestrel is just one bird. Imagine what code you could write with a forest of them at your fingertips!

**post scriptum**

* `returning` is part of Ruby on Rails. `tap` is part of Ruby 1.9. It is available for Ruby 1.8 as part of the [andand gem](http://andand.rubyforge.org). `sudo gem install andand`.
* [inside.rb](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/inside.rb): If you are using Rails, drop it in `config/initializers` to make it available in your project.
* [You keep using that idiom](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/you_keep_using_that_idiom.markdown#readme). I do not think it means what you think it means.

_More on combinators_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), [The Hopelessly Egocentric Blog Post](http://github.com/raganwald/homoiconic/tree/master/2009-02-02/hopeless_egocentricity.md#readme), [Wrapping Combinators](http://github.com/raganwald/homoiconic/tree/master/2009-06-29/wrapping_combinators.md#readme), and [Mockingbirds and Simple Recursive Combinators in Ruby](https://github.com/raganwald/homoiconic/blob/master/2011/11/mockingbirds.md#readme).

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)](http://leanpub.com/javascript-allonge "JavaScript Allongé")![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* "[JavaScript Allongé](http://leanpub.com/javascript-allonge),[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)