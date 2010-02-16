Scratching my Head
===

    AdvancedOpenWater:~ raganwald$ irb
    irb(main):001:0> 1 <=> 2
    => -1
    irb(main):002:0> [1,2] <=> [1,2]
    => 0
    irb(main):003:0> [1,2] <=> [1,1]
    => 1
    irb(main):004:0> [1,2] <=> [2,1]
    => -1
    
So far so good, I think I understand how Ruby's Array class implements the "boat" operator. Which implies something about ordering arrays. Let's confirm my understanding:

    irb(main):005:0> [1,2] < [2,1]
    NoMethodError: undefined method `<' for [1, 2]:Array
            from (irb):5
            from :0
    
Ha! As [Pete Forde][peteforde] puts it, "Nothing about Ruby surprises me any more."

----
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

[Reg Braithwaite](http://reginald.braythwayt.com): [CV](http://reginald.braythwayt.com/RegBraithwaiteDev0110_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)

[peteforde]: http://twitter.com/peteforde "Pete Fode on Twitter"