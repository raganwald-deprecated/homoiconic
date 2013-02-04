Misadventure, Part III: Models and Views
===

*Misadventure is a little game written on top of Faux and Backbone.js*

**introduction**

[Misadventure][play] is a little game in the style of [Adventure][a]. Misadventure is written in JavaScript and runs entirely in the browser. Misadventure is written in standard Model-View-Controller style, making heavy use of the [Faux][f] and [Backbone.js][b] libraries. In this series of posts I will give you a tour of Misadventure's [code][source], showing how it uses Faux to structure its routes and templates as well as how it uses Backbone.js to organize its models and interactive view code.

<a target="_blank" href="http://min.us/mvkEt6y#1"><img src="http://i.min.us/jeaApo.png" border="0"/></a>

This is Part III, wherein we dive into controller methods that wire models, collections, views, and templates together with a look at `controller.location(...)`. In [Part I][pi], we had an introduction to the game and its controller, and in [Part II][pii] we looked at controller methods and a simple view-free template. In [Part IV][piv], we'll do a double-take and talk about loading classes.

invoking controller.location()
---

We'll begin our look at using Backbone's [models][bm] and [views][bv] with a look at `controller.location(...)`. This method is interesting because it uses parameters to instantiate a model and a Backbone [collection][bcc], then it displays the model through a view.

As we saw in [Part I][pi], `controller.location(...)` is configured like this:

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

        .method('location', {
          route: ':seed/:location_id'
        })

And Faux turns what we write into this "extended" configuration (meaning this is a combination of what we actually write and what Faux infers for us):

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
        
Because its route is configured to be '/:seed/:location_id', `controller.location(...)` is invoked by almost any fragment featuring two strings separated by forward slashes such as `#/7762367175167509/9581772962891746`, `#/3072363413300996/4150982475107942`, or even `#/yahoo/serious`. That doesn't mean it can do anything sensible with the route, just that the controller will trigger `.location(...)` in response. (`controller.location(...)` can also be invoked directly, as we will see later.)

So what happens when `controller.location(...)` is invoked? Unlike `controller.wake()`, controller.location(...)` is expecting one or more parameters. If it's invoked with a fragment like `#/7762367175167509/9581772962891746`, this is exactly equivalent to calling it directly like this:

    controller.location({ seed: '7762367175167509', location_id: '9581772962891746' });
    
(Controller methods in Faux differs slightly from controller methods in a pure Backbone application. In Faux, the parameters extracted from the route are passed as key-value pairs. In pure Backbone, they would be passed as function parameters like this: `.location('7762367175167509', '9581772962891746')`.)

Just as with `.wake()`, Faux uses the calculations in the configuration (both declared and inferred by convention) to infer additional parameters. It is given `seed`, so it can ignore `seed=`. What about `locations=`?

    'locations=': {                // <- 'inherited' from .begin(...)
      seed: function (seed) { return LocationCollection.find_or_create({ seed: seed }); },
      location: function (location) { return location.collection; } // <- by convention, from the name
    }

We have a calculation for determining `locations` given `seed`. Faux evaluates `LocationCollection.find_or_create({ seed: seed })` and thus our parameters go from:

    {
      seed: '7762367175167509',
      location_id: '9581772962891746'
    }

To:

    {
      seed: '7762367175167509',
      locations: ... // an instance of LocationCollection,
      location_id: '9581772962891746'
    }
    
Now we have `seed`, `locations`, and `location_id`. Faux knows about this:

    'location=': {
      'locations location_id': function (locations, location_id) { return locations.get(location_id); }
    }

This says that if you have `locations` and `location_id`, you can calculate `location`. This is a standard inference Faux draws from the names and from the existence of a `Location` model class as well as a `LocationCollection` collection class. (If you need to use other names, you can do so by explicitly providing the appropriate calculations for Faux.)

Faux evaluates `locations.get(location_id)` and there are no further calculations to perform:

    {
      seed: '7762367175167509',
      locations: ... // an instance of LocationCollection,
      location_id: '9581772962891746',
      location: ... // an instance of Location
    }

If you're wondering why Faux uses this declarative syntax for calculations instead of something like:

    location: function (seed, location_id) {
      var locations = LocationCollection.find_or_create({ seed: seed });
      var location = LocationCollection.get(location_id);
      // ...
    }

The reason is that Faux can be much more flexible about parameters. For example, Faux generates a `route_to_location(...)` helper as we saw in [Part II][pii] that can be called with just a `location`. Faux can work out the `seed` and the `location_id` needed from the route using the calculations. Faux can also allow you to call `controller.location({ location: ... })` as we'll see below.

Now that we understand how Faux determines all of the parameters (and not just the ones passed in through the route), let's take a closer look at `locations` and `location`, and more importantly, the `LocationCollection` collection class and the `Location` model class.

<a target="_blank" href="http://min.us/mvkEt6y#2"><img src="http://i.min.us/jefdsa.png" border="0"/></a>

LocationCollection and Location
---

Given a `seed` and a `location_id`, the first thing Faux does is evaluate `LocationCollection.find_or_create({ seed: '7762367175167509' })`. Have a look at the `LocationCollection` class, it's in [location.js][ljs]. The first thing is that `find_or_create({ seed: '7762367175167509' })` is a class method. It allows us to cache location collections so that we don't have to make a new one every time we process a new route.

But the first time, we'll have to make a new `LocationCollection`. So what is a `LocationCollection`? Quite simply, it's a Corn Maze. Out of the box, Backbone.js gives you collections that store models by `id`, can proxy to a remote server by AJAX, and so on.

When writing a Backbone.js-based application, you can use collections of models as-is and out of the box, and you can also add functionality and semantics. In our case, we want to enhance our collection to represent a Maze. A maze can be represented as a graph of nodes with arcs between the nodes representing open passages. The nodes will be represented by instances of `Location` with arcs between the nodes represented by attributes. Arcs are decorated with compass directions, so travelling "North" from a node would lead on a different arc than travelling "East."

The `LocationCollection` class is responsible for maintaining a two-dimensional collection of nodes in a maze. So if you want to iterate through the locations in a row from West to East without regard for whether walls block passage, you work through the `LocationCollection`. But if you want to travel from node to node following the passages, you work through the `Locations`.

    window.Location = Backbone.Model.extend({
  
      // initalize each location to be surrounded by walls
      initialize: function () {
        _(['north', 'south', 'east', 'west']).each(function (direction) {
          this.attributes[direction] = this;
        }, this);
      },
  
      // Methods that return the adjacent location, even if it is `this`.
      north: function () { return this.attributes.north && this.collection.get(this.attributes.north.id); },
      south: function () { return this.attributes.south && this.collection.get(this.attributes.south.id); },
      west: function () { return this.attributes.west && this.collection.get(this.attributes.west.id); },
      east: function () { return this.attributes.east && this.collection.get(this.attributes.east.id); },
  
      // Methods that return whether the adjacent location is a different location and passable.
      has_north: function () { return this.attributes.north && this !== this.attributes.north; },
      has_south: function () { return this.attributes.south && this !== this.attributes.south; },
      has_west: function () { return this.attributes.west && this !== this.attributes.west; },
      has_east: function () { return this.attributes.east && this !== this.attributes.east; },
  
      // Methods that return whether the adjacent location is passable, which could be
      // an adacent location or an exit.
      passage_north: function () { return this !== this.attributes.north; },
      passage_south: function () { return this !== this.attributes.south; },
      passage_west: function () { return this !== this.attributes.west; },
      passage_east: function () { return this !== this.attributes.east; },
  
  
      // Methods that return whether the adjacent location is the exit.
      escapes_north: function () { return undefined === this.attributes.north; },
      escapes_south: function () { return undefined === this.attributes.south; },
      escapes_west: function () { return undefined === this.attributes.west; },
      escapes_east: function () { return undefined === this.attributes.east; }
  
    });

Each location has four attributes, `north`, `south`, `east`, and `west`. The preferred method of access is through the instance methods `north()`, `south()`, `east()`, and `west()`. If there is a passage to another node in any direction, the attribute contains that node. If there is a wall blocking passage, or the node is on the edge of the maze, that attribute is the location itself. This is like having an arc that leads back to its origin.

A location can have an `undefined` direction attribute. This is the way we note that a location is adjacent to the exit, and that travelling in that direction escapes from the maze (`undefined` approximating the idea of travelling outside of the maze's geometry). There are convenience methods such as `escapes_north()` to test whether travelling North would escape the maze and `passage_west()` that tests whether travelling West would lead somewhere else (either escape or another location).

`Location` instances are constructed and owned by `LocationCollection` instances.

    window.LocationCollection = Backbone.Collection.extend({
  
      model: Location,
  
      initialize: function (models, options) {
        this.seed = options.seed || this._random_string();
        this.field_width = options.width || 15;
        this.field_height = options.height || 15;
        this._regenerate();
      },
  
      _random_string: function () {
        return Math.random().toString().substring(2);
      },
  
      // **Generate a New Maze**
      _regenerate: function () {
        // ...
      },
  
      _bisect: function (low_row, high_row, low_col, high_col) {
        // ...
      }
  
    }, {

      find_or_create: (function () {
        var cache = {};
        return function (options) {
          options || (options = {});
          var lc;
          if (_.isUndefined(options.seed)) {
            lc = new window.LocationCollection([]);
            cache[lc.seed] = lc;
          }
          else if (_.isUndefined(cache[options.seed])) {
            lc = new window.LocationCollection([], options);
            cache[options.seed] = lc;
          }
          else lc = cache[options.seed];
          return lc;
        };
      })()
  
    });

The basic structure is simple. `Location.find_or_create({ seed: ... })` caches location collections by seed. Multiple calls with the same seed will simply fetch the collection from the cache instead of recreating it. `.initialize(...)` concerns itself with options. The `seed` gets a random value by default, however we actually expect to be provide a seed value when we create a new location collection. `height` and `width` aren't adjustable in the interface yet, so they get default values of `15`.

Having set its properties in `.initialize`, the location collection calls `._regenerate()`. This method constructs a new maze given the seed, height, and width. Let's look at how our maze is regenerated.

The first thing we do is call [Math.seedrandom][sr] with the `seed`. An important property of this method is that it must be [idempotent][idem]. Why? Consider what happens if we start a new maze and play continuously. With every call to `controller.location(...)`, the seed is provided and the location collection is retrieved from the cache. Thus, it will always be the same location collection with the same maze layout. But what happens if someone hits reload? Or fetches a link from a bookmark? We need to generate exactly the same maze in every respect. Thus, we seed the random number generator before we regenerate the maze.

    _regenerate: function () {
      var width = this.field_width;
      var height = this.field_height;
      Math.seedrandom(this.seed);
    
Next, we create a two-dimensional collection of new locations. Each location has a pseudo-random `id`. We also initialize locations with a row and column. We don't use these at the moment, but they are useful for debugging.

      this.field = _.range(0, height).map(function (row) {
        return _.range(0, width).map(function (col) {
          return new Location({ id: this._random_string(), row: row, col: col });
        }, this);
      }, this);
    
Then we note the `centre` location, we'll need that for `controller.wake`.

      this.centre = this.field[Math.floor(height/2)][Math.floor(width/2)];
    
At this point our locations aren't wired together, each location is surrounded by walls. It's time to create a grid of adjacent locations, so we wire the interior of the maze up, connecting adjacent locations:

      _(_.range(1, height)).each(function (i_row) {
        _(_.range(1, width)).each(function (j_col) {
          this.field[i_row][j_col].attributes.north = this.field[i_row - 1][j_col];
          this.field[i_row - 1][j_col].attributes.south = this.field[i_row][j_col].attributes;
          this.field[i_row][j_col].attributes.west = this.field[i_row][j_col - 1];
          this.field[i_row][j_col - 1].attributes.east = this.field[i_row][j_col];
        }, this);
      }, this);
      
At this point we have a grid, all interior locations are connected to each other and there is a wall around the periphery. We'll pick a random side and open one exit on it:
    
      var which = Math.random();
      if (which < 0.25) {
        var j_col = Math.floor(Math.random() * width);
        _(this.field).first()[j_col].attributes.north = undefined;
      }
      else if (which < 0.5) {
        var j_col = Math.floor(Math.random() * width);
        _(this.field).last()[j_col].attributes.south = undefined;
      }
      else if (which < 0.75) {
        var i_row = Math.floor(Math.random() * height);
        _(this.field[i_row]).first().attributes.west = undefined;
      }
      else {
        var i_row = Math.floor(Math.random() * height);
        _(this.field[i_row]).last().attributes.east = undefined;
      }
    
We then build a random maze inside the grid. One of the properties of a maze is that there is at least one route between any two locations in the maze. That guarantees that there is a route from centre to exit. This algorithm adds walls. You can substitute any other wall-adder that you like. We're not going to step through the `_recursive_bisect(...)` algorithm for generating a maze. You can study the code in [location.js][ljs], and Jamis Buck [describes and animates the algorithm as part of his series on generating mazes][r].

      this._recursive_bisect(0, height - 1, 0, width - 1);
    
Now we call Backbone.js's `refresh` method on an array of all the locations. This adds them in bulk to the collection so that `locations.get(location_id)` will work. Then we're done!

      this.refresh(_.flatten(this.field));
    }
  
**summary**

The maze is represented as a graph of locations. Each location know whether it lies adjacent to the exit and which adjacent locations can be reached from it. The location collection's responsibilities are to construct the graph of locations from a seed value and to serve a location given its unique `id`.

<a target="_blank" href="http://min.us/mvkEt6y#3"><img src="http://i.min.us/jeflO8.png" border="0"/></a>

LocationView
---

At this point we know how `controller.location(...)` calculates the `locations` and `location` given a `seed` and a `location_id`. We've seen how an entire maze can be constructed from the seed and how the class caches collections so that subsequent access is fast.

But now let's see what happens when `controller.location()` renders its template. Things are a little more advanced than with `controller.wake()`. What we saw in [Part II][pii] was simple template being passed the parameters.

Like `controller.wake()`, `controller.location(...)` will invoke its namesake template `location.haml` (you can override this default choice by naming another template, of course). But there is a crucial difference: `controller.location(...)` is configured with `clazz: ControllerView` by convention. Meaning, that Faux assumed that since we were defining a controller method called `location`, and since there was a class `LocationView` that extends `Backbone.View`, we must want `LocationView` to manage the view for us.

Faux takes `LocationView` and extends it with a custom `.render()` method, something like this:

    var anonymous_view_clazz = LocationView.extend({
      render: function () {
        // run any before_rnder functions
        // display the parameters in haml/location.haml
        // run any after_render functions
      }
    });
    
    var view = new anonymous_view_clazz(parameters);

It extends `LocationView` with a `.render()` method that displays the template `location.haml`. This is important, because when you write views that update themselves, it will re-render the template as we would expect.

Let's peek at the first few lines of `location.haml` and see if anything is different from `wake.haml`:

    %img{ src: this.passage_image_source() }

    %p.caption 
      %em You are in #{this.text_description()}
      
Hmm! In `wake.haml` we accessed the parameters as locals. In a template associated with a view class, the instance of the view is available as `this`. Good style is to access the parameters as `this.options` instead of as locals. For example, the seed would be `this.options.seed`.

Functions like `this.text_description()` are methods on the view instance, of course. A view becomes a good way to organize helper functions and unobtrusive JavaScript for a template. Here's `LocationView` showing the helper methods that are designed to be called from within the template:

    window.LocationView = Backbone.View.extend({
  
      before_render: function () { ... }
      after_render: function () { ... }
      go_north: function () { ... },
      go_south: function () { ...  },
      go_east: function () { ... },
      go_west: function () { ... },
  
      // The text description is a clumsy homage to [Adventure][play].
      //
      // [play]: http://unspace.github.com/misadventure/
      text_description: (function () {
        var descriptions = ['a hole with no way out',
          'a little maize of twisting passages',
          'a little maize of twisty passages',
          'a little twisty maize of passages',
          'a maize of little twisting passages',
          'a maize of little twisty passages',
          'a maize of twisting little passages',
          'a maize of twisty little passages',
          'a twisting little maize of passages',
          'a twisting maize of little passages',
          'a twisty little maize of passages',
          'a twisty maize of little passages',
          'a little twisting maize of passages',
          'amazing little twisting passages',
          'amazing little twisty passages',
          'amazing twisting little passages'];
        return function () {
          return descriptions[
            (this.model.has_north() ? 1 : 0) + 
            (this.model.has_south() ? 2 : 0) + 
            (this.model.has_west() ? 4 : 0) + 
            (this.model.has_east() ? 8 : 0)
          ];
        };
      })(),
  
      // a rough approximation of what you might see here
      passage_image_source: (function () {
        var passages = ['./images/passages1.png',
          './images/passages1.png',
          './images/passages2.png',
          './images/passages3.png',
          './images/passages4.png'];
        return function () {
          return passages[
            (this.model.has_north() ? 1 : 0) + 
            (this.model.has_south() ? 1 : 0) + 
            (this.model.has_west() ? 1 : 0) + 
            (this.model.has_east() ? 1 : 0)
          ];
        };
      })()
  
    });

There's one more thing. Faux looks for `before_render` and `after_render` functions in the view class. When it composes the `.render()` method for the view, it mixes this [method advice][aop] in. `LocationView` uses `before_render` and `after_render` to bind a keypress listener to the DOM's document object. When the user presses an arrow key, the view's `go_north`, `go_south`, `go_east`, or `go_west` methods are called.

Now you see another use for view classes: Managing the code required for the user experience. Let's have a look at `go_north`:

    go_north: function () {
      if (this.model.has_north()) {
        this.options.controller.location({ location: this.model.north() });
      }
      else if (this.model.escapes_north()) {
        this.options.controller.bed({ location: this.model })
      }
    }

Up to now we've talked about directly invoking a controller method, but here we see it in action. This is much more readable and stable than trying to simulate a redirect through the URL. We also see that as promised, although the route for `controller.location(...)` expects a `seed` and a `location_id`, the controller method can take a `location` and go from there. If you try an arrow key in the browser, you'll also see that calling the controller method properly updates the fragment in the history so that navigation and bookmarking works properly.

Faux isolates the details of URLs from the code.

(Backbone.js provides a convenient and expressive mechanism for views to handle DOM events, however this will not work for keypresses unless they are associated with a form inside the DOM element managed by the view. There's no form, so we can't use Backbone's mechanism and have rolled our own listener. You can read the code in [bed_view.js][bvjs].)

**summary**

The view class is the natural repository for code related to displaying what is seen and for handling interaction with the user. The view class extends `Backbone.View`, and Faux writes a `.render()` method for the view that displays the template. You can customize this method by writing `before_render` and `after_render` methods. When a view class like `LocationView` is is use, the view instance is the template's current context and available as `this`. You can thus write your own helper methods in the view.

Although we don';t show it in Misadventure, you can use standard Backbone event handlers and wire views to models to handle automatic updates.

more location.haml
---

In [Part II][pii], we saw that a template can access the controller method's parameters as locals, and we also saw that it can access helper methods as local functions. Let's take a full look at `location.haml`:

    %img{ src: this.passage_image_source() }

    %p.caption 
      %em You are in #{this.text_description()}

    %ol{ id: this.model.id }
      :if this.options.location.escapes_north()
        %li
          %a.north{ href: route_to_bed({ location: this.options.location }) } 
            %strong &uarr; freedom beckons north
      :if this.options.location.has_north()
        %li
          %a.north{ href: route_to_location({ location: this.options.location.north() }) } &uarr; move north

      :if this.options.location.escapes_south()
        %li
          %a.south{ href: route_to_bed({ location: this.options.location }) } 
            %strong &darr; freedom beckons south  &darr;
      :if this.options.location.has_south()
        %li
          %a.north{ href: route_to_location({ location: this.options.location.south() }) } turn south &darr;

      :if this.options.location.escapes_west()
        %li
          %a.west{ href: route_to_bed({ location: this.options.location }) } 
            %strong &larr; freedom beckons to the west
      :if this.options.location.has_west()
        %li
          %a.north{ href: route_to_location({ location: this.options.location.west() }) } &larr; go west

      :if this.options.location.escapes_east()
        %li
          %a.east{ href: route_to_bed({ location: this.options.location }) } 
            %strong freedom beckons to the east &rarr;
      :if this.options.location.has_east()
        %li
          %a.north{ href: route_to_location({ location: this.options.location.east() }) } go east &rarr; 

      %li
        Or you can 
        %a.close_eyes{ href: route_to_wake() } close your eyes
         and go back to sleep, maybe it will all go away.

We see that this view mixes accessing the view instance through `this`. The current location is actually available in two different ways. You could access it directly using `location` or you could access it through the view using `this.options.location` as we've done here. When the view instance is instantiated, the controller method parameters are passed in as options.

As we saw in [Part II][pii], we can pass a parameter like the current location to a route helper, and Faux figures out what to do to display the correct fragment. For example, `route_to_location` will work out the `seed` from `location.collection.seed`, and the `location_id` from `location.id`. Experiment. It works just as well had you written:

    route_to_location({ seed: locationcollection.seed, location_id: location.west().id })

(It's slightly better style to access parameters like `location` through the view, as this allows interactive views to change their own options..)

<a target="_blank" href="http://min.us/mvkEt6y#4"><img src="http://i.min.us/jbJZZ8.png" border="0"/></a>

Summary
---

Our `controller.location(...)` method uses a model, a collection, and a view. It infers parameters and those parameters are available as locals in `location.haml`, however the preferred style is to access the parameters as options in the view instance. The view instance is the natural repository for code that helps the template, set things up or tears them down, and controls interaction with the user.

Next, in [Part IV][piv], we'll do a double-take and talk about loading classes.

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

[bc]: http://documentcloud.github.com/backbone/#Controller "Backbone.Controller"
[bcc]: http://documentcloud.github.com/backbone/#Collection "Backbone.Collection"
[bm]: http://documentcloud.github.com/backbone/#Model "Backbone.Model"
[bv]: http://documentcloud.github.com/backbone/#View "Backbone.View"
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
[ljs]: http://unspace.github.com/misadventure/docs/location.html
[bvjs]: http://unspace.github.com/misadventure/docs/bed_view.html
[s]: http://yayinternets.com/
[ui]: http://unspace.ca
[b]: http://documentcloud.github.com/backbone/
[wake]: http://unspace.github.com/misadventure/#/wake
[l1]: http://unspace.github.com/misadventure/#/42492610216140747/7624672284554068
[l2]: http://unspace.github.com/misadventure/#/42492610216140747/5682321739861935
[l3]: http://unspace.github.com/misadventure/#/42492610216140747/3916709493533819
[bed]: http://unspace.github.com/misadventure/#/42492610216140747/bed
[pi]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_i.md#readme
[pii]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_ii.md#readme
[sr]: http://davidbau.com/archives/2010/01/30/random_seeds_coded_hints_and_quintillions.html "Random Seeds, Coded Hints, and Quintillions"
[idem]: https://secure.wikimedia.org/wikipedia/en/wiki/Idempotence
[aop]: https://secure.wikimedia.org/wikipedia/en/wiki/Aspect-oriented_programming "Aspect Oriented Programming"
[piv]: http://github.com/raganwald/homoiconic/tree/master/2011/02/misadventure_part_iv.md#readme