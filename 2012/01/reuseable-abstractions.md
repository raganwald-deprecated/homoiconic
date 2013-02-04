# Reusable Abstractions in CoffeeScript (and JavaScript!)

[David Nolen][swan] made a really interesting observation:

[swan]: https://github.com/swannodette

> Wow. HashMaps in ClojureScript are functions! Now this may look like some special case provided by the language but that's not true. ClojureScript eats its own dog food - the language is defined on top of reusable abstractions.
>
> --[Comparing JavaScript, CoffeeScript & ClojureScript](http://dosync.posterous.com/comparing-javascript-coffeescript-clojurescri)

HashMaps in ClojureScript are functions. That's a really powerful idea. Why? Well, let's think about it. Right now, in CoffeeScript (and JavaScript), we have two things that behave in almost the same way but have different syntax:

```coffeescript
a = b[c] # b is an array or an object

e = f(g) # f is a function
```

There is a good thing about this: The two different syntaxes signal to the reader whether we are dealing with arrays or functions.

There is a bad thing about this: None of the tools we develop for functions work with the syntax for arrays.

For example, we can *compose* any two functions with Underscore's `compose` function:

```coffeescript
f = (x) -> x + 1
g = (x) -> x * 2

h = _.compose(f, g)
  # h(3) => f(g(3)) => 7
```

But we can't compose a function with an array reference:

```coffeescript
a = [2, 3, 5, 7, 11, 13, 17, 19]
b = (x) -> x * 2

c = _.compose(a, b)
  # c(3) => TypeError: Object 2,3,5,7,11,13,17,19 has no method 'apply'
```

And this is just the beginning. You can `.map` over an array, but you can't pass an array to `.map` as an argument. Same for standard objects (a/k/a HashMaps). We can go though our toolbox, and find hundreds of places where we have a special tool for functions that we can't use on arrays or objects. How annoying. I suppose we could "monkey-patch" `Array` to support `.apply` and `.call` to get around some of these errors, but the cure would be worse than the disease.

### Why CoffeeScript is an acceptable ClojureScript\*

There are tremendous benefits to a language making these two things equivalent "[all the way down][turtles]." But for many practical purposes, we can reap the benefits of having arrays and objects be first-class functions by wrapping arrays and objects in a function. Here's one such implementation:

```coffeescript
dfunc = (dictionary) ->
  (indices...) ->
    indices.reduce (a, i) ->
      a[i]
    , dictionary
```

`dfunc` takes an array or object you want to use as a "dictionary" and turns it into a function. So you can write:

```coffeescript
address = dfunc
  street: "1010 Foo Ave."
  apt: "11111111"
  city: "Bit City"
  zip: "00000000"
```

And now you have a function, just like one of ClojureScript's use cases ([try it!][try]). `dfunc` is also useful for encapsulating the choice of using an object or array lookup for implementing a  function. In [Cafe au Life][cafe], rules for [life-like games][ll] are represented as an array of arrays of neighbour counts. For example, the rules for Conway's Game of Life are represented as:

```coffeescript
[
  [0, 0, 0, 1, 0, 0, 0, 0, 0, 0] # A cell in state 0 changes to state 1 if it has exactly 3 neighbours
  [0, 0, 1, 1, 0, 0, 0, 0, 0, 0] # A cell in state 1 changes to state 0 unless it has 2 or 3 neighbours
]
```

And the rules for the life-like game [Maze][maze] are represented as:

```coffeescript
[
  [0, 0, 0, 1, 0, 0, 0, 0, 0] # A cell in state 0 changes to state 1 if it has exactly 3 neighbours
  [0, 1, 1, 1, 1, 1, 0, 0, 0] # A cell in state 1 changes to state 0 unless it has 1 to 5 neighbours
]
```

Naturally, the code for actually *processing* the rules could use `[]` to look things up. But why should it know how the rules are represented internally? Instead, we wrap the rule array with `dfunc`,making a `rule` function out of an array representation of the rules, and from that, make a `succ` or "successor" function that computes the success for for any cell in a matrix of cells:

```coffeescript
rule = dfunc [
  # ... rules for the current game ...
]

succ = (cells, row, col) ->
  current_state = cells[row][col]
  neighbour_count = cells[row-1][col-1] + cells[row-1][col] +
    cells[row-1][col+1] + cells[row][col-1] +
    cells[row][col+1] + cells[row+1][col-1] +
    cells[row+1][col] + cells[row+1][col+1]
  rule(current_state, neighbour_count)
```

Of course, `succ` could be written to depend on the array implementation of the rules. But turning it into a function factors it cleanly. We can change `rule` and `succ` independently, which is what we expect from *encapsulating* the array in a function.

[maze]: http://www.conwaylife.com/wiki/Maze
[turtles]: http://en.wikipedia.org/wiki/Turtles_all_the_way_down
[try]: http://coffeescript.org/#try:dfunc%20%3D%20(dictionary)%20-%3E%0A%20%20(indices...)%20-%3E%0A%20%20%20%20indices.reduce%20(a%2C%20i)%20-%3E%0A%20%20%20%20%20%20a%5Bi%5D%0A%20%20%20%20%2C%20dictionary%0A%0Aaddress%20%3D%20dfunc%0A%20%20street%3A%20%221010%20Foo%20Ave.%22%0A%20%20apt%3A%20%2211111111%22%0A%20%20city%3A%20%22Bit%20City%22%0A%20%20zip%3A%20%2200000000%22%0A%0Aalert%20address('city')%0A%0A

### And yet...

David Nolen also pointed out that encapsulating an array or object in a function isn't the same thing as having a language treat them as functions or even better, have them be made out of the same stuff. When you wrap an object inside of a function, you've hidden it, you lose access to everything about it except for the function's interface. Sometimes, that's exactly what you want. Much of software design is about modules exposing the right abstractions to their peers and clients.

And sometimes, that isn't what you want, and a language like ClojureScript effectively has it both ways: HashMaps are functions, so you can teat them as HashMaps and treat them as functions. And if you want to encapsulate them in a function so you can hide their HashMap nature, you can do that too. Brendan Eich suggests that [Function Proxies][proxies] are the right way forward for JavaScript (and CoffeeScript). This could get interesting once proxies are widely adopted.

[proxies]: http://wiki.ecmascript.org/doku.php?id=harmony:proxies
[lib]: http://code.google.com/p/es-lab/source/browse/trunk/src/proxies/DirectProxies.js

### Summary: Reusable Abstractions in CoffeeScript (and JavaScript)

Within a single function, it's good CoffeeScript and JavaScript to implement certain things with arrays and objects as dictionaries. Naturally! But when *exposing* properties as part of an API, functions are preferred, because functions are more easily reused abstractions and they preserve a read-only contract. JavaScript and CoffeeScript don't actually implement arrays and HashMaps as functions, but it's easy to wrap them in a function and obtain many of the benefits.

[cafe]: http://raganwald.github.com/cafeaulife/docs/cafeaulife.html
[ll]: http://www.conwaylife.com/wiki/Cellular_automaton#Well-known_Life-like_cellular_automata

([discuss](http://news.ycombinator.com/item?id=3528744))

p.s. About [Cafe au Life][cafe]. From time to time, I write a post and include overly simple examples. Such examples help to highlight the techniques being discussed by ruthlessly doing away with the accidental (for the purpose of the technique) complexity of real-world code. I've decided to take a different tack for a while. I plan to use Cafe au Life as my standard code base for CoffeeScript examples. My hope is that it plays out as follows: The examples will be a less obvious because readers have to figure out a little about implementing Life recursively, and there will be opportunities to derail discussions by pointing out poor choices I've made that have nothing to do with a particular post. But in return, discussions have the potential to be richer for being set in the context of trying to implement a beautiful algorithm, and any digressions will be fortuitous and productive.

p.p.s \* *I kid, I kid. Don't take the flame-bait!*

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