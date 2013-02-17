Anything to Declare?
===

"Separation of Concerns" is often given as a strong motivating force when organizing code. I certainly think about it a lot (and it comes up fairly regularly when I try to organize my thoughts in essay form, e.g. [My Favourite Interview Question][q] and [Why Why Functional Programming Matters Matters][ww]).

As you've no doubt heard 97 bajillion times from me, I'm on a team that has been developing a new JavaScript framework for writing Single Page Interface ("SPI") applications called [Faux][f]. I just finished a refactoring session, and I'd like to sketch what changed and how it's relevant to separating concerns. The main idea is that in order to implement a new feature, route helpers for templates, I needed to factor declarations out of what were formerly opaque functions. Once the declarations were factored out, I could implement the new feature and apply some convention over configuration to make it palatable.

**disclaimer**

There's nothing really insightful in this post, I'm mostly writing it to sort out the ideas in my own head and as something to look back at to understand what the bleep I was thinking when I built certain features into Faux.

<a href="http://www.flickr.com/photos/vkareh/2997275679/" title="Corn Maze by vkareh, on Flickr"><img src="http://farm4.static.flickr.com/3205/2997275679_9ff3cfd478.jpg" width="500" height="375" alt="Corn Maze" /></a>

**background**

My colleague [Jamie Gilgen][jg] started work on an interesting idea: An example app for [Faux][f] that would start its life as a simple Rails app and be refactored into an SPI app. This would demonstrate how well Faux does at separating the concerns of domain logic on the server from the user interface in the browser. It would also be a nice sales pitch for folks that are comfortable with Rails but are just venturing into SPI applications.

I took a glance at her work the other day, and the bottom dropped out of my stomach. Sprinkled throughout the app's templates are rails `link_to` helpers like this:

    = link_to "Edit", edit_card_path(@card)

Oops, Faux didn't have any helpers like this! We spent a ton of time making a library that helps displaying stuff, but for whatever reason we never even thought to write helpers for links or routes. I guess we were just so comfortable with our routes that we saw nothing wrong with writing code like this:

    %a.north{ href: '#/' + seed + '/' + location.north().id }

This is why example apps are essential. When you're working with something very simple, there's absolutely no excuse for a complicated implementation. And that piece of code is complicated and brittle and repeats some logic that lives in a controller.

> With client work, you can always lie to yourself a little: "This code is complicated because the underlying business logic is complicated, and there's nothing we can do about it. That code is complicated because the client insists on a complicated UI, there's nothing we can do about it."

So, last night when I got home from the gym I decided to take a little un-billable time and put it towards fixing this problem. I started by developing an even simpler example to serve as a test bed: [Misadventure][m]. Misadventure is a gross over-simplification of text-based [adventure][a] games (you can play Misadventure [here][play]). You've been abducted by aliens and you wake up in a corn maze. Naturally, you have to find your way out, one step at a time.

The key benefit of Misadventure for the purpose of working on helpers for routes is that it is route-heavy: Every location in the corn maze has its own id and the game can reconstruct the maze from a seed that is provided to JavaScript's PRNG `Math.random`. There's not much else going on, so working on Misadventure makes it easy to focus on the feature we need.

**the situation**

The first thing I did was design the new feature. I wanted to rewrite all the haml-js template code that looked like this:

    %a{ href: '#/' + seed + '/' + location.id }
    
Into this:

    %a.{ href: route_to_location({ location: location }) }
    
From there, things like `link_to` helpers and so on can proceed fairly naturally. So what needs to be done?

Well, let's revisit what Faux does. Faux works with [Backbone.js][b]. In Faux, you write a definition like this:

    var controller = new Faux.Controller({ ... });

    controller.display('location', {
      route: ':seed/:location_id',
      before_display: function (params) { 
        params.locations = LocationCollection.find_or_create({ seed: params.seed });
        params.location = params.locations.get(params.location_id);
        return params;
      }
    });

From this, Faux writes a controller method for you: `controller.location(params)`. This method is composed of a bunch of little functions that look something like this:

    function location (params) {
      location_redirect(
        location_display(
          location_transform(
            location_fetch_data(
              location_get_params(
                params
              )
            )
          )
        )
      );
    }

Along the way, each of those little functions can transform the `params` by adding or removing values. We've defined a transformation:

    before_display: function (params) { 
      params.locations = LocationCollection.find_or_create({ seed: params.seed });
      params.location = params.locations.get(params.location_id);
      return params;
    }

This transformation will happen as part of `controller.location(params)` before the template is displayed. Some other Faux code will extract `params.seed` and `params.location_id` from the route, and then the code written here will take over and generate `params.locations` and `params.location`, which the template and view will use.

<a href="http://www.flickr.com/photos/wilsonh/1731303635/" title="Corn maze by WHardcastle, on Flickr"><img src="http://farm3.static.flickr.com/2328/1731303635_cf2110f13b.jpg" width="500" height="375" alt="Corn maze" /></a>

**the problem**

What we'd like is that when we define `controller.location(params)`, we also get `helpers.route_to_location(params)`. Then we mix `helpers` into locals when displaying a template, and presto, you can use it in a template easily.

Our problem is that we've defined a way to go from `params.seed` and `params.location_id` to `params.location`, but not how to go backwards. Unless you're dating someone who has proved that [P=NP][pnp], we cannot reliably go from outputs to function inputs given just half of the function.

We need to go in both directions if we wish to write `route_to_location({ location: location })`. We somehow have to extract its id, get its collection, and then get its collection's seed. In essence, we need something like:

    yalpsid_erofeb: function (params) { 
      params.location_id = params.location.id;
      params.locations = params.location.collection;
      params.seed = params.locations.seed;
      return params;
    }
    
That way, given `{ location: location }`, we could transform it into `{ location: location, location_id: ..., locations: ..., seed: ... }`. And with *that* in our hands, we know how to turn `#/:seed/:location_id` into a fully interpolated route.

The other problem is that our transformation is stuck inside our complicated pipeline of functions. Our functions might do a number of other things along the way. How do we know which bits transform `params` and which bits have other side effects such as fetching a template from the server using AJAX?

In essence, we have two problems:

1. We are only defining the transformation in one direction, and;
2. We have tightly coupled transformation with other concerns.

**the solution**

Obviously, we need to be able to define transformations both ways. We also need to decouple them from stuff that has nothing to do with transformations, stuff that happens at specific moments in the pipeline of `controller.location(params)`.

If we think about it for a moment, we realize that some things in the pipeline are *ordered*. Although we don't write out the code, Faux inserts some code in our pipeline so that the template for displaying `constroller.location(params)` is fetched asynchronously from the server *before* we display our data. And of course, when data needs to be fetched that has to happen *before* display as well.

Whereas transformations are a little different. Consider this transformation written in English: "If you have a location id and a collection of locations, but you don't have a location, you can extract the location from the collection with `locations.get(location_id)`." You don't need to define when this happens, you could hold onto the rule and apply it the moment you have a `location_id` and  `locations` but lack a `location`.

It really isn't a function to be applied procedurally, it's something that you should declare and have Faux sort out the details for you. So let's rewrite Faux to do that (I love this part, it's like when the [Galloping Gourmet][gg] slides a pan with some uncooked food into one oven and presto, after the commercial, he pulls a fully roasted [Osterducken][o] out of another oven).

So now, we'll write this:

    var controller = new Faux.Controller({ ... });

    controller.display('location', {
      route: ':seed/:location_id',
      translate: {
        seed: {
          locations: function (locations) { return locations.seed; }
        },
        locations: {
          seed: function (seed) { return LocationCollection.find_or_create({ seed: seed }); }
        }
        location_id: {
          location: function (location) { return location.id; }
        },
        location: {
          'locations location_id': function (locations, location_id) {
            return locations.get(location_id);
          }
        },
        locations: {
          location: function (location) { return location.collection; }
        }
      }
    });

The structure is that our `translate:` declaration is composed of a series of declarations like this:

    location_id: {
      location: function (location) { return location.id; }
    }

This says that if we want a `location_id`, we can make it from a `location` with the function `function (location) { return location.id; }`.

This declaration uses two inputs:

    location: {
      'locations location_id': function (locations, location_id) {
        return locations.get(location_id);
      }
    }

It says that if we want a `location`, we can make it from a collection of `locations` and from a `location_id` with the function `function (locations, location_id) { return locations.get(location_id); }`.

Armed with translations declared in this fashion, the latest version of [Faux][f] will sort everything out for us. Whether you invoke the route `#/12345/67890` or call `controller.location({ seed: 12345, location_id: 67890 })`, Faux can sort out how to display the data in the location template. And should you call `route_to_location({ location: location })`, Faux can generate `#/12345/67890` using the translations as well.

<a href="http://www.flickr.com/photos/zebuladesign/4023334045/" title="Dinosaur themed Corn Maze by nzebula, on Flickr"><img src="http://farm3.static.flickr.com/2803/4023334045_265fb849cd.jpg" width="500" height="375" alt="Dinosaur themed Corn Maze" /></a>

**but...**

Obviously, there are a lot of lines of declaration involved. Can we make some of this go away?

Absolutely! We can infer some of the declarations automatically. If we already know that `params.location` is an instance of `Backbone.Model`, we should be able to infer the translation `id: { location: function (location) { return location.id; } }` automatically. Likewise, if we have a `params.locations`, we might reasonably try to infer that `params.location` can be obtained from `params.locations.get(location_id)`.

And thanks to my new [espresso maker][twist], the latest release of Faux is able to make almost all of the inferences we need. Here're the latest, trimmed down controller declarations:

    controller

      .begin({
        route: ':seed',
        translate: {
          seed: {
            locations: ".seed".lambda()
          },
          locations: {
            seed: function (seed) { return LocationCollection.find_or_create({ seed: seed }); }
          }
        }
      })
  
        .display('wake')
  
        .display('bed')
  
        .display('location', {
          route: ':location_id'
        })
    
        .end();

We've told Faux how to go from a `seed` to a `LocationCollection`, and how to extract the `seed` from a `LocationCollection`. We've named our collection `locations` (`location_collection` would also work). Faux is able to make all of the necessary inferences:

* `location = locations.get(location_id)`
* `locations = location.collection`
* `location_id = location.id`

Such inferences place a heavy reliance on convention over configuration, of course. But what's interesting is that they are only possible when we separate our concerns, when we factor our code.

**conclusion**

I wouldn't hold this out as a case study in refactoring by any stretch, Faux is still struggling to escape its embryonic sack. But it is a reminder that when facing something that seems impossibly ugly to implement, the answer may be factoring things on different lines, especially (as in this case) when something can be transformed from imperative to declarative form.

My feeling is that it is nicer to work with declarations than with imperative functions or methods. In an imperative language like JavaScript or ruby, declarations need some kind of engine to be useful. However, once you have things in declarative form, you have a lot of flexibility about how to apply them to the code.

In this case, turning functions into declarations lets us build controller methods and `route_to` helpers, and it helps us perform more convention over configuration.

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

[q]: http://raganwald.com/2006/06/my-favourite-interview-question.html
[ww]: http://raganwald.com/2007/03/why-why-functional-programming-matters.html
[f]: https://github.com/unspace/faux
[jg]: https://github.com/jamiebikies
[b]: http://documentcloud.github.com/backbone/
[pnp]: http://www.joeydevilla.com/2003/04/07/what-happened-to-me-and-the-new-girl-or-the-girl-who-cried-webmaster/ "What happened to me and the new girl (or: 'The girl who cried Webmaster')"
[gg]: https://www.youtube.com/watch?v=V94H7K_nu5A "Graham Kerr and Johnny Carson"
[o]: https://secure.wikimedia.org/wiktionary/en/wiki/osterducken
[m]: https://github.com/raganwald/misadventure
[a]: http://www.digitalhumanities.org/dhq/vol/001/2/000009/000009.html
[twist]: http://mypressi.com/ "MyPressi Twist"
[play]: http://raganwald.github.com/misadventure/