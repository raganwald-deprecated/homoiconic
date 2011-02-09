Misadventure, Part IV: Class Loading (Updated!)
===

*Misadventure is a little game written on top of Faux and Backbone.js*

**introduction**

[Misadventure][play] is a little game in the style of [Adventure][a]. Misadventure is written in Javascript and runs entirely in the browser. Misadventure is written in standard Model-View-Controller style, making heavy use of the [Faux][f] and [Backbone.js][b] libraries. In this series of posts I will give you a tour of Misadventure's [code][source], showing how it uses Faux to structure its routes and templates as well as how it uses Backbone.js to organize its models and interactive view code.

<a target="_blank" href="http://min.us/mvkEt6y#1"><img src="http://i.min.us/jeaApo.png" border="0"/></a>

This is Part IV, wherein we'll do a double-take and talk about loading classes. In [Part I][pi], we had an introduction to the game and its controller, and in [Part II][pii], we looked at controller methods and a simple view-free template. In [Part III][piii], we dived into controller methods that wire models, collections, views, and templates together with a look at `controller.location(...)`

index.html
---

Let's flash back to [index.html][index]: Here's the code that loads our Javascript files for us:

    <!-- hard requirements for Faux -->
    <script src="./javascripts/vendor/jquery.1.4.2.js"></script>
    <script src="./javascripts/vendor/async.js"></script>
    <script src="./javascripts/vendor/documentcloud/underscore.js"></script>
    <script src="./javascripts/vendor/documentcloud/backbone.js"></script>
    <script src="./javascripts/vendor/haml-js.js"></script>
    
    <!-- fixes for using haml-js with IE -->
    <script src="./javascripts/vendor/ie.js"></script>
    
    <!-- Faux -->
    
    <script src="./javascripts/vendor/faux.js"></script>
    
    <!-- other libraries we happen to like -->
    <script src="./javascripts/vendor/seedrandom.js"></script>
    <script src="./javascripts/vendor/functional/to-function.js"></script>
    <script src="./javascripts/vendor/jquery.combinators.js"></script>
    <script src="./javascripts/vendor/jquery.predicates.js"></script>
    
    <!--misadventure's controller -->
    <script src="./javascripts/controller.js"></script>

You'll notice we load exactly one file for Misadventure itself, [controller.js][cjs]. We've read about the controller, that's fine. But we've also read about some other backbone classes in the application like `Location`, `LocationCollection`, `LocationView`, and `BedView`. Where are they?

The answer is that `Location`, `LocationCollection`, and `LocationView` are in the file [location.js][ljs], and `BedView` is in the file [bed_view.js][bvjs], which Faux loaded for us. But we haven't loaded these Javascript files. How does Faux know to load them?

loading javascript by convention
---

Faux is able to load Javascript files automatically, provided they are named appropriately. Faux may try to load a Javascript file if it is looking for a class but that class hasn't been defined. Let's say Faux is looking for a class named `WunderBar` while defining a method named `show_bar`. Faux's rules are:

1. If there is a class named `WunderBar`, use it.
2. If there is no class named `WunderBar`, but there is a file named `show_bar.js`, load that file.
3. If there is no a file named `show_bar.js`, or there is a file but loading it doesn't define a class named `WunderBar`, look for a file named `wunder_bar.js` and load it.

Misadventure takes advantage of two of these rules to demonstrate how they work. There is a file named `location.js`, so Faux loads it when defining `controller.location(...)`. There is no file named `wake.js` or `wake_view` or anything else like that, so Faux doesn't find any classes associated with `controller.wake()`. There is no file named `bed.js`, but there is a file named `bed_view.js`, so Faux is able to load it and define the `BedView` class.

**a standard for organizing javascript files**

Looking at Faux's rules, you can see that it strongly encourages organizing your Backbone.js model, collection and view classes in files named after the classes or after the methods.

In simple cases, you can place each class into a file using underscores instead of CamelCase, e.g. `bed_view.js` for the `BedView` class. This works well when the class does not have any dependencies on other models, collections, or views. This does not work for classes that have dependencies that need to be resolved.

Unlike frameworks such as Ruby on Rails, Faux does not dynamically resolve dependencies. Consider the class `LocationCollection`:
    
    window.LocationCollection = Backbone.Collection.extend({
      
      model: Location,
      
      // ...
  
    });

`LocationCollection` has a *dependency* on the class `Location`. If we place `LocationCollection` in `location_collection.js`, Faux will load it when sorting out the `controller.location(...)` method, but Faux does not guarantee the load order. Therefore, it might try to load `location_collection.js` before the class `Location` has been resolved and fail to define `LocationCollection` properly.

Now let's be specific about the word "dependency." There are two forms that matter to Faux. First, there are _define-time dependencies_. This is code that is run when you define your methods. The dependency between `LocationCollection` and `Location` is a define-time dependency, because `Location` will be resolved when the `LocationCollection` class is created. There are also _run-time dependencies_. Consider this code from `controller.js`:

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
      
      // ...
      
Clearly all of our methods depend on `LocationCollection` at run time because `function (seed) { return LocationCollection.find_or_create({ seed: seed }); }` depends on `LocationCollection`. However, this doesn't matter to us because that function won't be evaluated until a controller method is invoked, by which time `LocationCollection` will have been defined. (*Note: If a run-time function depends on a class that Faux will not automatically load for you, you must load the class's definition yourself.*)

But back to our problem with `LocationCollection`. It _does_ have a define-time dependency on the class `Location`. For this reason, we choose to organize the classes for `controller.location(...)` into a file named after the method, `location.js` (as is common with Faux definitions, the name of this method is the same as the name of the main model class, but either way it is loaded _first_ before Faux tries to resolve individual classes for this method):

    window.Location = Backbone.Model.extend({ ... });
    
    window.LocationCollection = Backbone.Collection.extend({
      
      model: Location,
      
      // ...
  
    });

Now `Location` is guaranteed to resolve when resolving `LocationCollection` because they are in the same file. This is a simple case. In more complex applications you will run into dependencies between model classes. In such cases, you can always override Faux's rules by loading the files yourself using `<script>` tags or with `jQuery.getScript(...)`.
  
**you're in control**

You can disable this behaviour for your entire application or within a scope with the configuration option `dynamic`. To disable all dynamic class loading:

    dynamic: {
      method: false,
      clazz: false
    }
    
    // or...

    dynamic: false

To disable loading of class files but allow loading of method files:

    dynamic: {
      method: true,
      clazz: false
    }

To disable loading of method files but allow loading of class files:

    dynamic: {
      method: false,
      clazz: true
    }

To enable both:

    dynamic: {
      method: true,
      clazz: true
    }
    
    // or...
    
    dynamic: true

**summary**

If you place your classes in files named after your methods or after the classes themselves, Faux will load them for you and save you the trouble of explicitly loading every file. You can always override this behaviour by explicitly loading Javascript files and/or by explicitly forbidding Faux from trying to load Javascript files by convention.


[index]: http://github.com/unspace/misadventure/tree/master/index.html
[js]: http://github.com/unspace/misadventure/tree/master/javascripts
[pi]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_i.md#readme
[pii]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_ii.md#readme
[piii]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_iii.md#readme
[piv]: http://github.com/raganwald/homoiconic/tree/master/2011/02/misadventure_part_iv.md#readme
[cjs]: http://unspace.github.com/misadventure/docs/controller.html
[play]: http://unspace.github.com/misadventure/
[a]: http://www.digitalhumanities.org/dhq/vol/001/2/000009/000009.html
[b]: http://documentcloud.github.com/backbone/
[source]: http://github.com/unspace/misadventure
[f]: https://github.com/unspace/faux
[ljs]: http://unspace.github.com/misadventure/docs/location.html
[bvjs]: http://unspace.github.com/misadventure/docs/bed_view.html