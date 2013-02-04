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

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)](http://leanpub.com/javascript-allonge "JavaScript Allongé")![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)