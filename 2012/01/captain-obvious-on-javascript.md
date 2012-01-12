# Captain Obvious on JavaScript

In JavaScript, anywhere you find yourself writing:

```javascript
function (x) { return foo(x); }
```
  
You can [usually][awb] substitute just `foo`. For example, this code:

[awb]: http://www.wirfs-brock.com/allen/posts/166 "A JavaScript Optional Argument Hazard"

```javascript
var floats = someArray.map(function (value) {
  return parseFloat(value);
});
```
  
Could be written:

```javascript
var floats = someArray.map(parseFloat);
```
  
This understanding is *vital*. Without it, you can be led astray into thinking that this code:

```javascript
array.forEach(function (element) {
  // do something
});
```
  
...Is just a funny way of writing a for loop. It's not!

`forEach` isn't a way of saying "Do this thing with every member of `array`." No, `forEach` is an array method that takes a function as an argument, so this code is a way of saying "Apply every member of `array` to this function". You can pass `forEach` a function literal (as above), a variable name that resolves to a function, even an expression like `myObject.methodName` that looks like a method but is really a function defined in an object's prototype.

Once you have internalized the fact that *any* function will do, you can refactor code to clear out the cruft. This example uses [Jquery][j] in the browser:

[j]: http://jquery.org

```javascript
$('input').toArray().map(function (domElement) {
  return parseFloat(domElement.value);
})
```
  
Let's turn that into:

```javascript
$('input').toArray()
  .map(function (domElement) {
    return domElement.value;
  })
  .map(function (value) {
    return parseFloat(value);
  })
```
  
And thus:

```javascript
$('input').toArray()
  .map(function (domElement) {
    return domElement.value;
  })
  .map(parseFloat)
```
Once you get started turning function literals into other expressions, you can't stop. The next step on the road to addiction is using functions that return functions:

```javascript
function get (attr) {
  return function (object) { return object[attr]; }
}
```

Which permits us to write:

```javascript
$('input').toArray()
  .map(get('value'))
  .map(parseFloat)
```
  
Which really means, "Get the `.value` from every `input` DOM element, and map the `parseFloat` function over the result."

## a step in the right direction

Obviously, this last example involves creating a new function and iterating *twice* over the array. Avoiding the extra loop may be an important performance optimization. Then again, it may be premature optimization. Captain Obvious says: "*These are not examples of things you should do, these are examples of things you should understand how to do and why they work.*"

Once you inderstand them, it might occur to you that the `.sequence` method from Oliver Steele's [Functional javaScript][fj] library will be useful:

[fj]: http://osteele.com/sources/javascript/functional/

```javascript
$('input').toArray()
  .map(
    Functional.sequence(
      get('value'),
      parseFloat
    )
  )
```

`Functional.sequence` composes two or more functions in the argument order (Functional Javascript also provides `.compose` to compose multiple functions in applicative order). For the purpose of this post, they could be defined something like this:

```javascript
var naiveSequence = function (a, b) {
  return function (c) { 
    return b(a(c));
  };
}

var naiveCompose = function (a, b) {
  return function (c) { 
    return a(b(c));
  };
}
```

(`Functional.sequence` and `Functional.compose` are far more thorough than these naive examples, of course.)

Now the code iterates over the array just once, mapping it to the composition of the two functions while still preserving the new character of the code where the elements of an expression have been factored into separate functions. Is this better than the original? It is if you want to refactor the code to do interesting things like memoize one of the functions. But that is no longer obvious.

What *is* obvious is that JavaScript is a functional language, and the more ways you have of factoring expressions into functions, the more ways you have of organizing your code to suit your own style, performance, or assignment of responsibility purposes.

p.s. Captain Obvious would not write such excellently plain-as-the-nose-on-his-face posts without the help of people like [@jcoglan](https://twitter.com/#!/jcoglan), [@CrypticSwarm](https://twitter.com/#!/CrypticSwarm), [@notmatt](https://twitter.com/#!/notmatt), [@cammerman](https://twitter.com/#!/cammerman), [Skyhighatrist](http://www.reddit.com/user/Skyhighatrist), and [@BrendanEich](https://twitter.com/#!/BrendanEich).

[pi]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/parseInt
[pf]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/parseFloat

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one e-book.
* [What I've Learned From Failure](http://leanpub.com/shippingsoftware), my very best essays about getting software from ideas to shipping products, collected into one e-book.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://reginald.braythwayt.com) | [@raganwald](http://twitter.com/raganwald)