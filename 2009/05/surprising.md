:O
===

In [Rails](http://api.rubyonrails.org/classes/ActiveRecord/NamedScope/ClassMethods.html):

		class Foo < ActiveRecord

			named_scope :bars, :conditions => { :bar => true }

		end
		
		Foo.all(:limit => 20)
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.bars.all(:limit => 20)
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.all(:limit => 20).bars
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

			named_scope :with_ids, lambda {|*ids|
				{:conditions => {:id => ids}}
			}

			named_scope :with, lambda {|*args|
				args.first || {}
			}

		end

		Foo.with_ids(1533, ...).bars
			=> [ #<Foo id: 1533, ... >, ... ]
		Foo.with(:limit => 20).bars
			=> [ #<Foo id: 1533, ... >, ... ]

[That is all](http://github.com/raganwald/homoiconic/blob/master/2009-05-20/all_yall.rb "source code").

---

NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)