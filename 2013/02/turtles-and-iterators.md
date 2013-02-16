Tortoises, Teleporting Turtles, and Iterators
=============================================

(These code examples are in CoffeeScript. [Click here](./turtles-and-iterators.js.md#tortoises-teleporting-turtles-and-iterators) for code examples in JavaScript.)

A good long while ago (The First Age of Internet Startups), someone asked me one of those pet algorithm questions. It was, "Write an algorithm to detect a loop in a linked list, in constant space."

I'm not particularly surprised that I couldn't think up an answer in a few minutes at the time. And to the interviewer's credit, he didn't terminate the interview on the spot, he asked me to describe the kinds of things going through my head.

I think I told him that I was trying to figure out if I could adapt a hashing algorithm such as XORing everything together. This is the "trick answer" to a question about finding a missing integer from a list, so I was trying the old, "Transform this into [a problem you've already solved](http://www-users.cs.york.ac.uk/susan/joke/3.htm#boil)" meta-algorithm. We moved on from there, and he didn't reveal the "solution."

I went home and pondered the problem. I wanted to solve it. Eventually, I came up with something and tried it (In Java!) on my home PC. I sent him an email sharing my result, to demonstrate my ability to follow through. I then forgot about it for a while.

![Turtles all the way down](http://i.minus.com/i04jwKF6lLEDt.jpg)

Some time later, I was told that the correct solution was:

```coffeescript
class LinkedList
  constructor: (@content, @next = undefined) ->
  appendTo: (content) ->
    new LinkedList(content, this)
  tailNode: ->
    @next?.tailNode() or this
      
tortoiseAndHareLoopDetector = (list) ->
  tortoise = list
  hare = list.next
  while tortoise? and hare?
    return true if tortoise is hare
    tortoise = tortoise.next
    hare = hare.next?.next
  false
  
list = new LinkedList(5).appendTo(4).appendTo(3).appendTo(2).appendTo(1)

tortoiseAndHareLoopDetector(list)
  #=> false

list.tailNode().next = list.next
# five now points to two

tortoiseAndHareLoopDetector list
  #=> true
```

This algorithm is called "The Tortoise and the Hare," and was discovered by Robert Floyd in the 1960s. You have two node references, and one traverses the list at twice the speed of the other. No matter how large it is, you will eventually have the fast reference equal to the slow reference, and thus you'll detect the loop.

At the time, I couldn't think of any way to use hashing to solve the problem, so I gave up and tried to fit this into a powers-of-two algorithm. My first pass at it was clumsy, but it was roughly equivalent to this:

```coffeescript
teleportingTurtleLoopDetector = (list) ->
  speed = 1
  turtle = rabbit = list
  # tortoise is now the first element, hare the second (if there is one)
  while true
    for i in [0..speed] by 1
      rabbit = rabbit.next
      return false unless rabbit?
      return true if rabbit is turtle
    turtle = rabbit 
    speed *=2
  false
  
list = new LinkedList(5).appendTo(4).appendTo(3).appendTo(2).appendTo(1)

teleportingTurtleLoopDetector(list)
  #=> false

list.tailNode().next = list.next
# five now points to two

teleportingTurtleLoopDetector list
  #=> true
```

Today, thanks to [Reddit](http://www.reddit.com/r/programming/comments/18io6e/detecting_a_loop_in_singly_linked_list_tortoise/), I came across a discussion of this algorithm, [The Tale of the Teleporting Turtle](http://www.penzba.co.uk/Writings/TheTeleportingTurtle.html). I'd like to congratulate myself for thinking of a fast algorithm, but the simple truth is that I got lucky. It's not like I thought of both algorithms and compared them on the basis of time complexity. Nor, for that matter, did I think of it in the interview.

Reading about these algorithms today reminded me of a separation of concerns issue: Untangling how you traverse a data structure from what you do with its elements.

**a very simple problem**

Let's consider a remarkably simple problem: Finding the sum of the elements of an array. In iterative style, it looks like this:

```coffeescript
sum = (array) ->
  total = 0
  total += number for number in array
  total
```

What's the sum of a linked list of numbers? How about the sum of a tree of numbers (represented as an array of array of numbers)? Must we re-write the `sum` function for each data structure?

There are two roads ahead. One involves a generalized `reduce` or `fold` method for each data structure. The other involves writing an [Iterator](https://developer.mozilla.org/en-US/docs/JavaScript/New_in_JavaScript/1.7#Iterators) for each data structure and writing our `sum` to take an iterator as its argument. Let's use iterators, especially since we need two different iterators for the same data structure, so a single object method is inconvenient.

Since we don't have iterators baked into the underlying JavaScript engine yet, we'll write our iterators as functions:

```coffeescript
class LinkedList
  constructor: (@content, @next = undefined) ->
  appendTo: (content) ->
    new LinkedList(content, this)
  tailNode: ->
    @next?.tailNode() or this
    
ListIterator = (list) ->
  ->
    node = list?.content
    list = list?.next
    node
      
sum = (iter) ->
  total = 0
  number = iter()
  while number?
    total += number
    number = iter()
  total  
    
list = new LinkedList(5).appendTo(4).appendTo(3).appendTo(2).appendTo(1)

sum ListIterator list
  #=> 15
  
ArrayIterator = (array) ->
  index = 0;
  ->
    array[index++]

sum ArrayIterator [1..5]
  #=> 15
```

Summing an array that can contain nested arrays adds a degree of complexity. Writing a function that iterates recursively over a data structure is an interesting problem, one that is trivial in a language with [coroutines](https://en.wikipedia.org/wiki/Coroutine). Since we don't have Generators yet, and we don't want to try to turn our loop detection inside-out, we'll Greenspun our own coroutine by maintaining our own stack.

> This business of managing your own stack may seem weird to anyone born after 1970, but old fogeys fondly remember that after walking barefoot to and from University uphill in a blizzard both ways, the interview question brain teaser of the day was to write a "Towers of Hanoi" solver in a language like BASIC that didn't have reentrant subroutines.

```coffeescript
LeafIterator = (array) ->
  index = 0
  state = []
  myself = ->
    element = array[index++]
    if element instanceof Array
      state.push({array, index})
      array = element
      index = 0
      myself()
    else if element is undefined
      if state.length > 0
        {array, index} = state.pop()
        myself()
      else
        undefined
    else
      element
  myself
  
sum LeafIterator [1, [2, [3, 4]], [5]]
  #=> 15
```

We've successfully separated the issue of what one does with data from how one traverses over the elements.

**folding**

Just as pure functional programmers love to talk monads, newcomers to functional programming in multi-paradigm languages often drool over [folding] a/k/a mapping/injecting/reducing. We're just a level of abstraction away:

```coffeescript
fold = (iter, binaryFn, seed) ->
  acc = seed
  element = iter()
  while element?
    acc = binaryFn.call(element, acc, element)
    element = iter()
  acc

foldingSum = (iter) -> fold iter, ((x, y) -> x + y), 0

foldingSum LeafIterator [1, [2, [3, 4]], [5]]
```

Fold turns an iterator over a finite data structure into an accumulator. And once again, it works with any data structure. You don't need a different kind of fold for each kind of data structure you use.

[folding]: https://en.wikipedia.org/wiki/Fold_(higher-order_function)

**unfolding and laziness**

Iterators are functions. When they iterate over an array or linked list, they are traversing something that is already there. But they could, in principle, manufacture the data as they go. Let's consider the simplest example:

```coffeescript
NumberIterator = (base = 0) ->
  number = base
  ->
    number++
    
fromOne = NumberIterator(1)

fromOne()
  #=> 1
fromOne()
  #=> 2
fromOne()
  #=> 3
fromOne()
  #=> 4
fromOne()
  #=> 5
```

And here's another one:

```coffeescript
FibonacciIterator = ->
  previous = 0
  current = 1
  ->
    value = current
    [previous, current] = [current, current + previous]
    value
    
fib = FibonacciIterator()

fib()
  #=> 1
fib()
  #=> 1
fib()
  #=> 2
fib()
  #=> 3
fib()
  #=> 5
```

A function that starts with a seed and expands it into a data structure is called an *unfold*. It's the opposite of a fold. It's possible to write a generic unfold mechanism, but let's pass on to what we can do with unfolded iterators.

This business of going on forever has some drawbacks. Let's introduce an idea: A function that takes an Iterator and returns another iterator. We can start with `take`, an easy function that returns an iterator that only returns a fixed number of elements:

```coffeescript
take = (iter, numberToTake) ->
  count = 0
  ->
    if ++count <= numberToTake
      iter()
    else
      undefined

oneToFive = take NumberIterator(1), 5

oneToFive()
  #=> 1
oneToFive()
  #=> 2
oneToFive()
  #=> 3
oneToFive()
  #=> 4
oneToFive()
  #=> 5
oneToFive()
  #=> undefined
```

With `take`, we can do things like return the squares of the first five numbers:

```coffeescript
square take NumberIterator(1), 5
  #=> [ 1,
  #     4,
  #     9,
  #     16,
  #     25 ]
```

How about the squares of the odd numbers from the first five numbers?

```coffeescript
square odds take NumberIterator(1), 5
  #=> TypeError: object is not a function
```

Bzzzt! Our `odds` function returns an array, not an iterator.

```coffeescript
square  take odds(NumberIterator(1)), 5
  #=> RangeError: Maximum call stack size exceeded
```

You can't take the first five odd numbers at all, because `odds` tries to get the entire set of numbers and accumulate the odd ones in an array. This can be fixed. For unfolds and other infinite iterators, we need more functions that transform one iterator into another:

```coffeescript
iteratorMap = (iter, unaryFn) ->
  ->
    element = iter()
    if element?
      unaryFn.call(element, element)
    else
      undefined
      
squaresIterator = (iter) -> iteratorMap iter, (n) -> n * n

iteratorFilter = (iter, unaryPredicateFn) ->
  ->
    element = iter()
    while element?
      return element if unaryPredicateFn.call(element, element)
      element = iter()
    undefined

oddsFilter = (iter) -> iteratorFilter iter, odd
```

Now we can do things like take the sum of the first five odd squares of fibonacci numbers:

```coffeescript
foldingSum take (oddsFilter squaresIterator FibonacciIterator()), 5
  #=> 205
```

This solution composes the parts we already have, rather than writing a tricky bit of code with ifs and whiles and boundary conditions.

**summary**

Untangling the concerns of how to iterate over data from what to do with data leads us to thinking of iterators and working directly with iterators. For example, we can map and filter iterators rather than trying to write separate map and filter functions or methods for each type of data structure. This leads to the possibility of working with lazy or infinite iterators.

*This material will be added to [JavaScript Allongé][ja], [CoffeeScript Ristretto][cr], and/or [allong.es](http://allong.es) after feedback and review*.

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)][ja]![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)][cr]![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé][ja], [CoffeeScript Ristretto][ja], and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code. 

[ja]: http://leanpub.com/javascript-allonge "JavaScript Allongé"
[cr]: http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto"

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

