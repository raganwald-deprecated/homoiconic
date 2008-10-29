and and or
===

In a comment on [Ruby Stylista](http://www.pathf.com/blogs/2008/10/ruby-stylista/), I mentioned how I use the `and` and `or` keywords in Ruby. To refresh, `and` and `or` work just like `&&` and `||`, only with very low precedence. For example:

	foo = 5 && 10; foo
	  => 10
	foo = (5 && 10); foo;
	  => 10
	foo = 5 and 10; foo
	  => 5
	(foo = 5) and 10; foo
	  => 5

You can see from the examples how the expression is 'grouped' by the very low precedence of `and` and `or`. Since they are such low precedence, I use them to create conditional execution, to tie two imperative statements together. For example, you could write:

	foo = fubar() if do_something()

This reverses the order of execution, putting the caluse `do_something()` after `foo = fubar()` even though it will happen in the opposite order. If you wish to write them in temporal order, you can use `and`:

	do_something() and foo = fubar()

This puts "first things first." Likewise you can use `or` to reverse the order of an `unless` statement. Instead of:

	raise 'fubar' unless do_something()

You could write:

	do_something() or raise 'fubar'

Again putting the first thing first. I normally only do this if both clauses are imperative. In other words, I would not rewrite either of these statements because the predicate is a query with no side-effects:

	foo = fubar() if something.blank?
	raise 'fubar' unless something?

The predicate seems less important than the consequent, which suggests that it should come second even though the test is performed first.

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub") <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a><script src="http://feeds.feedburner.com/~s/raganwald?i=http://github.com/raganwald/homoiconic/tree/master/2008-10-28/and_and_or.markdown" type="text/javascript" charset="utf-8"></script>
		<script language="JavaScript" type="text/javascript" src="http://pub44.bravenet.com/counter/code.php?id=382140&usernum=3754613835&cpv=2">
		</script>
		<script type="text/javascript" src="http://www.assoc-amazon.com/s/link-enhancer?tag=raganwald001-20">
		</script>
		<noscript>
			<img src="http://www.assoc-amazon.com/s/noscript?tag=raganwald001-20" alt="" />
		</noscript>
	</div>