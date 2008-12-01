How to keep your privates to yourself
===

Thanks to Java and C++, the notion of a private method is commonplace:

	class Foo
	
		def fubar
			fu + 'bar'
		end
		
		def snafu
			'sna' + fu
		end
		
		private
		
		def fu
			'fu'
		end
		
	end

The method `#fu` is private to `self`. (This differs from Java, where private methods are private to any instance of the same class. In Ruby, you cannot call another object's private method even if you are both the same type of object). This type of code often happens when you perform an [Extract Method](http://www.refactoring.com/catalog/extractMethod.html) refactoring, moving some functionality common to `#fubar` and `#snafu` into its own method.

This is fine when `#fu` has semantic meaning to the entire class. Think about it for a moment: any method in the class can use it, so it really is part of the class' internal API. If you have a large class with many public methods, you can accumulate a very large number of private helper methods, many of which are only actually called from a single method, much less two methods.

Such classes often become extremely unwieldy: it is difficult to know which helpers are called by which methods, which is why some OO developers prefer [small classes and short methods](http://binstock.blogspot.com/2008/04/perfecting-oos-small-classes-and-short.html "Perfecting OO's Small Classes and Short Methods"). Alas, small classes and short methods are often difficult to accomplish in some environments. Model classes based on ActiveRecord tend to grow very quickly, because refactoring them into smaller pieces requires migrating the database, and that is relatively expensive.

An alternate way forward is to find ways of organizing the code that directly reflect the dependencies. One of my goals when I organize code is to use Ruby's scoping: if a variable or method is only accessible within a certain scope, it is blatantly obvious that nothing outside of that scope depends on the variable or method.

In this example, `#double` should be in a scope with `#buzz` and `#zztop`. That way you could see at a glance that `#lewis` and `#springsteen` do not use it:

	class Fizz
	
		def buzz
			'bu' + double('z')
		end
		
		def zztop
			double('z') + 'top'
		end
		
		def lewis
			'huey'
		end
		
		def springsteen
			'bruce'
		end
		
		private
		
		def double(c)
			c + c
		end
		
	end