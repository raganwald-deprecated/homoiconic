# Garbage Collection in CoffeeScript (and JavaScript)

> "There are only two hard things in Computer Science: Cache invalidation and naming things."—Tim Bray, quoting Phil Karlton

## HashLife

[Cafe au Life][recursiveuniverse] is an implementation of John Conway's [Game of Life][life] cellular automata written in [CoffeeScript][cs]. Cafe au Life runs on [Node.js][node].

The "Life Universe" is an infinite two-dimensional matrix of cells. Cells are indivisible and are in either of two states, commonly called "alive" and "dead." Time is represented as discrete quanta called either "ticks" or "generations." With each generation, a rule is applied to decide the state the cell will assume. The rules are decided simultaneously, and there are only two considerations: The current state of the cell, and the states of the cells in its [Moore Neighbourhood][moore], the eight cells adjacent horizontally, vertically, or diagonally.

Cafe au Life implements Conway's Game of Life, as well as other "[life-like][ll]" games in the same family.

[ll]: http://www.conwaylife.com/wiki/Cellular_automaton#Well-known_Life-like_cellular_automata
[moore]: http://en.wikipedia.org/wiki/Moore_neighborhood
[source]: https://github.com/raganwald/cafeaulife/blob/master/lib
[life]: http://en.wikipedia.org/wiki/Conway's_Game_of_Life
[cs]: http://jashkenas.github.com/coffee-script/
[node]: http://nodejs.org

![Period 24 Glider Gun](http://recursiveuniverse.github.com/docs/Trueperiod24gun.png)

*(A period 24 Glider Gun. Gliders of different periods are useful for transmitting signals in complex Life machines.)*

Cafe au Life is based on Bill Gosper's [HashLife][hl] algorithm. HashLife is usually implemented in C and optimized to run very long simulations with very large 'boards' stinking fast. The HashLife algorithm is, in a word, **a beautiful design**, one that is "in the book." To read its description ignites the desire to explore it on a computer.

Broadly speaking, HashLife has two major components. The first is a high level algorithm that is implementation independent. This algorithm exploits repetition and redundancy, aggressively 'caching' previously computed results for regions of the board. The second component is the cache itself, which is normally implemented cleverly in C to exploit memory and CPU efficiency in looking up precomputed results.

[hl]: http://en.wikipedia.org/wiki/Hashlife

[recursiveuniverse]: http://recursiveuniver.se/

Without repeating what the annotated source code explains in detail, HashLife leverages the fact that information has a speed limit: The state of any cell in Life can only affect its neighbours in one generation, their neighbours in two generations, and so on. Applying this in reverse, if you want to compute the state of a cell in `n` generations you do not need to consider any cells except those `n` distance away or closer.

HashLife exploits this by dividing the universe into squares of dimension `2^n`. For any such square where `n>1`, there is a center square of size `2^(n-1)`. The future of the centre can always be computed out to `2^(n-2)` generations, and it will always be the same no matter where the square appears.

For example, if we have a 16 by 16 square (`2^4`), there is a centre square of size 8 by 8 (`2^3`) that can be computed out to 4 generations in the future (`2^2`). Once we have done that computation, we can re-use it wherever we see the exact same 16 by 16 arrangement of alive and dead cells.

HashLife employs this idea elegantly to represent the life universe as a quadtree, stashing squares and their futures in a large cache (the "hash" in "HashLife"). The resulting performance is startling: Patterns that evolve with a great deal of repetition can be calculated to prodigious sizes and unimaginable distances into the future.

One maximally favourable example is the Gilder Gun. Glider guns generate a stream of identical gliders marching off into infinity. Cafe au Life needs only a few seconds to calculate the future of a glider gun 143.4 quadrillion generations into the future, one for each second from the formation of the Earth until now. It's a [beautiful algorithm][beauty].

[beauty]: http://raganwald.posterous.com/a-beautiful-algorithm

## Cafe au Life's Limitation

Cafe au Life is fine for highly repetitious patterns. Or put in another way, Cafe au Life is fine with patterns that have futures with low entropy. The size of the cache is driven by the information encoded in the future of the pattern. A large but regular pattern might need less space to compute than a small pattern that evolves in chaotic ways.

That matters, because part of Life's delight is how unpredictable it is. There are large patterns that evolve in highly regular ways, and small petterns that roil and bubble like soup on the boil. One such pattern is a methuselah called "[rabbits][rabbits]:"

[![Rabbits](http://www.conwaylife.com/w/images/c/c9/Rabbits.png)][rabbits]

Rabbits has just nine cells, but it [evolves][rabbitsvideo] for 17,331 generations before stabilizing with 1,744 cells. The result consists of 136 blinkers (including 14 traffic lights), 109 blocks, 65 beehives (including three honey farms), 40 gliders, 18 boats, 18 loaves, seven ships, four tubs, three ponds and two toads.

[rabbits]: http://www.argentum.freeserve.co.uk/lex_r.htm#rabbits
[rabbitsvideo]: http://www.youtube.com/watch?v=jHeRYjxmQQA

The first cut at Cafe au Life did not limit the cache in any way. As a pattern evolved, squares would be added to the cache but never removed, so the cache simply grew. This was fine up until I tried to run rabbits. The cache ballooned to nearly 800,000 squares, then the entire instance of node.js ran out of memory.

This is one of the delights of Life: One pattern with thirty-six cells can grow to a population with 23.9 quadrillion active cells, while another a fourth of its size chokes the cache with fewer than 2,000 cells. The connection of initial state to complexity of the result over time is one of the deep properties of computation and in some ways the *central* problem in Computer Science.

Clearly, Cafe au Life needed to "grow up" and implement a garbage collection strategy. In short, it needed to start removing squares from the cache to keep things at a manageable size when patterns had complex evolutions.

### Garbage collection

Cafe au Life is not meant to be a sophisticated implementation of HashLife. Practical implementations are written in tightly coded C and handle massive patterns that emulate universal turing machines, print numbers, and perform other impressive tricks. So garbage collection would by necessity be written as simply as possible.

The relationships between squares are highly regular. HashLife represents the universe as a quadtree, so each square has exactly four child squares. As computations are made, each square lazily computes a number of "result squares" for future times ranging from 0 generations in the future (its current centre) out to `2^(n-2)` as explained above.

Leaving aside for the moment the question of temporary results generated as the algorithm does its work, the cache itself has a very regular reference structure, and thus a simple reference counting scheme works. A square is the parent of each of its four direct children and it is also the parent of each of the result squares it calculates. Every square in the cache has zero or more parents in the cache. A square with no parents in the cache is eligible to be removed. When it is removed, the reference count for each child is decremented, and if they become zero, the child is removed as well.

Garbage collection could be done in parallel with computation, but it is simpler to check the cache to see if it is getting full (>700,000 squares) and if so, perform garbage collection until there is enough headroom to continue computation (arbitrarily set at <350,000 squares). The numbers can be tuned if necessary, collecting too much garbage will hamper performance by forcing the algorithm to recalculate futures that had been thrown away. And of course, collecting too little garbage will cause the garbage collection algorithm to be invoked repeatedly, imposing overhead.

Performance could be improved by tuning the start collection and stop collection thresholds. Another potential s improvement would be to create a strategy for prioritizing squares to be garbage collected, such as by Least Recently Used.

### Recursion: See "recursion"

The reference counting strategy outlined is missing a key consideration: In the midst of calculating the future of a pattern, there are intermediate results that must not be garbage collected from the cache. Although Node's JavaScript engine will not garbage collect the objects representing the squares from memory if they are in variables, the entire algorithm depends on the assumption that every object representing a square has been "canonicalized" and that there is only ever one active object for each unique square of any size.

The cache enforces this, and if a variable were to contain an object representing a square while that same square was removed from the cache, another part of the code could easily wind up creating a copy of the square, breaking the "contract" that there is only ever one representation of each square. If a square is to be removed from the cache, it must not be in use anywhere in the computation. Thus, if it is needed again, a new copy will be created and cached and all references will be to the new copy, preserving the requirement that there is only ever one representation at any one time.

The garbage collection algorithm must have a way to know which squares are currently being used while Cafe au Life recursively computes the future of a pattern if it is to collect garbage at any point in the middle of a computation. The squares in use must have their reference counts incremented while they are in use and then decremented as soon as they are no longer needed. Decrementing the reference counts as soon as possible is essential to good garbage collection.

### Summary

Cafe au Life was to be upgraded to add garbage collection via reference counting. References would be maintained for children of squares in the cache, and squares used for intermediate calculations were to have references for the time they were needed.

## Implementing Garbage Collection in Cafe au Life

Cafe au Life is written in pseudo-literate style. The code is written specifically to be understood by the first-time reader. This is sometimes a mistake in production code, where optimizing for someone's first day on the job at the expense of their second through nth day may be a grave mistake.

The overall style is of a succession of "reveals." The basic classes are revealed with very little extraneous code, then a a series of modules are introduced that "monkey-patch" or "provide advice to point cuts" or even "introduce the computed, non-local [COMEFROM][comefrom]" to add functionality as new concepts are articulated in the accompanying annotations.

[comefrom]: https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md

Naturally, all of the code that implements garbage collection was placed in its own module, [gc.coffee][gcc].

[gcc]: http://recursiveuniverse.github.com/docs/gc.html

In order to add something as pervasive as garbage collection, the first step was to determine where the existing code would need to be "advised." In some cases, functionality could be added to existing methods without any changes. In others, existing methods would need to be refactored to create opportunities to advise them.

### Extending existing functionality

For example, we set a recursively computable square's reference count to zero by adding after advice to its initialize method using [YouAreDaChef][y]:

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

### Refactoring memoization

Some of the original code needed to be refactored to permit the gc module to provide method advice. The first thing that needed to be refactored was the code that [memoized][memo] the calculation of results.

[memo]: https://en.wikipedia.org/wiki/Memoization

As explained above, every square has four child quadrant squares. It also calculates results for times from zero to `2^(n-2)` generations in the future. If those were calculated every time they were needed, HashLife's canonicalization of squares would simply be a way to save the space required to represent very large Life universes. However, HashLife also saves computation by memoizing those calculations. Once a square calculates its result for a particular time in the future, it saves the result and reuses it.

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

The new version of `result` uses the `@memoize` class method to memoize its return value, and now the gc module can hook into `set_memo` to manage the child's reference count (Note that in CoffeeScript, declaring `@memoize:` declares a method on the class, not each instance):

```coffeescript
  YouAreDaChef(Square.RecursivelyComputable)
    .before 'set_memo', (index) ->
      if (existing = @get_memo(index))
        existing.decrementReference()
    .after 'set_memo', (index, square) ->
      square.incrementReference()
```

(Note that the original code still runs all of its test cases perfectly: if you remove the garbage collection module from the project and don't run any of the gc-specific specs, Cafe au Life retains 100% of its original functionality. That's what refactoring means: Changing the way a program is organized or "factored," without adding to or removing its functionality.)

**This is a work-in-progress! Please do not post to Hacker News, &c.**

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one e-book.
* [What I've Learned From Failure](http://leanpub.com/shippingsoftware), my very best essays about getting software from ideas to shipping products, collected into one e-book.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://reginald.braythwayt.com) | [@raganwald](http://twitter.com/raganwald)