# A taste of CoffeeScript, a dab of Underscore, a helping of Life

### Introduction

When introducing an idea, it is often wise to do so with as simple an example as possible. With programming tips, a simple example maximizes the signal-to-noise ration by focusing the code on the idea being introduced. I've used this style a fair bit, and readers tell me choosing simple examples makes my essays easy to understand.

All this notwithstanding, I feel like a change. So, I present this post about [CoffeeScript][c] and the [Underscore][u] library. Instead of simple examples, I will be using examples from a project I cooked up just to provide some material.

[c]: http://jashkenas.github.com/coffee-script/
[u]: http://documentcloud.github.com/underscore/

The example project is called [Cafe au Life][cal]. It's an implementation of John Conway's [Game of Life][life] that uses one of my favourite algorithms of all time, Bill Gosper's brilliant (no, I am not running out of adjectives) [HashLife][hl]. HashLife is a beautiful algoritm, one "[from the book][erdos]."

[cal]: http://github.com/raganwald/cafeaulife
[life]: http://en.wikipedia.org/wiki/Conway's_Game_of_Life
[HashLife][hl]
[erdos]: http://en.wikipedia.org/wiki/Paul_Erdős

In this article, we're going to learn a very little of the CoffeeScript language. I assume that you're familiar with basic JavaScript, including but not limited to knowing what a function literal is, what a `.prototype` is, and of course a little about strings, numbers, arrays, and objects in JavaScript. We're also going to constantly allude to the Cafe au Life implementation of HashLife. This might be distracting, all I can do is try to make it *interesting*.

## HashLife

*Obviously* you are familiar with John Conway's Game of Life. Technically speaking, it's a zero-player game, meaning no choices are involved, it's a cellular automata that is [Turing-equivalent][te]. The universe is an infinite two-dimensional orthogonal grid of square cells, each of which is in one of two possible states, *alive* or *dead*. Every cell interacts with its eight neighbours, which are the cells that are horizontally, vertically, or diagonally adjacent. At each step in time, the following transitions occur:

[te]: http://rendell-attic.org/gol/tm.htm

* Any live cell with fewer than two live neighbours dies, as if caused by under-population.
* Any live cell with two or three live neighbours lives on to the next generation.
* Any live cell with more than three live neighbours dies, as if by overcrowding.
* Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

The initial pattern constitutes the seed of the system. The first generation is created by applying the above rules simultaneously to every cell in the seed—births and deaths occur simultaneously, and the discrete moment at which this happens is sometimes called a tick (in other words, each generation is a pure function of the preceding one). The rules continue to be applied repeatedly to create further generations.

Let's express the Life rules in CoffeeScript. Here's the exact class from Cafe au Life:

```coffeescript
class SquareSz4 extends Divisible
  constructor: (params) ->
    super(params)
    @generations = 1
    @result = _.memoize( ->
      a = @.to_json()
      succ = (row, col) ->
        count = a[row-1][col-1] + a[row-1][col] + a[row-1][col+1] + a[row][col-1] + a[row][col+1] + a[row+1][col-1] + a[row+1][col] + a[row+1][col+1]
        if count is 3 or (count is 2 and a[row][col] is 1) then Indivisible.Alive else Indivisible.Dead
      Square.find_or_create
        nw: succ(1,1)
        ne: succ(1,2)
        se: succ(2,2)
        sw: succ(2,1)
    )
```

In this post, we're going to do a simple thing: Explain everything going on in that one piece of CoffeeScript code. Along the way, we'll learn a little about CoffeeScript, a little about the Underscore library, and a little about HashLife.

### Functions in CoffeeScript

Let's look at one snippet of CoffeeScript code:

```coffeescript
succ = (row, col) ->
  count = a[row-1][col-1] + a[row-1][col] + a[row-1][col+1] + a[row][col-1] + a[row][col+1] + a[row+1][col-1] + a[row+1][col] + a[row+1][col+1]
  if count is 3 or (count is 2 and a[row][col] is 1) then Indivisible.Alive else Indivisible.Dead
```

This is a function declaration. It's equivalent to the following JavaScript:

```javascript
var succ = function (row, col) {
  var count = a[row-1][col-1] + a[row-1][col] + a[row-1][col+1] + a[row][col-1] + a[row][col+1] + a[row+1][col-1] + a[row+1][col] + a[row+1][col+1]
  return count === 3 || (count == 2 && a[row][col] === 1) ? Indivisible.Alive : Indivisible.Dead
}
```

Let's see what we can learn comparing the snippets:

1. Functions are introduced with `->`. For example, `(x) -> x + 1` is a function that adds one to its argument.
2. In lieu of braces, CoffeeScript uses indentation (a/k/a "Significant Whitespace"). SO for non-trivial functions, we write the arguments and arrow on one line, and the body of the function on successive lines, indented once.
3. A common problem with JavaScript programs is failing to declare variables with the `var` keyword. CoffeeScript does it for you, as we can see with `succ` and `count`.
4. JavaScript functions must explicitly use `return` to return a value. Like Ruby, CoffeeScript returns the value of the last expression evaluated. No explicit `return` is necessary.
5. CoffeeScript tries to make everything an expression that evaluates to something, including many things that are not expressions in JavaScript. We see here that `if` statements in JavaScript are `if` *expressions* in CoffeeScript. The closest equivalent in JavaScript is the much-reviled ternary operator.

We'll return to the code in a moment. HashLife operates on square regions of the board, with the length of the side of each square being a natural power of two ( `2^0 -> 1`, `2^1 -> 2`, `2^2 -> 4`, `2^3 -> 8`...). Cafe au Life 

### Subdivisions

One property of a square of size `2^n | n > 0` is that it can be divided into four component squares of size `2^(n-1)`. For example, a square of size eight (`2^3`) is composed of four component squares of size four (`2^2`):

    nw        ne  
      +--++--+
      |..||..|
      |..||..|
      +--++--+
      +--++--+
      |..||..|
      |..||..|
      +--++--+
    sw        se

The squares of size four are in turn each composed of four component squares of size two (`2^1`), which are each composed of four component squares of size one (`2^0`), which cannot be subdivided.(For simplicity, a Cafe au Life board is represented as one such large square, although the HashLife algorithm can be used to handle any board shape by tiling it with squares.)

HashLife exploits this symmetry by representing all squares of size `n > 0` as CoffeeScript class instances with four quadrants, conventionally labeled `nw`, `ne`, `se` and `sw`.

(The technical name for such a data structure is a [QuadTree][qt].)

[qt]: http://en.wikipedia.org/wiki/Quadtree

### Representing squares

```coffeescript
class Square
  constructor: ->
    @toString = _.memoize( ->
      (_.map @to_json(), (row) ->
        (_.map row, (cell) ->
          if cell then '*' else ' '
        ).join('')
      ).join('\n')
    )
```

The key principle behind HashLife is taking advantage of redundancy. Therefore, two squares with the same alive and dead cells are always represented by the same, immutable square objects. There is no concept of an array or bitmap of cells except when performing import and export.

```coffeescript
class Indivisible extends Square
  constructor: (@hash) ->
  toValue: ->
    @hash
  to_json: ->
    [@hash]
  level: ->
    0
  empty_copy: ->
    Indivisible.Dead

Indivisible.Alive = _.tap new Indivisible(1), (alive) ->
  alive.is_empty = ->
    false
Indivisible.Dead = _.tap new Indivisible(0), (dead) ->
  dead.is_empty = ->
    true
```

All cells larger than size one are 'divisible':

```coffeescript
class Divisible extends Square
  constructor: (params) ->
    super()
    {@nw, @ne, @se, @sw} = params
  #...
```

HashLife exploits repetition and redundancy by making all squares idempotent and unique. In other words, if two squares contain the same sequence of cells, they are represented by the same instance of class `Square`. For example, there is exactly one representation of a cell of size two containing four empty cells, roughly:

```coffeescript
empty_two = new Divisible
  nw: Indivisible.Empty
  ne: Indivisible.Empty
  se: Indivisible.Empty
  sw: Indivisible.Empty
```

Likewise, there is one and only one square representing a cell of size four containing sixteen empty cells. Note well:

```coffeescript
new Divisible
  nw: empty_two
  ne: empty_two
  se: empty_two
  sw: empty_two
```

Furthermore, different squares can share the same quadrant. Here is a square of size four with a checker-board pattern:

```coffeescript
full_two = new Divisible
  nw: Indivisible.Alive
  ne: Indivisible.Alive
  se: Indivisible.Alive
  sw: Indivisible.Alive

new Divisible
  nw: empty_two
  ne: full_two
  se: empty_two
  sw: full_two
```

It uses the same square used to make up the empty square of size four. We see from these examples the fundamental way HashLife represents the state of the Life "universe:" Squares are subdivided into quadrants of one size smaller, and the same square can and is reused anywhere that same representation is needed.

### The Speed of Light

In Life, the "Speed of Light" or "*c*" is one cell vertically, horizontally, or diagonally in any direction. Meaning, that cause and effect cannot travel faster than *c*.

One consequence of this fundamental limit is that given a square of size `2^n | n > 1` at time `t`, HashLife has all the information it needs to calculate the alive and dead cells for the inner square of size `2^n - 2` at time `t+1`. For example, if HashLife has this square at time `t`:

    nw        ne  
      +--++--+
      |..||..|
      |..||..|
      +--++--+
      +--++--+
      |..||..|
      |..||..|
      +--++--+
    sw        se

HashLife can calculate this square at time `t+1`:

    nw        ne
    
       +----+
       |....|
       |....|
       |....|
       |....|
       +----+
       
    sw        se

And this square at time `t+2`:

    nw        ne
    
    
        +--+
        |..|
        |..|
        +--+
        
       
    sw        se

And this square at time `t+3`:

    nw        ne
    
    
        
         ++
         ++
        
        
       
    sw        se
    

This is because no matter what is in the cells surrounding our square, their effects cannot propagate faster than the speed of light, one row inward from the edge every step in time.

HashLife takes advantage of this by storing enough information to quickly look up the shrinking 'future' for every square of size `2^n | n > 1`. The information is called a square's *result*.

### Computing the result for squares

Let's revisit the obvious: Squares of size one and two do not have results, because at time `t+1`, cells outside of the square will affect every cell in the square.

The smallest square that computes a result is of size four (`2^2`). Its result is a square of size two (`2^1`) representing the state of those cells at time `t+1`:

    ....
    .++.
    .++.
    ....

The computation of the four inner `+` cells from their adjacent eight cells is straightforward and can be calculated from the basic 2-3 rules or looked up from a table with 65K entries. Thus, the result of a square of size four is a square of size two representing the state of the centre at time `t+1`. Since the result represents the state one 'moment' later, we say the result is one generation into the future. (We will see later that larger squares results more generations into the future.)