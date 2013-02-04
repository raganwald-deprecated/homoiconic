Misadventure, Part II: controller.wake()
===

*Misadventure is a little game written on top of Faux and Backbone.js*

**introduction**

[Misadventure][play] is a little game in the style of [Adventure][a]. Misadventure is written in JavaScript and runs entirely in the browser. Misadventure is written in standard Model-View-Controller style, making heavy use of the [Faux][f] and [Backbone.js][b] libraries. In this series of posts I will give you a tour of Misadventure's [code][source], showing how it uses Faux to structure its routes and templates as well as how it uses Backbone.js to organize its models and interactive view code.

<a target="_blank" href="http://min.us/mvkEt6y#1"><img src="http://i.min.us/jeaApo.png" border="0"/></a>

This is Part II, wherein we start our examination of controller methods with a look at `controller.wake()`. In [Part I][pi], we had an introduction to the game and its controller. In [Part III][piii], we'll look at a controller method that wires a model, a collection, and a view up to a template. In [Part IV][piv], we'll do a double-take and talk about loading classes.

controller.wake()
---

As we saw in [Part I][pi], `controller.wake()` is configured like this:

    controller

      .begin({
        'seed=': {
          locations: function (locations) { return locations.seed; },
          '': function () { return Math.random().toString().substring(2); }
        },
        'locations=': {
          seed: function (seed) { return LocationCollection.find_or_create({ seed: seed }); }
        }
      })

        .method('wake')

And Faux turns what we write into this "extended" configuration (meaning this is a combination of what we actually write and what Faux infers for us):

    .method('wake', {
      route: '/wake',            // <- by convention, from the name
      partial: 'haml/wake.haml', // <- by convention, from the name
      clazz: false,              // <- by convention, from the name
      'seed=': {                 // <- 'inherited' from .begin(...)
        locations: function (locations) { return locations.seed; },
        '': function () { return Math.random().toString().substring(2); }
      },
      'locations=': {
        '': function () { return LocationCollection.find_or_create(); },
        seed: function (seed) {  // <- 'inherited' from .begin(...)
          return LocationCollection.find_or_create({ seed: seed }); 
        }
      }
    })
        
In [Part I][pi] we saw that because its route is configured to be `/wake`, `controller.wake()` is invoked by a fragment of `#wake`. It can also be invoked directly, as we saw when the page is first loaded. It has no parameters.

So what happens after it is invoked? This is where the additional configuration comes into play:

      'seed=': {
        locations: function (locations) { return locations.seed; },
        '': function () { return Math.random().toString().substring(2); }
      },
      
And:

      'locations=': {
        seed: function (seed) {
          return LocationCollection.find_or_create({ seed: seed }); 
        }
      }

These options name two parameters, `seed` and `locations`. They also describe how might calculate either one if it isn't provided. What they say is:

1. To calculate `seed`, if you have `locations`, return `locations.seed`
2. To calculate `seed`, if nothing else works, return `Math.random().toString().substring(2)`
2. To calculate `locations`, if you have `seed`, return `LocationCollection.find_or_create({ seed: seed })`

You can see that the convention is to provide a hash of variable(s) provided to functions that do the calculating. The special case is that if you provide an empty string as a key, it becomes the "default" calculation.

In our case, we aren't providing any parameters, so Faux can't calculate `seed` from `locations`, and it can't use `seed` to calculate `locations` (since it doesn't have seed). Since it doesn't have any other calculation that works, Faux will use the "default" calculation for `seed` of `Math.random().toString().substring(2)`.

(We don't know what a "seed" is, but knowing that we included [Math.seedrandom][sr] in the project, we can make an educated guess that the "seed" is used to make sure we have a repeatable series of pseudo-random numbers. Given that we seem to work with randomly generated mazes, when we get to the post about generating the mazes, you won't be surprised to discover that each seed generates its own maze, and therefore by storing or passing around the seed we have a compact way of storing the layout of the maze. Randomly generating a new seed is a way of identifying a new maze even if we haven't generated it yet.)

Let's say this produces `'19608841026141122'`. So our parameters went from `{}` (no parameters) to `{ seed: '19608841026141122' }`. What about `locations`? Well, now that we have`seed`, Faux can calculation `locations` using `LocationCollection.find_or_create({ seed: seed })`. So Faux now has parameters of `{ seed: '19608841026141122', locations: ... }`.

wake.haml
---

"And?" you may ask. Well, Faux knows this method is called `Wake`. And by default, Faux has figured out that its template is `haml/wake.haml`. Templates can be displayed by themselves or they can be controlled by an instance of `Backbone.View` (or much more likely, an instance of a class you define by extending `Backbone.View`). Which class to use is determined by the `clazz` configuration.

Faux has already looked for a `Backbone.View` class called `WakeView`, but we haven't defined one. If Faux can't find a view class with the conventional name and you don't tell it you want to use a different class, Faux assumes you don't want to use a view class, just a template. Thus, Faux assumes `clazz: false` as you saw above and just displays the `wake.haml` template.

Therefore, the `controller.wake()` method displays the parameters it has in the `wake.haml` template:

    %p.intro You have been abducted by aliens!

    %img{ src: './images/cornfield.gif' }

    %p.caption You wake up in a cornfield.

    %ol
      %li
        %a.stand_north{ href: route_to_location({ location: locations.centre }) } Stand up
         and look around.

      %li.reset
        Or you can 
        %a.close_eyes{ href: route_to_wake() } close your eyes
         and go back to sleep, maybe it will all go away.

And this is what you see:

<a target="_blank" href="http://min.us/mvkEt6y#1"><img src="http://i.min.us/jeaApo.png" border="0"/></a>

The two things of interest in our template are `href: route_to_location({ location: locations.centre })` and `href: route_to_wake()`. Each of the controller methods we defined has a corresponding `route_to` helper method that is available locally in templates. So (obviously) the `route_to_location` helper returns the route that invokes `controller.location(...)` and the `route_to_wake` helper returns the route that invokes `controller.wake()`.

Let's look at `route_to_location({ location: locations.centre })`. We're passing in a parameter named `location`. We'll get to that in a moment, but the value is interesting: We take our `locations` parameter and get the `centre` property. (That happens to be the centre of the corn maze, but we'll cover locations shortly.)

So what happens when we call `route_to_location({ location: locations.centre })`? Let's take a sneak peek at our definition for `controller.location`:

      .method('location', {
        route: '/:seed/:location_id'
        partial: 'haml/location.haml', // <- by convention, from the name
        model_clazz: Location,         // <- by convention, from the name
        clazz: LocationView,           // <- by convention, from the name
        'seed=': {                     // <- 'inherited' from .begin(...)
          locations: function (locations) { return locations.seed; },
          '': function () { return Math.random().toString().substring(2); }
        },
        'locations=': {                // <- 'inherited' from .begin(...)
          seed: function (seed) { return LocationCollection.find_or_create({ seed: seed }); },
          location: function (location) { return location.collection; } // <- by convention, from the name
        },
        'location_id': {               // <- by convention, from the name
          location: function (location) { return location.id; }
        },
        'location=': {                 // <- by convention, from the name
          'locations location_id': function (locations, location_id) { return locations.get(location_id); }
        }
      })
    
Faux wants to generate a route. So it needs a `seed` and a `location_id`. We've defined how to make a `seed` out of `locations`. And Faux has inferred how to make `locations` out of a `location` from the name. So Faux figures the seed out from the location your supply. Faux also needs a `location_id`, and once again Faux has inferred the correct function from the names, and it can fill in the values.

(If you don't like to use such obvious naming conventions, you are free to define your own conversion functions, just as we did for `seed` and `locations`).

So having provided the centre `location`, Faux is able to calculate a route of `http://unspace.github.com/misadventure/#/7221645157845498/6682013437305772` using `route_to_location`.  With `route_to_wake`, no calculations are needed because the route, `/wake`, doesn't have any parameters.

This, incidentally, is the whole point of writing the separate calculations as part of the configuration instead of as a function. Faux can mix that in with conversions it infers by convention and thus support `route_to` helpers.

Consider the alternative. If we didn't have separate calculations, you would have to write `route_to_location({ seed: location.collection.seed, location_id: location.id })`. That's better than `'#/' + location.collection.seed + '/' + location.id`, but not much. Now all this code needs to know is that the route to a location requires a location. The specifics of how that is translated to the route is hidden. Perhaps some future refactoring might build enough information into the location's id that no seed is necessary.

<a target="_blank" href="http://min.us/mvkEt6y#4"><img src="http://i.min.us/jbJZZ8.png" border="0"/></a>

Summary
---

Our `controller.wake()` method doesn't use a Backbone view class. It infers parameters and those parameters are available as locals in `wake.haml`. Also, `route_to` helpers are available in `wake.haml` as local functions.

In [Part III][piii] of this series, we will look at `controller.location(...)` in detail. `controller.location(...)` uses a model, a controller, and view class, so we'll have an opportunity to learn a little about how Backbone view classes work and how Faux wires controller methods, models, collections, views, and templates together.

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

[bc]: http://documentcloud.github.com/backbone/#Controller
[haml-lang]: http://haml-lang.com/
[a]: http://www.digitalhumanities.org/dhq/vol/001/2/000009/000009.html
[f]: https://github.com/unspace/faux
[play]: http://unspace.github.com/misadventure/
[r]: http://weblog.jamisbuck.org/2011/1/12/maze-generation-recursive-division-algorithm
[j]: http://weblog.jamisbuck.org/
[rb]: http://braythwayt.com
[source]: http://github.com/unspace/misadventure
[docco]: https://github.com/raganwald/homoiconic/blob/master/2010/11/docco.md "A new way to think about programs"
[cjs]: http://unspace.github.com/misadventure/docs/controller.html
[s]: http://yayinternets.com/
[ui]: http://unspace.ca
[b]: http://documentcloud.github.com/backbone/
[wake]: http://unspace.github.com/misadventure/#/wake
[l1]: http://unspace.github.com/misadventure/#/42492610216140747/7624672284554068
[l2]: http://unspace.github.com/misadventure/#/42492610216140747/5682321739861935
[l3]: http://unspace.github.com/misadventure/#/42492610216140747/3916709493533819
[bed]: http://unspace.github.com/misadventure/#/42492610216140747/bed
[pi]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_i.md#readme
[piii]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_iii.md#readme
[sr]: http://davidbau.com/archives/2010/01/30/random_seeds_coded_hints_and_quintillions.html "Random Seeds, Coded Hints, and Quintillions"
[piv]: http://github.com/raganwald/homoiconic/tree/master/2011/02/misadventure_part_iv.md#readme