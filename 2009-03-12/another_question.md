I have a question about organizing projects:
===

If someone wrote code like this:

    class Account
      ...
    end
    
    class Customer
      ...
    end

    class Displayamajig
    
      def display_account(account)
        ...
      end
      
      def display_customer(customer)
        ...
      end
      
      ...
      
    end
    
    class Persistamajig
    
      def persist_account(account)
        ...
      end
      
      def retrieve_account(account_identifier)
        ...
      end
    
      def persist_customer(customer)
        ...
      end
      
      def retrieve_customer(customer_identifier)
        ...
      end
      
      ...
      
    end
    
    ...

Would you suggest they rewrite things like this?

    class Account
    
      def display
        ...
      end
      
      def persist
        ...
      end
      
      def retrieve(identifier)
        ...
      end
      
      ...
      
    end
    
    class Customer
    
      def display
        ...
      end
      
      def persist
        ...
      end
      
      def retrieve(identifier)
        ...
      end
      
      ...
      
    end

If so, wouldn't it make sense that if you saw an application organized like this:

[![A Standard Rails App](http://farm4.static.flickr.com/3609/3349332232_75c370f812_o.png)](http://www.flickr.com/photos/raganwald/3349332232/ "A Standard Rails App") 

That you should refactor it into this:

[![A Refactored Rails App](http://farm4.static.flickr.com/3440/3348520567_3030b63a31_o.png)](http://www.flickr.com/photos/raganwald/3348520567/ "A Refactored Rails App")

**Why? Why not??**

*Join the discussion on [Hacker News](http://news.ycombinator.com/item?id=513472)*.

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