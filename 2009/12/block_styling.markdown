Block Styling
===

> There are two kinds of programming languages that are unsurprising to the programmer. The first kind has users that say, "Everything about this language is unsurprising." The second has users that say, "Nothing about this language surprises me any more." --after a conversation with [Pete Forde](http://www.peteforde.com/ "Pete Forde")

You probably know that Ruby supports writing parameter-less blocks using `begin` and `end`:

    fu = begin
           a = 1
           b = 2
           c = 3
           a + b + c
         end
    # => 6

You may also know that you can use parentheses with multiple lines:

    fu = ( a = 1
           b = 2
           c = 3
           a + b + c )
    # => 6
    
I didn't know that! As usual, semi-colons work as separators:

    fu = ( a = 1
           b = 2; c = 3
           a + b + c )
    # => 6
    
The sharp-eyed amongst you may have noticed that some of these statements could be combined with Ruby's destructuring assignment:

    fu = ( a, b, c = 1, 2, 3
           a + b + c )
    # => 6
    
But that's a *different* language feature. Okay, that's enough lingua obscura for today.

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