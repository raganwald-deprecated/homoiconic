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

---

Recent work:

* [JavaScript Allonge](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [jQuery Combinators](http://githiub.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[peteforde]: http://twitter.com/peteforde "Pete Fode on Twitter"