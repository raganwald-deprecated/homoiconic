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
      @followers_count="412", @screen_name="raganwald", @url="http://reginald.braythwayt.com", @description="",
      @id="18137723">, @in_reply_to_status_id="", @id="1275406032">

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one e-book.
* [What I've Learned From Failure](http://leanpub.com/shippingsoftware), my very best essays about getting software from ideas to shipping products, collected into one e-book.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

[Reg Braithwaite](http://reginald.braythwayt.com) | [@raganwald](http://twitter.com/raganwald)
