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

---
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald) or [RSS](http://feeds.feedburner.com/raganwald "raganwald's rss feed"). I work with [Unspace](http://unspace.ca), and I like it.

[j]: http://osteele.com/sources/javascript/functional/