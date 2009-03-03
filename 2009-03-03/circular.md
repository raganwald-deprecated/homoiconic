Circular
===

    sudo gem install twitter
    irb(main):001:0> require 'rubygems'
    => true
    irb(main):002:0> require 'twitter'
    => true
    irb(main):003:0> twit = Twitter::Base.new('raganwald', 'mondrijaan')
    => #<Twitter::Base:0x1141f6c @api_host="twitter.com", @proxy_host=nil, @config={:email=>"raganwald", :password=>"mondrijaan"}, @proxy_port=nil>
    irb(main):004:0> twit.update 'http://github.com/raganwald/homoiconic/blob/master/2009-03-03/circular.md'

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

[Hire Reg Braithwaite!](http://reginald.braythwayt.com/RegBraithwaiteGH0109_en_US.pdf "")
