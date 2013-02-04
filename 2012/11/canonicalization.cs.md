# Canonicalization in CoffeeScript

(click [here](https://github.com/raganwald/homoiconic/blob/master/2012/11/canonicalization.js.md#readme) for examples in JavaScript)

---

In CoffeeScript, a few types of values--numbers, strings, `undefined`, `null`, `true`, and `false`--have *canonical* representations. In other words, every `true` is identical to every other `true`, every `42` is identical to every other `42`, &c.

This is not the case for objects, arrays, and functions. When we create a new object, even if it appears to be the "same" as some other object, it is a different value, as we can tell when we test its identity with `is`:

```coffeescript
{ foo: 'bar' } is { foo: 'bar' }
  #=> false  
```  

Sometimes, this is not what you want. A non-trivial example is the [HashLife] algorithm for computing the future of Conway's Game of Life. HashLife aggressively caches both patterns on the board and their futures, so that instead of iteratively simulating the cellular automaton a generation at a time, it executes in logarithmic time.

[HashLife]: https://en.wikipedia.org/wiki/Hashlife

In order to take advantage of cached results, HashLife must canonicalize square patterns. If two data structures represent the same pattern of cells on the board, they must be the same value regardless of how they were computed.

One way to make this work is to eschew having all the code create new objects with a constructor. Instead, the construction of new objects is delegated to a cache. When a function needs a new object, it asks the cache for it. If a matching object already exists, it is returned. If not, a new one is created and placed in the cache.

This is the algorithm used by [recursiveuniver.se], an experimental implementation of HashLife in CoffeeScript. The fully annotated source code for canonicalization is [online], and it contains this method for the `Square.cache` object:

[recursiveuniver.se]: http://recursiveuniver.se
[online]: http://recursiveuniver.se/docs/canonicalization.html

```coffeescript
for: (quadrants, creator) ->
  found = Square.cache.find(quadrants)
  if found
    found
  else
    {nw, ne, se, sw} = quadrants
    Square.cache.add _for(quadrants, creator)
```
        
Instead of enjoying a stimulating digression explaining how that works, let's make our own. We're going to build a class for cards in a traditional deck. Without canonicalization, it looks like this:

```coffeescript
class Card
  ranks = [2..10].concat ['J', 'Q', 'K', 'A']
  suits = ['C', 'D', 'H', 'S']
  constructor: ({@rank, @suit}) ->
    throw "#{@rank} is a bad rank" unless @rank in ranks
    throw "#{@suit} is a bad suit" unless @suit in suits
  toString: ->
    '' + @rank + @suit
```
        
The instances are not canonicalized:

```coffeescript        
 new Card({rank: 4, suit: 'S'}) is new Card({rank: 4, suit: 'S'})
   #=> false
```
       
Nota Bene: *If a constructor function explicitly returns a value, that's what is returned. Otherwise, the newly constructed object is returned. Unlike other functions and methods, the last evaluated value is not returned by default.*

We can take advantage of that to canonicalize cards:

```coffeescript
class Card
  ranks = [2..10].concat ['J', 'Q', 'K', 'A']
  suits = ['C', 'D', 'H', 'S']
  cache = {}
  constructor: ({@rank, @suit}) ->
    throw "#{@rank} is a bad rank" unless @rank in ranks
    throw "#{@suit} is a bad suit" unless @suit in suits
    return cache[@toString()] or= this
  toString: ->
    '' + @rank + @suit
```
        
Now the instances are canonicalized:

```coffeescript        
 new Card({rank: 4, suit: 'S'}) is new Card({rank: 4, suit: 'S'})
   #=> true
```
       
Wonderful! That being said, there is a caveat of canonicalizing instances of a class: The JavaScript engine that executes CoffeeScript at run time does not support [weak references](https://en.wikipedia.org/wiki/Weak_reference). If you wish to perform cache eviction for memory management purposes, you will have to implement your own reference management scheme. This may be non-trivial.

(Discuss on [/r/coffeescript](http://www.reddit.com/r/coffeescript/comments/12nidl/quick_tip_canonicalization_in_coffeescript/). This note appears in slightly different form in the book [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto).)

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