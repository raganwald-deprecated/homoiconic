Keep Your Privates To Yourself
===

> Wherein we examine a way to break large classes into private modules and furthermore find a way to make methods private to a module and not to its downstream dependants.

Problem Statement: Subdividing a Class
---

In some architectures, model classes are extremely heavyweight. This is especially the case with database-backed models in legacy schema. Sometimes, the pain of refactoring and migrating the database is so large that developers are reluctant to institute [small classes and short methods](http://binstock.blogspot.com/2008/04/perfecting-oos-small-classes-and-short.html "Perfecting OO's Small Classes and Short Methods").

Scope is an issue: if you break subclasses `C1`, `C1`, and `C3` out of class `C`, you may not actually want `C1`, `C1`, and `C3` to be part of the global scope. You can embed them in `C`, but now `C::C1`, `C::C2`, and `C::C3` are part of `C`'s API. The exact same reasoning holds for breaking functionality out into modules `M1`, `M2`, and `M3`: You don't want them to be part of global scope, nor do you want `C::M1`, `C::M2`, and `C::M3` to be part of `C`'s API.

What we want is to be able to create a 'private' subdivision of a class, such as a module that is private to a class.

No Embedded Modules
---

	class Foo
  
	  module Bar
	    def bar
	      'bar'
	    end
	  end
  
	  include Bar
  
	end
	
	class Fizz
	
		include Foo::Bar
	
	end
	
	Fizz.new.bar
		=> 'bar
		
As mentioned above, simply embedding `Bar` in `Foo` does not make it private, it is part of `Foo`'s API. When you write this code, you are telling every developer they are free to use `Foo::Bar`. We'll have to try something else.

No Private Modules
---

	class Foo
  
	  private
  
	  module Bar
	    def bar
	      'bar'
	    end
	  end
  
	  include Bar
  
	end
	
	obj = Object.new
	obj.extend Foo::Bar
	obj.bar
	
		=> 'bar

Nogoodnik, the `private` keyword does not apply to modules.

Solution: Anonymous Modules
---

	class Foo
  
	  include(Module.new do
	    def bar
	      'bar'
	    end
	  end)
  
	end

	Foo.new.bar
		=> 'bar'
	Foo.ancestors
		=> [Foo, #<Module:0x213cc>, Object, Kernel]

This works. if we want to group several methods and declarations together, we can create an anonymous module inside of a class. It is one of `Foo`'s ancestors, but it is not part of `Foo`'s API. Now we have a recipe for breaking classes into private parts.

Digression: Private Private Bits
---

The recipe for creating anonymous modules within a class is useful for breaking large classes up into chunks of related methods. However, all methods within those anonymous modules are mixed into the base class. Consider the case where you have two related methods, `fubar` and `snafu`:

	class Acronym
  
	  include(Module.new do
    
	    def fubar
	      'fu' + 'bar'
	    end
    
	    def snafu
	      'sna' + 'fu'
	    end
	
	  end)
  
	end

	Acronym.instance_methods - Object.instance_methods
		=> ["fubar", "snafu"]

Let's [extract a helper method](http://www.refactoring.com/catalog/extractMethod.html "Refactoring: 
Extract Method"):

	class Acronym
  
	  include(Module.new do
    
	    def fubar
	      fu() + 'bar'
	    end
    
	    def snafu
	      'sna' + fu()
	    end
    
	    private
    
	    def fu
	      'fu'
	    end
    
	  end)
  
	  def arnie_sez
	    fu() + ', _'
	  end
  
	end

	Acronym.instance_methods - Object.instance_methods
		=> ["fubar", "snafu"]
	Acronym.new.arnie_sez
		=> "fu, _"

As you can see, you can declare private methods in a module (whether anonymous or not), and those methods remain private. However, they are mixed into the class just as the public methods are mixed into the class. Which means they are part of `Acronym`'s *internal* API.

New Problem Statement: Private Helpers
---

What we now want is a way to create functionality that is private inside of a module. So the methods that are mixed into a class can use it, but no other methods from the class can use it. That way, it is 100% clear that the functionality is strictly for the methods in the module.

Solution: Closures and `define_method`
---

One way to accomplish this is to eschew the `def` keyword and use `define_method` with a block. That works because the block is a closure and has access to the local variables in the environment where it was created, while the body of a `def` keyword does not:

	class Acronym
  
	  include(Module.new do
    
	    fu = lambda do
	      'fu'
	    end
    
	    define_method :fubar do
	      fu.call + 'bar'
	    end
    
	    define_method :snafu do
	      'sna' + fu.call
	    end
    
	  end)
  
	  def arnie_sez
	    fu.call + ', _'
	  end
  
	end

	p Acronym.new.snafu
		=> "snafu"
	p Acronym.new.arnie_sez
		=> NameError: undefined local variable or method ‘fu’ for #<Acronym:0x20d64>

If `fu` was not already bound to a local variable, it ceases to exist after the module definition is complete. Even if it was, `#arnie_sez` is defined using the `def` keyword, and the body of a method defined with `def` cannot access local variables from the environment of the class' definition. (If you try really hard, you can take advantage of a known problem that is fixed in Ruby 1.9 to break this in Ruby 1.8, but that is not a fatal flaw).

IMO, this recipe is more than an idle curiosity. The example above shows how to chunk related functionality together, and how to create functionality private to the chunk. And there is another good use for this recipe:

Problem Statement: Organizing Large Methods
---

Quite often you need to break a method up into smaller methods. The traditional procedural solution are private helper methods:

	class Acronym
  
	  def fubar
	    'fu' + 'bar'
	  end
  
	  private
  
	  def fu
	    'fu'
	  end
  
	  def bar
	    'bar'
	  end
  
	end

	Acronym.new.fubar
		=> "fubar"

But as we saw above, it is not obvious that the	`#fu` and `#bar` methods are really private to `#fubar` and not meant to be used by any method in the `Acronym` class.

Local lambdas create extra objects
---

One approach is to create lambdas local to a method:

	class Acronym
  
	  def fubar
	    fu = lambda { 'fu' }
	    bar = lambda { 'bar' }
	    fu.call + bar.call
	  end
  
	end

This makes it very clear that they are not to be used elsewhere. However, you are creating new lambdas every time you call `#fubar`. This probably doesn't matter, however no matter how insignificant the time or memory overhead relative to database queries and the rest of the method, it is difficult to get such code through an inspection without someone trying to score points off you by complaining about the 'excessive' object creation.

Also, you may be accused of having learned programming back when Borland Pascal was all the rage. Nested procedures are very Lisp and Pascal. You would think that being Lisp-like is a good thing in a language its creator nicknamed "MatzLisp," but you will often find the real world of Ruby programmers surprising.

So performance and preserving your reputation are not at risk, this is another solution suitable for the case where the helper is only used by one method. If creating the extra lambdas is inappropriate, you can fall back to the solution given above:

	class Acronym
  
	  include(Module.new do
    
	    fu = lambda { 'fu' }
	    bar = lambda { 'bar' }
  
	    define_method :fubar do
	      fu.call + bar.call
	    end
  
	  end)
  
	end

Conclusion and Some Sugar
---

If you find `include(Module.new do...end)` looks awkward, we can fix that:

	class Module
  
	  def anonymous_module(&block)
	    self.send :include, Module.new(&block)
	  end
  
	end

	class Acronym
  
	  anonymous_module do
    
	    fu = lambda { 'fu' }
	    bar = lambda { 'bar' }
  
	    define_method :fubar do
	      fu.call + bar.call
	    end
  
	  end
  
	end

In conclusion, for those times you do not want to break a class into completely separate modules and classes, you can use anonymous modules to subdivide a class without extending its API. Within an anonymous module, you can use `define_method`, lambdas, and local variables to create helpers that are truly private to the module. This is handy for behaviour shared by methods in the module or for making helpers for a single method.

*	[anonymous\_method.rb](http:anonymous_method.rb)
* An example of this recipe in action: The `separate_args` lambda from [recursive\_combinators.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/recursive_combinators.rb)

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub")
	
Subscribe here to [a constant stream of updates](http://github.com/feeds/raganwald/commits/homoiconic/master "Recent Commits to homoiconic"), or subscribe here to [new posts and daily links only](http://feeds.feedburner.com/raganwald "raganwald's rss feed").

<a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>