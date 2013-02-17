Refactoring to jQuery Combinators
=================================

## Introduction

jQuery is a general-purpose library that provides a number of browser-specific functions. Its core
functionality manipulates selections of DOM entities in a fluent style. There are four fundamental
operations on a selection:

1. Filter a selection, analogous to `Array.prototype.filter`. Special case:
   Create a selection by filtering the entire document.
2. Traverse from a selection to another selection, e.g. from a selection of DOM elements
   to their children.
3. Perform some operation on the selection for side effects, e.g. making the selected
   elements visible.
4. Map from a selection to some other value or values, e.g from a selection to an integer
   representing the size of the selection.

jQuery provides a large number of methods that fit into one of these four categories, and
when you use its built-in methods, you can write idiomatic, "fluent" jQuery code. But when you
incorporate your own logic, you have to break out of the fluent style.

### Life, the Universe, and jQuery

Let's say we are writing an implementation of [Life][life] (because we are). And let's
say that we are representing the Life Universe as a table, with one `td` for each cell in the
universe (because we did). And live cells have the class `alive`.

If we wanted to select all the cells to the right of a live cell, we could do this in jQuery:
`$('td.alive + td')`. And if we wanted to filter a selection of cells to those that were to the
right of a live cell, we could write:

		$selection
			.filter('td.alive + td')

So far, so good. Yay jQuery! But how do we name this relationship? How do we DRY up our code?
And how do we do it in a way that naturally fits in with jQuery's style?

### jQuery Combinators

[jQuery Combinators] to the rescue. jQuery Combinators provides a method called `.into` that turns
any function into a traverse, and `.select` that turns any function into a filter. So we can write:

    function hasAliveOnLeft ($selection) {
      return $selection
        .filter('td.alive + td')
    }

And now, whenever we want to use this, we can write:

		$selection
			.select(hasAliveOnLeft)
			
Just as if `hasAliveOnLeft` was a built-in jQuery filter. There's also `.tap` for turning your own
functions into methods that perform an operation and return the selection, just like jQuery's 
built-in operations.

[jQuery Combinators]: http://raganwald.github.com/JQuery-Combinators

## Life in jQuery

[Here] is an implementation of [Conway's Game of Life][life] written with jQuery Combinators (and here's the [annotated source code][code]). 

[life]: https://en.wikipedia.org/wiki/Conway's_Game_of_Life
[Here]: http://raganwald.com/JQuery-Combinators/life/index.html
[code]: http://raganwald.com/JQuery-Combinators/life/life.html

![Life with jQuery Combinators](http://i.minus.com/ibt7pqptCtmRHb.png)

The main loop that advances the universe a single generation is called `stepForwardOneGeneration`. It is written as a single fluent jQuery expression. Omitting comments, it looks like this:

```javascript
function stepForwardOneGeneration () {
	
	$(cellSelector)
	
		.tap(resetNeighbourCount)
		.tap(resetLeftRightCount)
		
		.select(hasOnLeftOrRight(aliveSelector))
			.tap(incrementNeighbourCount(1))
			.tap(incrementLeftRightCount(1))
			.end()
		.select(hasOnLeftAndRight(aliveSelector))
			.tap(incrementNeighbourCount(2))
			.tap(incrementLeftRightCount(2))
			.end()
			
		.select(hasAboveOrBelow(aliveSelector))
			.tap(incrementNeighbourCount(1))
			.end()
		.select(hasAboveAndBelow(aliveSelector))
			.tap(incrementNeighbourCount(2))
			.end()
			
		.select(hasAboveOrBelow(oneLeftRightNeighbourSelector))
			.tap(incrementNeighbourCount(1))
			.end()
		.select(hasAboveOrBelow(twoLeftRightNeighboursSelector))
			.tap(incrementNeighbourCount(2))
			.end()
		.select(hasAboveAndBelow(oneLeftRightNeighbourSelector))
			.tap(incrementNeighbourCount(2))
			.end()
	  .select(hasAboveAndBelow(twoLeftRightNeighboursSelector))
			.tap(incrementNeighbourCount(4))
			.end()
			
		.tap(resetLeftRightCount)
		
		.select(willBeBorn)
			.tap(animateBirths)
			.end()
		.select(willDie)
			.tap(animateDeaths)
			.end()
			
		.tap(resetNeighbourCount)
}
```

Repeatable, predictable. Start with a selection of all cells, do some stuff to it (via `.tap`), and then perform the same action several times: Create a sub-selection with `.select`, do some stuff with `.tap`, and use `.end` to "pop" back to the original selection.

Here's what the almost identical code looks like without jQuery Combinators:

```javascript
function stepForwardOneGeneration () {
	
	var allCells = $(cellSelector)
	
	resetNeighbourCount(allCells);
	resetLeftRightCount(allCells);
	
	var selectionWithAliveOnLeftOrRight = hasOnLeftOrRight(aliveSelector)(allCells);
	incrementNeighbourCount(1)(selectionWithAliveOnLeftOrRight);
	incrementLeftRightCount(1)(selectionWithAliveOnLeftOrRight);
	
	var selectionWithAliveOnLeftAndRight = hasOnLeftAndRight(aliveSelector)(allCells);
	incrementNeighbourCount(2)(selectionWithAliveOnLeftAndRight);
	incrementLeftRightCount(2)(selectionWithAliveOnLeftAndRight);
	
	incrementNeighbourCount(1)(
		hasAboveOrBelow(aliveSelector)(allCells)
	);
	incrementNeighbourCount(2)(
		hasAboveAndBelow(aliveSelector)(allCells)
	);
	
	incrementNeighbourCount(1)(
		hasAboveOrBelow(oneLeftRightNeighbourSelector)(allCells)
	);
	incrementNeighbourCount(2)(
		hasAboveOrBelow(twoLeftRightNeighboursSelector)(allCells)
	);
	incrementNeighbourCount(2)(
		hasAboveAndBelow(oneLeftRightNeighbourSelector)(allCells)
	);
	incrementNeighbourCount(4)(
		hasAboveAndBelow(twoLeftRightNeighboursSelector)(allCells)
	);
	
	resetLeftRightCount(allCells);
	
	animateBirths(
		willBeBorn(allCells)
	);
	animateDeaths(
		willDie(allCells)
	);
	
	resetNeighbourCount(allCells)
	
}
```

What's the difference? Why prefer the first?

## Factorization

The first version flows fluently as jQuery flows fluently. This is more than just "pretty" visually. It's easier to insert some new code in the first version than the second, or move code around. Each piece acts on a selection without creating temporary variables or nesting selection calls inside of procedures that execute for side effects.

Consider this "standard" code:

```javascript
animateDeaths(
	willDie(allCells)
);
```

`willDie` is a function that takes a selection a filters for those live cells that will die in the next generation, and `animateDeaths` is a procedure that animates their disappearance. How would you adjust this code to add something new, like adjusting a population count?

```javascript
var $toDie = willDie(allCells);

animateDeaths($toDie);
reducePopulationCount($toDie);
```
Compare to the jQuery Combinators version:

```javascript
.select(willDie)
	.tap(animateDeaths)
	.end()
```

Which becomes:

```javascript
.select(willDie)
	.tap(animateDeaths)
	.tap(reducePopulationCount)
	.end()
```
This is the strength of jQuery when working with its own built-in "fluent" methods, and jQuery Combinators gives your own domain-specific functions the same strength.

Here's a more extreme example, an excerpt from the "standard" code that takes a selection of cells and filters for those that have a cell with a particular class below them:

```javascript
$result = $result.add(
	cellsInColumnByIndex(columnIndex)(
		cellsInColumnByIndex(columnIndex)(
			$(cellSelector+clazz)
		)
			.parent()
				.prev('tr')
					.children()
	)
		.filter($selection)
)
```

The flow of filtering isn't particularly obvious. Compare this to the Combinators solution:

```javascript
$result = $result.add(
	$(cellSelector+clazz)
		.into(cellsInColumnByIndex(columnIndex))
			.parent()
				.prev('tr')
					.children()
						.into(cellsInColumnByIndex(columnIndex))
							.filter($selection)
)
```

The order of filtering is obvious by inspection, and again is much easier to reuse or modify. The combinators code factors more easily than the "standard" code.

## Summary

jQuery Combinators allows us to take our own domain-specific traverses, filters, and side-effectful functions and use them "fluently" on selections just like jQuery's built-in methods. The result is code that:

1. Is easier to read and understand, and;
2. Is easier to modify or refactor.

(Discuss on [/r/javascript](http://www.reddit.com/r/javascript/comments/138snc/refactoring_to_jquery_combinators/). This essay appears in slightly different form in the book [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto).)

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

