Meld, a replacement for jQuery's $.extend
===

If you use jQuery, you may have used `$.extend`:

    $.extend({foo: 'fu'}, {bar: 'bar'})
      // => { foo: 'fu', bar: 'bar'}

One thing you may consider perfectly normal is the following:

    $.extend({foo: 'fu', etc: { one: 1 }}, {bar: 'bar', etc: { two: 2 }})
      // => { foo: 'fu', bar: 'bar', etc: { two: 2 } }

However, you may have a PBKAC as I do and prefer the following:

    $.extend({foo: 'fu', etc: { one: 1 }}, {bar: 'bar', etc: { two: 2 }})
      // => { foo: 'fu', bar: 'bar', etc: { one: 1, two: 2 } }
      
In which case:

    var meld = (function () {
      var recursor = function () {
        var args = Functional.select(Functional.I, arguments);
        if (args.length == 0) {
          return;
        }
        else if (args.length == 1) {
          return args[0];
        }
        else if (Functional.some("typeof(_) !== 'object'", args)) {
          return args[args.length - 1];
        }
        else return Functional.foldl(function (extended, obj) {
          for (var i in obj) {
            if (obj.hasOwnProperty(i)) {
              extended[i] = recursor(extended[i], obj[i]);
            }
          }
          return extended;
        }, {}, args);
      };
      return recursor;
    })();

    meld({foo: 'fu', etc: { one: 1 }}, {bar: 'bar', etc: { two: 2 }})
      // => { foo: 'fu', bar: 'bar', etc: { one: 1, two: 2 } }
      
Note that `meld` requires [Functional JavaScript][j] and that `meld` is purely functional, unlike `$.extend` which destructively modifies its first argument.

*UPDATE*

It turns out that `$.extend` does what I wanted provided you pass true as the first parameter. Wonderful news!

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

[j]: http://osteele.com/sources/javascript/functional/