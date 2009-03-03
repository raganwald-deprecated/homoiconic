Circular
===

  sudo gem install twitter
  irb(main):001:0> require 'rubygems'
  => true
  irb(main):002:0> require 'twitter'
  => true
  irb(main):003:0> twit = Twitter::Base.new('raganwald', 'mondrijaan')
  => #<Twitter::Base:0x1141f6c @api_host="twitter.com", @proxy_host=nil, @config={:email=>"raganwald", :password=>"mondrijaan"}, @proxy_port=nil>
  irb(main):004:0> twit.update 'http://github.com/raganwald/homoiconic/master/tree/2009-03-03/circular.md'