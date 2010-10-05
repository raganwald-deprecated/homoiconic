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

Alas, it didn't work right out of the gate, and Chris goes on to explain how he remedied the issue. If you haven't spotted the bug, you might want to try the following simplified version in Firebug or Safari's error console:

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

**the problem**

Let's start by diagnosing the issue. We're defining six new methods for `String` instances. Unlike Ruby, methods in Javascript and functions in Javascript are the exact same thing, so we can also say that we're creating six new functions, one for each element in the conjunctions array. Note that it's technically wrong to say that we are creating one function. We're creating six different functions, one each time the Javascript interpreter encounters the `function` keyword.

Inside each of our six functions, we refer to the variable `conjunction`. Javascript correctly notes that this refers to the variable defined outside of the function in the line `var conjunction = conjunctions[i];`. `conjunction` has a different value each time we create a new function, so we might think that when each of our functions are invoked they will refer to its value when the function was created.

This is not the case. Each of our functions simply stores a reference to the variable `conjunction` and when the function is invoked, it looks up the value at invocation time, not definition time. Its value at function invocation time is irrelevant.

The easiest way to fix this problem is to make sure that each of the six functions we create has their own `conjunction` variable rather than having them all share the same variable.

> Practice explaining code to others is one of the keys to improving your ability to write self-explanatory code.

This brings us to the key question: *When do we create a new variable in Javascript*? Most of you probably consider this question ridiculously trivial to understand, but let's work out how to explain it. You never know when you'll have to explain your code to someone else. The ideal code is self-explanatory, and practice explaining code to others is one of the keys to improving your ability to write self-explanatory code.

Let's look at this code again, simplified greatly:

    for (/* ... */) {
      var conjunction = // ...
      // ...
    }

It appears as if we're using the `var` keyword to create a new variable each time through the for loop. *But this is not so*. Although we execute that line of code six times, we only create *one* variable. The rest of the time, we're simply assigning a new value to it.

To understand this issue, we really have to let go of the idea that if we give something a name (like "conjunction"), that there is one thing with that name. There might be one, there might be many. Likewise sometimes something doesn't have a name (like an anonymous function) but it exists anyways.

Names are just ways of looking things up, that's all.

**scope**

When is a new variable created? Well, the interpreter might do one thing, it might do another, but in practice it is sufficient to say the following:

*A new variable is created for each parameter every time a function is invoked.*

Note that if a function is invoked 100 times, each of its parameters will actually create 100 different new variables even though all 100 share the same name in the code. We say that parameters in Javascript have *function scope*. My mental model is that when a function is invoked, Javascript creates a new dictionary of variables and values. The first thing it does is make entries for each of the parameters. Some other part of the program might have variables with the same name (common variables like "i," "key," or "value" might exist in many different dictionaries), but since those variables are written in different dictionaries, they don't conflict with our variables.

Variables created with the `var` keyword also have function scope. When a naïve Javascript interpreter encounters the `var` keyword, it looks in the dictionary for the currently invoked function to see if the variable already exists. If it doesn't, it makes a new entry.

So is a dictionary a scope? Not quite. We've written about creating variables. What about looking up their values? When a variable is used, javascript looks it up in the current dictionary. If it isn't in the dictionary, Javascript looks in the dictionary for whatever function was invoked when the current function was *created*. Not invoked, created. If it isn't there, Javascript repeats the process until it is looking in a top-level dictionary that represents code running when Javascript was first invoked.

The dictionaries can be thought to nest, but I prefer to think of them as having a parent-child relationship. Invoking a function creates a new dictionary, but the new dictionary is the child of the code that created the function, not the code that invokes the function.

The chain of dictionaries is called a *scope*. In practice, making dictionaries children of the dictionary for the function that creates another function makes it easy to determine where a variable is defined by examining the lexical form of the source code statically. Thus, this style of scoping is called **Lexical Scope**.

**soling the problem**

Now that we've examined javascript's lexical scope in detail, we have a solution. If we want different values for `conjunction` each time we create a new function, we need different variables each time through the for loop. To create new variables, we have to invoke a new function each time though the for loop. 

Here's the simplest refactoring, the one that minimizes rearranging our code:

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

Each time through the for loop, we're creating a new, anonymous function *with the definition of `conjunction` inside the function's body*. We then invoke the function immediately, which creates a new scope. The `var` keyword creates a new variable in each scope, and we thus get six different variables, each of which has its own value.

This solves our problem, and the pattern of defining variables inside of an anonymous function that is immediately invoked is very useful. Amongst other things, it's handy for keeping the global namespace clean or creating private variables. And there's another way to use an anonymous function to create new variables. Here's a function that counts:

    var count = (function (counter) {
      return function () {
        return ++counter;
      }
    })(0);
    
    count()
      => 1
      
    count()
      => 2

You recall that parameters create new variables as well. I prefer this strongly because I know that the creation of the function is what establishes a new scope, and a function's parameters are sitting right there in its definition.

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

p.s. It seems that my tongue being in cheek was not obvious about the expression "future-proof." So here's the long explanation: Using this "functional" implementation of `let` makes your code "let-like," and certainly it will be easy to rewrite it if and when `let` is supported as a keyword on all of the Javascript platforms you intend to target. Even if you are writing for a browser that supports Javascript 1.7 and `let`, you have to turn the keyword on precisely because the keyword will break existing code, so using this implementation of `let` is safe. To summarize, if you are working in an environment where you can count on the `let` keyword, I think you should use it. If you aren't, I prefer to use this functional implementation, knowing that it will be easy to 'port' should the need ever arise.

---
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald) or [RSS](http://feeds.feedburner.com/raganwald "raganwald's rss feed"). I work with [Unspace Interactive](http://unspace.ca), and I like it.

[eee_closures]: http://japhr.blogspot.com/2010/10/gah-i-still-dont-know-closures.html
[thrush]: http://github.com/raganwald/homoiconic/blob/master/2008-10-30/thrush.markdown#readme
[js17]: https://developer.mozilla.org/en/New_in_JavaScript_1.7#let_statement