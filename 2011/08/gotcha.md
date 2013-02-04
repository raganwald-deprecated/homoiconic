Gotcha!
===

I'm working late on a Saturday at the office on a Rails project (I have a real first world problem). One of the neat things you probably already know about `ActiveRecord::Relation` is that you can create something that looks like a scope using a class method. Here's one that duplicates the `.find(...)` method, more or less:

    class Example < ActiveRecord::Base
  
      def self.including_ids(ids)
        where(id: ids)
      end
  
    end
  
This takes advantage of the fact that you can provide an array as a value and `ActiveRecord::Relation` will generate an `WHERE id IN (...)` clause for you. Alas, I needed to write my own clause to achieve the reverse:

    class Example < ActiveRecord::Base
  
      def self.including_ids(ids)
        where(id: ids)
      end
  
      def self.excluding_ids(ids)
        where('id NOT IN (:exluded_ids)', exluded_ids: ids)
      end
  
    end

And the gotcha? Well what do you think happens when you write `Example.including_ids([])`. If you said "an empty selection," you're right. What about this?

    Example.excluding_ids([])
      => # ????
    
Were you expecting an empty selection? *Me neither*.

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