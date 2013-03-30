Keep Your Privates To Yourself
===

> Wherein we examine a way to break large classes into private modules and furthermore find a way to make methods private to a module and not to its downstream dependents.

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

Modules Can't Be Private
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

If you find `include(Module.new do...end)` looks awkward, we can fix that:

	class Module
	
	  def anonymous_module(&block)
	    self.send :include, Module.new(&block)
	  end
	
	end

	class Acronym
	
	  anonymous_module do
	
	    def fubar
	      'fubar'
	    end
	
	    def snafu
	      'snafu'
	    end
	
	  end
	
	end

More about Anonymous Modules
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
	  => NameError: undefined local variable or method ‘fu' for #<Acronym:0x20d64>

If `fu` was not already bound to a local variable, it ceases to exist after the module definition is complete. Even if it was, `#arnie_sez` is defined using the `def` keyword, and the body of a method defined with `def` cannot access local variables from the environment of the class' definition. (If you try really hard, you can take advantage of a known problem that is fixed in Ruby 1.9 to break this in Ruby 1.8, but that is not a fatal flaw).

Problems with closures and `define_method`
---

The `define_method`-and-lambda approach has a few problems:

* RDoc no longer sees the `define_method`'d method, so any comments you wrote for it won't get turned into documentation.
* Because it's just a lambda bound to a variable, the private helper has to appear before the method that calls it.  This makes the code a bit harder for a client of the module to read, as they have to skip over implementation details to get to the public interface.
* The appears-before constraint also means two such helper methods can't call each other.  This means (among other things) you can't do mutual recursion.

Solutions: wrapper methods and forward declarations
----

An inelegant solution to the RDoc problem is to wrap the `define_method` in another, regular method:

    # Call this to fubar x, y and z
    def fubar(x, y, z)
      fubar_wrapped(x, y, z)
    end

    define_method :fubar_wrapped do |x, y, z|
      fu.call + 'bar'
    end

However, this solution isn't great for two reasons:

* now `fubar_wrapped` is part of the module's public interface.
* the parameter list `x, y, z` has to be mentioned three times.  Making the wrapper take `*args` doesn't help because then RDoc loses the parameter information.

There's probably a better way to do this.

To allow mutual recursion, we can borrow an idiom from C (admittedly never a good sign): forward declarations.

    # forward declarations
    fu = nil
    bar = nil

    # public interface
    def fubar
      fu.call + bar.call
    end

    # helpers
    fu = lambda do
      bar.call
    end

    bar = lambda do
      fu.call
    end

This also means if all you're looking for is the public interface, you don't have to skip over the helper code to get to it, but you do have to skip over the forward declarations, so it's not clear whether that's a win.  Also, the forward declarations are fugly, but they get the job done.

Another use for closures in an anonymous module
---

What if you would like to create a class variable that should be "local" to a module because it is only used by a method or methods in the module:

	class Acronym

	  anonymous_module do

	    def fubar
	      @@effed_up ||= 0
	      @@effed_up += 1
	      "You effed up #{@@effed_up} times"
	    end

	  end

	end

	Acronym.new.fubar
	  => "You effed up 1 times"
	Acronym.new.fubar
	  => "You effed up 2 times"
	Acronym.new.fubar
	  => "You effed up 3 times"

What happens when another method in the `Acronym` class wants to use `@@effed_up`?

	class Acronym
	
	  def snafu
	    @@effed_up ||= 0
	    @@effed_up += 1
	    "You effed up #{@@effed_up} times"
	  end
	
	end
	  
	Acronym.new.snafu
	  => "You effed up 4 times"

It seems that class variables are not private to a module. However, we can use local variables and closures for more than just lambdas:

	class Acronym

	  anonymous_module do
	  
	    effed_up = 0

	    define_method :fubar do
	      effed_up += 1
	      "You effed up #{effed_up} times"
	    end

	  end

	end 

	Acronym.new.fubar
	  => "You effed up 1 times"
	Acronym.new.fubar
	  => "You effed up 2 times"
	Acronym.new.fubar
	  => "You effed up 3 times"

You can use local variables and `define_method` to create the effect of class variables that are strictly local to the module and private from other methods in the class.

Problem Statement: Organizing Large Methods
---

Quite often you need to break a method up into smaller methods. The traditional procedural solution are private helper methods:

	class Acronym
	
	  def fubar
	    fu() + bar()
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

But as we saw above, it is not obvious that the  `#fu` and `#bar` methods are really private to `#fubar` and not meant to be used by any method in the `Acronym` class.

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

Conclusion and a Tip
---

In conclusion, for those times you do not want to break a class into completely separate modules and classes, you can use anonymous modules to subdivide a class without extending its API. Within an anonymous module, you can use `define_method`, lambdas, and local variables to create helpers that are truly private to the module. This is handy for behaviour shared by methods in the module or for making helpers for a single method.

And a tip: *Using local variables and `defne_method` to create private helpers and variables local to a module is not restricted to anonymous modules, you can use it with any module you like.*

*  [anonymous\_method.rb](http:anonymous_method.rb)
* An example of this recipe in action: The `separate_args` lambda from [recursive\_combinators.rb](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/recursive_combinators.rb)

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