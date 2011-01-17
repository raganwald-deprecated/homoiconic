Separation of Concerns
===

"Separation of Concerns" is often given as a strong motivating force when organizing code. I certainly think about it a lot (and it comes up fairly regularly when I try to organize my thoughts in essay form, e.g. [My Favourite Interview Question][q] and [Why Why Functional Programming Matters Matters][ww]).

I recently did a marathon refactoring session with [Faux][f], and I'd like to sketch what changed and how it's relevant to separating concerns.

**background**

As you've no doubt heard 97 bajillion times from me, I'm on a team that has been developing a new Javascript framework for writing Single Page Interface applications called [Faux][f]. We started by extracting it from a really interesting client project, and now we're documenting it and writing example apps.

Example apps are great because when you're working with something very simple, there's absolutely no excuse for a complicated implementation. With client work, you can always lie to yourself a little: "This code is complicated because the underlying business logic is complicated, and there's nothing we can do about it. That code is complicated because the client insists on a complicated UI, there's nothing we can do about it." But with an example app, the code ought to be very simple, and there's no rationalization possible. If the code isn't simple, rewrite it and/or the framework until it is simple.

My colleague [Jamie Gilgen][jg] started work on an interesting idea: An example that would start its life as a simple Rails app and be refactored into an SPI app. This would demonstrate how well Faux does at separating the concerns of domain logic on the server from the user interface in the browser. It would also be a nice sales pitch for folks that are comfortable with Rails but are just venturing into SPI applications.

I took a glance at her work and the bottom dropped out of my stomach. Sprinkled throughout the app's templates are rails `link_to` helpers like this:

    = link_to "Edit", edit_card_path(@card)
    |
    = link_to "Destroy", @card, :confirm => 'Are you sure?', :method => :delete
    |
    = link_to "View All", cards_path

But Faux didn't have any helpers like this! We spent a ton of time making a library that helps displaying stuff, but for whatever reason we never even thought to write helpers for links or routes. I guess we were just so comfortable with our routes that we saw nothing wrong with writing code like this:

    %a.north{ href: '#/' + seed + '/' + this.model.north().id }
    
Well. You can get away with this when you're writing a complex template as part of a complex application. And even if you don't like it, the ticket to change things goes in the same bin as the ticket to add features that the client is actually funding, so progress is slow.

<a href="http://www.flickr.com/photos/vkareh/2997275679/" title="Corn Maze by vkareh, on Flickr"><img src="http://farm4.static.flickr.com/3205/2997275679_9ff3cfd478.jpg" width="500" height="375" alt="Corn Maze" /></a>

But last night when I got home from the gym I decided to take a little un-billable time and put it towards fixing this problem. I started by developing an even simpler example to serve as a test bed: [misadventure][m]. Misadventure is a gross over-simplification of text-based [adventure][a] games. You wake up in a cornfield, the cornfield is really a maze, you have to find your way out of the maze.

The key benefit of misadventure for the purpose of working on helpers for routes is that it is route-heavy: Every location in the cornfield has its own id and the game can reconstruct the cornfield from a seed that is provided to Javascript's PRNG `Math.random`.

there's not much else going on, so it's easy to focus on the feature we need.

**the situation**

The first thing I did was design the new feature. I wanted to rewrite all the haml-js template code that looked like this:

    %a{ href: '#/' + seed + '/' + this.model.id }
    
Into this:

    %a.{ href: route_to_location({ model: model }) }
    
From there, things like `link_to` helpers and so on can proceed fairly naturally. So what needs to be done?

Well, let's revisit what Faux does. Faux works with [Backbone.js][b]. In Faux, you write a definition like this:

    var controller = new Faux.Controller({ ... });

    controller.display('location', {
      location: true,
      route: ':seed/:id',
      before_display: function (params) { 
        params.cornfield = LocationCollection.find_or_create({ seed: params.seed });
        params.model = params.cornfield.get(params.id);
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
      params.cornfield = LocationCollection.find_or_create({ seed: params.seed });
      params.model = params.cornfield.get(params.id);
      return params;
    }

This transformation will happen as part of `controller.location(params)` before the template is displayed. Some other Faux code will extract `params.seed` and `params.id` from the route, and then the code written here will take over and generate `params.cornfield` and `params.model`, which the template and view will use.

**the problem**

What we'd like is that when we define `controller.location(params)`, we also get `helpers.route_to_location(params)`. Then we mix `helpers` into locals when displaying a template, and presto, you can use it in a template easily.

Our problem is that we've defined a way to go from `params.seed` and `params.id` to `params.model`, but not how to go backwards. Unless you're dating someone who has proved that [P=NP][pnp], we cannot reliably go from outputs to function inputs given just half of the function.

We need to go in both directions if we wish to write `route_to_location({ model: model })`. We somehow have to extract its id, get its collection, and then get its collection's seed. In essence, we need something like:

    yalpsid_erofeb: function (params) { 
      params.id = params.model.id;
      params.cornfield = params.model.collection;
      params.seed = params.cornfield.seed;
      return params;
    }
    
That way, given `{ model: model }`, we could transform it into `{ model: model, id: ..., cornfield: ..., seed: ... }`. And with *that* in our hands, we know how to turn `#/:seed/:id` into a fully interpolated route.

The other problem is that our transformation is stuck inside our complicated pipeline of functions. Our functions might do a number of other things along the way. How do we know which bits transform `params` and which bits have other side effects such as fetching a template from the server using AJAX?

In essence, we have two problems:

1. We are only defining the transformation in one direction, and;
2. We have tightly coupled transformation with other concerns.

**the solution**

Obviously, we need to be able to define transformations both ways. We also need to decouple them from stuff that has nothing to do with transformations, stuff that happens at specific moments in the pipeline of `controller.location(params)`.

If we think about it for a moment, we realize that some things in the pipeline are *ordered*. Although we don't write out the code, Faux inserts some code in our pipeline so that the template for displaying `constroller.location(params)` is fetched asynchronously from the server *before* we display our data. And of course, when data needs to be fetched that has to happen *before* display as well.

Whereas transformations are a little different. Consider this transformation written in English: "If you have an id and a cornfield, but you don't have a model, you can make a model with `cornfield.get(id)`." You don't need to define when this happens, you could hold onto the rule and apply it the moment you have an `id` and a `cornfield` but lack a `model`.

It really isn't a function to be applied procedurally, it's something that you should declare and have Faux sort out the details for you. So let's rewrite Faux to do that (I love this part, it's like when the [Galloping Gourmet][gg] slides a pan with some uncooked food into one oven and presto, after the commercial, he pulls a fully roasted [Osterducken][o] out of another oven).

So now, we'll write this:

    var controller = new Faux.Controller({ ... });

    controller.display('location', {
      location: true,
      route: ':seed/:id',
      translate: {
        seed: {
          cornfield: function (cornfield) { return cornfield.seed; }
        },
        cornfield: {
          seed: function (seed) { return LocationCollection.find_or_create({ seed: seed }); }
        }
        id: {
          model: function (model) { return model.id; }
        },
        model: {
          'cornfield id': function (cornfield, id) {
            return cornfield.get(id);
          }
        },
        cornfield: {
          model: function (model) { return model.collection; }
        }
      }
    });

The structure is that our `translate:` declaration is composed of a series of declarations like this:

    id: {
      model: function (model) { return model.id; }
    }

This says that if we want an `id`, we can make it from a `model` with the function `function (model) { return model.id; }`. This declaration uses two inputs:

    model: {
      'cornfield id': function (cornfield, id) {
        return cornfield.get(id);
      }
    }

Armed with translations declared in this fashion, the latest version of [Faux][f] will sort everything out for us. It works out what to transform and when to transform it automatically on our behalf. If you're curious, this is what that code looks like at the moment:

    handler.roweis.satisfy = function (data, original_wanted) {
      var all_wanted = _(handler.roweis.translate).keys();
      var wanted = original_wanted || all_wanted;
      var try_satisfaction;
      do {
        satisifed_something = false;
        all_wanted = _(all_wanted).select(function (to) {
          return _.isUndefined(data[to]);
        });
        wanted = _(wanted).select(function (to) {
          return _.isUndefined(data[to]);
        });
        _(all_wanted).each(function (to) {
          _(handler.roweis.translate[to]).each(function (fn, froms) {
            froms = _.flatten(_(froms.split(',')).map(".split(' ')".lambda()));
            var values = _(froms).map(function (from) { return data[from]; });
            if (!_.any(values, _.isUndefined)) {
              data[to] = fn.apply(handler, values)
              satisifed_something || (satisifed_something = !(_.isUndefined(data[to])));
            }
          });
        });
      }
      while (satisifed_something && wanted.length);
      if (_.isArray(original_wanted)) {
        _(wanted).each(function (still_want, i) {
          original_wanted[i] = still_want;
        });
        var original_wanted_length = original_wanted.length;
        for (var i = wanted.length; i < original_wanted_length; ++i) {
          original_wanted.pop();
        }
      }
    }

Luckily, we don't have to look at it to use Faux! What we need to know is that whether you invoke the route `#/12345/67890` or call `controller.location({ seed: 12345, id: 67890 })`, Faux can sort out how to display the data in the location template. And should you call `route_to_location({ model: model })`, Faux can generate `#/12345/67890` using the translations as well.

**but...**

Obviously, there are a lot of lines of declaration involved.

We can and should continue to work on this. For example, we ought to be able to exploit our knowledge of [Backbone.js][b] to make a lot of this go away. If we already know that `params.model` is an instance of `Backbone.Model`, we should be able to infer the translation `id: { model: function (model) { return model.id; } }` automatically.

And in fact, work is underway to do this. But the key here is that this work is only possible because we have separated the definition of translations apart from the functional pipeline making up `controller.location(params)`. If those transformations were still embedded into the pipeline, work on inferring transformations would be difficult and error-prone. The result would be incredibly brittle.

This refactoring may not look like what most people call "Separation of Concerns." That's because most examples given for separating concerns emphasize *responsibility*. In simpler terms, most separation of concerns focus on deciding who is responsible for doing things and where those things should happen.

Whereas here we have split the definition of `controller.location(params)` according to *when* things can happen. Some things should continue to happen at specific stages of the function pipeline. Others can happen as soon as the data required to satisfy their `translate` definitions is available.

Separating code by when it needs to happen is a useful technique.

<hr/>
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.

[q]: http://weblog.raganwald.com/2006/06/my-favourite-interview-question.html
[ww]: http://weblog.raganwald.com/2007/03/why-why-functional-programming-matters.html
[f]: https://github.com/unspace/faux
[jg]: https://github.com/jamiebikies
[b]: http://documentcloud.github.com/backbone/
[pnp]: http://www.joeydevilla.com/2003/04/07/what-happened-to-me-and-the-new-girl-or-the-girl-who-cried-webmaster/ "What happened to me and the new girl (or: 'The girl who cried Webmaster')"
[gg]: https://www.youtube.com/watch?v=V94H7K_nu5A "Graham Kerr and Johnny Carson"
[o]: https://secure.wikimedia.org/wiktionary/en/wiki/osterducken
[m]: https://github.com/raganwald/misadventure
[a]: http://www.digitalhumanities.org/dhq/vol/001/2/000009/000009.html