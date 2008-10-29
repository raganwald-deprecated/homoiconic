unfold
---

Here's a little something from my old blog that I found myself using again. If you want the background, you might like my old posts [Really simple anamorphisms in Ruby](http://weblog.raganwald.com/2007/11/really-simple-anamorphisms-in-ruby.html) and [Really useful anamorphisms in Ruby](http://weblog.raganwald.com/2007/11/really-useful-anamorphisms-in-ruby.html).

This week-end, I found myself thinking about `#unfold` in a new way: it's a way of turning an iteration into a collection. So anywhere you might use `for` or `while` or `until`, you can use `#unfold` to create an ordered collection instead. This allows you to use all of your existing collection methods like `#select`, `#reject`, `#map`, and of course `#inject` instead of writing out literal code to accomplish the same thing.

For example, given a class, here are all of the classes and superclasses that implement the class method `#foo`:

	class Foo
	  
	  def self.foo_handlers
	    self.unfold(&:superclass).select { |klass| klass.respond_to?(:foo) }
	  end
	
	end

The little idea here is that you don't have to write a loop of some sort climbing the class tree and accumulating an array of classes that respond to `#foo` as you go. This expresses the same idea in terms of operations on a collection.

**Git it**

The code for unfold is at [unfold.rb](unfold.rb). To use it in a Rails project, drop unfold.rb in config/initializers. 

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub") <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a><script src="http://feeds.feedburner.com/~s/raganwald?i=http://github.com/raganwald/homoiconic/tree/master/2008-10-27/unfold.markdown" type="text/javascript" charset="utf-8"></script>
		<script language="JavaScript" type="text/javascript" src="http://pub44.bravenet.com/counter/code.php?id=382140&usernum=3754613835&cpv=2">
		</script>
		<script type="text/javascript" src="http://www.assoc-amazon.com/s/link-enhancer?tag=raganwald001-20">
		</script>
		<noscript>
			<img src="http://www.assoc-amazon.com/s/noscript?tag=raganwald001-20" alt="" />
		</noscript>
	</div>