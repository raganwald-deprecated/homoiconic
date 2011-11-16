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
      
Note that `meld` requires [Functional Javascript][j] and that `meld` is purely functional, unlike `$.extend` which destructively modifies its first argument.

*UPDATE*

It turns out that `$.extend` does what I wanted provided you pass true as the first parameter. Wonderful news!

**(more)**

NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one convenient and inexpensive e-book!

Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.

[j]: http://osteele.com/sources/javascript/functional/