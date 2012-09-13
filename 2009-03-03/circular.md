Circular
===

    AdvancedOpenWater:~ raganwald$ sudo gem install twitter

...

    AdvancedOpenWater:~ raganwald$ irb
    irb(main):001:0> require 'rubygems'
    => true
    irb(main):002:0> require 'twitter'
    => true
    irb(main):003:0> twit = Twitter::Base.new('raganwald', 'already_changed_back')
    => #<Twitter::Base:0x1141f6c @api_host="twitter.com", @proxy_host=nil, @config={:email=>"raganwald", :password=>"already_changed_back"}, @proxy_port=nil>
    irb(main):004:0> twit.update 'http://github.com/raganwald/homoiconic/blob/master/2009-03-03/circular.md'
    => #<Twitter::Status:0x11356cc @truncated=false, @source="web", @favorited=false,
      @text="http://tinyurl.com/agrcgh", @created_at="Tue Mar 03 20:33:19 +0000 2009", @in_reply_to_user_id="",
      @user=#<Twitter::User:0x1125178 @location="Toronto", @name="Reg Braithwaite", @protected=false,
      @profile_image_url="http://s3.amazonaws.com/twitter_production/profile_images/79244481/Picture_1_normal.png",
      @followers_count="412", @screen_name="raganwald", @url="http://braythwayt.com", @description="",
      @id="18137723">, @in_reply_to_status_id="", @id="1275406032">

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CS/JS library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)
