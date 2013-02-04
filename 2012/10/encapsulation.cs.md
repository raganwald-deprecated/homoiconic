Encapsulating State in CoffeeScript
===================================

(click [here](https://github.com/raganwald/homoiconic/blob/master/2012/10/encapsulation.js.md) for examples in JavaScript)

---

> OOP to me means only messaging, local retention and protection and hiding of state-process, and extreme late-binding of all things.--[Alan Kay][oop]

[oop]: http://userpage.fu-berlin.de/~ram/pub/pub_jf47ht81Ht/doc_kay_oop_en

In CoffeeScript, an object is fundamentally the same thing as what other programming languages call (variously) maps, dictionaries, records, structs, frames, or what-have-you. Sure, there is some support for prototypes and there is some support for building what look like classes. But at their heart, CoffeeScript objects are simple yet flexible and powerful.

As an example of how powerful they can be without the extra support for "classes," we're going to look at encapsulation using CoffeeScript's objects. We're not going to call it "object-oriented programming," mind you, because that would start a long debate. This is just plain encapsulation([1](#notes)), with a dash of information-hiding.

### bundling functions with data

The key characteristic of encapsulation is bundling data with functions that operate on the data. Consider a [stack]. There are three basic operations: pushing a value on, popping a value off, and testing to see whether the stack is empty or not.

[stack]: https://en.wikipedia.org/wiki/Stack_(data_structure)

We can create a stack quite easily with an object containing an array and an index([2](#notes)):

```coffeescript
stack =
  array: []
  index: -1
push = (value) ->
  stack.array[stack.index += 1] = value
pop = ->
  do (value = stack.array[stack.index]) ->
    stack.index -= 1 if stack.index >= 0
    value
isEmpty = ->
  stack.index < 0
```
      
Bundling the functions with the data does not require any special "magic" features. CoffeeScript objects can have elements of any type, including functions:

```coffeescript
stack = do (obj = undefined) ->
  obj =
    array: []
    index: -1
    push: (value) ->
      obj.array[obj.index += 1] = value
    pop: ->
      do (value = obj.array[obj.index]) ->
        obj.index -= 1 if obj.index >= 0
        value
    isEmpty: ->
      obj.index < 0

stack.isEmpty()
  #=> true
stack.push('hello')
  #=> 'hello'
stack.push('CoffeeScript')
 #=> 'CoffeeScript'
stack.isEmpty()
  #=> false
stack.pop()
 #=> 'CoffeeScript'
stack.pop()
 #=> 'hello'
stack.isEmpty()
  #=> true
```

### hiding state

Our stack does bundle functions with data, but it doesn't hide its state. "Foreign" code could interfere with its array or index. So how do we hide these? We already have a closure, let's use it:

```coffeescript
stack = do (array = [], index = -1) ->
  push: (value) ->
    array[index += 1] = value
  pop: ->
    do (value = array[index]) ->
      array[index] = undefined
      index -= 1 if index >= 0
      value
  isEmpty: ->
    index < 0

stack.isEmpty()
  #=> true
stack.push('hello')
  #=> 'hello'
stack.push('CoffeeScript')
 #=> 'CoffeeScript'
stack.isEmpty()
  #=> false
stack.pop()
 #=> 'CoffeeScript'
stack.pop()
 #=> 'hello'
stack.isEmpty()
  #=> true
```

We don't want to repeat this code every time we want a stack, so let's make ourselves a "stack maker:"

```coffeescript
StackMaker = ->
  do (array = [], index = -1) ->
    push: (value) ->
      array[index += 1] = value
    pop: ->
      do (value = array[index]) ->
        array[index] = undefined
        index -= 1 if index >= 0
        value
    isEmpty: ->
      index < 0

stack = StackMaker()
```

The stack maker is nothing more than a function that returns a new stack for us. Now we can make stacks freely, and we've hidden their internal data elements. We have methods and encapsulation, and we've built them out of CoffeeScript's fundamental functions and objects. No extra language support is required, because basic objects, functions, and closures are powerful features that can be combined to build almost any data structure we require.

### question: is encapsulation "object-oriented?"

We've built something with hidden internal state and "methods," all without needing special `def` or `private` keywords. Mind you, we haven't included all sorts of complicated mechanisms to support inheritance, mixins, and other opportunities for debating the nature of the One True Object-Oriented Style on the Internet.

So some would say "Yes," while others would say, "Perhaps technically, but not as most programmers expect, so it's No Damn Good." Then again, the key lesson experienced programmers repeat (although it often falls on deaf ears) is, [Composition instead of Inheritance](http://www.c2.com/cgi/wiki?CompositionInsteadOfInheritance).

So maybe we aren't missing much.

(Discuss on [hacker news](http://news.ycombinator.com/item?id=4693246) and [/r/coffeescript](http://www.reddit.com/r/coffeescript/comments/11ysax/encapsulation_in_coffeescript/). This essay appears in slightly different form in the upcoming book [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto).)

---

Notes
---

1. *Encapsulation*: "A language construct that facilitates the bundling of data with the methods (or other functions) operating on that data."--[Wikipedia]
2. Yes, there's a far superior way to track the size of the array, but we don't need it to demonstrate encapsulation and hiding of state, and this gives us an excuse to demonstrate how to manage complex state involving multiple values.

[Wikipedia]: https://en.wikipedia.org/wiki/Encapsulation_(object-oriented_programming)

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