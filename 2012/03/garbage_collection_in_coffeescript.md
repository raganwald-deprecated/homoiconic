# Implementing Garbage Collection in CoffeeScript/JavaScript with Aspect-Oriented Programming

> "There are only two hard things in Computer Science: Cache invalidation and naming things."—Tim Bray, quoting Phil Karlton

This essay walks through my experience adding garbage collection to [Cafe au Life][recursiveuniverse], an implementation of John Conway's [Game of Life][life] that achieves stunning performance by aggressively caching both data and computations.

Cafe au Life is written in a pseudo-literate style that leans heavily on [aspect-oriented software development][aosd] to separate concerns and especially to produce a series of successive "reveals" of functionality. This essay walks through some of the refactoring required to make it possible to implement garbage collection through class extension and method advice, paying particular attention to memoization and abstracting functional composition.

[aosd]: https://en.wikipedia.org/wiki/Aspect-oriented_software_development

![Period 24 Glider Gun](http://recursiveuniverse.github.com/docs/Trueperiod24gun.png)

*(A period 24 Glider Gun. Gliders of different periods are useful for transmitting signals in complex Life machines.)*

## Cafe au Life

[Cafe au Life][recursiveuniverse] is written in the [CoffeeScript][cs] dialect of JavaScript. Cafe au Life runs on [Node.js][node]. Cafe au Life implements Conway's Game of Life, as well as other "[life-like][ll]" games in the same family.

[ll]: http://www.conwaylife.com/wiki/Cellular_automaton#Well-known_Life-like_cellular_automata
[moore]: http://en.wikipedia.org/wiki/Moore_neighborhood
[source]: https://github.com/raganwald/cafeaulife/blob/master/lib
[life]: http://en.wikipedia.org/wiki/Conway's_Game_of_Life
[cs]: http://jashkenas.github.com/coffee-script/
[node]: http://nodejs.org

Cafe au Life's engine is based on Bill Gosper's [HashLife][hl] algorithm. The HashLife algorithm is, in a word, a [beautiful algorithm][beauty], one that is "in the book." To read its description ignites the desire to explore it on a computer.

Broadly speaking, HashLife has two major components. The first is a high level algorithm that is implementation independent. This algorithm exploits repetition and redundancy, aggressively 'caching' previously computed results for regions of the board. The second component is the cache itself, which is normally implemented cleverly in C to exploit memory and CPU efficiency in looking up precomputed results. Implementations like [Golly][golly] are optimized to run very long simulations with huge patterns.

[golly]: http://golly.sourceforge.net/

[hl]: http://en.wikipedia.org/wiki/Hashlife

[recursiveuniverse]: http://recursiveuniver.se/

### HashLife

Without repeating what the annotated source code explains in detail, HashLife leverages the fact that information has a speed limit: The state of any cell in Life can only affect its neighbours in one generation, their neighbours in two generations, and so on. Applying this in reverse, if you want to compute the state of a cell in `n` generations you do not need to consider any cells except those `n` distance away or closer.

HashLife exploits this by dividing the universe into squares of dimension `2^n`. For any such square where `n>1`, there is a center square of size `2^(n-1)`. The future of the centre can always be computed out to `2^(n-2)` generations, and it will always be the same no matter where the square appears.

For example, if we have a 16 by 16 square (`2^4`), there is a centre square of size 8 by 8 (`2^3`) that can be computed out to 4 generations in the future (`2^2`). Once we have done that computation, we can re-use it wherever we see the exact same 16 by 16 arrangement of alive and dead cells.

HashLife employs this idea elegantly to represent the life universe as a quadtree, stashing squares and their futures in a large cache (the "hash" in "HashLife"). The resulting performance is startling: Patterns that evolve with a great deal of repetition can be calculated to prodigious sizes and unimaginable distances into the future.

One maximally favourable example is the Gilder Gun. Glider guns generate a stream of identical gliders marching off into infinity. Cafe au Life needs only a few seconds to calculate the future of a glider gun 143.4 quadrillion generations into the future, one for each second from the formation of the Earth until now.

[beauty]: http://raganwald.posterous.com/a-beautiful-algorithm

## Cafe au Life's Limitation

Cafe au Life is fine for highly repetitious patterns. Or put in another way, Cafe au Life is fine with patterns that have futures with low entropy. The size of the cache is driven by the information encoded in the future of the pattern. A large but regular pattern might need less space to compute than a small pattern that evolves in chaotic ways.

That matters, because part of Life's delight is how unpredictable it is. There are large patterns that evolve in highly regular ways, and small patterns that roil and bubble like soup on the boil. One such pattern is a methuselah called "[rabbits][rabbits]:"

[![Rabbits](http://www.conwaylife.com/w/images/c/c9/Rabbits.png)][rabbits]

Rabbits has just nine cells, but it [evolves][rabbitsvideo] for 17,331 generations before stabilizing with 1,744 cells. The result consists of 136 blinkers (including 14 traffic lights), 109 blocks, 65 beehives (including three honey farms), 40 gliders, 18 boats, 18 loaves, seven ships, four tubs, three ponds and two toads.

[rabbits]: http://www.argentum.freeserve.co.uk/lex_r.htm#rabbits
[rabbitsvideo]: http://www.youtube.com/watch?v=jHeRYjxmQQA

The first cut at Cafe au Life did not limit the cache in any way. As a pattern evolved, squares would be added to the cache but never removed, so the cache simply grew. This was fine up until I tried to run rabbits. The cache ballooned to nearly 800,000 squares, then the entire instance of node.js ran out of memory.

Thus, one pattern with thirty-six cells can grow to a population with 23.9 quadrillion active cells, while another a fourth of its size chokes the cache with fewer than 2,000 cells. The connection of initial state to complexity of the result over time is one of the deep properties of computation and in some ways the *central* problem in Computer Science.

Clearly, Cafe au Life needed to "grow up" and implement a garbage collection strategy. In short, it needed to start removing squares from the cache to keep things at a manageable size when patterns had complex evolutions.

### Garbage collection

Cafe au Life is not meant to be a sophisticated implementation of HashLife. Practical implementations are written in tightly coded C and handle massive patterns that emulate universal turing machines, print numbers, and perform other impressive tricks. So garbage collection would by necessity be written as simply as possible.

The relationships between squares are highly regular. HashLife represents the universe as a quadtree, so each square has exactly four child squares. As computations are made, each square lazily computes a number of "result squares" for future times ranging from 0 generations in the future (its current centre) out to `2^(n-2)` as explained above.

Leaving aside for the moment the question of temporary results generated as the algorithm does its work, the cache itself has a very regular reference structure, and thus a simple reference counting scheme works. A square is the parent of each of its four direct children and it is also the parent of each of the result squares it calculates. Every square in the cache has zero or more parents in the cache. A square with no parents in the cache is eligible to be removed. When it is removed, the reference count for each child is decremented, and if they become zero, the child is removed as well.

Garbage collection could be done in parallel with computation, but it is simpler to check the cache to see if it is getting full (>700,000 squares) and if so, perform garbage collection until there is enough headroom to continue computation (arbitrarily set at <350,000 squares). The numbers can be tuned if necessary, collecting too much garbage will hamper performance by forcing the algorithm to recalculate futures that had been thrown away. And of course, collecting too little garbage will cause the garbage collection algorithm to be invoked repeatedly, imposing overhead.

### Recursion: See "Recursion"

The reference counting strategy outlined is missing a key consideration: In the midst of calculating the future of a pattern, there are intermediate results that must not be garbage collected from the cache. Although Node's JavaScript engine will not garbage collect the objects representing the squares from memory if they are in variables, the entire algorithm depends on the assumption that every object representing a square has been "canonicalized" and that there is only ever one active object for each unique square of any size.

The cache enforces this, and if a variable were to contain an object representing a square while that same square was removed from the cache, another part of the code could easily wind up creating a copy of the square, breaking the "contract" that there is only ever one representation of each square. If a square is to be removed from the cache, it must not be in use anywhere in the computation. Thus, if it is needed again, a new copy will be created and cached and all references will be to the new copy, preserving the requirement that there is only ever one representation at any one time.

The garbage collection algorithm must have a way to know which squares are currently being used while Cafe au Life recursively computes the future of a pattern if it is to collect garbage at any point in the middle of a computation. The squares in use must have their reference counts incremented while they are in use and then decremented as soon as they are no longer needed. Decrementing the reference counts as soon as possible is essential to good garbage collection.

### Summary

Cafe au Life was to be upgraded to add garbage collection via reference counting. References would be maintained for children of squares in the cache, and squares used for intermediate calculations were to have references for the time they were needed.

## Implementing Garbage Collection in Cafe au Life

Cafe au Life is written in pseudo-literate style. The code is written specifically to be understood by the first-time reader. This is sometimes a mistake in production code, where optimizing for someone's first day on the job at the expense of their second through nth day may be a grave mistake. However, Cafe au Life is not a production application, it is a test bed for some of my own experiments. Since I often write about my experiences with code, I wanted Cafe au Life to be approachable despite the non-trivial nature of its algorithm.

Cafe au Life's overall style is of a succession of "reveals." The basic classes are revealed with very little extraneous code, then a a series of modules are introduced that "monkey-patch" or "provide advice to point cuts" or even "introduce the computed, non-local [COMEFROM][comefrom]" to add functionality as new concepts are articulated in the accompanying annotations.

[comefrom]: https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md

Naturally, all of the code that implements garbage collection was placed in its own module, [gc.html.coffee][gc.html], that modifies all of the code that came before it. Thus, it is possible to understand and even run Cafe au Life from the code without garbage collection, and then incorporate garbage collection when you're ready to consider how it works.

[gc.html]: http://recursiveuniverse.github.com/docs/gc.html

### Scattering and Tangling

Aspect-oriented software developers talk about "scattering" and "tangling."

Scattering is when a responsibility (such as garbage collection) is spread across across the code base. For example, the `Square.Smallest` and `Square.Seed` classes are defined in the Rule Module, while `Square.RecursivelyComputable` is defined in the Future Module. If reference counting was added in the traditional OO style where each class knows all about its own methods, the responsibility for garbage collection would be "scattered" across multiple modules.

Tangling is when code that should be small and have a single clear responsibility is entangled with other responsibilities. For example, memoizing a result should increment the result square's count. If that code was added to the memoization method, we would be "entangling" the responsibility for memoization with the responsibility for reference counting.

By refactoring our methods to permit advice and class extension, we eliminate the tangling and the scattering.

### Extending Existing Functionality

In order to add something as pervasive as garbage collection, the first step was to determine where the existing code would need to be "advised." In some cases, functionality could be added to existing methods without any changes. In others, existing methods would need to be refactored to create opportunities to advise them. For example, we set a recursively computable square's reference count to zero by adding after advice to its initialize method using the [YouAreDaChef][y] library:

[y]: https://github.com/raganwald/YouAreDaChef

```coffeescript
  YouAreDaChef(Square.RecursivelyComputable)
    .after 'initialize', ->
      @references = 0
```

This leaves the original class definition bare of any discussion of reference counts. We likewise add new reference count methods that garbage collection needs within the code describing garbage collection. For example:

```coffeescript
  _.extend Cell.prototype,
    has_references: ->
      true
    has_no_references: ->
      false
    has_one_reference: ->
      false
    has_many_references: ->
      true
    incrementReference: ->
      this
    decrementReference: ->
      this
    children: -> {}
    remove: ->
    removeRecursively: ->
```

And:

```coffeescript
  _.extend Square.RecursivelyComputable.prototype,
    has_references: ->
      @references > 0
    has_no_references: ->
      @references is 0
    has_one_reference: ->
      @references is 1
    has_many_references: ->
      @references > 1
    incrementReference: ->
      throw "incrementReference!? #{@references}" unless @references >= 0
      @references += 1
      this
    decrementReference: () ->
      throw "decrementReference!?" unless @references > 0
      @references -= 1
      this
```

There are a number of other ways we extend or modify the existing code without changes or with trivial refactoring to accommodate placing the functionality in the garbage collection module.

### Refactoring Memoization

Some of the original code (found in [future.coffee][future]) needed to be refactored to permit the garbage collection module to provide method advice. The first thing that needed to be refactored was the code that [memoized][memo] the calculation of results.

[memo]: https://en.wikipedia.org/wiki/Memoization
[future]: http://recursiveuniverse.github.com/docs/future.html

As explained above, every square in Cafe au Life has four child quadrant squares. Every non-trivial square also calculates its own results for times from zero to `2^(n-2)` generations in the future. If those were calculated every time they were needed, HashLife's canonicalization of squares would simply be a way to save the space required to represent very large Life universes. However, HashLife also saves computation by memoizing those calculations. Once a square calculates its result for a particular time in the future, it saves the result and reuses it.

The original implementation memoized results using [underscore.js's][u] `_.memoize` function. For example:

[u]: http://documentcloud.github.com/underscore/

```coffeescript
  initialize: ->
    super()
    @result = _.memoize( -> Square.canonicalize
      nw: @subsquares_via_subresults.nw.result()
      ne: @subsquares_via_subresults.ne.result()
      se: @subsquares_via_subresults.se.result()
      sw: @subsquares_via_subresults.sw.result()
    )
```

(For those not familiar with  `_.memoize`, it takes a function and returns a memoized version of the function. The memoized function caches its results so that subsequent calls with the same parameters are turned into cache lookups. Using `_.memoize` to create a method is done within the object's `initialize` method because if we memoize the class' prototype of the method, all of the different objects will share the same cache, while we want each object to have its own cache.)

Unfortunately, while `_.memoize` is elegant, it blocks us from implementing garbage collection. As you recall, we wish to count the references from a parent to a child, including from a square to its result. (If we don't count references to results, a square could return a memoized result that has been garbage collected from the cache.) We need to memoize results in a way that exposes them to inspection, so the memoization was refactored into a general-purpose feature with methods that could be "advised:"

```coffeescript
    initialize: ->
      super()
      @memoized = {}

    @memoize: (name, method_body) ->
      (args...) ->
        index = name + _.map( args, (arg) -> "_#{arg}" ).join('')
        @get_memo(index) or @set_memo(index, method_body.call(this, args...))

    get_memo: (index) ->
      @memoized[index]

    set_memo: (index, square) ->
      @memoized[index] = square

    # ...


    result:
      @memoize 'result', ->
        Square.canonicalize
          nw: @subsquares_via_subresults().nw.result()
          ne: @subsquares_via_subresults().ne.result()
          se: @subsquares_via_subresults().se.result()
          sw: @subsquares_via_subresults().sw.result()
```

The new version of `result` uses the `@memoize` class method to memoize its return value, and now the garbage collection module can hook into `set_memo` to manage the child's reference count (Note that in CoffeeScript, declaring `@memoize:` declares a method on the class, not each instance):

```coffeescript
  YouAreDaChef(Square.RecursivelyComputable)
    .before 'set_memo', (index) ->
      if (existing = @get_memo(index))
        existing.decrementReference()
    .after 'set_memo', (index, square) ->
      square.incrementReference()
```

(The original code still runs all of its test cases perfectly: if you remove the garbage collection module from the project and don't run any of the garbage collection-specific specs, Cafe au Life retains 100% of its original functionality. That's what refactoring means: Changing the way a program is organized or "factored," without adding to or removing its functionality.)

### Refactoring Functional Composition

The `result` method quoted above was refactored to use a new mechanism for memoizing return values. It was also refactored to allow another module to modify the way functions are chained together, or as is more commonly termed, [composed][composition].

As noted above, the `.result` method looked like this:

```coffeescript
  result:
    @memoize 'result', ->
      Square.canonicalize
        nw: @subsquares_via_subresults().nw.result()
        ne: @subsquares_via_subresults().ne.result()
        se: @subsquares_via_subresults().se.result()
        sw: @subsquares_via_subresults().sw.result()
```

Now that we understand the memoization, what does the underlying code do? Well, it canonicalizes a square from four quadrants, each of which is constructed in parallel by calling another method that seems to return four squares and taking the results of those squares.

This is awkward to explain. A better way to put it is... `@subsquares_via_subresults()` `->` `.result()` `->` `Square.canonicalize`. Information is flowing through a pipeline of functions, they're just disguised as methods, and the information is conveyed in a map, something like `{ nw: ..., ne: ..., se: ..., sw: ... }`.

We will not examine `@subsquares_via_subresults` in detail here, but if you feel like digging through [the code as it was before refactoring][br], you can see that all of the calculations required to get a result follow the pattern of taking a hash and transforming it step by step until it is finally given to `Square.canonicalize` to producet the final result.

[br]: https://github.com/raganwald/cafeaulife/blob/8de77f8d62e763c22dafd6222b1ef8a9b8881b13/lib/future.coffee
[composition]: https://en.wikipedia.org/wiki/Function_composition_(computer_science)

And? Well, one of our "problems" with garbage collection is needing to increment the reference count when we need a square as part of a computation, then decrement its count when we're done. It's no good to increment the count at the very beginning of the computation and hold it until we return, because when performing a very complex calculation (like the future of a square 143 quadrillion generations in the future), we will end up holding values for the entire computation as it recursively iterates through space and time.

By transforming the computation of `.result` into a chain of functions operating on a map, we create smaller "scopes" for the temporary values we need. Although we're doing it with garbage collection in mind, in a larger sense we're refactoring the method such that we expose the structure of the computation and make it first-class. Here's how we do it.

First, we need a helper function that can map a simple function over a hash of values:

 ```coffeescript
     @map_fn: (fn) ->
      (parameter_hash) ->
        _.reduce parameter_hash, (acc, value, key) ->
          acc[key] = fn(value)
          acc
        , {}
 ``` 
 
 Then we define a series of functions that we'll apply to our maps:
 
 ```coffeescript
     @take_the_canonicalized_values: @map_fn(
      (quadrants) ->
        Square.canonicalize(quadrants)
    )

    @take_the_results: @map_fn(
      (square) ->
        square.result()
    )

    @take_the_results_at_time: (t) ->
      @map_fn(
        (square) ->
          square.result_at_time(t)
      )
 ```
 
We'll also need some translations that transform a map with one structure to a map with another. If we were Java programmers we'd [break out the XSLT][mousetrap], but we'll keep them simple:

[mousetrap]: http://raganwald.com/2008/02/mouse-trap.html?showComment=1203629040000

  
```coffeescript
    @square_to_intermediate_map: (square) ->
      nw: square.nw
      ne: square.ne
      se: square.se
      sw: square.sw
      nn:
        nw: square.nw.ne
        ne: square.ne.nw
        se: square.ne.sw
        sw: square.nw.se
      ee:
        nw: square.ne.sw
        ne: square.ne.se
        se: square.se.ne
        sw: square.se.nw
      ss:
        nw: square.sw.ne
        ne: square.se.nw
        se: square.se.sw
        sw: square.sw.se
      ww:
        nw: square.nw.sw
        ne: square.nw.se
        se: square.sw.ne
        sw: square.sw.nw
      cc:
        nw: square.nw.se
        ne: square.ne.sw
        se: square.se.nw
        sw: square.sw.ne
```

And:

```coffeescript
    @intermediate_to_subsquares_map: (intermediate_square) ->
      nw:
        nw: intermediate_square.nw
        ne: intermediate_square.nn
        se: intermediate_square.cc
        sw: intermediate_square.ww
      ne:
        nw: intermediate_square.nn
        ne: intermediate_square.ne
        se: intermediate_square.ee
        sw: intermediate_square.cc
      se:
        nw: intermediate_square.cc
        ne: intermediate_square.ee
        se: intermediate_square.se
        sw: intermediate_square.ss
      sw:
        nw: intermediate_square.ww
        ne: intermediate_square.cc
        se: intermediate_square.ss
        sw: intermediate_square.sw
```

Combining our transformations with mapped functions, we can construct methods like `.result` with the `sequence` function:

```coffeescript
    @sequence: (fns...) ->
      _.compose(fns.reverse()...)
```

This makes our methods very readable:

```coffeescript
    result:
      @memoize 'result', ->
        Square.canonicalize(
          Square.RecursivelyComputable.sequence(
            Square.RecursivelyComputable.square_to_intermediate_map
            Square.RecursivelyComputable.take_the_canonicalized_values
            Square.RecursivelyComputable.take_the_results
            Square.RecursivelyComputable.intermediate_to_subsquares_map
            Square.RecursivelyComputable.take_the_canonicalized_values
            Square.RecursivelyComputable.take_the_results
          )(this)
        )
```

If you reconstruct the code at the time of this refactoring, it runs all the tests just fine. The only difference is that we've replaced JavaScript's native method for composing an expression with our own `sequence` function composing a series of functions set up as a pipeline of maps.

### And now... The Garbage Collection Itself

Once we've refactored our methods to use `sequence`, we can change the way they behave by decorating `sequence` with code that increments and decrements reference counts. Here's the actual code from [gc.coffee][gc.html]:

 ```coffeescript 
    each_leaf = (h, fn) ->
      _.each h, (value) ->
        if value instanceof Square
          fn(value)
        else if value.nw instanceof Square
          fn(value.nw)
          fn(value.ne)
          fn(value.se)
          fn(value.sw)

    sequence: (fns...) ->
      _.compose(
        _(fns).map( (fn) ->
            (parameter_hash) ->
              each_leaf(parameter_hash, (sq) -> sq.incrementReference())
              Square.cache.resize(700000, 350000)
              _.tap fn(parameter_hash), ->
                each_leaf(parameter_hash, (sq) -> sq.decrementReference())
          ).reverse()...
      )
```

The revised version of `sequence` takes the input map, increments the reference for each leaf of the tree, and  resizes the cache such that it does not exceed 700,000 squares. It then calls the function, decrementing the leaves of the tree when it's finished.

We'll repeat for the nth time that this version of `sequence` is "monkey-patched" by the garbage collection module, the code in the future module is not altered other than the original refactoring to sequence functions.

### Does it blend?

Having implemented garbage collection using aspect-oriented programming, we need to test it. Can we now compute the future of the rabbits pattern?

```
raganwald@Reginald-Braithwaites-iMac[cafeaulife (master)⚡] coffee
coffee> require('./lib/menagerie').rabbits.future_at_time(17331).population
GC: 700000->350000
GC: 700000->350000
1744
coffee> 
```

Success of a sort! Cafe au Life collects garbage twice (and takes its sweet time) but correctly reports the future of the rabbits pattern after 17,331 generations.

## In Conclusion

Garbage collection is a hard problem. It is usually pervasive, as it touches many different parts of a computation engine. In Cafe au Life, adding garbage collection required substantial changes to both memoization and the computation of results.

However, these changes need not involve scattering and tangling: Through refactoring, class extension, and method advice, we concentrate all of the responsibility for garbage collection in the Garbage Collection Module.

### Further Work

This implementation focuses on making garbage collection work, but not on making it work *well*. With small but chaotic patterns like "rabbits," the distinction may not matter much. However, large and chaotic patterns may repeatedly cycle the cache, degrading HashLife to linear performance.

Performance could be improved by tuning the start collection and stop collection thresholds. Another potential improvement would be to create a strategy for prioritizing squares to be garbage collected, such as by Least Recently Used. Improving the strategy for when garbage is collected and which squares are garbage collected is the "hard thing in computer science" mentioned at the top of the essay, but nevertheless must be done to make Cafe au Life useful for experimentation with non-trivial patterns.

### Source Code

* 	The [Rules Module][rules.html] provides a method for setting up the [rules][rules] of the Life universe.
* 	The [Future Module][future.html] provides methods for computing the future of a pattern, taking into account its ability to grow beyond the size of its container square.
* 	The [Cache Module][cache.html] implements a very naive hash-table for canonical representations of squares. HashLife uses extensive [canonicalization][canon] to optimize the storage of very large patterns with repetitive components.
* 	The [Garbage Collection Module][gc.html] implements a simple reference-counting garbage collector for the cache.
* 	The [API Module][api.html] provides methods for grabbing JSON or strings of patterns and resizing them to fit expectations.
* 	The [Menagerie Module][menagerie] provides a few well-know life objects predefined for you to play with. It is entirely optional.

[rules.html]: http://recursiveuniverse.github.com/docs/rules.html
[rules]: http://www.conwaylife.com/wiki/Cellular_automaton#Well-known_Life-like_cellular_automata
[future.html]: http://recursiveuniverse.github.com/docs/future.html
[cache.html]: http://recursiveuniverse.github.com/docs/cache.html
[canon]: https://en.wikipedia.org/wiki/Canonicalization
[api.html]: http://recursiveuniverse.github.com/docs/api.html
[menagerie]: http://recursiveuniverse.github.com/docs/menagerie.html

### Bonus

from [Wikipedia][monad]:

> In functional programming, a monad is a programming structure that represents computations. Monads are a kind of abstract data type constructor that encapsulate program logic instead of data in the domain model. A defined monad allows the programmer to chain actions together and build different pipelines that process data in various steps, in which each action is decorated with additional processing rules provided by the monad... Programs written in functional style can make use of monads to structure procedures that include sequenced operations.

[monad]: https://en.wikipedia.org/wiki/Monads_in_functional_programming

Discuss on [programming.reddit.com][proggit] and [hacker news][hn].

[proggit]: http://www.reddit.com/r/programming/comments/quesk/implementing_garbage_collection_in_csjs_using/
[hn]: http://news.ycombinator.com/item?id=3697992

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