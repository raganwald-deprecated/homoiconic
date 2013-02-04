Just when I thought I was out... they pull me back in.
===

For some little time I've been [disquieted][sick] by Ruby's global environment for classes and modules. Class definitions are the ultimate global variables: Any monkey patch you make in your code affects all the other code running anywhere in the same instance of the interpreter.

Naturally, you're a careful programmer and you have close to 100% code coverage, so you don't mind working with really sharp tools. This is fine when you're a leaf node: If your application uses other code but is not used by other code, if your manipulation of the global class definitions breaks one of the gems or libraries you're using, you have the power to work around things, change libraries, or change approaches.

The problem comes in when you are writing code for other people to use. If you decide that it's cool to implement `#sum` in your library, you might break the code for anyone implementing `#sum` downstream of you. Okay, they can decide whether to use your version of `#sum` or whether they prefer another library. But what happens when your definition of `#sum` breaks some code in another library or gem you've never heard of and therefore never tested?

Much hilarity ensues if one of your hapless users decides to use your library and the other library, of course. Two reasonable programmers&#8212;you and the other library author&#8212;each did reasonable things with close to 100% code coverage and nevertheless the code doesn't work together and users have no ability to fix the problem for themselves.

![Godfather, Part III](http://gallery.sendbad.net/data/media/68/godfather_part_iii_ver1.jpg)

**plus ça change (plus c'est la même chose)**

I've said this before, and even then it was hardly a grand revelation. And it has been months since I did any work with Ruby. I've had a refreshing time working with JavaScript. But this morning I found myself writing this code in a [tiny little framework][roweis] I'm writing with some colleagues for a project at [Unspace Interactive][unspace]:

    if (controller.target) {
      controller.render_target = function (render_target_context) {
        return (function (selection) {
          selection
            .find(controller.target)
              .ergo(function (element) {
                controller.render(render_target_context, function (rendered) {
                  element.append(rendered);
                });
              });
        });
      };
    }
    
Notice the use of [jQuery Combinators][comb]'s `ergo`? I'm the author of `ergo`, and I want to use my own tools. But jQuery plugins work just like Ruby's global class definitions. If I extend `jQuery.fn` to include `ergo`, every user of my framework gets it whether they like it or not.

Regrettably, I have to remove any use of jQuery Combinators from [Roweis][roweis]. And if one day you look at my code and wonder why I don't seem to be eating my own dog food, the reason is that although I like the taste, I don't want to force-feed it to everyone else. jQuery Combinators belongs in the application JavaScript, not the framework code.

Not a big deal in itself, but this really emphasizes that if you want change, you have to really change. JavaScript in the Browser is completely different from Ruby on the Server in all the ways that don't matter a damn.

*fin*

(You can dis or cuss this post on [Reddit][prg].)

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

[sick]: http://github.com/raganwald/homoiconic/blob/master/2009-04-08/sick.md#readme "I'm Sick Of This Shit"
[unspace]: http://unspace.ca
[comb]: http://github.com/raganwald/jQuery-Combinators
[roweis]: http://github.com/raganwald/Roweis
[prg]: http://www.reddit.com/r/programming/comments/d6wp7/just_when_i_thought_i_was_out_they_pull_me_back_in/