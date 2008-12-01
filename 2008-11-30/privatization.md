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

The method `#fu` is private to `self`. (This differs from Java, where private methods are private to any instance of the same class. In Ruby, you cannot call another object's private method even if you are both the same type of object).

In the Java world, private methods are often helpers of one sort or another. In the popular [Eclipse IDE](http://www.eclipse.org/ "Eclipse.org home"), 