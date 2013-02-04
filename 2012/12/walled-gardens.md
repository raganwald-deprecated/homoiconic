# Programming's Walled Gardens

This essay is about my own personal programming anti-pattern. Well, not personal in the sense of me being the only person who does this, but personal in the sense of this being a recurring problem for me. I call this anti-pattern **The Walled Garden**. A "Walled Garden" is a web site or application that lives within an interoperable, open ecosystem but nevertheless provides a collection of proprietary tools and services that have very limited interaction with the open, free standards outside.

[![Entrance to the old walled garden.. by ronsaunders47, on Flickr](http://farm9.staticflickr.com/8209/8200129155_31c282579e.jpg)](http://www.flickr.com/photos/ronsaunders47/8200129155/)

Walled garden entice programmers in with glittering advantages over free alternatives, and they choose the walled garden out of a practical need to have the best tools at that moment in time.

But it's just a moment in time, or perhaps a window. In time, the open, free alternatives catch up to and eventually surpass the tools provided inside the garden, however users find it difficult to leave because of some lock-in effect such as all the other users in the garden, or data that is in proprietary formats. Gradually the garden lags the open marketplace. Development slows, leaving the trapped users stuck in an unproductive, difficult environment.

### walled gardens in the marketplace

Proprietary walled gardens in software development are easy to spot. In the 1980s, there was a huge category of development environments called "4GLs." They were integrated systems that included a database of some sort, a visual designer, a proprietary scripting language, and some kind of distribution runtime or compiler mechanism. They were very good for putting together small business applications.

I used one called [4th Dimension](http://www.4d.com) to create software that managed classified advertising for desktop publishers. Apple's HyperCard was discontinued, but now lives on as [Runtime Revolution](http://www.runrev.com) in mobile devices. I remember building a configuration wizard for some shrink-wrapped software with it. I had a cross-platform desktop app with a GUI running in less than an hour.

Rumour has it that the largest ecosystem for programmers is Microsoft Excel. Access probably isn't far behind. And there's some thingummy called Flash that people seem to like when they want to break your browser, make undeletable tracking cookies, or inject a virus into your operating system.

> Please note that I am not talking about developing for a platform, like developing for iPhone as opposed to developing for the "mobile web." I'm talking about the tools used to do the development. It's very easy to have walled garden tools that target an open platform. Runtime Revolution, for example, can deliver Unix applications. 

These commercial walled gardens are easy to spot. It's difficult to call them an anti-pattern: They help people make things people like. Eventually the free market catches up to these things, but in 1988 it was no good sticking your nose up in the air and telling everyone to write classified advertising software in C++.

![Modify Style in Tableau](http://i.minus.com/iobFOZr9kZLZ9.gif)

So you have to, as Sean Kelly would say, "Make the calculation," and decide for yourself if the ease of use today trumps the eventual dead end your software will fall into. If so, you may choose to build for the walled garden. The calculation is plain, and one of the reasons most people stop to at least think about the consequences of developing for a walled garden is that it is very clear that you are developing for someone else's walled garden. You may decide it's a good idea, you may decide to do something else, but you're keenly aware that you are adding a dependency on some other organization to your software.

> ### digression: the economics of a walled garden

> Walled gardens in development function just like any library, platform, or abstraction. They offer some benefit, such as being able to perform database queries using SQL. In exchange, you must learn their interface. You must learn where their abstraction "leaks." And somebody must maintain the walled garden's implementation. In the case of a commercial walled garden, it's the vendor. 

### walling yourself in

Although I have used commercial walled gardens, I don't consider that an anti-pattern. The anti-pattern is where you build *yourself* a walled garden. Meaning, you are designing a piece of software and you build yourself a platform for building the software.

Like commercial walled gardens, you are trading understanding your platform's interface and leaky abstraction for some benefits in your code. Unlike commercial walled gardens, you retain the obligation to maintain your own walled garden infrastructure. Sometimes, you can slough off this obligation by turning your walled garden into successful open source, gaining "many eyes" for finding and fixing bugs, tutorials and screencasts for explaining the abstraction, and so forth. This is what happened to HAML, Ruby on Rails and Backbone.js.

But typically, they do not escape to the outside world and become an extra layer of complexity in your architecture. Someone learning to work with your code (like you after a long absence) must learn the application, the domain, *and* your platform. Unlike popular platforms, your platform does not benefit from having "many eyes" making its bugs shallow. There are no screencasts or books explaining how to use it. Nothing in StackOverflow. It exists in its own tiny bubble, lagging further and further behind the state of the art in the open development world with every passing day.

The risks of building your own walled garden are very high. Most do not get adopted by the outside world. Open source is a lottery, a cruel and capricious one. Even good software can be passed over. You must tirelessly market your code, and even then you may get steamrollered.

I would never do this, I would never build a substantial application on top of a home-brewed framework. Or rather, [once bitten](https://github.com/raganwald-deprecated/faux "Faux"), twice shy.

The last statement was made in jest. I probably will do it again, but I will be mindful of the consequences. I am reminded of something that the startup world often talks about. When looking at an idea, they ask: "Is this a company? A product? Or a feature?" Companies can be built. Products are usually flipped quickly. Features rarely survive.

> One strategy for building a "product" walled garden instead of a feature is to align your walled garden carefully with some unique aspect of the application's domain. Every line of code that is a cross-cutting, general concern for all applications is probably wasted. Every line of code that is specific to this application or its niche is generally valuable.

> Domain-Specific Languages often fit this bill. For example, you might have an incredibly complicated kind of logic for configuring build-to-order tract houses.  A rules engine that manages the logic and interprets a DSL might be a good bet. Building a visual code editor for that language is probably not.

When it comes to frameworks, I often see an entire framework built around what really ought to be a feature or plugin in another framework. It's generally not worth trying to build a framework just to get a feature. Even if it's an awesome, must-have feature. If you're going to buy yourself a lottery ticket, make it a really good ticket. Make sure your walled garden offers something so integral to the application you are building that it's a real product.

### that insidious wyrm

In my own case, I have a particular weakness for a subtle form of walled garden. I like meta-programming. I like writing libraries that help me write code. Sometimes these are just libraries that help me write code. Sometimes these are walled gardens.

Obviously, every time we build an abstraction of some kind, there are the same economics of investment as walled gardens in some sense. There's a cost to learning the abstraction, a benefit to employing it, and a cost to maintain the abstraction. (Martin Fowler has made this point repeatedly.)

In JavaScript your code may be littered with `var that = this;`, which you are using to fix the context for callbacks. That was once very fine style and is still needed in some cases where you must manage older browsers. But in most cases `Function.prototype.bind` is now the right way to solve the problem. (If you program in JavaScript and have no idea what I'm talking about, may I recommend an [excellent book](http://leanpub.com/javascript-allonge) that covers function contexts in detail?) The point being, every abstraction is subject to obsolescence.

So what makes some abstractions walled gardens and others not? One of the things we identify about the walled garden is the wall itself. Things inside the garden do not interoperate smoothly with things outside of the garden. An idiom like `var that = this;` may no longer be ideal, but it doesn't break any behaviour of functions in JavaScript. It isn't a walled garden.

![Code from recusiveuniver.se](http://i.minus.com/iU6Re7cxuZNjZ.png)

### case study: youaredachef

Let's look at an abstraction that evolved from an idiosyncratic piece of meta programming into a walled garden, a library I wrote called [YouAreDaChef](https://github.com/raganwald/YouAreDaChef)

I wrote YouAreDaChef to implement [aspect-oriented programming](https://en.wikipedia.org/wiki/Aspect-oriented_programming) in the style of [Lisp Flavors]. My requirement was that I wanted to write [a HashLife implementation of Conway's Game of Life](http://recursiveuniver.se). The special design feature was that I wanted to write it in a series of files, where each file depended only on the preceding file, like this: "A" depends on "B" which depends on "C" which depends on "D" which depends on "E" and so forth. In other words, the dependency graph was to be a list.

My implementation used objects, and each file "monkey-patched" the existing set of classes and methods to add new functionality. Therefore, no file knew anything about the files "downstream" and in fact would function just fine without them. For example, you can run the engine just fine without garbage collection. It will be faster but not work for patterns with high runtime complexity.

To simplify all this "monkey-patching," I wrote YouAreDaChef. Instead of writing things like:

```javascript
var __oldInitialzie = Square.RecursivelyComputable.prototype.initialize;

Square.RecursivelyComputable.prototype.initialize = function () {
  var value = __oldInitialize.apply(this, arguments);
  this.references = 0;
  return value
}
```
I wrote things like:
 
```javascript
YouAreDaChef(
  Square.RecursivelyComputable.prototype.initialize
).after('initialize', function () { this.references = 0 });
```
 
This actually worked well in the code, and so far I had written myself a meta-programming tool of sorts. Although it looks weird and we can debate the benefits of AOP all day long, everything it did was still 100% JavaScript. There was no wall. The acid test is, I could have taken that code and mixed it with other tools like [Method Combinators](https://github.com/raganwald/method-combinators) just fine.

But then I became possessed with a desire for some kind of intellectual purity. I decided that in order to be "correct," YouAreDaChef had to handle inheritance.  Let's say some method had some after advice, like we saw above. What happens if we inherit from the class and attempt to override the method?

If YouAreDaChef worked as shown above, you would override the method's original body and the advice at the same time. That's the JavaScript way, you override whatever is sitting in the prototype. Before, after, these are just ways to rewrite a single property that contains a single function.

But the intellectually pure approach to AOP is that I should be able to override the original body but keep the advice. So any class that inherits from `Square.RecursivelyComputable` can implement their own `inherit` and automagically get `this.references = 0` executed after their implementation. This is a very powerful way to structure inheritance, and I wish more languages revisited AOP.

But, it's not how JavaScript works. Nevertheless, I Greenspunned it into YouAreDaChef. I rewrote YouAreDaChef so that it maintained various data structures containing the advice and looked things up at runtime. So if you looked at the code for a method, you'd see a little stub that called back to YouAreDaChef. If you overrode a method with anything except YouAreDaChef, everything would work in unpredictable ways. Unpredictable, that is, unless you were intimately familiar with YouAreDaChef's implementation.

But you could override the method body using YouAreDaChef and still inherit advice. And everything would still work. Everything *inside the walled garden* would still work, that is. By changing how inheritance worked, I had turned YouAreDaChef into a walled garden. It no longer interoperated with other JavaScript programming technique. It would break if you used both YouAreDaChef and Method Combinators in the same codebase.

In this case, the line between abstraction and walled garden is easy to see: The moment at which I changed a fundamental language feature and broke interoperability with other tools and techniques.

## Summary

Summing this up is easy: Walled gardens exist in programming. Some are commercial platforms for development like Flash. Some are internal, one-off platforms. And some are libraries or tools. The defining characteristic of all of these walled gardens is the wall, the extent to which they make it difficult for you to interoperate smoothly with other programming tools and approaches.

Writing your own libraries is great. But stop and think very hard when you are tempted to extend some standard functionality in a way that breaks interoperability with other tools.

(Discuss on [hacker news](http://news.ycombinator.com/item?id=4957225) or [proggit](http://www.reddit.com/r/programming/comments/15ahmy/programmings_walled_gardens/))

### postscript to youaredachef

I learned from YouAreDaChef, and I wrote [Method Combinators](https://github.com/raganwald/method-combinators). You don't need the library, the concept is so simple you can roll your own. Combinators are functions that decorate other functions, including adding functionality after another function.

Combinators interoperate perfectly with all of JavaScript's tools and philosophies. They're a lot like the Unix tools that have stood the test of time: Small, simple bits of code that each do one thing well and are written to be composed with one another so that you can build your own solutions from aggregations of simpler tools.

Combinators may be idiosyncratic, but they aren't a walled garden.

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

[mock]: http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422
[Lisp Flavors]: https://en.wikipedia.org/wiki/Flavors_(programming_language)