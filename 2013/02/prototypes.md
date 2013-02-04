# Classes vs Prototypes in JavaScript

*From time to time people mention that they're heard that JavaScript doesn't have classes, that it uses "prototypical inheritance," and what is the difference between class-based inheritance and prototype-based inheritance?*

---

Although each "object-oriented" programming language has its own particular set of semantics, the majority in popular use have "classes." A class is an entity responsible for creating objects and defining the behaviour of objects. Classes may be objects in their own right, but if they are, they're different from other types of objects. For example, the `String` class in Ruby is not itself a string, it's an object whose class is `Class`.

All objects in a "classical" system have a class, and their class is a class. That sounds tautological, until we look at JavaScript. JavaScript objects don't have a class. There's a "type" you can query with `typeof` and there's a `constructor`.

The constructor of an object, as we've learned, is a function that was invoked with the `new` operator. In JavaScript, any function can be a constructor, even if it doesn't look like one:

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

As you can see, the `square` function will act as a constructor if you call it with `new`. There is no special kind of thing that constructs new objects, every function is (potentially) a constructor.

What about prototypes? Well, again JavaScript differs from a "classical" system like Ruby. In Ruby, classes are objects, but they're special objects. For example, here are the methods associated with the Ruby class `String`:

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

And here are the methods associated with an instance of a string:

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

In JavaScript, prototypes are also objects, but unlike a classical system, there are no special methods or properties associated with a prototype. Any object can be a prototype, even an empty object. In fact, that's exactly what is associated with a constructor by default:

    function Nullo () {};
    Nullo.prototype
      //=> {}
      
There's absolutely nothing special about a prototype object. No special class methods, no special constructor of its own, nothing. Here's some proof that *anything* can be a prototype:

    function Weird (name) {
      if (name) {
        this.name = name;
      }
    };
    Weird.prototype = new Weird('Arthur');
    var empty = new Weird();
      //=> {}
    empty.name;
      //=> 'Arthur'

Yes, we just made a constructor and used it to make its own prototype. You can't do that in Ruby.

### summary of the difference between classes and prototypes

A class in a formal classist language can be an object, but if it is it's a special kind of object with special properties and methods. For example, if you're allowed to dynamically define a new method, you do so by calling a method on the class.

A constructor in JavaScript is any function. A prototype in JavaScript is any object, any object whatsoever. It can be something you're using elsewhere or a new object just for working with this constructor. You can change it by assigning a new object to the constructor's `prototype` property. You add and remove properties or methods by assigning them to the object just like any other object--because it is any other object.

### so why do some people say that javascript has "classes" for some definition of "class?"

Because if you are disciplined and assign only functions to a prototype object, and if those functions use `this` to work with an instance, and if you set up a prototype chain when you want inheritance, you have something that works just like a simple class-based system.

But if you want more, you have a flexible system that does allow you to do more. It's up to you.

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)][ja]![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code. 

[ja]: http://leanpub.com/javascript-allonge "JavaScript Allongé"

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)