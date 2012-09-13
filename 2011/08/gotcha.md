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

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CS/JS library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)