# More Combinator Recipes in JavaScript: Partial, Bound, Send and Fluent

(This post follows [Part I]. The recipes in this post are excerpted the book [JavaScript Allongé](http://leanpub.com/javascript-allonge).)
      
## Partial

A basic function building block is *partial application*. When a function takes multiple arguments, we "apply" the function to the arguments by evaluating it with all of the arguments, producing a value. But what if we only supply some of the arguments? In that case, we can't get the final value, but we can get a function that represents *part* of our application.

Partial application is such a common need that many libraries provide some form of partial application tool. You'll find examples in [Lemonad](https://github.com/fogus/lemonad) from Michael Fogus, [Functional JavaScript](http://osteele.com/sources/javascript/functional/) from Oliver Steele and the terse but handy [node-ap](https://github.com/substack/node-ap) from James Halliday.

These two recipes are for quickly and simply applying a single argument, either the leftmost or rightmost.

```javascript
function lpartial (fn, larg) {
  var slice = Array.prototype.slice;
  
  return function () {
    return fn.apply(this, [larg].concat(slice.call(arguments,0)))
  }
}

function rpartial (fn, rarg) {
  var slice = Array.prototype.slice;
  
  return function () {
    return fn.apply(this, slice.call(arguments,0).concat([rarg]))
  }
}

function greet (me, you) {
  return "Hello, " + you + ", my name is " + me
}

var heliosSaysHello = lpartial(greet, 'Helios');

heliosSaysHello('Eartha')
  //=> 'Hello, Eartha, my name is Helios'
  
var sayHelloToCeline = rpartial(greet, 'Celine');

sayHelloToCeline('Eartha')
  //=> 'Hello, Celine, my name is Eartha'
```

Now we can revisit [splat](https://github.com/raganwald/homoiconic/blob/master/2012/12/combinators_1.md#splat). If we were using [Underscore] to ensure that we worked in older browsers, we could write:

```javascript
  function splat (fn) {
    return function (list) {
      return _.map(list, fn)
    }
  }
```

This is really a partial application of `map` in disguise. Let's make it obvious:

```javascript
function splat (fn) {
  return rpartial(_.map, fn)
}
```

### partial with template arguments

`lpartial` and `rpartial` work, but are cumbersome if we want to partially apply a function with a "hole" in the arguments, e.g. 

```javascript   
function formal (greeting, you, me) {
    return greeting + ", " + you + ", my name is " + me
}

formal("Hello", "Thomas", "Clara")
  //=> 'Hello, Thomas, my name is Clara'

var hiMyNameIsPeter = rpartial(lpartial(formal,'Hi'), 'Peter');

hiMyNameIsPeter('Stu')
  //=> 'Hi, Stu, my name is Peter'
```

The "partial" function in this recipe works with any function that does not expect any of its arguments to be `undefined`, and is also context-agnostic.

```javascript
function partial (fn) {
  var fn = arguments[0],
      args = Array.prototype.slice.call(arguments, 1),
      holes = [],
      argIndex;
    
  if (arguments.length > 1) {
    for (argIndex = 0; argIndex < args.length; ++argIndex) {
      if (args[argIndex] === void 0) {
        holes.push(argIndex)
      }
    }
  }  
  else if (fn.length > 0) {
    for (argIndex = 0; argIndex < fn.length; ++argIndex) {
      holes[argIndex] = argIndex;
    }
  }
  
  function partial () {
    var significant = (arguments.length > holes.length) ?
          holes.length : arguments.length,
        savedHoles = [],
        argIndex;
    for (argIndex = 0; argIndex < significant; ++argIndex) {
      if (arguments[argIndex] === void 0) {
        savedHoles.push(holes.shift())
      }
      else args[holes.shift()] = arguments[argIndex];
    }
    holes = savedHoles.concat(holes);
    if (holes.length === 0) {
      return fn.apply(this, args)
    }
    else return partial
  }
  return partial
}

var hiMyNameIsPeter = partial(formal, 'Hi', undefined, 'Peter');

hiMyNameIsPeter('Stu')
  //=> 'Hi, Stu, my name is Peter'
```

As you can see, `partial` takes a template of arguments and returns a function that applies all the arguments that aren't undefined. If there are still some undefined arguments, it returns a partial function again. The one caveat is that if the function supplied expects a variable number of arguments, you should supply the "template" arguments directly to `partial`.

```javascript
var addAll = partial(function () {
  return Array.prototype.reduce.call(arguments, function (a, b) { return a + b})
}, 1, undefined, 3);

addAll(2)
  //=> 6
```

As noted above, our partial recipe allows us to create functions that are partial applications of functions that are context aware. We'd need a different recipe if we wish to create partial applications of object methods.

### Function.prototype.bind

Which brings us to a question: Why can't we use `Function.prototype.bind`? Well, it is opinionated about binding the context. Consider this awful code:

```javascript
function hello (person) {
  return "Hello, " + person.name + ", my name is " + this.name
}
```
    
We can write:

```javascript
hello.call({ name: 'Fred' }, { name: 'Wilma' })
  //=> "hello, Wilma, my name is Fred"
```

And we can partially apply this function:

```javascript
helloWilma = partial(hello, { name: 'Wilma' });

helloWilma.call({ name: 'Fred' })
  //=> "hello, Wilma, my name is Fred"
```

This cannot be accomplished with `Function.prototype.bind`:

```javascript
helloBetty = hello.bind({ name: 'Bjarne' }, { name: 'Betty' });

helloBetty.call({ name: 'Bam Bam' })
  //=> 'Hello, Betty, my name is Bjarne'
```
      
The context has been forcibly bound and neither `.call` nor `.apply` will override this.

## Instances

JavaScript has objects, obviously. In fact everything either is an object or can be coerced into an object at any time. But to be more specific, we will use the word *instance* to refer to an object that has methods. Aren't all functions belonging directly to an object or indirectly through its prototype methods? Usually. We call such functions  *methods* if they directly or indirectly refer to the object using `this`.

To put it simply, a function is a method if it has to have `this` set correctly to work and if it can be accessed using `.` or `[]`. So instances are simply object that have methods.

The rest of the recipes are concerned with instances and their methods.

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

We saw that `bound` can be used to get a bound method from an instance. Unfortunately, invoking such methods is a little messy:

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

[Underscore]: http://underscorejs.org
      
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

## Practical Considerations

The recipes given all work well, and are surprisingly fast on most platforms (but not IE!). That being said, extensive use of `arguments` can be expensive. A production-class library might offer versions of some combinators tuned for a fixed number of arguments, such as `send0` for no arguments, `send1` for one argument, and `sendn` for a variable number of arguments.

If you're using these in the browser and want the maximum amount of compatibility, be prepared to either shim methods like `.map` and `.bind` or write your own wrappers that default to the platform if the methods are available.

## Summary of Part II

* We've seen three combinators for instance methods: "bound," "send," and "fluent."
* We've seen a combinator for partial application: "partial."
* "bound" has implications for callbacks. "send" is useful for mapping and folding. "fluent" simplifies the creation of fluent APIs.
* The recipes are fine for most purposes but YMMV, especially if you want maximum backwards compatibility with browsers.

The recipes in this post are from the book [JavaScript Allongé](http://leanpub.com/javascript-allonge), a book focused on working with functions in JavaScript, including combinators, constructors, methods, and decorators. You can download a [free sample PDF](http://samples.leanpub.com/javascript-allonge-sample.pdf).

[Feedback welcome](mailto:reg@braythwayt.com). Discuss on [hacker news](http://news.ycombinator.com/item?id=4933207) or [reddit](http://www.reddit.com/r/javascript/comments/150294/more_combinator_recipes_in_javascript_partial/).

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

[andand]: https://github.com/raganwald/andand
[maybe]: https://en.wikipedia.org/wiki/Monad_(functional_programming)#The_Maybe_monad

[Part I]: https://github.com/raganwald/homoiconic/blob/master/2012/12/combinators_1.md

[Underscore]: http://underscorejs.org