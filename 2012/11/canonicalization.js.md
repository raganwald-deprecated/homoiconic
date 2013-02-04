# Canonicalization in JavaScript

(click [here](https://github.com/raganwald/homoiconic/blob/master/2012/11/canonicalization.cs.md#readme) for examples in CoffeeScript)

---

In JavaScript, a few types of values--numbers, strings, `undefined`, `null`, `true`, and `false`--have *canonical* representations. In other words, every `true` is identical to every other `true`, every `42` is identical to every other `42`, &c.

This is not the case for objects, arrays, and functions. When we create a new object, even if it appears to be the "same" as some other object, it is a different value, as we can tell when we test its identity with `===`:

```javascript
{ foo: 'bar' } === { foo: 'bar' }
  //=> false
```

Sometimes, this is not what you want. A non-trivial example is the [HashLife] algorithm for computing the future of Conway's Game of Life. HashLife aggressively caches both patterns on the board and their futures, so that instead of iteratively simulating the cellular automaton a generation at a time, it executes in logarithmic time.

[HashLife]: https://en.wikipedia.org/wiki/Hashlife

In order to take advantage of cached results, HashLife must canonicalize square patterns. If two data structures represent the same pattern of cells on the board, they must be the same value regardless of how they were computed.

One way to make this work is to eschew having all the code create new objects with a constructor. Instead, the construction of new objects is delegated to a cache. When a function needs a new object, it asks the cache for it. If a matching object already exists, it is returned. If not, a new one is created and placed in the cache.

This is the algorithm used by [recursiveuniver.se], an experimental implementation of HashLife in the JavaScript's CoffeeScript dialect. The fully annotated source code for canonicalization is [online], and it contains this method for the `Square.cache` object:

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
        
Instead of enjoying a stimulating digression explaining CoffeeScript and how that method works, let's make our own. We're going to build a class for cards in a traditional deck. Without canonicalization, it looks like this:

```javascript
var ranks = [2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
var suits = ['C', 'D', 'H', 'S']
function Card(rank, suit) {
  if (ranks.indexOf(rank) < 0) {
    throw '' + rank + ' is a bad rank'
  }
  if (suits.indexOf(suit) < 0) {
    throw suit + ' is a bad suit'
  }
  this.rank = rank;
  this.suit = suit;
}
Card.prototype.toString = function () {
  return '' + this.rank + this.suit
}
```
        
The instances are not canonicalized:

```javascript  
new Card(4, 'S') === new Card(4, 'S')
  //=> false
```
       
Nota Bene: *If a constructor function explicitly returns a value, that's what is returned. Otherwise, the newly constructed object is returned.*

We can take advantage of that to canonicalize cards:

```javascript
var ranks = [2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
var suits = ['C', 'D', 'H', 'S']
function Card(rank, suit) {
  if (ranks.indexOf(rank) < 0) {
    throw '' + rank + ' is a bad rank'
  }
  if (suits.indexOf(suit) < 0) {
    throw suit + ' is a bad suit'
  }
  this.rank = rank;
  this.suit = suit;
  var hash = this.toString();
  var cache = this.constructor.cache;
  return cache[hash] || (cache[hash] = this)
}
Card.prototype.toString = function () {
  return '' + this.rank + this.suit
}
Card.cache = {};
```
        
Now the instances are canonicalized:

```javascript        
new Card(4, 'S') === new Card(4, 'S')
  //=> true
```
       
Wonderful! That being said, there is a caveat of canonicalizing instances of a class: JavaScript does not support [weak references](https://en.wikipedia.org/wiki/Weak_reference). If you wish to perform cache eviction for memory management purposes, you will have to implement your own reference management scheme. This may be non-trivial.

(Discuss on [/r/javascript](http://www.reddit.com/r/javascript/comments/12nice/quick_tip_canonicalization_in_javascript/). This note appears in slightly different form in the book [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto).)

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