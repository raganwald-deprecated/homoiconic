# What is the value of `i`?

[Stefan Tilkov][st] mentioned that he was asked to predict the value of `i` after the following code was evaluated:

[st]: http://www.innoq.com/blog/st/

    i = 1; i += ++i + ++i;
    
Before I go on, what's *your* answer?  

```



















(scroll down)



















```

I think it's probably a trick question. Off the top of my head, the answer could be three or six, depending on whether the language is Ruby or JavaScript. It's valid in both of those languages, as well as valid in Java and some other Algol descendants. So the answer very much depends upon what language you're using to evaluate that code.

Most interestingly, the correct answer seems to be that the result is *undefined* in the C family of languages. That's because it features three assignments to `i` in one statement, and you aren't supposed to have more than one assignment per variable. I find that very interesting! Essentially, C takes the position that if assignments are involved, you cannot define the result of an expression, only a statement. So if I were to ask you:

> `i` has the value one. What is the result of evaluating the expression `++i`?

The correct answer for C is, "That depends, what's in the rest of the statement?" Whereas for Ruby, JavaScript, and many other languages, you can look at an individual expression and the language is explicit about exactly what that expression does, and when (or if) it does it. For such languages, you make a little expression tree in your head and each branch of the tree can be evaluated independently of the other branches. C is a little more complicated. There is some tangling between branches if an assignment is made.

It seems like a little thing, but for me this is an extremely deep distinction between C and many other languages. There are many, many languages where each expression can be evaluated independently of other expressions in the same "statement." Of course, the value of bindings can be altered by whatever happens before an expression is evaluated, but the expression has a well-defined behaviour. Many languages go so far as to erase the distinction between statements and expressions: Everything's an expression. That makes it much easier to reason about expressions and statements, and much easier to build compilers, interpreters, and other tools. 

I don't have some wonderful insight or suggestion to close with, just that I think the trend in language design is in the direction of everything being an expression and having them all be independent of each other. And I think such languages go a long way towards making "trick questions" like this go away.

There's no trick question if the language's semantics aren't tricky to begin with.

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