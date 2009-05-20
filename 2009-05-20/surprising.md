:O
===

In [Rails](http://api.rubyonrails.org/classes/ActiveRecord/NamedScope/ClassMethods.html):

		class Foo < ActiveRecord
			named_scope :bars, :conditions => { :bar => true }
		end
		
		Foo.all
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.bars.all
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.all.bars
			=> NoMethodError: undefined method `bars' for #<Array:0x64b6d28>
			
And also:

		Foo.find(1533, ...)
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.bars.find(1533, ...)
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.find(1533, ...).bars
			=> NoMethodError: undefined method `bars' for #<Array:0x64b6d28>

So:

		class Foo < ActiveRecord
			named_scope :bars, :conditions => { :bar => true }
			named_scope :yall, lambda {|*args|
		    args.first || {}
		  }
			named_scope :these, lambda {|*ids|
				{:conditions => {:id => ids}}
			}
		end

		Foo.yall
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.bars.yall
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.yall.bars
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.these(1533, ...)
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.bars.these(1533, ...)
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.these(1533, ...).bars
			=> [ #<Foo id: 1533, ... >, ... ]