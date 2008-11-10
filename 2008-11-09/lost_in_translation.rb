Lost in Translation: The real behaviour of Proc#arity
---

Obviously, something must have been lost when translating the docs to English. [For example](http://ruby-doc.org/core/classes/Proc.html#M001577 "Proc#arity"):

> `prc.arity → fixnum`: Returns the number of arguments that would not be ignored. If the block is declared to take no arguments, returns 0. If the block is known to take exactly n arguments, returns n. If the block has optional arguments, return -n-1, where n is the number of mandatory arguments. **A proc with no argument declarations is the same a block declaring || as its arguments.**

	Proc.new {}.arity          #=>  0
	Proc.new {||}.arity        #=>  0
	Proc.new {|a|}.arity       #=>  1
	Proc.new {|a,b|}.arity     #=>  2
	Proc.new {|a,b,c|}.arity   #=>  3
	Proc.new {|*a|}.arity      #=> -1
	Proc.new {|a,*b|}.arity    #=> -2
	
Let's try it:

	raganwald:2008-11-07 raganwald$ ruby -v
	ruby 1.8.6 (2008-03-03 patchlevel 114) [universal-darwin9.0]
	raganwald:2008-11-07 raganwald$ irb
	>> Proc.new {}.arity
	=> -1
	>> Proc.new {||}.arity 
	=> 0
	>> Proc.new {|*a|}.arity
	=> -1

I guess I need to find another way of detecting a proc with no argument declarations. At least until [known issue 574](http://redmine.ruby-lang.org/projects/ruby/issues?format=pdf "Ruby Issues [PDF]") is resolved.