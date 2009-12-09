Block Styling
===

(*This is just an FYI, there is little of deep significance to follow...*)

You probably know that Ruby supports writing parameter-less blocks using `begin` and `end`:

    fu = begin
           a = 1
           b = 2
           c = 3
           a + b + c
         end
    # => 6

You may also know that you can use parentheses with multiple lines:

    fu = ( a = 1
           b = 2
           c = 3
           a + b + c )
    # => 6
    
I didn't know that! As usual, semi-colons work as separators:

    fu = ( a = 1
           b = 2; c = 3
           a + b + c )
    # => 6
    
The sharp-eyed amongst you may have noticed that some of these statements could be combined with Ruby's destructuring assignment:

    fu = ( a, b, c = 1, 2, 3
           a + b + c )
    # => 6
    
But that's a *different* language feature. Okay, that's enough lingua obscura for today.

----
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0909_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)