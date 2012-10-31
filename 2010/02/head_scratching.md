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

* "[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[peteforde]: http://twitter.com/peteforde "Pete Fode on Twitter"