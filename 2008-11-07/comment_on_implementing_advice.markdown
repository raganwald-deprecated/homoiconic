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
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.