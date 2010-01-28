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

Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteDev0110_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)