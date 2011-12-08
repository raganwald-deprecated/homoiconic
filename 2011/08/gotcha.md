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

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one convenient and inexpensive e-book.
* [Katy](http://github.com/raganwald/Katy), fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), Coffeescript/Javascript method combinations for Underscore projects.

Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.