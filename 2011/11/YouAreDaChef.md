Aspect-Oriented Programming in Coffeescript with a side order of Combinator Birds
---

*This article is based on [Aspect-Oriented Programming in Ruby using Combinator Birds][ruby].*

[ruby]: https://github.com/raganwald/homoiconic/blob/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme

In [Combinatory Logic](http://en.wikipedia.org/wiki/Combinatory_logic), the bluebird is one of the most important and fundamental combinators, because the bluebird *composes* two other combinators. Although this is usually discussed as part of [functional programming style](http://weblog.raganwald.com/2007/03/why-why-functional-programming-matters.html "Why Why Functional Programming Matters Matters"), it is equally valuable when writing object-oriented programs. In this post, we will develop an [aspect-oriented programming](http://en.wikipedia.org/wiki/Aspect-oriented_programming "") (or "AOP") module that adds before, after and around methods to Javascript/Coffeescript/Underscore.js programs, with the implementation inspired by the bluebird. 

[dry]: http://en.wikipedia.org/wiki/Don't_repeat_yourself

> As explained in [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), the practice of nicknaming combinators after birds was established in Raymond Smullyan's amazing book [To Mock a Mockingbird](http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422). In this book, Smullyan explains combinatory logic and derives a number of important results by presenting the various combinators as songbirds in a forest. Since the publication of the book more than twenty years ago, the names he gave the birds have become standard nicknames for the various combinators.

[![Eastern bluebird (c) 2008 Doug Greenberg, some rights reserved reserved](http://farm3.static.flickr.com/2376/2451392973_cd28956b14_o.jpg)](http://www.flickr.com/photos/dagberg/2451392973/ "Eastern bluebird (c) 2008 Doug Greenberg, some rights reserved")  

**the bluebird**

The bluebird is written `Bxyz = x(yz)`. In Coffeescript, we can define the bluebird like this:

	bluebird = (x) ->
		(y) ->
			(z) ->
				x(y(z))

In other words:

	bluebird(x)(y)(z) is x(y(z))

If this seems a little arcane, consider a simple expression `(x * 2) + 1`: This expression *composes* multiplication and addition. Composition is so pervasive in programming languages that it becomes part of the syntax, something we take for granted. We don't have to think about it until someone like Oliver Steele writes a library like [functional javascript](http://osteele.com/sources/javascript/functional/) that introduces a `compose` function, then we have to ask what it does.

Before we start using bluebirds, let's be clear about something. We wrote that `bluebird(x)(y)(z)` is equivalent to `x(y(z))`. We want to be very careful that we understand what is special about `x(y(z))`. How is it different from `x(y)(z)`?

The answer is:

	x(y(z))
		=> puts z into y, then puts the result of that into x
	
	x(y)(z)
		=> puts y into x, getting a function out, then puts z into the new function
	
So with a bluebird, you can directly compose two functions, creating a new one that has the same effect as pipelining the output of one function into another, without needing to create temporary variables or add syntactic elements like parentheses.

Now that we've had a look at function composition, let's talk about some of its practical uses.

**composition**

Modern object-oriented software design [favours composition over inheritance][coi] and celebrates code that is [DRY][dry]. The idea is to separate each object's concerns and responsibility into separate units of code, each of which have a single responsibility. When two different types of objects share the same functionality, they do not repeat their implementation, instead they share their implementation.

[coi]: https://en.wikipedia.org/wiki/Composition_over_inheritance

When composing functionality at the method level of granularity, techniques such as mixins and delegation are effective design tools. But at a finer level of granularity, we sometimes wish to share functionality within methods. In a traditional design, we have to extract the shared functionality into a separate method that is called by other methods.

On an ad hoc basis, that's fine. But after you've been doing this for a while, you begin to notice certain patterns emerging. You often have some unique thing you want to do, but you want to set up an object before you do it. For example, you might have a partially constructed object and want to *hydrate* it, loading the complete object from persistent storage, before invoking certain methods. 

If you have objects that are only partially hydrated (for example, they may only have been initialized with a URI to a remote REST-ful server), many different methods on those objects will share the same code to instantiate the complete object. You'll want to check if the object needs to be hydrated before invoking certain methods.

You could write:

	class Wumpus
		roar: ->
			hydrate(this)
			# ...
		run: ->
			hydrate(this)
			#...

	class Hunter
		draw: (bow) ->
			hydrate(this)
			# ...
		run: ->
			hydrate(this)
			#...
		
	hydrate = (object) ->
		# code that hydrates the object from storage

But I do not care for that. Implementation tricks like hydrating objects, memoizing return values, or other performance tweaks are orthogonal to the mechanics of what methods like `roar` or `run` are supposed to do.

If you are maintaining this class, is it obvious that issues like hydrating objects are entirely independent of what the methods do? I say no, because the call to `hydrate()` is stuck right in the method body alongside whatever "business logic" is actually relevant to the method's purpose.

What we could do instead is put the entire question of hydration elsewhere. Now, by moving the hydration code into a separate function we have moved the question of *how to  hydrate* out of our `Wumpus` class. But we haven't moved the question of *which methods should operate on a hydrated object* out as well. To do that, we need something called *method combinations.*

**method combinations**

Here's our code again, this time using  [YouAreDaChef][chef] to provide *before combinations*:

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

Whenever the `roar`, `draw`, or `run` methods are called, YouAreDaChef calls `hydrate(this)` first.  And  the two concerns--How a Wumpus works and when it ought to be hydrated--are totally separated. This isn't a new idea, it's called aspect-oriented programming, and practitioners will describe what we're doing in terms of method advice and point cuts.

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

**the queer birds and other method ocmbinations**

That looks handy. But we also want an _after method_, a way to compose methods in the other order. Good news, the queer bird combinator is exactly what we want. 


[![happy pride (c) 2008 penguincakes, some rights reserved reserved](http://farm4.static.flickr.com/3035/2891197379_556f528536.jpg)](http://www.flickr.com/photos/penguincakes/2891197379/ "happy pride (c) 2008 penguincakes, some rights reserved")  


Written `Qxyz = y(xz)`, the Coffeescript equivalent is:

	queer_bird.call(x).call(y).call(z)
		=> y(x(z))

	queer_bird = (x) ->
		(y) ->
			(z) ->
				y(x(z))

In other words:

	queer_bird(x)(y)(z) is y(x(z))

Queer birds--or after combinations--are very handy for things like logging method calls or cleaning things up. Event triggering code is often very decoupled from method logic: The whole point of events is to invert control so that an object like a `Wumpus` doesn't need to know which objects want to do something after it moves. For example,  a backbone.js view might be observing the Wumpus and wish to update itself when the Wumpus moves:

	YouAreDaChef(Wumpus, Hunter)
		.after 'run', () ->
			this.trigger 'move', this

	CaveView = Backbone.View.extend
		initialize: ->
			# ...
			@model.bind 'move', @wumpusMoved
		wumpusMoved: (wumpus) ->
			# ...

The code coupling the view to the model has now been separated from the code defining the model itself. YouAreDaChef also provides other mechanisms for separating concerns. *Around combinations* (also called around advice) are a very general-purpose combinator. With an around combination, the original method (the pointcut) is passed to the advice funtion as a parameter, allowing it to be called at any time.

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

The bluebird is an interesting combinator because it controls function combination, allowing us to change the order of application without parameters. We used the bluebird as a thinly veiled excuse to look at the [YouAreDaChef][chef] library and at method combinations, a technique for separating concerns in coffeescript code when the level of granularity is smaller than a method.

---

_More on combinators_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), [The Hopelessly Egocentric Blog Post](http://github.com/raganwald/homoiconic/tree/master/2009-02-02/hopeless_egocentricity.md#readme), and [Wrapping Combinators](http://github.com/raganwald/homoiconic/tree/master/2009-06-29/wrapping_combinators.md#readme).

**(more)**
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.