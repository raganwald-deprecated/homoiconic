cdr been clearer
===

The other day, I noticed [a flurry of people arguing](http://github.com/rails/rails/commit/22af62cf486721ee2e45bb720c42ac2f4121faf4#comments "Comments on a commit to rails") about whether adding methods like `#second`, `#third`, and `#fourth` to `Array` is a good idea or not.

I quipped:

> Would anyone prefer methods like caddr?

I'd better clear something up. I have never written a method like `#fourth` for myself, but I am not rabidly opposed to their inclusion in Rails or Ruby either. My opinion on opening core classes is that it is not sustainable in the long run, but at the same time I'm not losing sleep over the idea that upgrading to Edge Rails will break some piece of code where I've defined the method `#second` as meaning an instance of array seconds the nomination of another model object for speaker of the house.

If it isn't going to break my code, or if people using it isn't going to make their code unreadable... It's hard for me to get worked up about it.

When I asked if people would prefer `caddr`, I was absolutely not suggesting that `#fourth` was clearly superior because it's English. Lisp's `c(a|d)+r` methods are like specialized tools. They are readable to professional Lisp programmers because (a) they are a standard part of the language, and (b) they are more powerful than `#fourth` because they can reach into any arbitrary nested list and extract a node.

Words become unwieldy when you need a lot of them to get the job done. That's why I don't write "The fourteenth day of the sixth month of the year one thousand, nine hundred, and sixty-two" when people ask me my birth date, and that's why terser tools are important parts of programming. If you had to reach into a nested list, you might find `.fourth.last.first.third` a little cumbersome.

I think it's perfectly fine to want to write Ruby code that looks like English. And if you aren't writing "The fourteenth day of the sixth month of the year one thousand, nine hundred, and sixty-two" but rather "The fourth item of this list," it's no big whup to me if you prefer `#fourth` to `[3]`.

So why did I ask the question? I guess I was trying to provoke people into doing something other than arguing about whether David had just moved their cheese. While it's fine to say you like `#fourth`, I think it's also even better to say "Ok, but what would be *really* useful is..." 

That's all.

p.s. If you press me to give a firm opinion, I choose [blue in green](http://bikeshed.com) :-)

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)](http://leanpub.com/javascript-allonge "JavaScript Allongé")![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)