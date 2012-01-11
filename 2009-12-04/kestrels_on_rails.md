Kestrels on Rails
===

As I noted in [Kestrels](http://github.com/raganwald/homoiconic/blob/master/2008-10-29/kestrel.markdown), Ruby on Rails provides #returning, a method with K Combinator semantics:

    returning(expression) do |name|
      # name is bound to the result of evaluating expression
      # this block is evaluated and the result is discarded
    end
      => # the result of evaluating the expression is now returned

Rails also provides *object initializer blocks* for ActiveRecord models. Here's an example from one of my unit tests:

    @board = Board.create(:dimension => 9) do |b|
      b['aa'] = 'black'
      b['bb'] = 'black'
      b['cb'] = 'black'
      b['da'] = 'black'
      b['ba'] = 'white'
      b['ca'] = 'white'
    end
    
So, it looks like in Rails you can choose between an object initializer block and #returning:

    @board = returning(Board.create(:dimension => 9)) do |b|
      b['aa'] = 'black'
      b['bb'] = 'black'
      b['cb'] = 'black'
      b['da'] = 'black'
      b['ba'] = 'white'
      b['ca'] = 'white'
    end
    
In both cases the created object is returned regardless of what the block would otherwise return. But beyond that, the two Kestrels have very different semantics. "Returning" fully evaluates the expression, in this case creating the model instance in its entirety, including all of its callbacks. The object initializer block, on the other hand, is called as part of initializing the object *before* starting the lifecycle of the object including its callbacks.

"Returning" is what you want when you want to do stuff involving the fully created object and you are trying to logically group the other statements with the creation. In my case, that's what I want, I am trying to say that @board is a board with black stones on certain intersections and white stones on other intersections.

Object initialization is what you want when you want to initialize certain fields by hand and perform some calculations or logic before kicking off the object creation lifecycle. That wasn't what I wanted in this case because my `[]=` method depended on the object being initialized. So my code had a bug that was fixed when I changed from object initializers to #returning.

Summary: In Rails, object initializers are evaluated before the object's life cycle is started, #returning's block is evaluated afterwards. And that is today's *lingua obscura*.

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one e-book.
* [What I've Learned From Failure](http://leanpub.com/shippingsoftware), my very best essays about getting software from ideas to shipping products, collected into one e-book.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://reginald.braythwayt.com) | [@raganwald](http://twitter.com/raganwald)