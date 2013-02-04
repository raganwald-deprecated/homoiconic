Let's make closures easy
===

In [Gah! I Still Don't Know Closures][eee_closures], Chris Strom refactored this JavaScript code:

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

    function declareConjunctions () {
      var conjunctions = ['before', 'after', 'below', 'above', 'inside', 'outside'];
    
      for (var i=0; i<conjunctions.length; i++) {
        var conjunction = conjunctions[i];
        String.prototype[conjunctions[i]] = function (that) {
          return this + ' ' + conjunction + ' ' + that;
        };
      }
    }
    
And here's what's wrong:

    declareConjunctions();

    "miles davis".before("wynton marsalis")
      => "miles davis outside wynton marsalis"
      
    "head".inside("hat")
      => "head outside hat"

Hmmm.

**the problem**

Let's start by diagnosing the issue. We're defining six new methods for `String` instances. Unlike Ruby, methods in JavaScript and functions in JavaScript are the exact same thing, so we can also say that we're creating six new functions, one for each element in the conjunctions array. Note that it's technically wrong to say that we are creating one function. We're creating six different functions, one each time the JavaScript interpreter encounters the `function` keyword.

Inside each of our six functions, we refer to the variable `conjunction`. JavaScript correctly notes that this refers to the variable defined outside of the function in the line `var conjunction = conjunctions[i];`. `conjunction` has a different value each time we create a new function, so we might think that when each of our functions are invoked they will refer to its value when the function was created.

This is not the case. Each of our functions simply stores a reference to the variable `conjunction` and when the function is invoked, it looks up the value at invocation time, not definition time. Its value at function definition time is irrelevant.

The easiest way to fix this problem is to make sure that each of the six functions we create has their own `conjunction` variable rather than having them all share the same variable.

> Practice explaining code to others is one of the keys to improving your ability to write self-explanatory code.

This brings us to the key question: *When do we create a new variable in JavaScript*? Most of you probably consider this question ridiculously trivial to understand, but let's work out how to explain it. You never know when you'll have to explain your code to someone else. The ideal code is self-explanatory, and practice explaining code to others is one of the keys to improving your ability to write self-explanatory code.

Let's look at this code again, simplified greatly:

    function declareConjunctions () {
      // ...
      for (/* ... */) {
        var conjunction = // ...
        // ...
      }
    }

It appears as if we're using the `var` keyword to create a new variable each time through the for loop. *But this is not so*. To understand this issue, we really have to understand when the JavaScript interpreter creates a new variable and when it simply assigns a value to an existing variable.

[<img src="http://2.bp.blogspot.com/_JrXOqYWNfjc/S0n5yp4kheI/AAAAAAAAB14/id9j_d7tYIQ/s400/Redwing_Arlesey_2010Jan10.jpg" height="432" width="500"/>][thrush]

**scope**

When is a new variable created? Well, the interpreter might do one thing, it might do another, but in practice it is sufficient to say the following:

*A new variable is created for each parameter and every variable declared with the `var` keyword every time a function is invoked.*

Note that if a function is invoked 100 times, each of its parameters will actually create 100 different new variables even though all 100 share the same name in the code. We say that parameters in JavaScript have *function scope*. My mental model is that when a function is invoked, JavaScript creates a new dictionary of variables and values. The first thing it does is make entries for each of the parameters. Some other part of the program might have variables with the same name (common variables like "i," "key," or "value" might exist in many different dictionaries), but since those variables are written in different dictionaries, they don't conflict with our variables.

Variables created with the `var` keyword also have function scope. When the JavaScript interpreter is first parsing a function declaration, it searches for `var` keywords. These are "hoisted" to the beginning of the function that immediately encloses them. So if you write this:

    function declareConjunctions () {
      var conjunctions = ['before', 'after', 'below', 'above', 'inside', 'outside'];
    
      for (var i=0; i<conjunctions.length; i++) {
        var conjunction = conjunctions[i];
        String.prototype[conjunctions[i]] = function (that) {
          return this + ' ' + conjunction + ' ' + that;
        };
      }
    }

The interpreter rearranges things so it looks like this:

    function declareConjunctions () {
      var conjunctions, conjunction;
      
      conjunctions = ['before', 'after', 'below', 'above', 'inside', 'outside'];
    
      for (var i=0; i<conjunctions.length; i++) {
        conjunction = conjunctions[i];
        String.prototype[conjunctions[i]] = function (that) {
          return this + ' ' + conjunction + ' ' + that;
        };
      }
    }

Now it's very obvious that there is one and only only one `conjunction` variable created when you invoke `declareConjunctions`. The fact that the `var` keyword was placed inside a for loop is irrelevant. After the interpreter has created dictionary entries for each of the parameters, it creates dictionary entries for each of the "hoisted" variables declared with `var`.

So is a dictionary a scope? Not quite. We've written about creating variables. What about looking up their values? When a variable is used, javascript looks it up in the current dictionary. If it isn't in the dictionary, JavaScript looks in the dictionary for whatever function was invoked when the current function was *created*. Not invoked, created. If it isn't there, JavaScript repeats the process until it is looking in a top-level dictionary that represents code running when JavaScript was first invoked.

The dictionaries can be thought to nest, but I prefer to think of them as having a parent-child relationship. Invoking a function creates a new dictionary, but the new dictionary is the child of the code that created the function, not the code that invokes the function.

The chain of dictionaries is called a *scope*. In practice, making dictionaries children of the dictionary for the function that creates another function makes it easy to determine where a variable is defined by examining the lexical form of the source code statically. Thus, this style of scoping is called **Lexical Scope**.

We take lexical scope for granted with JavaScript: When our function refers to the `conjunction` variable, we look for its definition right there in the code surrounding the function. That's lexical scoping in action. (There is another way to do things, Dynamic Scoping, where a scope is the child of the scope of the code that invokes a function. Im that case, `conjunction` would have to be defined by whatever code invokes `"christian mcbride".after("jaco pastorius")`. If that seems impossibly contrived, consider that exception handling is dynamically scoped and people find ways to make it useful.)

**solving the problem**

Now that we've examined javascript's lexical scope in detail, we have a solution. If we want different values for `conjunction` each time we create a new function, we need different variables each time through the for loop. To create new variables, we have to invoke a new function each time though the for loop. 

Here's the simplest refactoring, the one that minimizes rearranging our code:

    function declareConjunctions () {
      var conjunctions = ['before', 'after', 'below', 'above', 'inside', 'outside'];
      for (var i=0; i<conjunctions.length; i++) {
        (function () {
          var conjunction = conjunctions[i];
          String.prototype[conjunctions[i]] = function (that) {
            return this + ' ' + conjunction + ' ' + that;
          };
        })();
      }
    }

Now we get the expected behaviour:

    declareConjunctions();
    
    "miles davis".before("wynton marsalis")
      => "miles davis before wynton marsalis"
      
    "head".inside("hat")
      => "head inside hat"
      
Why did this work? Well, let's look at what we added:

    (function () {
      var conjunction = conjunctions[i];
      // blah, blah
    })();

Each time through the for loop, we're creating a new, anonymous function *with the definition of `conjunction` inside that function's body*. We then invoke the function immediately, which creates a new scope. The `var` keyword creates a new variable in each scope, and we thus get six different variables, each of which has its own value. Let's look at what the interpreter does when it "hoists" our variable:

    function declareConjunctions () {
      var conjunctions;
      
      conjunctions = ['before', 'after', 'below', 'above', 'inside', 'outside'];
      
      for (var i=0; i<conjunctions.length; i++) {
        (function () {
          var conjunction;
          
          conjunction = conjunctions[i];
          String.prototype[conjunctions[i]] = function (that) {
            return this + ' ' + conjunction + ' ' + that;
          };
        })();
      }
    }

This solves our problem, because adding a new function inside the for loop means that the closest function definition is inside the for loop, which is where the interpreter hoists the variable declaration.

The pattern of defining variables inside of an anonymous function that is immediately invoked is very useful. Amongst other things, it's handy for keeping the global namespace clean or creating private variables. And there's another way to use an anonymous function to create new variables. Here's a function that counts:

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

This binds `$` and `F` without conflicting with other libraries that may want to define `$` or `F` for their own purposes. The only trouble with structuring things as parameters is that in JavaScript, the definition of the parameter and the value it is passed can be a long way away from each other.

[<img src="http://1.bp.blogspot.com/_JrXOqYWNfjc/S0n5UufzeoI/AAAAAAAAB1I/Y5OpeIWPU2c/s1600/Fieldfare1_Arlesey_2010Jan10.jpg" height="427" width="500"/>][thrush]

**let's get closer**

If you prefer to keep your parameters closer to the values you are going to bind, we can use a JavaScript version of the [Thrush Combinator][thrushcombinator], `let`:

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

But the very best reason for using `let` is that [JavaScript 1.7 includes a `let` keyword][js17]! Knowing that you'll be using `let` eventually, why get in the habit now?

---

p.s. A proggit reader [brings up a good point][proggit]: *Closures* are a means of implementing *lexical scope*. Closures are an implementation mechanism, not a language feature.

p.p.s. There's an excellent discussion of variable hoisting in [this excellent article][answers].
	
NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[eee_closures]: http://japhr.blogspot.com/2010/10/gah-i-still-dont-know-closures.html
[thrushcombinator]: http://github.com/raganwald/homoiconic/blob/master/2008-10-30/thrush.markdown#readme
[js17]: https://developer.mozilla.org/en/New_in_JavaScript_1.7#let_statement
[thrush]: http://dansbirdingblog.blogspot.com/2010/01/urban-thrushes-whooper-and-nice-goose.html "Urban Thrushes, a Whooper, and a Nice Goose"
[proggit]: http://www.reddit.com/r/programming/comments/dn4ra/lets_make_closures_easy/c11fv9e
[answers]: http://www.nczonline.net/blog/2010/01/26/answering-baranovskiys-javascript-quiz/ "Answering Baranovskiy's JavaScript Quiz"