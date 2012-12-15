# Combinator Recipes for Working With Objects in JavaScript, Part I

### combinators

The word "combinator" has a precise technical meaning in mathematics:

> "A combinator is a higher-order function that uses only function application and earlier defined combinators to define a result from its arguments."--[Wikipedia][combinators]

[combinators]: https://en.wikipedia.org/wiki/Combinatory_logic "Combinatory Logic"

In this book, we will be using a much looser definition of "combinator:" Pure functions that act on other functions to produce functions. If Objects are nouns and Methods are verbs, **Combinators are the adverbs of programming**.

If we were learning Combinatorial Logic, we'd start with the most basic combinators like `S`, `K`, and `I`, and work up from there to practical combinators. We'd learn that the fundamental combinators are named after birds following the example of Raymond Smullyan's famous book [To Mock a Mockingbird][mock].

[mock]: http://www.amazon.com/gp/product/B00A1P096Y/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=B00A1P096Y&linkCode=as2&tag=raganwald001-20

There are an infinite number of combinators, but in this article we will focus on combinators that are useful when working with Plain Old JavaScript Objects ("POJOs") and with instances.

## Splat

In JavaScript, arrays have a `.map` method. Map takes a function as an argument, and applies it to each of the elements of the elements. Map then returns all of the results in an array. For example:

    [1, 2, 3, 4, 5].map(function (n) { 
      return n*n 
    })
      //=> [1, 4, 9, 16, 25]
      
We say that `.map` *maps* its arguments over the receiver array's elements. Or if you prefer, that it defines a mapping between its receiver and its result. Libraries like [Underscore] provide a map *function*. It usually works like this:

    _.map([1, 2, 3, 4, 5], function (n) { 
      return n*n 
    })
      //=> [1, 4, 9, 16, 25]
      
> Why provide a map function? well, JavaScript is an evolving language, and when you're writing code that runs in a web browser, you may want to support browsers using older versions of JavaScript that didn't provide the `.map` function. One way to do that is to "shim" the map method into the Array class, the other way is to use a map function. Most library implementations of map will default to the `.map` method if its available.

This recipe isn't for `map`: It's for `splat`, a function that wraps around `map` and turns any other function into a mapping. In concept, `splat` is very simple:

    function splat (fn) {
      return function (array) {
        return _.map(array, fn)
      }
    }
    
Or if you aren't using a library with `map`:

    function splat (fn) {
      return function (array) {
        return array.map(fn)
      }
    }

Here's the above code written using `splat`:

    var squareMap = splat(function (n) { 
      return n*n 
    });
    
    squareMap([1, 2, 3, 4, 5])
      //=> [1, 4, 9, 16, 25]
      
If we didn't use `splat`, we'd have written something like this

    var squareMap = function (array) {
      return _.map(array, function (n) { 
        return n*n 
      })
    };
    
> Functional programming wonks will explain that something called *partial functional application* would be handy here. If JavaScript had it. Which it doesn't. Oh well.

And we'd do that every time we wanted to construct a method that maps an array to some result. `splat` is a very convenient abstraction for a very common pattern.

(`splat` *was suggested by [ludicast](http://github.com/ludicast)*)
    
[Underscore]: http://underscorejs.org

## Get

`get` is a very simple function. It takes the name of a property and returns a function that gets that property from an object:

    function get (attr) {
      return function (object) { return object[attr]; }
    }

You can use it like this:

    var inventory = {
      apples: 0,
      oranges 144,
      eggs: 36
    };
    
    get('oranges')(inventory)
      //=> 144

This isn't much of a recipe yet. But let's combine it with `splat`:

    var inventories = [
      { apples: 0, oranges: 144, eggs: 36 },
      { apples: 240, oranges: 54, eggs: 12 },
      { apples: 24, oranges: 12, eggs: 42 }
    ];
  
    splat(get('oranges'))(inventories)
      //=> [ 144, 54, 12 ]
    
That's nicer than writing things out "longhand:"

    splat(function (inventory) { return inventory.oranges })(inventories)
      //=> [ 144, 54, 12 ]

Ruby users recognize `get`, it's equivalent to `Symbol#to_proc`, the method that allows them to write `inventory.map &:oranges` instead of using a block.

## Pluck

This pattern of combining `splat` and `get` is very frequent in JavaScript code. So much so, that we can take it up another level:

    function pluck (attr) {
      return splat(get(attr))
    }
    
    pluck('eggs')(inventories)
      //=> [ 36, 12, 42 ]
      
Libraries like [Underscore] provide `pluck` in a different form:

    _.pluck(inventories, 'eggs')
      //=> [ 36, 12, 42 ]

Our recipe is terser when you want to name a function:

    var eggsByStore = pluck('eggs');
    
vs.

    function eggsByStore (inventories) {
      return _.pluck(inventories, 'eggs')
    }

[Underscore]: http://underscorejs.org

## Maybe

A common problem in programming is checking for `null` or `undefined` (hereafter called "nothing," while all other values including `0`, `[]` and `false` will be called "something"). Languages like JavaScript do not strongly enforce the notion that a particular variable or particular property be something, so programs are often written to account for values that may be nothing.

This recipe concerns pattern that is very common: A function `fn` takes a value as a parameter, and its behaviour by design is to do nothing if the parameter is nothing:

    function isSomething (value) {
      return value != null
    }

    function checksForSomething (value) {
      if (isSomething(value)) {
        // function's true logic
      }
    }

Alternately, the function may be intended to work with any value, but the code calling the function wishes to emulate the behaviour of doing nothing by design when given nothing:

    var something = isSomething(value) ? 
      doesntCheckForSomething(value) : value;
    
Naturally, there's a recipe for that, borrowed from Haskell's [maybe monad][maybe], Ruby's [andand], and CoffeeScript's existential method invocation:

    function maybe (fn) {
      return function () {
        var i;
        
        if (arguments.length === 0) {
          return
        }
        else {
          for (i = 0; i < arguments.length; ++i) {
            if (arguments[i] == null) return arguments[i]
          }
          return fn.apply(this, arguments)
        }
      }
    }

`maybe` reduces the logic of checking for nothing to a combinator you apply to a function:

    function checksForSomething = maybe(function (value) {
      // function's true logic
    });
    
    var something = maybe(doesntCheckForSomething(value));
    
Now let's look an an elegant use for `maybe`. You recall `get` from above? `get('name')` acts like `function (obj) { return obj.name }` You can use `get` with `.map`: `arrayOfObjects.map(get('name'))` or with `splat`: `splat(get('name))(arrayOfObjects)`. Now consider: What if `arrayOfObjects` is a sparse array? If some of its entries are `null`?

`maybe` to the rescue:

    arrayOfObjects.map(maybe(get('name')))
    
This maps the array, getting the name if there is a value.

## Summary of Part I

* We've seen four handy combinators: `get`, `splat`, `pluck`, and `maybe`.
* `get` and `maybe` play well together; `splat` and `pluck` are conveniences that help program in a functional rather than OO style.

In Part II, we'll look at some combinators that are specifically tuned for working with instance methods: "bound," "send," and "fluent." (*cough*). The recipes in this post are from my book [JavaScript Allongé](http://leanpub.com/javascript-allonge), a book focused on working with functions in JavaScript, including combinators, constructors, methods, and decorators. You can download a [free sample PDF](http://samples.leanpub.com/javascript-allonge-sample.pdf).

[Feedback welcome](mailto:reg@braythwayt.com)!

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