Misadventure, Part III: Models and Views
===

*Misadventure is a little game written on top of Faux and Backbone.js*

**introduction**

[Misadventure][play] is a little game in the style of [Adventure][a]. Misadventure is written in Javascript and runs entirely in the browser. Misadventure is written in standard Model-View-Controller style, making heavy use of the [Faux][f] and [Backbone.js][b] libraries. In this series of posts I will give you a tour of Misadventure's [code][source], showing how it uses Faux to structure its routes and templates as well as how it uses Backbone.js to organize its models and interactive view code.

This is Part III, wherein we start our examination of controller methods with a look at `controller.wake()`. In [Part I][pi], we had an introduction to the game and its controller, and in [Part II][pii] we looked at controller methods and a simple view-free template.

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

LocationCollection and Location
---

Given a `seed` and a `location_id`, the first thing Faux does is evaluate `LocationCollection.find_or_create({ seed: '7762367175167509' })`. Have a look at the `LocationCollection` class, it's in [models.js][mjs]. The first thing is that `find_or_create({ seed: '7762367175167509' })` is a class method. It allows us to cache location collections so that we don't have to make a new one every time we process a new route.

But the first time, we'll have to make a new `LocationCollection`. So what is a `LocationCollection`? Quite simply, it's a Corn Maze. Out of the box, Backbone.js gives you collections that store models by `id`, can proxy to a remote server by AJAX, and so on.

When writing a Backbone.js-based application, you can use collections of models as-is and out of the box, and you can also add functionality and semantics. In our case, we want to enhance our collection to represent a Maze. A maze can be represented as a graph of nodes with arcs between the nodes representing open passages. The nodes will be represented by instances of `Location` with arcs between the nodes represented by attributes. Arcs are decorated with compass directions, so travelling "North" from a node would lead on a different arc than travelling "East."

The `LocationCollection` class is responsible for maintaining a two-dimensional collection of nodes in a maze. So if you want to iterate through the locations in a row from West to East without regard for whether walls block passage, you work through the `LocationCollection`. But if you want to travel from node to node following the passages, you work through the `Locations`.

    window.Location = Backbone.Model.extend({
  
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

Having set its properties in `.initialize`, the location collection calls `._regenerate()`. This method constructs a new maze given the seed, height, and width. Let's look at how our maze is regenerated:

    _regenerate: function () {
      var width = this.field_width;
      var height = this.field_height;
      Math.seedrandom(this.seed);
    
      // Start with a rectangle of locations
      this.field = _.range(0, height).map(function (row) {
        return _.range(0, width).map(function (col) {
          return new Location({ id: this._random_string(), row: row, col: col });
        }, this);
      }, this);
    
      // the centre will be the starting location
      this.centre = this.field[Math.floor(height/2)][Math.floor(width/2)];
    
      // Create passageways between adjacent locations, while closing off the
      // west and east sides
      _(_.range(0,height)).each(function (row) {
        _(this.field[row]).first().attributes.west = _(this.field[row]).first();
        _(this.field[row]).last().attributes.east = _(this.field[row]).last();
        _(_.range(0,width)).each(function (col) {
          if (row > 0) {
            this.field[row][col].attributes.north = this.field[row - 1][col];
            this.field[row - 1][col].attributes.south = this.field[row][col].attributes;
          }
          if (col > 0) {
            this.field[row][col].attributes.west = this.field[row][col - 1];
            this.field[row][col - 1].attributes.east = this.field[row][col];
          }
        }, this);
      }, this);
    
      // close off the north and south sides
      _(_(this.field).first()).each(function (top_location) {
        top_location.attributes.north = top_location;
      });
      _(_(this.field).last()).each(function (bottom_location) {
        bottom_location.attributes.south = bottom_location;
      });
    
      // open one exit
      var which = Math.random();
      if (which < 0.25) {
        var col = Math.floor(Math.random() * width);
        _(this.field).first()[col].attributes.north = undefined;
      }
      else if (which < 0.5) {
        var col = Math.floor(Math.random() * width);
        _(this.field).last()[col].attributes.south = undefined;
      }
      else if (which < 0.75) {
        var row = Math.floor(Math.random() * height);
        _(this.field[row]).first().attributes.west = undefined;
      }
      else {
        var row = Math.floor(Math.random() * height);
        _(this.field[row]).last().attributes.east = undefined;
      }
    
      // recursively bisect the field until it is a maze
      this._recursive_bisect(0, height - 1, 0, width - 1);
    
      // refresh the collection
      this.refresh(_.flatten(this.field));
    }
  
The first thing we do is call [Math.seedrandom][sr] with the `seed`. An important property of this method is that it must be [idempotent][idem]. WHy? Consider what happens if we start a new maze and play continuously. With every call to `controller.location(...)`, the seed is provided and the location collection is retrieved from the cache. Thus, it will always be the same location collection with the same maze layout. But what happens if someone hits reload? Or fetches a link from a bookmark? We need to generate exactly the same maze in every respect. Thus, we seed the random number generator before we regenerate the maze.

Next, we create a two-dimensional collection of new locations. Each location has a pseudo-random `id`. We also initialize locations with a row and column. We don't use these at the moment, but they are useful for debugging. Then we note the `centre` location, we'll need that for `controller.wake`.


But now let's see what happens when `controller.location()` renders its template. Things are a little more advanced than with `controller.wake()`. What we saw in [Part II][pii] was simple template being passed the parameters.

Like `controller.wake()`, `controller.location(...)` will invoke its namesake template `location.haml` (you can override this default choice by naming another template, of course). But what happens between calculating all of the parameters and displaying the template?

LocationView
---

We saw above that unlike `controller.wake()`, `controller.location(...)` was configured with `clazz: ControllerView` by convention. Meaning, that Faux assumed that since we were defining a controller method called `location`, and since there was a class `LocationView` that extends `Backbone.View`, we must want `LocationView` to manage the view for us.

You can see that the convention is to provide a hash of variable(s) provided to functions that do the calculating. The special case is that if you provide an empty string as a key, it becomes the "default" calculation.

In our case, we aren't providing any parameters, so Faux can't calculate `seed` from `locations`, and it can't use `seed` to calculate `locations` (since it doesn't have seed). Since it doesn't have any other calculation that works, Faux will use the "default" calculation for `seed` of `Math.random().toString().substring(2)`.

(We don't know what a "seed" is, but knowing that we included [Math.seedrandom][sr] in the project, we can make an educated guess that the "seed" is used to make sure we have a repeatable series of pseudo-random numbers. Given that we seem to work with randomly generated mazes, when we get to the post about generating the mazes, you won't be surprised to discover that each seed generates its own maze, and therefore by storing or passing around the seed we have a compact way of storing the layout of the maze. Randomly generating a new seed is a way of identifying a new maze even if we haven't generated it yet.)

Let's say this produces `'19608841026141122'`. So our parameters went from `{}` (no parameters) to `{ seed: '19608841026141122' }`. What about `locations`? Well, now that we have`seed`, Faux can calculation `locations` using `LocationCollection.find_or_create({ seed: seed })`. So Faux now has parameters of `{ seed: '19608841026141122', locations: ... }`.

wake.haml
---

"And?" you may ask. Well, Faux knows this method is called `Wake`. And by default, Faux has figured out that its template is `haml/wake.haml`. Templates can be displayed by themselves or they can be controlled by an instance of `Backbone.View` (or much more likely, an instance of a class you define by extending `Backbone.View`). Which class to use is determined by the `clazz` configuration.

Faux has already looked for a `Backbone.View` class called `WakeView`. Looking in [views.js][vjs], we see that there is a `BedView` and a `LocationView`, but no `WakeView`. If Faux can't find a view class with the conventional name and you don't tell it you want to use a different class, Faux assumes you don't want to use a view class, just a template. Thus, Faux assumes `clazz: false` as you saw above and just displays the `wake.haml` template.

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

Summary
---

Our `controller.wake()` method doesn't use a Backbone view class. It infers parameters and those parameters are available as locals in `wake.haml`. Also, `route_to` helpers are available in `wake.haml` as local functions.

In Part III of this series (to come), we will look at `controller.bed()` in detail. `controller.bed()` uses a view class, so we'll have an opportunity to learn a little about how Backbone view classes work and how Faux wires a controller method, a view class, and a template together.

**(more)**
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.

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
[rb]: http://reginald.braythwayt.com
[source]: http://github.com/unspace/misadventure
[docco]: https://github.com/raganwald/homoiconic/blob/master/2010/11/docco.md "A new way to think about programs"
[cjs]: http://unspace.github.com/misadventure/docs/controller.html
[mjs]: http://unspace.github.com/misadventure/docs/models.html
[vjs]: http://unspace.github.com/misadventure/docs/views.html
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