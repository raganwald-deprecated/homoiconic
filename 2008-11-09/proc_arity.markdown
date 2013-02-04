Proc#arity in Ruby 1.8
---

[The docs for Proc#arity](http://ruby-doc.org/core/classes/Proc.html#M001577) state:

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

**update**

I thought I'd have a look at method arity as well:

	class Foo
  
	  def no_args
	  end
  
	end

	Foo.module_eval { define_method :no_args_2 do; end }

	Foo.instance_method(:no_args).arity
	  => 0
	Foo.instance_method(:no_args_2).arity
	  => -1

It seems that if you explicitly define a method taking no parameters, you get the correct arity. However, if you use `define_method` and a block, you get the bug again.

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