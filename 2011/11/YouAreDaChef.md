Separating Concerns in CoffeeScript using Aspect-Oriented Programming
---

Modern object-oriented software design [favours composition over inheritance][coi] and celebrates code that is [DRY][dry]. The idea is to separate each object's concerns and responsibility into separate units of code, each of which have a single responsibility. When two different types of objects share the same functionality, they do not repeat their implementation, instead they share their implementation.

[coi]: https://en.wikipedia.org/wiki/Composition_over_inheritance
[dry]: http://en.wikipedia.org/wiki/Don't_repeat_yourself

When composing functionality at the method level of granularity, techniques such as mixins and delegation are effective design tools. But at a finer level of granularity, we sometimes wish to share functionality within methods. In a traditional design, we have to extract the shared functionality into a separate method that is called by other methods.

**decomposing methods**

You might think of extracting smaller methods from bigger methods as *decomposing* methods. You break them into smaller pieces, and thus you can share functionality or rearrange the pieces so that your code is organized by responsibility.

For example, let's say that we are writing a game for the nostalgia market, and we wish to use partially constructed objects to save resources. When we go to actually use the object, we *hydrate* it, loading the complete object from persistent storage. This is a coarse kind of *lazy evaluation*.

Here's some bogus code:

	class Wumpus
		roar: ->
			# code that hydrates a Wumpus
			# ...
			# code that roars
			# ...
		run: ->
			# code that hydrates a Wumpus
			# ...
			# code that runs
			# ...

	class Hunter
		draw: (bow) ->
			# code that hydrates a Hunter
			# ...
			# code that draws a bow
			# ...
		run: ->
			# code that hydrates a Hunter
			# ...
			# code that runs
			# ...

We can decompose it into this:

	class Wumpus
		roar: ->
			hydrate(this)
			# code that roars
			# ...
		run: ->
			hydrate(this)
			# code that runs
			# ...

	class Hunter
		draw: (bow) ->
			hydrate(this)
			# code that draws a bow
			# ...
		run: ->
			hydrate(this)
			# code that runs
			# ...
		
	hydrate = (object) ->
		# code that hydrates the object from storage

**composing methods**

On an ad hoc basis, decomposing methods is fine. But there is a subtle problem. Implementation tricks like hydrating objects, memoizing return values, or other performance tweaks are orthogonal to the mechanics of what methods like `roar` or `run` are supposed to do. So why is `hydrate(this)` in every method?

Now the obvious answer is, "Ok, it might be orthogonal to the main business of each method, but it's just one line." The trouble with this answer is that method decomposition doesn't scale. We need a line for hydration, a line or two for logging, a few lines for error handling, another for wrapping certain things in a transaction...

Even when each orthogonal concern is boiled down to just one line, you can end up having the orthogonal concerns take up more space than the main business. And that makes the code hard to read in practice. You don't believe me? take a look at just about every programming tutorial ever written. They almost always say "Hand waving over error handling and this and that" in their code examples, because they want to make the main business of the code clearer and easier to read.

We ought to do the same thing, move hydration, error handling, logging, transactions, and anything else orthogonal to the main business of a method out of the method. And we can.\

**method combinations**

Here's our code again, this time using the  [YouAreDaChef][chef] library to provide *before combinations*:

[chef]: https://github.com/raganwald/YouAreDaChef

	YouAreDaChef = require('YouAreDaChef.coffee').YouAreDaChef

	class Wumpus
		roar: ->
			# ...
		run: ->
			#...

	class Hunter
		draw: (bow) ->
			# ...
		run: ->
			#...

	hydrate = (object) ->
		# code that hydrates the object from storage

	YouAreDaChef(Wumpus, Hunter)
		.before 'roar', 'draw', 'run', () ->
			hydrate(this)

Whenever the `roar`, `draw`, or `run` methods are called, YouAreDaChef calls `hydrate(this)` first.  And  the two concerns--How a Wumpus works and when it ought to be hydrated--are totally separated. This isn't a new idea, it's called [aspect-oriented programming][aop], and practitioners will describe what we're doing in terms of method advice and point cuts.

[aop]: http://en.wikipedia.org/wiki/Aspect-oriented_programming 

Ruby on Rails programmers are familiar with this idea. If you have ever written any of the following, you were using Rails' built-in aspect-oriented programming support:

	after_save
	validates_each
	alias_method_chain
	before_filter

These and other features of Rails implement method advice, albeit in a very specific way tuned to portions of the Rails framework. 

**the unwritten rule**

> There is an unwritten rule that says every Ruby programmer must, at some point, write his or her own AOP implementation --Avdi Grimm

Let's look at how YouAreTheChef works. Here's a simplified version of the code for the `before` combination:

    YouAreDaChef: (clazzes...) ->
        before: (method_names..., advice) ->
          _.each method_names, (name) ->
            _.each clazzes, (clazz) ->
              if _.isFunction(clazz.prototype[name])
                pointcut = clazz.prototype[name]
                clazz.prototype[name] = (args...) ->
                  advice.apply(this, args)
                  pointcut.call(this, args)

This is really simple, we are composing a method with a function. The method already defined in the class is called the *pointcut*, and the function we are supplying is called the *advice*. Unlike a purely functional combinator, we are only executing the advice for side-effects, not for its result. But in object-oriented imperative programming, that's usually what we want.

**other method combinations**

That looks handy. But we also want an _after method_, a way to compose methods in the other order. Good news, the after combination is exactly what we want. After combinations are very handy for things like logging method calls or cleaning things up.

But there's another great use for after combinators, triggering events. Event triggering code is often very decoupled from method logic: The whole point of events is to invert control so that an object like a `Wumpus` doesn't need to know which objects want to do something after it moves. For example,  a Backbone.js view might be observing the Wumpus and wish to update itself when the Wumpus moves:

	YouAreDaChef(Wumpus, Hunter)
		.after 'run', () ->
			this.trigger 'move', this

	CaveView = Backbone.View.extend
		initialize: ->
			# ...
			@model.bind 'move', @wumpusMoved
		wumpusMoved: (wumpus) ->
			# ...

The code coupling the view to the model has now been separated from the code defining the model itself.

YouAreDaChef also provides other mechanisms for separating concerns. *Around combinations* (also called around advice) are a very general-purpose combinator. With an around combination, the original method (the pointcut) is passed to the advice function as a parameter, allowing it to be called at any time.

Around advice is useful for wrapping methods. Using an around combinator, you could bake error handling and transactions into methods without encumbering their code with implementation details. In this example, we define the methods to be matched using a regular expression, and YouAreDaChef passes the result of the match to the advice function, which wraps them in a transaction and adds some logging:

    class EnterpriseyLegume
      setId:         (@id)         ->
      setName:       (@name)       ->
      setDepartment: (@department) ->
      setCostCentre: (@costCentre) ->
    
    YouAreDaChef(EnterpriseyLegume)
    
      .around /set(.*)/, (pointcut, match, value) ->
        performTransaction () ->
          writeToLog "#{match[1]}: #{value}"
          pointcut(value)

**summary**

Method combinations are a technique for separating concerns when the level of granularity is smaller than a method. This makes the code DRY and removes the clutter of orthogonal responsibilities.

[coffee]: http://coffeescript.org/

---

This article is loosely based on [Aspect-Oriented Programming in Ruby using Combinator Birds][ruby], part of a series about combinatory logic and its application to Ruby programming: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), [The Hopelessly Egocentric Blog Post](http://github.com/raganwald/homoiconic/tree/master/2009-02-02/hopeless_egocentricity.md#readme), and [Wrapping Combinators](http://github.com/raganwald/homoiconic/tree/master/2009-06-29/wrapping_combinators.md#readme).

[ruby]: https://github.com/raganwald/homoiconic/blob/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme

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