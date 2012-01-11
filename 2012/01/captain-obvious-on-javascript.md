# Captain Obvious on JavaScript

In JavaScript, anywhere you find yourself writing:

```javascript
function (x) { return foo(x); }
```
  
You can just as easily write `foo`. For example, this code:

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

Obviously, this last example involves creating a new function and iterating *twice* over the array. Avoiding the extra loop may be an important performance optimization. Then again, it may be premature optimization. Captain Obvious says: "*These are not examples of things you should do, these are examples of things you should understand how to do and why they work.*"

p.s. For extra credit, rewrite this example to use [parseInt][pi] instead of [parseFloat][pf]. Does it work as advertised? Why? Why not?

[pi]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/parseInt
[pf]: https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/parseFloat

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one e-book.
* [What I've Learned From Failure](http://leanpub.com/shippingsoftware), my very best essays about getting software from ideas to shipping products, collected into one e-book.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.