# Combinator Recipes for Working With Objects in JavaScript, Part II

(This post follows [Part I]. The recipes in this post are excerpted the book [JavaScript Allongé](http://leanpub.com/javascript-allonge).)

### instances

JavaScript has objects, obviously. In fact everything either is an object or can be coerced into an object at any time. But to be more specific, we will use the word *instance* to refer to an object that has methods. Aren't all functions belonging directly to an object or indirectly through its prototype methods? Usually. We call such functions  *methods* if they directly or indirectly refer to the object using `this`.

To put it simply, a function is a method if it has to have `this` set correctly to work and if it can be accessed using `.` or `[]`. So instances are simply object that have methods.

The recipes in this second part of the essay are concerned with instances and their methods.

## Bound

In [Part I], we saw a recipe for `get` that plays nicely with properties:

    function get (attr) {
      return function (obj) {
        return obj[attr]
      }
    }

Simple and useful. But when we consider instances with methods, we can see that `get` (and `pluck`) has a failure mode. Specifically, it's not very useful if we every want to get a *method*, since we'll lose the context. Consider some hypothetical class:

    function InventoryRecord (apples, oranges, eggs) {
      this.record = {
        apples: apples,
        oranges: oranges,
        eggs: eggs
      }
    }
    
    InventoryRecord.prototype.apples = function apples () {
      return this.record.apples
    }
    
    InventoryRecord.prototype.oranges = function oranges () {
      return this.record.oranges
    }
    
    InventoryRecord.prototype.eggs = function eggs () {
      return this.record.eggs
    }
    
    var inventories = [
      new InventoryRecord( 0, 144, 36 ),
      new InventoryRecord( 240, 54, 12 ),
      new InventoryRecord( 24, 12, 42 )
    ];
    
Now how do we get all the egg counts?

    splat(get('eggs'))(inventories)
      //=> [ [Function: eggs],
      //     [Function: eggs],
      //     [Function: eggs] ]

And if we try applying those functions...

    splat(get('eggs'))(inventories).map(
      function (unboundmethod) { 
        return unboundmethod() 
      }
    )
      //=> TypeError: Cannot read property 'eggs' of undefined
      
Of course, these are unbound methods we're "getting" from each object. Here's a new version of `get` that plays nicely with methods:

    function bound () {
      var messageName = arguments[0],
          args = Array.prototype.slice.call(arguments, 1);
          
      if (arguments.length === 1) {
        return function (instance) {
          return instance[messageName].bind(instance)
        }
      }
      else {
        return function (instance) {
          return Function.prototype.bind.apply(
            instance[messageName], 
            [instance].concat(args)
          )
        }
      }
    }

    splat(bound('eggs'))(inventories).map(
      function (boundmethod) { 
        return boundmethod() 
      }
    )
      //=> [ 36, 12, 42 ]

`bound` is the recipe for getting a bound method from an object by name. It has other uses, such as callbacks. `bound('render')(aView)` is equivalent to `aView.render.bind(aView)`.

## Send

We saw that `bound` can be used to get a bound method from an instance. Unfortunately, invoking such methods as a little messy:

    splat(bound('eggs'))(inventories).map(
      function (boundmethod) { 
        return boundmethod() 
      }
    )
      //=> [ 36, 12, 42 ]

As we noted, it's ugly to write

    function (boundmethod) { 
      return boundmethod() 
    }

So instead, we write a new recipe:

    function send () {
      var args = Array.prototype.slice.call(arguments, 0),
          fn = bound.apply(this, args);
      
      return function (instance) {
        return fn(instance)();
      }
    }

    splat(send('apples'))(inventories)
      //=> [ 0, 240, 24 ]
      
`send('apples')` works very much like `&:apples` in the Ruby programming language. How about that, JavaScript's "Good Parts" are damn cool. Actually, `send` is a little better. Consider...

    InventoryRecord.prototype.addApples = function apples (howMany) {
      return this.record.apples += howMany;
    }

    splat(send('addApples', 24))(inventories)
      //=> [ 24, 264, 48 ]
      
## And now, a decorator: Fluent

Instance methods can be bifurcated into two classes: Those that query something, and those that update something. Most design philosophies arrange things such that update methods return the value being updated. For example:

    function Cake () {}
    
    extend(Cake.prototype, {
      setFlavour: function (flavour) { 
        return this.flavour = flavour 
      },
      setLayers: function (layers) { 
        return this.layers = layers 
      },
      bake: function () {
        // do some baking
      }
    });
    
    var cake = new Cake();
    cake.setFlavour('chocolate');
    cake.setLayers(3);
    cake.bake();

Having methods like `setFlavour` return the value being set mimics the behaviour of assignment, where `cake.flavour = 'chocolate'` is an expression that in addition to setting a property also evaluates to the value `'chocolate'`.

The [fluent] style presumes that most of the time when you perform an update you are more interested in doing other things with the receiver then the values being passed as argument(s), so the rule is to return the receiver unless the method is a query:

    function Cake () {}
    
    extend(Cake.prototype, {
      setFlavour: function (flavour) { 
        this.flavour = flavour;
        return this
      },
      setLayers: function (layers) { 
        this.layers = layers;
        return this
      },
      bake: function () {
        // do some baking
        return this
      }
    });

The code to work with cakes is now easier to read and less repetitive:

    var cake = new Cake().
      setFlavour('chocolate').
      setLayers(3).
      bake();

For one-liners like setting a property, this is fine. But some functions are longer, and we want to signal the intent of the method at the top, not buried at the bottom. Normally this is done in the method's name, but fluent interfaces are rarely written to include methods like `setLayersAndReturnThis`.

[fluent]: https://en.wikipedia.org/wiki/Fluent_interface

The `fluent` method *decorator* solves this problem:

    function fluent (methodBody) {
      return function () {
        methodBody.apply(this,arguments);
        return this
      }
    }

Now you can write methods like this:

    Cake.prototype.bake = fluent(function () {
      // do some baking
      // using many lines of code
      // and possibly multiple returns
    });

It's obvious at a glance that this method is "fluent." So what's a decorator? A decorator is a specialized combinator. All combinators are functions that answer another function. Decorators are combinators that take a single function as an argument and by convention, the function they return is semantically related to the function they consumed.

A *method* decorator is even more specific in that it's a decorator carefully written to function properly when decorating a method defined in a prototype. Most of the time this is as simple as properly handling the function context, but some decorators have state (The Underscore library has a number of these such as `debounce`), and if they do not preserve state in the instance's context, they cannot be used as method decorators in the prototype.

Fluent is one of the simpler method decorators. Others implement before and after advice, perform pre- and post-condition contract validation, or even handle asynchronous invocation and chaining.

## Summary of Part II

* We've seen three combinators for instance methods: "bound," "send," and "fluent."
* "bound" has implications for callbacks. "send" is useful for mapping and folding. "fluent" simplifies the creation of fluent APIs.

The recipes in this post are from my book [JavaScript Allongé](http://leanpub.com/javascript-allonge), a book focused on working with functions in JavaScript, including combinators, constructors, methods, and decorators. You can download a [free sample PDF](http://samples.leanpub.com/javascript-allonge-sample.pdf).

[Feedback welcome](mailto:reg@braythwayt.com).

---

Recent work:

* "[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), a CoffeeScript implementation of Bill Gosper's HashLife written in the [Williams Style](https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md).
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily. 

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[andand]: https://github.com/raganwald/andand
[maybe]: https://en.wikipedia.org/wiki/Monad_(functional_programming)#The_Maybe_monad

[Part I]: https://github.com/raganwald/homoiconic/blob/master/2012/12/combinators_1.md