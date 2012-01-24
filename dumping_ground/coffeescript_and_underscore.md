# A taste of CoffeeScript, a dab of Underscore, a helping of Life

### Introduction

When introducing an idea, it is often wise to do so with as simple an example as possible. With programming tips, a simple example maximizes the signal-to-noise ration by focusing the code on the idea being introduced. I've used this style a fair bit, and readers tell me choosing simple examples makes my essays easy to understand. All this notwithstanding, I feel like a change. So, I present this post about [CoffeeScript][c] and the [Underscore][u] library. Instead of simple examples, I will be using examples from a project I cooked up just to provide some material.

[c]: http://jashkenas.github.com/coffee-script/
[u]: http://documentcloud.github.com/underscore/

The example project is called [Cafe au Life][cal]. It's an implementation of John Conway's [Game of Life][life] that uses one of my favourite algorithms of all time, Bill Gosper's brilliant (no, I am not in any danger of running out of adjectives) [HashLife][hl]. HashLife is a beautiful algorithm, one "[from the book][erdos]."

[cal]: http://github.com/raganwald/cafeaulife
[life]: http://en.wikipedia.org/wiki/Conway's_Game_of_Life
[hl]: http://en.wikipedia.org/wiki/Hashlife
[erdos]: http://en.wikipedia.org/wiki/Paul_Erdős

In this article, we're going to learn a very little of the CoffeeScript language. I assume that you're familiar with basic JavaScript, including but not limited to knowing what a function literal is, what a `.prototype` is, and of course a little about strings, numbers, arrays, and objects in JavaScript. We're also going to constantly allude to the Cafe au Life implementation of HashLife. This might be distracting, all I can do is try to make it *interesting*.

We're not going to start with the basics and then carefully introduce new ideas that rely on what we've already learned. We're going to jump in and learn as we go. This is a terrible way of learning if you only have one text to study, but if you have several different instructional essays and book to review, examples of the language constructs in the context of a non-trivial piece of code can provide some perspective on how the pieces relate to each other.

## HashLife

*Obviously* you are familiar with John Conway's Game of Life. Life is a cellular automata. Its universe is an infinite two-dimensional orthogonal grid of square cells, each of which is in one of two possible states, *alive* or *dead*. Every cell interacts with its eight neighbours, which are the cells that are horizontally, vertically, or diagonally adjacent. At each step in time, the following transitions occur:

* Any live cell with fewer than two live neighbours dies, as if caused by under-population.
* Any live cell with two or three live neighbours lives on to the next generation.
* Any live cell with more than three live neighbours dies, as if by overcrowding.
* Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

The initial pattern constitutes the seed of the system. The first generation is created by applying the above rules simultaneously to every cell in the seed—births and deaths occur simultaneously, and the discrete moment at which this happens is sometimes called a tick (in other words, each generation is a pure function of the preceding one). The rules continue to be applied repeatedly to create further generations.

From these simple rules arise many complex phenomena. Life was carefully designed to be a very simple set of rules that were conjectured to be Turing-equivalent. This was later proven to be the case theoretically, and still later people built [Turing Machines][tm], Minsky Register Machines, and even a Universal Turing Machine

[tm]: http://rendell-attic.org/gol/tm.htm

Let's express the Life rules in CoffeeScript. Here's the exact code from Cafe au Life:

```coffeescript
@result = _.memoize( 
  ->
    a = @.to_json()
    succ = (row, col) ->
      count = a[row-1][col-1] + a[row-1][col] + a[row-1][col+1] + a[row][col-1] + 
              a[row][col+1] + a[row+1][col-1] + a[row+1][col] + a[row+1][col+1]
      if count is 3 or (count is 2 and a[row][col] is 1) then Indivisible.Alive else Indivisible.Dead
    Square.find_or_create
      nw: succ(1,1)
      ne: succ(1,2)
      se: succ(2,2)
      sw: succ(2,1)
)
```

In this post, we're going to do a simple thing: Explain everything going on in that one piece of CoffeeScript code. Along the way, we'll learn a little about CoffeeScript, a little about the Underscore library, and a little about HashLife.

### Squares in HashLife

We'll return to the code in a moment. HashLife operates on square regions of the board, with the length of the side of each square being a natural power of two ( `2^0 -> 1`, `2^1 -> 2`, `2^2 -> 4`, `2^3 -> 8`...). One property of a square of size `2^n | n > 0` is that it can be divided into four quadrants of size `2^(n-1)`. For example, a square of size eight is composed of four quadrants of size four (in all these diagrams, the lines and crosses are part of the quadrants):

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

The squares of size four are in turn each composed of four quadrants of size two, which are each composed of four quadrants of size one, which cannot be subdivided.(For simplicity, a Cafe au Life board is represented as one such large square, although the HashLife algorithm can be used to handle any board shape by tiling it with squares.) HashLife exploits this symmetry by representing all squares of size `n > 0` as CoffeeScript class instances with four quadrants, conventionally labeled `nw`, `ne`, `se` and `sw`. The technical name for such a data structure is a [QuadTree][qt].

[qt]: http://en.wikipedia.org/wiki/Quadtree

### Representing squares

```coffeescript
class Square
```

In CoffeeScript, classes are declared using the `class` keyword. If you're familiar with dynamic languages like Ruby, you probably expect that classes aren't really *declared* in the sense that a class is declared in a static language like Java. You're right! The class is an object and you can assign it to a variable, return a class from a function, and so on. This particular class is the smallest possible kind of class, one that declares no methods and does not extend another class.

The smallest possible square is a cell. Defying the rational choice of "Cell," I have named the class that represents a single cell, `Indivisible`. It *extends* the class `Square`,. which means that ever instance of Indivisible IS-AN instance of Square, and every instance of Indivisible inherits all of the methods of Square (there aren't any at the moment, but still):

```coffeescript
class Indivisible extends Square
```

Speaking of methods:

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
```

If you've never seen CoffeeScript before, there are a ten(!) new ideas to grasp here:

1. Combining indentation with labels (like `constructor:` and `toValue:`) is how CoffeeScript declares object literals, a/k/a hashes.
2. The hash for a class defines the properties for the object's prototype.
3. When the prototype's properties are functions, you get object methods.
4. Functions are introduced with `->`. For example, `(x) -> x` is the I combinator, a function that returns its argument. This syntax nests: `(x) -> (y) -> x` is the K Combinator, a function that returns a constant function. The arguments to the function are to the left of the arrow, and the body follows.
5. JavaScript functions must explicitly use `return` to return a value. Like Ruby, CoffeeScript returns the value of the last expression evaluated. No explicit `return` is necessary.
6. If you don't have any arguments, you can omit them. Thus, `-> 'Hello World'` is a function that takes no arguments and always returns "Hello World."
7. In lieu of braces, CoffeeScript uses indentation (a/k/a "Significant Whitespace"). For non-trivial functions, we write the arguments and arrow on one line, and the body of the function on successive lines, indented once. However, you can write a function on one line or embedded in another expression if you like.
8. `@` in CoffeeScript is short-form for `this.`, So `[@hash]` is actually an array literal that is equivalent to `[ this.hash ]` in JavaScript.
9. CoffeeScript has [destructuring assignment][da] and destructuring parameter declarations. They can handle extracting values from hashes or arrays, variable numbers of parameters, and this useful case: `(@hash) ->`. This odd expression defines a function that takes a single argument and assigns it to `this.hash` instead of assigning it to a newly created parameter variable. Since the function has no body, it doesn't do anything else. It's equivalent to: `(hash) -> @hash = hash`.
10. The method `constructor` is special: It is called when you make a new instance of our class, such as `new Indivisible(1)`. This creates a new instance of indivisible, and calls its `constructor` method with an argument of `1`. As we saw above, this will be assigned to the `.hash` property by the method `(@hash) ->`.

[da]: http://coffeescript.org/#destructuring

Indivisible.Alive = _.tap new Indivisible(1), (alive) ->
  alive.is_empty = ->
    false
Indivisible.Dead = _.tap new Indivisible(0), (dead) ->
  dead.is_empty = ->
    true
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
  var count = a[row-1][col-1] + a[row-1][col] + a[row-1][col+1] + a[row][col-1] + 
              a[row][col+1] + a[row+1][col-1] + a[row+1][col] + a[row+1][col+1];
  return count === 3 || (count == 2 && a[row][col] === 1) ? Indivisible.Alive : Indivisible.Dead;
}
```

Let's see what we can learn comparing the snippets:

1. Functions are introduced with `->`. For example, `(x) -> x` is the I combinator, a function that returns its argument. This syntax nests: `(x) -> (y) -> x` is the K Combinator, a function that returns a constant function.
2. In lieu of braces, CoffeeScript uses indentation (a/k/a "Significant Whitespace"). For non-trivial functions, we write the arguments and arrow on one line, and the body of the function on successive lines, indented once.
3. A common problem with JavaScript programs is failing to declare variables with the `var` keyword. CoffeeScript does it for you, as we can see with `succ` and `count`.
4. JavaScript functions must explicitly use `return` to return a value. Like Ruby, CoffeeScript returns the value of the last expression evaluated. No explicit `return` is necessary.
5. CoffeeScript tries to make everything an expression that evaluates to something, including many things that are not expressions in JavaScript. We see here that `if` statements in JavaScript are `if` *expressions* in CoffeeScript. The closest equivalent in JavaScript is the much-reviled ternary operator.
6. Most of the time, you want to use `===` in JavaScript instead of `==`. CoffeeScript provides the `is` operator as a synonym for `===`, as well as `and` and `or` as synonyms for `&&` and `||`
7. You don't need semicolons when each line is a separate statement.

Put together, the `succ` function references a variable `a` bound outside of its scope. `a` is an array representing a portion of the Life universe. The array is encoded 
with a `1` for each cell that is alive and a `0` for each cell that is dead. `succ` is called with two parameters, `row` and `col`, representing the index of a cell. `succ` returns whether that cell is alive or dead in the next generation by returning an object that represents an alive cell or a dead cell.

---

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