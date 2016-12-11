[matthias\_georgi](http://www.reddit.com/user/matthias_georgi/) commented on reddit:

> Looking at the implementation of instance_exec, I am really concerned about performance. This code gets executed for each adviced method call:

	def instance_exec(*args, &block)
	  begin
	    old_critical, Thread.critical = Thread.critical, true
	    n = 0
	    n += 1 while respond_to?(mname="__instance_exec#{n}")
	    InstanceExecHelper.module_eval{ define_method(mname, &block) }
	  ensure
	    Thread.critical = old_critical
	  end
	  begin
	    ret = send(mname, *args)
	  ensure
	    InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
	  end
	  ret
	end
	
>So for each advice call, there will be added an additional method to a module, which will be removed immediately after the call. This approach will probably slow down method calling by factor 10-100 (my estimate).

> Well, I know, there isn't any other solution for instance_exec at the moment, but somehow I don't like workarounds in this dimension. However, great article :)

Very correct, and when time permits we could look at a messier but faster solution for Ruby 1.8. I also think this problem goes away in Ruby 1.9.

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