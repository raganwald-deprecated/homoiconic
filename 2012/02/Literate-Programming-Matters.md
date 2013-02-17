# Literate Programming Matters

> No amount of pontification in English will ever make a piece of code clearer than the code itself--David Nolen, [Illiterate Programming](http://dosync.posterous.com/illiterate-programming)

There is an obvious truth this statement points towards: It's a terrible idea to try to fix bad code with good documentation. There's another obvious truth: Good documentation can't improve the code, it can only *explain* it. If you remove the documentation, the code is still the code.

David's essay is excellent advice, and it pushes my personal "like" buttons by pointing out that Smalltalk's elegance makes it easier to write good software, not harder. Those languages that pile on features designed to make the resulting code "easier to maintain" really do produce the opposite. 

However, as it happens I spend a lot of time writing words for humans to read as well as a lot of time writing programs for people to read. And I have some opinions about the relationship between the two. As a bonus, I have been doing some [literate programming][lp] lately, and my experience contradicts what David is saying about literate programming. Mind you, my experience *completely validates* what he is saying about the power of elegant languages for writing readable code.

What this suggests to me is that while David presents the concepts of literate programming and elegant programming using the expressions "literate" and "illiterate," we must be careful not to view them as a dichotomy: They're *orthogonal* issues.

[lp]: http://en.wikipedia.org/wiki/Literate_programming

## From Life

Of late, I've been working on a completely useless project: [Conway's Game of Life][life]. My implementation is called [Cafe au Life][cafe], and the interesting thing here is that it uses Bill Gosper's [HashLife][hl] algorithm to compute the future of a life pattern. This matters greatly to the question of writing readable code.

> An easy question: How well does the design document the actual game of Monopoly? If someone were to read the source code, do you think they could learn how to play the actual game?--[My favourite interview question](http://raganwald.com/2006/06/my-favourite-interview-question.html)

Life is an extraordinarily simple zero-player game. Quoting Wikipedia verbatim:

The universe of the Game of Life is an infinite two-dimensional orthogonal grid of square *cells*, each of which is in one of two possible states, *alive* or *dead*. Every cell interacts with its eight *neighbours*, which are the cells that are horizontally, vertically, or diagonally adjacent. At each step in time, the following transitions occur:

1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
2. Any live cell with two or three live neighbours lives on to the next generation.
3. Any live cell with more than three live neighbours dies, as if by overcrowding.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

The initial pattern constitutes the *seed* of the system. The first generation is created by applying the above rules simultaneously to every cell in the seed—births and deaths occur simultaneously, and the discrete moment at which this happens is sometimes called a *tick* (in other words, each generation is a pure function of the preceding one). The rules continue to be applied repeatedly to create further generations.

So far so good, and quote frankly, given a language that isn't brain-dead at birth, you ought to be able to write an implementation such that another programmer could come along, read your code sans comments, and figure out "Oh, this is the Game of Life!" Or if the weren't familiar with Life, they could read your code and write out the rules above.

Given the goal of writing code that explains the rules of life, the solution is obvious: You translate the ideas from the rules directly into the entities in the code. You need cells, you need a two-dimensional orthogonal grid, you need neighbours, you need transitions, ticks or generations, and so on.

If there is a nearly 1:1 correspondence between the entities and relationships of the rules and the entities and relationships of the code, you are going to have a very good shot at writing some highly readable code.

[hl]: http://en.wikipedia.org/wiki/Hashlife
[life]: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
[cafe]: http://raganwald.github.com/cafeaulife/docs/cafeaulife.html

## To HashLife

Now we come to [HashLife][hl]. HashLife is an algorithm that throws out the two-dimensional orthogonal grid and replaces it with a quadtree of squares. HashLife canonicalizes the squares to save space and memoizes the computation of the future to save time.

You can read all about it in my [literate implementation][cafe].

The problem this presents is that HashLife is one layer of indirection away from Life. I accept that you could write some code such that if someone is familiar with the HashLife algorithm, they look at your code and say: "Aha! Quad trees, Sqaure.canonicalize, _.memoize, this must be Gosper's HashLife." But if they have never seen HashLife, how will they recognize Life from it?

> At the University of Bigginton-on-Stoke, the top Comp. Sci. graduates are often uncertain of whether to commercialize research in a startup, or put up for postgraduate studies in Lisp and Haskell. The school has developed a two-part test to help them find their calling. In the first part of the test, the student is led into a lab and told to boil water. Finding a tap, a beaker, and a bunsen burner, he fills the beaker, places it on the burner, lights the burner, and when the water boils he is led off to the second test.

> In the second test, they again are told to boil water, but this time the beaker is already full of water and sitting on the burner. Two out of three graduates light the burner and are led off to found startups and become wealthy pragmatists who will fund the school's endowments for decades to come. But one out of three will study the apparatus, then disassemble it, *reducing it to a problem he has already solved*. He is given gowns and robes and welcomed as a valuable addition to the department, where he will write papers until the end of his days.

I think this is a common problem. Mathematicians do this as a matter of course, they recognize that a certain problem is really isomorphic to some other problem, and that by transforming it, they can take advantage of something they know about solving the other problem.

But in doing so, we move our code one level of indirection away from its original domain. Which makes it harder to grasp what it is trying to accomplish. This is important when considering whether a programming language can make itself clear.

I conjecture it can't, or at least not without a major paradigm shift. I think a programming language can make an implementation of Gosper's HashLife clear about Gosper's HashLife, but not about Life. I think this is a very general problem. We often build something simple that just works, and then we transform it. We might optimize it, which adds "accidental complexity" to the code. We might do a major transformation like switching from a 2D grid to a quadtree. Elegant languages will make that less painful, but I don't know that they can solve the problem of relating the optimized code to the original requirements.
 
There are other transformations that present the same difficulties. When we add requirements to some code, it becomes less clear. Error handling, database transactions, canonicalization/normalization, support for orthogonal features, all these things take code one step further away from its original, core purpose. And that makes it harder to read.

[hl]: http://en.wikipedia.org/wiki/Hashlife
[cafe]: http://raganwald.github.com/cafeaulife/docs/cafeaulife.html

## To Literate HashLife

 Every single explanation of the HashLife algorithm I've seen incorporates diagrams. For example:
 
        # We can also derive four overlapping squares, these representing `n`, `e`, `s`, and `w`:
        #
        #          nn
        #       ..+--+..        ..+--+..
        #       ..|..|..        ..|..|..
        #       +-|..|-+        +--++--+
        #       |.+--+.|      w |..||..| e
        #       |.+--+.|      w |..||..| e
        #       +-|..|-+        +--++--+
        #       ..|..|..        ..|..|..
        #       ..+--+..        ..+--+..
        #          ss

        # Deriving these from our four component squares is straightforward, and when we take their results,
        # we fill in four of the five missing blanks for our intermediate square:
        #
        #     nw        ne
        #
        #        ..nn..
        #        ..nn..
        #        ww..ee
        #        ww..ee
        #        ..ss..
        #        ..ss..
        #
        #     sw        se

But then the code that follows is made up of symbols:

        nn: Square
          .canonicalize
            nw: square.nw.ne
            ne: square.ne.nw
            se: square.ne.sw
            sw: square.nw.se
          .result()
        ee: Square
          .canonicalize
            nw: square.ne.sw
            ne: square.ne.se
            se: square.se.ne
            sw: square.se.nw
          .result()
        ss: Square
          .canonicalize
            nw: square.sw.ne
            ne: square.se.nw
            se: square.se.sw
            sw: square.sw.se
          .result()
        ww: Square
          .canonicalize
            nw: square.nw.sw
            ne: square.nw.se
            se: square.sw.ne
            sw: square.sw.nw
          .result()
          
They say the same thing, and yet the representation convenient for the human is different from the representation convenient for programming. I toyed with writing a DSL that would allow me to pass ASCII art diagrams to a function and have it "interpret" them. With that, one could dispense with the comments and simply write code that was easy to understand in visual form.

In the end, I decided this would probably end badly, with a leaky abstraction that really only worked well for the cases I anticipated in advance and would not stand up to refactoring or change over time. But I'm left with the thought that some ideas need different representations for humans to grok than for humans to work with.

It isn't as simple as writing for humans versus writing for the machine: Writing for humans to understand is different than writing for humans to manipulate once they understand.

### Envelope number two: "Reorganize"

I said above:

> There's another obvious truth: Good documentation can't improve the code, it can only *explain* it. If you remove the documentation, the code is still the code.

I think I was wrong about that. When writing Cafe au Life, I started out writing Cafe au Life in `cafeaulife.coffee` and explaining the approach in `README.md`. I then used [Docco][docco] to create annotated source code. A funny thing happened when I did that: I found that it was very hard to simply "annotate" the source code in such a way that it became easier to read.

The act of melding the README and the source code forced me to reorganize the source code. This makes sense. Even when working solely in English, you can communicate the same information in several different ways. An encyclopaedia of natural history will be optimized for users who know what they're looking for and just want details information. An introduction to natural history will be optimized for linear consumption by users who are learning about the subject.

Most naïve OO code resembles an encyclopedia. It is optimized for looking things up by people who know what they are trying to look up. The whole concept is that if I want to know what a square does, I look up the `Square` class and bang, all of its methods are there. There might be some deep flaws ([1][1], [2][2]) in considering this the *only* way to write OO programs, but let's grant that for that purpose, it is workable.

However, I decided that my audience were interested in learning how HashLife works. So I wasn't writing an encyclopaedia, I was writing an introduction. When writing an introduction, you need to explain something with a series of successive reveals.

### Successive reveals

So, it does not work to present heavyweight `Cell` and `Square` classes, instead you start with the simplest possible things:

    # The smallest unit of Life is the Cell:
    class Cell
      constructor: (@value) ->

        # A simple point-cut that allows us to apply advice to constructors.
        @initialize.apply(this, arguments)

      # By default, do nothing
      initialize: ->
      to_json: ->
        [@value]
      toValue: ->
        @value

    class Square

      # Squares are constructed from four quadrant squares or cells and store a hash used
      # to locate the square in the cache
      constructor: ({@nw, @ne, @se, @sw}) ->

        # A simple point-cut that allows us to apply advice to constructors.
        @initialize.apply(this, arguments)

      # By default, do nothing
      initialize: ->
      
There is no explanation of how a cache is used to canonicalize squares. And then as you go deeper into the explanation, you reveal more functionality. In a different part of the annotated source, the cache is explained and the code uses [YouAreDaChef][YouAreDaChef] to mix additional functionality into the initialization of a square:

    # Initialize a square's hash property to the cache's hash function
    YouAreDaChef(Square)
      .after 'initialize', ->
        @hash = Square.cache.hash(this)

Likewise there is another part of the code that actually calculates the "future" of a square region of the Life universe. Central to this is the idea of a square's *level*. Once again, that code injects the appropriate functionality into our classes:

      # 2x2 squares are level 1. 4x4 squares are level 2. In other words, the level of a square is the level of
      # its component quadrants plus one. This sets up a recursion which amounts to counting the squares in a
      # path from our subject square to its component cells.
      YouAreDaChef(Square)
        .after 'initialize', ->
          @level = @nw.level + 1

      # Cells are level zero, which terminates the recursion.
      _.extend Cell.prototype,
        level:
          0

### COMEFROM

There are many more examples, but they all boils down to the same thing: Writing in a literate style forced me to refactor the code by responsibility along a different basis. It is no longer easy to look at the `Square` class and see everything you need to know about squares.

On the other hand, it is now easy  to look at the `future.coffee` file and see everything you need to know about computing the future of a Life pattern, or look at `rules.coffee` and see everything you need to know about implementing [life-like][ll] games.

If I were to remove all the comments, the code *would* have been changed by my attempting to write it in literate style. This is partly because tools like Docco don't actually change the code. The original concept behind literate programming was that the tool could rearrange the code such that the annotated code could be organized for explanation while the source code would remain organized as an encyclopaedia.

Since I can't do that with Docco, I had to use a dash of Underscore and a smidgen of [YouAreDaChef][YouAreDaChef] to refactor the code. Some may not care for the idea of a computed, non-local [COMEFROM][COMEFROM]. Others may think it's [unorthodox, but effective][williams].

Now, this doesn't need any comments to do, the code could simply slice and dice the functionality and recombine it along different lines of responsibility. However, CoffeeScript lacks alternate structures for this. If you see the words `class Square`, you know that the next bunch of stuff described the code for a square (so far). There is no support for protocols cutting across classes. You have to cook up your own tools, whether they involve aspect-oriented programming, mixing in functionality, or what-have-you.

## Literate Programming Does Matter

As I see it, there are two related reasons why Literate Programming matters, and I think these reasons are orthogonal to the question of whether the underlying programming language is elegant.

First, some code is one or more steps removed from the underlying algorithm or idea. Whether it has been transformed for the purpose of optimization, or whether it has multiple, orthogonal requirements, I feel the elegance of the language can only help the developer explain what the code is doing, not connect the dots to the underlying idea or requirements that are one or more steps removed from the implementation.

Second, writing for exposition provokes a different organization than writing for reference. This is related to the first issue, in that when writing for exposition you may want to deal with orthogonal protocols or responsibilities in a particular order.

I don't know whether we need a literate programming tool that transforms the source directly, or whether we need different tools for recombining source code into runtime objects and classes. But I do feel we need to keep working on tools and language features for for reorganizing program entities, and I also feel that we need to continue to think about whether we can dispense with comments in words for cases where the code's behaviour is one or more steps removed from the simple requirements or where the format best suited for explaining it to a human (like a diagram) is not the format best suited for writing a program (like symbols).

([discuss][hn])

[YouAreDaChef]: https://github.com/raganwald/YouAreDaChef
[1]: https://github.com/raganwald/homoiconic/blob/master/2010/12/oop.md "OOP practiced backwards is "POO""
[2]: http://raganwald.com/2007/10/too-much-of-good-thing-not-all.html "Too much of a good thing: not all functions should be object methods"
[docco]: http://jashkenas.github.com/docco/
[ll]: http://www.conwaylife.com/wiki/Cellular_automaton#Well-known_Life-like_cellular_automata
[williams]: https://github.com/raganwald/homoiconic/blob/master/2011/11/COMEFROM.md
[COMEFROM]: http://en.wikipedia.org/wiki/COMEFROM'

[hn]: http://news.ycombinator.com/item?id=3576837

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