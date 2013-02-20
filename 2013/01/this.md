More than you ever wanted to know about "this" in JavaScript, Part I
====================================================================

*This is the first in a series of excerpts from the book [JavaScript Allongé][ja] on the common theme of "this," also known as "function context." [Part II is here](https://github.com/raganwald/homoiconic/blob/master/2013/01/function_and_method_decorators.md#function-and-method-decorators). The posts are intended to stand alone: There's no need to read the entire book to benefit from reading this material.*

[ja]: http://leanpub.com/javascript-allonge

### what is "this" and why do we need it?

In JavaScript, it's easy to make things that look and behave like objects without using function prototypes or "this." Here's a Queue:

```javascript
function QueueMaker () {
  var queue = {
    array: [], 
    head: 0, 
    tail: -1,
    pushTail: function (value) {
      return queue.array[queue.tail += 1] = value
    },
    pullHead: function () {
      var value;
      
      if (queue.tail >= queue.head) {
        value = queue.array[queue.head];
        queue.array[queue.head] = void 0;
        queue.head += 1;
        return value
      }
    },
    size: function () {
      return 1 + queue.tail - queue.head;
    }
  };
  return queue;
};

queue = QueueMaker();
queue.pushTail('Hello');
queue.pushTail('JavaScript');
queue.pushTail('Lovers');
queue.pullHead();
  //=> 'Hello'
```

Let's make a shallow copy of our queue using Underscore's `_.extend`:

```javascript
copyOfQueue = _.extend({}, queue);

queue !== copyOfQueue;
  //=> true
```
    
Wait a second. We know that array values are references. So it probably copied a reference to the original array. That would be bad! Let's make a copy of the array as well:

```javascript
copyOfQueue.array = [];
for (var i = 0; i < 2; ++i) {
  copyOfQueue.array[i] = queue.array[i];
}
```

Now let's pull the head off the original:

```javascript
queue.pullHead();
  //=> 'JavaScript'
```
      
If we've copied everything properly, we should get the exact same result when we pull the head off the copy:
   
```javascript   
copyOfQueue.pullHead();
  //=> 'Lovers'
```
      
What!? Even though we carefully made a copy of the array to prevent aliasing, it seems that our two queues behave like aliases of each other. The problem is that while we've carefully copied our array and other elements over, *the closures all share the same environment*, and therefore the functions in `copyOfQueue` all operate on the first queue's private data, not on the copies.

> This is a general issue with closures. Closures couple functions to environments, and that makes them very elegant in the small, and very handy for making opaque data structures. Alas, their strength in the small is their weakness in the large. When you're trying to make reusable components, this coupling is sometimes a hindrance.

Let's take an impossibly optimistic flight of fancy and redesign our queue:

```javascript 
function AmnesiacQueueMaker () {
  return {
    array: [], 
    head: 0, 
    tail: -1,
    pushTail: function (myself, value) {
      return myself.array[myself.tail += 1] = value;
    },
    pullHead: function (myself) {
      var value;
      
      if (myself.tail >= myself.head) {
        value = myself.array[myself.head];
        myself.array[myself.head] = void 0;
        myself.head += 1;
        return value;
      }
    },
    size: function (myself) {
      return 1 + myself.tail - myself.head;
    }
  }
};

queueWithAmnesia = AmnesiacQueueMaker();
queueWithAmnesia.pushTail(queueWithAmnesia, 'Hello');
queueWithAmnesia.pushTail(queueWithAmnesia, 'JavaScript');
```
    
The `AmnesiacQueueMaker` makes queues with amnesia: They don't know who they are, so every time we invoke one of their functions, we have to tell them who they are. You can work out the implications for copying queues as a thought experiment: We don't have to worry about environments, because every function operates on the queue you pass in.

The killer drawback, of course, is making sure we are always passing the correct queue in every time we invoke a function. What to do?

### what's all `this`?

Any time we must do the same repetitive thing over and over and over again, we industrial humans try to build a machine to do it for us. JavaScript is one such machine:

```javascript
function BanksQueueMaker () {
  return {
    array: [], 
    head: 0, 
    tail: -1,
    pushTail: function (value) {
      return this.array[this.tail += 1] = value;
    },
    pullHead: function () {
      var value;
      
      if (this.tail >= this.head) {
        value = this.array[this.head];
        this.array[this.head] = void 0;
        this.head += 1;
        return value;
      }
    },
    size: function () {
      return 1 + this.tail - this.head;
    }
  }
};

banksQueue = BanksQueueMaker();
banksQueue.pushTail('Hello');
banksQueue.pushTail('JavaScript');
```

Every time you invoke a function that is a member of an object, JavaScript binds that object to the name `this` in the environment of the function just as if it was an argument. Now we can easily make copies:

```javascript
copyOfQueue = _.extend({}, banksQueue);
copyOfQueue.array = [];
for (var i = 0; i < 2; ++i) {
  copyOfQueue.array[i] = banksQueue.array[i];
}
  
banksQueue.pullHead();
  //=> 'Hello'

copyOfQueue.pullHead();
  //=> 'Hello'
```

Presto, we now have a way to copy arrays. By getting rid of the closure and taking advantage of `this`, we have functions that are more easily portable between objects, and the code is simpler as well.

### more about "invoking a function that's a member of an object"

JavaScript binds "this" whenever you do this: `object.foo(...)`, or this: `object['foo'](...)`. But it doesn't bind "this" when you do this:

```javascript
var fn = object.foo;
fn(...);
```

Or this:

```javascript
var fn = object['foo'];
fn(...);
```

Watch out!

## What context applies when we call a function?

We just learned that when a function is called as an object method, the name `this` is bound in its environment to the object acting as a "receiver." For example:

```javascript
var someObject = {
  returnMyThis: function () {
    return this;
  }
};

someObject.returnMyThis() === someObject;
  //=> true
```
      
We've constructed a method that returns whatever value is bound to `this` when it is called. It returns the object when called, just as described.

### it's all about the way the function is called

JavaScript programmers talk about functions having a "context" when being called. `this` is bound to the context (Too bad the language binds the context to the name `this` instead of the name `context`!) The important thing to understand is that the context for a function being called is set by the way the function is called, not the function itself.

This is an important distinction. Consider closures: As we discussed repeatedly in blog posts and books about JavaScript, a function's free variables are resolved by looking them up in their enclosing functions' environments. You can always determine the functions that define free variables by examining the source code of a JavaScript program, which is why this scheme is known as [Lexical Scoping].

[Lexical Scope]: https://en.wikipedia.org/wiki/Scope_(computer_science)#Lexical_scoping

A function's context cannot be determined by examining the source code of a JavaScript program. Let's look at our example again:

```javascript
var someObject = {
  someFunction: function () {
    return this;
  }
};

someObject.someFunction() === someObject;
  //=> true
```
    
What is the context of the function `someObject.someFunction`? Don't say `someObject`! Watch this:

```javascript
var someFunction = someObject.someFunction;

someFunction === someObject.someFunction;
  //=> true

someFunction() === someObject;
  //=> false
```
      
It gets weirder:

```javascript
var anotherObject = {
  someFunction: someObject.someFunction;
}

anotherObject.someFunction === someObject.someFunction;
  //=> true
  
anotherObject.someFunction() === anotherObject;
  //=> true
  
anotherObject.someFunction() === someObject;
  //=> false
```
      
So it amounts to this: The exact same function can be called in two different ways, and you end up with two different contexts. If you call it using `someObject.someFunction()` syntax, the context is set to the receiver. If you call it using any other expression for resolving the function's value (such as `someFunction()`), you get something else. Let's investigate:

```javascript
(someObject.someFunction)() == someObject;
  //=> true
  
someObject['someFunction']() === someObject;
  //=> true
  
var name = 'someFunction';

someObject[name]() === someObject;
  //=> true
```

Interesting!

```javascript
var baz;

(baz = someObject.someFunction)() === this;
  //=> true
```
      
How about:

```javascript
var arr = [ someObject.someFunction ];

arr[0]() === arr;
  //=> true
```
    
It seems that whether you use `a.b()` or `a['b']()` or `a[n]()` or `(a.b)()`, you get context `a`. 

```javascript
var returnThis = function () { return this; };

var aThirdObject = {
  someFunction: function () {
    return returnThis();
  }
}

returnThis() === this;
  //=> true

aThirdObject.someFunction() === this;
  //=> true
```
      
And if you don't use `a.b()` or `a['b']()` or `a[n]()` or `(a.b)()`, you get the global environment for a context, not the context of whatever function is doing the calling. To simplify things, when you call a function with `.` or `[]` access, you get an object as context, otherwise you get the global environment.

### setting your own context

There are actually two other ways to set the context of a function. And once again, both are determined by the caller. As you probably know, everything in JavaScript behaves like an object, including functions. Functions have methods themselves, and one of them is `call`.

Here's `call` in action:

```javascript
returnThis() === aThirdObject;
  //=> false

returnThis.call(aThirdObject) === aThirdObject;
  //=> true
  
anotherObject.someFunction.call(someObject) === someObject;
  //=> true
```
      
When you invoke a function with `call`, you set the context by passing it in as the first parameter. Other arguments are passed to the function in the normal manner. Much hilarity can result from `call` shenanigans like this:

```javascript
var a = [1,2,3],
    b = [4,5,6];
    
a.concat([2,1]);
  //=> [1,2,3,2,1]
  
a.concat.call(b,[2,1]);
  //=> [4,5,6,2,1]
```
      
But now we thoroughly understand what `a.b()` really means: It's synonymous with `a.b.call(a)`. Whereas in a browser, `c()` is synonymous with `c.call(window)`.

### apply, arguments, and contextualization

JavaScript has another automagic binding in every function's environment. `arguments` is a special object that behaves a little like an array (Just enough to be frustrating, to be perfectly candid!)

For example:

```javascript
var third = function () {
  return arguments[2];
}

third(77, 76, 75, 74, 73);
  //=> 75
```

Hold that thought for a moment. JavaScript also provides a fourth way to set the context for a function. `apply` is a method implemented by every function that takes a context as its first argument, and it takes an array or array-like thing of arguments as its second argument. That's a mouthful, let's look at an example:

```javascript
third.call(this, 1,2,3,4,5);
  //=> 3

third.apply(this, [1,2,3,4,5]);
  //=> 3
```
      
Now let's put the two together. Here's another travesty:

```javascript
var a = [1,2,3],
    accrete = a.concat;
    
accrete([4,5]);
  //=> Gobbledygook!
```

We get the result of concatenating `[4,5]` onto an array containing the global environment. Not what we want! Behold:

```javascript
var contextualize = function (fn, context) {
  return function () {
    return fn.apply(context, arguments);
  }
};

accrete = contextualize(a.concat, a);
accrete([4,5]);
  //=> [ 1, 2, 3, 4, 5 ]
```
      
Our `contextualize` function returns a new function that calls a function with a fixed context. It can be used to fix some of the unexpected results we had above. Consider:

```javascript
var aFourthObject = {
      uncontextualized: function () {
        return this;
      },
      contextualized: function(context) {
        return contextualize(function (context) {
            return this;
        }, context)
      }
    },
    a = aFourthObject.uncontextualized,
    b = aFourthObject.contextualized(aFourthObject);
    
a() === aFourthObject;
  //=> false

b() === aFourthObject;
  //=> true
```
      
Wrapping a function so that it has a fixed context is called *binding* a function's context. There are various ways to bind a context and also to *avoid* binding a context for a function. We'll discuss binding in more detail in part II, but for now, consider the function combinator `compose`:

```javascript
function compose (fn1, fn2) {
  return function compose_ (something) {
    return fn1(fn2(something));
  }
}

function add1 (n) { return n + 1 };

function times3 (n) { return n * 3 };

var collatz = compose(add1, times3);

collatz(5);
  //=> 16
```

Works just fine with "pure" functions. Let's try it with something a little more complicated, our queue. Let's say we have a wonderful, brilliant, amazing idea. We want to leave queues working just fine, but we're going to modify one queue to always return the size of the queue after pushing or pulling things. And while we're engaging in our flight of fancy, we'll use `compose` to do it:

```javascript
function BanksQueueMaker () {
  return {
    array: [], 
    head: 0, 
    tail: -1,
    pushTail: function (value) {
      return this.array[this.tail += 1] = value;
    },
    pullHead: function () {
      var value;
      
      if (this.tail >= this.head) {
        value = this.array[this.head];
        this.array[this.head] = void 0;
        this.head += 1;
        return value;
      }
    },
    size: function () {
      return 1 + this.tail - this.head;
    }
  }
};

var queue = BanksQueueMaker();

queue.pushTail = compose(queue.size, queue.pushTail);
queue.pullHead = compose(queue.size, queue.pullHead);

queue.pushTail('Hello');
  //=> TypeError: Cannot set property 'NaN' of undefined
```

The problem with our `compose` method is that it took functions that expected a context and called them without a context. We can rewrite it:

```javascript
function compose (fn1, fn2) {
  return function compose_ (something) {
    return fn1.call(this, fn2.call(this, something));
  }
}

queue = BanksQueueMaker();

queue.pushTail = compose(queue.size, queue.pushTail);
queue.pullHead = compose(queue.size, queue.pullHead);

queue.pushTail('Hello');
  //=> 1
```

Now it works. In Part II, we'll take a much closer look at writing functions that are "context-agnostic" like our second version of `compose`, and we'll take a closer look at objects and methods.

> Now the obvious question is, why did we want to do that? And if we did want to do that, why did we use compose? Well, we're working with a blog post and it's easier to work with the methods in front of us than introduce an entirely new use case. But if you look at libraries like [Underscore][u] or [allong.es], you'll see plenty of functions designed to be composed with methods, like `once`, `debounce`, `throttle`, `fluent`, and so forth.

[u]:http://underscorejs.org
[allong.es]: http://allong.es

## Summary of Part I

You don't strictly *need* "this" to encapsulate data in objects, but "this" gives you the flexibility to share functions between objects. "this" is automatically set by JavaScript when you call a function in a method-calling style, or when you use `.call` or `.apply` to call a function. This can be used to force the context for a function, which is called *binding* the context to a function. In some cases, you want to write helper functions and combinators in a context-agnostic style.

Thanks for being patient enough to read the whole thing!

([discuss](http://www.reddit.com/r/javascript/comments/179j51/more_than_you_ever_wanted_to_know_about_this_in/))

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)][ja]![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)][cr]![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé][ja], [CoffeeScript Ristretto][ja], and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code. 

[ja]: http://leanpub.com/javascript-allonge "JavaScript Allongé"
[cr]: http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto"

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

