# Classes vs. Prototypes in JavaScript

*From time to time people mention that they've heard that JavaScript doesn't have classes, that it uses "prototypical inheritance," and what is the difference between class-based inheritance and prototype-based inheritance?*

---

Although each "object-oriented" programming language has its own particular set of semantics, the majority in popular use have "classes." A class is an entity responsible for creating objects and defining the behaviour of objects. Classes may be objects in their own right, but if they are, they're different from other types of objects. For example, the `String` class in Ruby is not itself a string, it's an object whose class is `Class`. All objects in a "classical" system have a class, and their class is a "class."

That sounds tautological, until we look at JavaScript. But let's start with a quick review of a popular classist language, Ruby.

### ruby

In Ruby, classes are objects, but they're special objects. For example, here are some of the methods associated with the Ruby class `String`:

```ruby
String.methods
  #=> [:try_convert, :allocate, :new, :superclass, :freeze, :===, :==,
       :<=>, :<, :<=, :>, :>=, :to_s, :included_modules, :include?, :name, 
       :ancestors, :instance_methods, :public_instance_methods, 
       :protected_instance_methods, :private_instance_methods, :constants, 
       :const_get, :const_set, :const_defined?, :const_missing, 
       :class_variables, :remove_class_variable, :class_variable_get, 
       :class_variable_set, :class_variable_defined?, :public_constant, 
       :private_constant, :module_exec, :class_exec, :module_eval, :class_eval, 
       :method_defined?, :public_method_defined?, :private_method_defined?, 
       :protected_method_defined?, :public_class_method, :private_class_method, 
       # ...
       :!=, :instance_eval, :instance_exec, :__send__, :__id__] 
```

And here are some of the methods associated with an instance of a string:

```ruby
String.new.methods
  #=> [:<=>, :==, :===, :eql?, :hash, :casecmp, :+, :*, :%, :[],
       :[]=, :insert, :length, :size, :bytesize, :empty?, :=~,
       :match, :succ, :succ!, :next, :next!, :upto, :index, :rindex,
       :replace, :clear, :chr, :getbyte, :setbyte, :byteslice,
       :to_i, :to_f, :to_s, :to_str, :inspect, :dump, :upcase,
       :downcase, :capitalize, :swapcase, :upcase!, :downcase!,
       :capitalize!, :swapcase!, :hex, :oct, :split, :lines, :bytes,
       :chars, :codepoints, :reverse, :reverse!, :concat, :<<,
       :prepend, :crypt, :intern, :to_sym, :ord, :include?,
       :start_with?, :end_with?, :scan, :ljust, :rjust, :center,
       # ...
       :instance_eval, :instance_exec, :__send__, :__id__]
```

As you can see, a "class" in Ruby is very different from an "instance of that class." And the methods of a class are very different from the methods of an instance of that class.

Here's how you define a Queue in Ruby:

```ruby
class Queue
  def initialize
    @array, @head, @tail = [], 0, -1
  end
  
  def pushTail value
    @array[@tail += 1] = value
  end
  
  def pullHead
    if !@isEmpty
      @array[@head].tap { |value|
        @array[@head] = nil
        @head += 1
      }
    end
  end
  
  def isEmpty
    @tail < @head
  end
end
```

There is special syntax for defining a class, and special syntax for defining the behaviour of instances. There are different ways of defining the way new instances are created in classist languages. Ruby uses a "magic method" called `initialize`. Now let's look at JavaScript.

### javascript has constructors and prototypes

JavaScript objects don't have a formal class, and thus there's no special syntax for defining how to create an instance or define its behaviour.

JavaScript instances are created with a *constructor*. The constructor of an instance is a function that was invoked with the `new` operator. In JavaScript, any function can be a constructor, even if it doesn't look like one:

```javascript
function square (n) { return n * n; }
  //=> undefined
square(2)
  //=> 4
square(2).constructor
  //=> [Function: Number]
new square(2)
  //=> {}
new square(2).constructor
  //=> [Function: square]
```

As you can see, the `square` function will act as a constructor if you call it with `new`. *There is no special kind of thing that constructs new objects, every function is (potentially) a constructor*.

That's different from a true classical language, where the class is a special kind of object that creates new instances.

How does JavaScript define the behaviour of instances? JavaScript doesn't have a special syntax or special kind of object for that, it has "prototypes." Prototypes are objects, but unlike a classical system, there are no special methods or properties associated with a prototype. Any object can be a prototype, even an empty object. In fact, that's exactly what is associated with a constructor by default:

```javascript
function Nullo () {};
Nullo.prototype
  //=> {}
```
      
There's absolutely nothing special about a prototype object. No special class methods, no special constructor of its own, nothing. Let's look at a simple Queue in JavaScript:

```javascript
var Queue = function () {
  this.array = [];
  this.head = 0;
  this.tail = -1;
};
  
Queue.prototype.pushTail = function (value) {
  return this.array[this.tail += 1] = value;
};
Queue.prototype.pullHead = function () {
  var value;
  
  if (!this.isEmpty()) {
    value = this.array[this.head];
    this.array[this.head] = void 0;
    this.head += 1;
    return value;
  }
};
Queue.prototype.isEmpty = function () {
  return this.tail < this.head;
};

Queue.prototype
  //=>  { pushTail: [Function],
  //=>    pullHead: [Function],
  //=>    isEmpty: [Function] }
```

The first way a prototype in JavaScript is different from a class in Ruby is that the prototype is an ordinary object with exactly the same properties that we expect to find in an instance: Methods `pushTail`, `pullHead`, and `isEmpty`.

The second way is that *any* object can be a prototype. It can have functions (which act like methods), it can have other values (like numbers, booleans, objects, or strings). It can be an object you're using for something else: An account, a view, a DOM object if you're in the browser, anything.

"Classes" are objects in most "classical" languages, but they are a special kind of object. In JavaScript, prototypes are not a special kind of object, they're just objects.

### summary of the difference between classes and prototypes

A class in a formal classist language can be an object, but it's a special kind of object with special properties and methods. It is responsible for creating new instances and for defining the behaviour of instances.

Instance behaviour in a classist language is defined with special syntax. If changes are allowed dynamically, they are done with special syntax and/or special methods invoked on the class.

JavaScript splits the responsibility for instances into a constructor and a prototype. A constructor in JavaScript can be any function. Constructors are responible for creating new instances.

A prototype in JavaScript can be any object. Prototypes are responsible for defining the behaviour of instances. prototypes don't have special methods or properties.

Instance behaviour in JavaScript is defined by modifying the prototype directly, e.g. by adding functions to it as properties. There is no special syntax for defining a class or modifying a class.

### so why do some people say that javascript has "classes" for some definition of "class?"

Because, **if**:

1. You use a function as a constructor, and;
2. You use a prototype for defining instance methods, and;
3. The prototype is used strictly for defining the instance methods and nothing else;

**Then**:

You will have something that works just like a simple class-based system, with the constructor function and its prototype acting as the "class."

But if you want more, you have a flexible system that does allow you to do [much much more][fd]. It's up to you.

([discuss](http://www.reddit.com/r/javascript/comments/17v813/classes_vs_prototypes_in_js/))

[fd]: https://github.com/raganwald/homoiconic/blob/master/2013/01/function_and_method_decorators.md#function-and-method-decorators "Function and Method Decorators"

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

