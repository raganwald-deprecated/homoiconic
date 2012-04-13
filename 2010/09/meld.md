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

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), an implementation of Bill Gosper's HashLife in CoffeeScript in the "Williams Style."
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[j]: http://osteele.com/sources/javascript/functional/