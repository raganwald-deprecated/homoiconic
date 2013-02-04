jQuery Predicates
===

With the [jQuery Combinators][comb] plug in, you can refactor if statements into fluent jQuery chaining calls. For example, given:

    var updated_killed_count = function (killed_stones) {
      // ...
      // some code updating a counter on the board
      // ...
      alert("Congratulations, you have killed " + killed_stones + ' stone(s).');
    }

You can turn this:

    var killed_stones = board
      .find('.killed')
        .removeClass('black white');
    if (killed_stones.length)
      updated_killed_count(killed_stones);

Into this:

    board
      .find('.killed')
        .ergo(updated_killed_count)
        .removeClass('black white');
        
That's nice: `.ergo` converts a test of existence into a guarded method call that chains fluently. However, sometimes you still want an old-fashioned `if` statement or anything else relying on testing existence. And if you are going to use something like an if statement to test for the existence of DOM elements, you might as well have some semantic sugar.

Thus, [jQuery Predicates][pred]. With jQuery Predicates in your jQuery quiver, you can replace this:

    if (killed_stones.length)
      updated_killed_count(killed_stones);
      
With this:

    if (killed_stones.exists())
      updated_killed_count(killed_stones);
    
And replace this:

    while (0 === stones.into(adjacents).length) {
      // ...
    }
      
With this:

    while (stones.into(adjacents).do_not_exist()) {
      // ...
    }

In short, [jQuery Predicates][pred] adds two queries to every jQuery selection: `.exists()` returns true if the selection has at least one element, and `.does_not_exist()` returns true if the selection is empty (for convenience, jQuery Predicates also defines the synonyms `.exist()` and `do_not_exist()`).

And naturally, jQuery Predicates plays well with jQuery Combinators. Using them together, you now have access to `.ergo()`, `.when()`, `.exists()`, and `.does_not_exist()` for discriminating between empty and non-empty selections.

Enjoy!

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

[comb]: http://github.com/raganwald/jQuery-Combinators
[pred]: http://github.com/raganwald/jQuery-Predicates
