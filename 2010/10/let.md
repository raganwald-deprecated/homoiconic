Let's make closures easy
===

In [Gah! I Still Don't Know Closures][eee_closures], Chris Strom refactored this:

    Frame.prototype.remove = function () {
      for (var i=0; i<this.elements.length; i++) {
        this.elements[i].remove();
      };
    };

    Frame.prototype.show = function() {
      for (var i=0; i<this.elements.length; i++) {
        this.elements[i].show();
      };
    };

    Frame.prototype.hide = function() {
      for (var i=0; i<this.elements.length; i++) {
        this.elements[i].hide();
      };
    };

    Frame.prototype.stop = function() {
      for (var i=0; i<this.elements.length; i++) {
        this.elements[i].stop();
      };
    };

Into this:

    var methods = ['remove', 'show', 'hide', 'stop'];
    for (var i=0; i<methods.length; i++) {
      var method = methods[i];
      Frame.prototype[methods[i]] = function () {
        for (var j=0; j<this.elements.length; j++) {
          this.elements[j][method]();
        };
      };
    }

Alas, it didn't work, and Chris goes on to explain how to remedy the problem. If you haven't spotted the bug, you might want to try the following simplified version in Firebug or Safari's error console:

    var conjunctions = ['before', 'after', 'below', 'above', 'inside', 'outside'];
    
    for (var i=0; i<conjunctions.length; i++) {
      var conjunction = conjunctions[i];
      String.prototype[conjunctions[i]] = function (that) {
        return this + ' ' + conjunction + ' ' + that;
      };
    }
    
And here's what's wrong:

    "miles davis".before("wynton marsalis")
      => "miles davis outside wynton marsalis"
      
    "head".inside("hat")
      => "head outside hat"

Hmmm.

**fixing our problem**
      
The culprit is that inside our function, we refer to the variable `conjunction`. Javascript correctly notes that this refers to the variable defined outside of the function in the line `var conjunction = conjunctions[i];`. However, all it stores is a reference to the variable. When the function is invoked, Javascript looks the variable up and fetches whatever was last written to the variable, which in this case is `'outside'`, the last element in our array.

We are making six different functions, however they all share the same variable reference. Although we execute the line `var conjunction = conjunctions[i];` six times, they're all within the same scope, so they're all the same variable. What we want is for each of our functions to have its own copy of the `conjunction` variable.

The easiest way to do that is to create a new scope each time though the for loop. First, here's the code:

    for (var i=0; i<conjunctions.length; i++) {
      (function () {
        var conjunction = conjunctions[i];
        String.prototype[conjunctions[i]] = function (that) {
          return this + ' ' + conjunction + ' ' + that;
        };
      })();
    }

Now we get the expected behaviour:

    "miles davis".before("wynton marsalis")
      => "miles davis before wynton marsalis"
      
    "head".inside("hat")
      => "head inside hat"
      
Why did this work? Well, let's look at what we added:

    (function () {
      var conjunction = conjunctions[i];
      // blah, blah
    })();

Each time through the for loop, we're creating a new, anonymous function *with the definition of `conjunction` inside the function's body*. Unlike executing the definition six times in a for loop, executing the definition inside a new function creates a new variable. We then execute the function immediately with no arguments. The entire exercise exists to create a new scope.

This solves our problem, and the pattern of defining variables inside of an anonymous function that is immediately invoked is very useful. Amongst other things, it's handy for keeping the global namespace clean or creating private variables. Here's a function that counts:

    var count = (function () {
      var counter = 0;
      return function () {
        return ++counter;
      }
    })();
    
    count()
      => 1
      
    count()
      => 2

It's so well known that you may not think you need additional syntactic sugar. But since you're sticking around, I can tell you that I prefer to write:

    var count = (function (counter) {
      return function () {
        return ++counter;
      }
    })(0);
˝
What we've done is extracted the variable declaration and turned it into a parameter of our anonymous function. I prefer this strongly because I know that the creation of the function is what establishes a new scope, and a function's parameters are sitting right there in its definition.

I'm not alone in my madness. Here is a common abbreviation pattern:

    (function ($,F) {
      
      // blah, blah, blah
      
    })(jQuery, Functional);

This binds `$` and `F` without conflicting with other libraries that may want to define `$` or `F` for their own purposes. The only trouble with structuring things as parameters is that in Javascript, the definition of the parameter and the value it is passed can be a long way away from each other.

**let's get closer**

If you prefer to keep your paramaters closer to the values you are going to bind, we can use a Javascript version of the [Thrush Combinator][thrush], `let`:

    var let = function () {
      var body = arguments[arguments.length-1];
      return body.apply(this, Array.prototype.slice.call(arguments, 0, arguments.length - 1));
    }
    
This lets us write:

    var count = let(0, function (counter) {
      return function () {
        return ++counter;
      }
    });

And:

    let(jQuery, Functional, function ($, F) {
      
      // blah, blah, blah
      
    });
    
Not to mention:

    for (var i=0; i<conjunctions.length; i++) {
      let(conjunctions[i], function (conjunction) {
        String.prototype[conjunctions[i]] = function (that) {
          return this + ' ' + conjunction + ' ' + that;
        };
      });
    }

And finally:

    var methods = ['remove', 'show', 'hide', 'stop'];
    for (var i=0; i<methods.length; i++) {
      let(methods[i], function (method) {
        Frame.prototype[methods[i]] = function () {
          for (var j=0; j<this.elements.length; j++) {
            this.elements[j][method]();
          };
        };
      });
    } 
    
Is `let` worth the bother? I think so. Although I've been using anonymous functions to establish scopes for a very long time, I realize that it isn't always immediately obvious what the code is doing. `let` is arresting: It reads in English "Let these values be assigned to these variables..." and makes a nice little obvious place that we are making a new scope.

And I suppose we shouldn't be making long functions, but even on a short function I prefer the values and the bindings be kept close together. Declaring variables inside a scope avoids that issue, but I strongly prefer using parameters when I want to create a new scope. The parameter variable is very close to the `function` keyword what establishes the scope, and that makes the code very easy to understand.

But the very best reason for using `let` is that [Javascript 1.7 includes a `let` keyword][js17]! Knowing that you'll be using `let` eventually, why not write your code so it is future-proof?

---
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald) or [RSS](http://feeds.feedburner.com/raganwald "raganwald's rss feed"). I work with [Unspace Interactive](http://unspace.ca), and I like it.

[eee_closures]: http://japhr.blogspot.com/2010/10/gah-i-still-dont-know-closures.html
[thrush]: http://github.com/raganwald/homoiconic/blob/master/2008-10-30/thrush.markdown#readme
[js17]: https://developer.mozilla.org/en/New_in_JavaScript_1.7#let_statement