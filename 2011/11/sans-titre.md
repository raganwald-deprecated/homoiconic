# Sans Titre

![Sans Titre](http://upload.wikimedia.org/wikipedia/en/f/fe/Mondrian_Composition_II_in_Red%2C_Blue%2C_and_Yellow.jpg)  
(*"Sans Titre," also called "Composition II in Red, Blue and Yellow" by Piet Mondrian, 1930*)

I have been programming in [CoffeeScript][cs] lately. In my opinion, it does a good job of paving over a lot of JavaScript's accidental complexity. Another thing  that I find interesting about it is that it encourages a certain kind of programming style. I like that. As Alan Perlis said, "A language that doesn't change the way you think about programming is not worth learning." CoffeeScript definitely changes the way I think about programming-in-the-small, about the way I express concepts in syntax.

[cs]: http://jashkenas.github.com/coffee-script/

One of the big ways CoffeeScript differs from JavaScript in that its control structures are whitespace-significant. Instead of:

	if (foo) {
		// ...
	} else {
		// ...
	}

You write:

	if foo
		# ...
	else
		# ...

The parser works out what you mean from the way you indent your code. There's a similar thing with object literals:

	my_object =
		foo: 'snafu'
		bar: 'public house'
		blitz: 'armoured assault'

I like that. It is [familiar][f]: That's the way we write outlines. It's an obvious textual way to describe a tree, which is the natural data representation for the dominant paradigm of software code.

[f]: http://www.asktog.com/papers/raskinintuit.html "INTUITIVE EQUALS FAMILIAR"

![AST][ast]  
(*image snarfed from [OranLooney.com][ast-link]*)
[ast]: http://oranlooney.com/static/misl/ast.png
[ast-link]: http://oranlooney.com/minimal-interpreted-scripting-language/

Here's another example. These two things produce different results:

    foo = 1
    if foo is 42
      console?.log "I don't think so, Tim"
    foo += 1
    console?.log "Foo is #{foo}"

And:

    foo = 1
    if foo is 42
      console?.log "I don't think so, Tim"
      foo += 1
    console?.log "Foo is #{foo}"

Thanks to the indentation, we see that in the first example, `foo +=1` will be executed and foo will end up being 2. But in the second example, `foo += 1` belongs to the if statement and will not be executed, since foo is not 42. This makes sense: The things that are indented **belong to** their parent. That's how trees work, that's how outlines work.

To make this super-clear, I will draw things such that we only see the shapes. This:

	# -----
	  # -----
	  # -----

Is not the same thing as:

	# -----
	  # -----
	# -----

Indentation matters.

## Method calls are whitespace-blind

Now let's look at methods and properties in CoffeeScript. Recall that with `if` statements, indentation matters. With method calls, *it doesn't*. Consider this expression:

	console?.log [1..3].concat([4..6]).map((x) -> x * x).filter((x) -> x % 2 is 0).reverse()

And this:

    console?.log [1..3]
    .concat([4..6])
    .map((x) -> x * x)
    .filter((x) -> x % 2 is 0)
    .reverse()

And this:

    console?.log [1..3]
      .concat([4..6])
      .map((x) -> x * x)
      .filter((x) -> x % 2 is 0)
      .reverse()

And one last one, this:

    console?.log [1..3]
      .concat([4..6])
        .map((x) -> x * x)
          .filter((x) -> x % 2 is 0)
            .reverse()

Although they have different indentation, they all produce the same result. Surprise!

## Why I'm surprised

Let's review, starting with:

	console?.log [1..3].concat([4..6]).map((x) -> x * x).filter((x) -> x % 2 is 0).reverse()

It says that this is one big expression. But this:

    console?.log [1..3]
    .concat([4..6])
    .map((x) -> x * x)
    .filter((x) -> x % 2 is 0)
    .reverse()

Says to me that every line is independent of the previous line. And this:

    console?.log [1..3]
      .concat([4..6])
      .map((x) -> x * x)
      .filter((x) -> x % 2 is 0)
      .reverse()'

Says to me that the `butFirst()` lines all belong to `console?.log [1..3]`. The last example makes sense again:

    console?.log [1..3]
      .concat([4..6])
        .map((x) -> x * x)
          .filter((x) -> x % 2 is 0)
            .reverse()

It says that each line belongs to the previous line, because our rule with outlines is that *when something is indented, it belongs to its parent*. Let's imagine for a moment that CoffeeScript treated method calls and property syntax using that rule.

## A hypothetical whitespace rule for CoffeeScript

In our hypothetical version of CoffeeScript, methods and properties will use our outline rule: If you have a property reference or method call, it either belongs to the thing to its left, as in `[1..3].concat([4..6])` or belongs to its parent, as in:

	[1..3]
	  .concat([4..6])

Using this rule, only the first and fourth examples above make sense:

	console?.log [1..3].concat([4..6]).map((x) -> x * x).filter((x) -> x % 2 is 0).reverse()

    console?.log [1..3]
      .concat([4..6])
        .map((x) -> x * x)
          .filter((x) -> x % 2 is 0)
            .reverse()

So when would we do things differently? Well, how about:

    path
      .moveTo(10, 10)
      .stroke("red")
      .fill("blue")
      .ellipse(50, 50)

This says that each of these methods (`moveTo`, `stroke`, `fill`, and `ellipse`) **belong to** `path`. Regardlesss of what each method returns, with our hypothetical whitespace rule, anything with this outline form would work the same way.

## Why we need this rule

Alan Kay and the rest of the team behind Smalltalk recognized that this was a common use case and baked it into their language with semicolons:

    (self new)
      add: FirstSquare new;
      add: (LadderSquare forward: 4);
      add: BoardSquare new;
      add: BoardSquare new;
      add: BoardSquare new;
      add: BoardSquare new;
      add: (LadderSquare forward: 2);
      add: BoardSquare new;
      add: BoardSquare new;
      add: BoardSquare new;
      add: (SnakeSquare back: 6);
      add: BoardSquare new;
      join: (GamePlayer named: 'Jack');
      join: (GamePlayer named: 'Jill');
      yourself

In Smalltalk, these are called *cascading* messages, and all those `add`s and `join`s and the final `yourself` are all sent to `(self new)`. This works so well that many modern libraries try to ape it by writing [fluent interfaces][fluent]. To get the same effect, methods create some side-effect and then return the receiver.

[fluent]: http://en.wikipedia.org/wiki/Fluent_interface

I don't blame anyone for writing a  fluent interface in a langue that doesn't support cascades. What else are you going to do? But not every method can return its receiver conveniently. For example, `pop`. How do you write:

	array.pop().pop().pop()

This isn't going to work because `pop` returns the value popped out of the array, not the array. If we rewrite `pop` to be fluent, you'd have to do weird things like this when you don't want to be fluent:

	_ = require 'underscore'
	next_value = _(array).last()
	array.pop()

Why can't we write `next_value = array.pop()`? That's a common use case as well. But our new rule comes to the rescue. When we want to pop three things off an array, we write:

	array
	  .pop()
	  .pop()
	  .pop()

And we want to use the value popped, we write:

	next_value = array.pop()

Remember, when we don't want  to cascade, we simply indent:

	undo_stack
		.pop()
			.undoIt()

We get both kinds of behaviour and our intent is always clear, regardless of whether we are dealing with a fluent library like jQuery or not.

## In summary

> My suggestion is that "chaining" method calls is a syntax issue and not a function issue, and that writing functions to return a certain thing just to cater to how you like to write programs is hacking around a missing language feature.

One thing that expressive languages like Ruby, Smalltalk, and Lisp teach us is that many 'design patterns' are actually language smells. The 'fluent interface' design patterns is just that: A sign that a language is missing a  cascading message feature.

This feature can easily be added to CoffeeScript, without a new operator, by simply making whitespace *more significant*.

---

([Discuss][d] on Hacker News. A relevant CoffeeScript feature request: [Improve chaining syntax][1495]. And back in March of 2010, I wrote "[Significant Whitespace][sw]")

[d]: http://news.ycombinator.com/item?id=3296202
[1495]: https://github.com/jashkenas/coffee-script/issues/1495
[1889]: https://github.com/jashkenas/coffee-script/issues/1889
[sw]: https://github.com/raganwald/homoiconic/blob/master/2010/03/significant_whitespace.md#readme

[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one convenient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)