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

<hr/>
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.