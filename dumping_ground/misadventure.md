Misadventure
---

*A little game written on top of Faux and Backbone.js*

**introduction**

[Misadventure][play] is a little game in the style of [Adventure][a]. Misadventure is written in Javascript and runs entirely in the browser. Misadventure's code makes use of the [Faux][f] and [Backbone.js][b] libraries. In this essay I will give you a brief tour of Misadventure's [code][source], showing how it uses Faux to structure its routes and templates as well as how it uses Backbone.js to organize its models and interactive view code.

**the game**

Open [http://unspace.github.com/misadventure][play] in your browser.

Misadventure starts inauspiciously:

<a target="_blank" href="http://min.us/mvkEt6y"><img src="http://i.min.us/jeaApo.png" border="0"/></a>

You notice that a *fragment* of [#/wake][wake] has been added to the URL, but the base URL hasn't changed. Since Single Page Interface architecture is all the rage these days, you already know that this means that the contents of the page are being loaded into the DOM without refreshing the entire page. That requires much less bandwidth and scales faster than rendering pages from the server.

Let's get back to using the game. You have two options. If you experiment, you discover that closing your eyes doesn't appear to do anything at this point, but if you stand up and look around, you'll get something like this:

<a target="_blank" href="http://min.us/mvkEt6y#2"><img src="http://i.min.us/jefdsa.png" border="0"/></a>

The fragment has changed again, now it's [#/42492610216140747/7624672284554068][l1]. You can move North by clicking the link or pressing the up arrow on the keyboard. Things appear to be the same, but the fragment has changed again, now it's [#/42492610216140747/5682321739861935][l2]. Moving North one more time takes you to what appears to be a different page:

<a target="_blank" href="http://min.us/mvkEt6y#3"><img src="http://i.min.us/jeflO8.png" border="0"/></a>

And the fragment has changed yet again, now it's [#/42492610216140747/3916709493533819][l3]. We just moved North. What happens if we move South? Let's investigate. First, each possible move is a standard HTML link. There's no magic Javascript. Let's look at the link to move South. It's the same URL, but the fragment looks familiar: [#/42492610216140747/5682321739861935][l2]. That's interesting, it's the exact same fragment that we were on a move ago.

And looking at the page, we see that the link to move South is colored <font color='red'>red</font>. There's no special magic going on. It's a standard link and it goes to a place that's still in the browser's history, so it is styled differently, just like any other link. We'll see how that works later, but let's try something else.

Use the back button or back command in your browser. It takes you to your previous location, just as if each location int he maze is a standard web page with its own unique link. That's because each location does have a unique link and behaves exactly like a standard web page. This means that all of the things you or any user expects from a page in a browser work here. You can navigate forward and back, bookmark locations, even mail links to friends.

Did you notice that in this document we're using links for the fragments? If you travel to the game through the links, you wind up in exactly the same maze in exactly the same location. The links are *stable*. We'll come back to how that works when we look at the code, but it's a key point, so we'll emphasize it:

> Everything you see in Misadventure has a unique URL and works with your browser's existing mechanisms like bookmarks or navigating backwards and forwards. The URLs are stable and are not tied to a temporary "session."

You can continue to navigate your way through the corn maze. Try using an arrow key instead of clicking a link. With patience and a little knowledge of how to recursively search a tree, you may eventually find your way to the exit and leave the corn maze:

<a target="_blank" href="http://min.us/mvkEt6y#4"><img src="http://i.min.us/jbJZZ8.png" border="0"/></a>

And by now you will not be surprised to discover that the final page has a fragment too: [#/42492610216140747/bed][bed]. Do you want to play again? Simply click [close your eyes][wake], and you'll find yourself playing in a brand new maze, with all different fragments. Have fun and when you come back, we'll take a look at the code that makes this work. 

**summary of what we've learned from misadventure's user experience**

Before we look at the code, here's a quick summary of what we've seen:

1. Every "page" has its own unique URL
2. Pages all have the same base URL, but the fragments change
3. The DOM is being refreshed in the browser
4. The URLs are stable and can be bookmarked or shared with other users
5. All standard navigation elements (e.g. back, forwards, links) work in standard ways
6. Misadventure also supports non-standard navigation in the form of arrow keys

Now we'll see how Misadventure uses Faux and Backbone.js to make this happen.

**code overview**

Misadventure is organized in a tree:

<a target="_blank" href="http://min.us/mveGGAQ"><img src="http://i.min.us/jeaE9S.png" border="0"/></a>

Ignoring `README.md`, `docs`, `images`, and `stylesheets`, we're going to look at [index.html][index] and the two most important directories in the project: [javascripts][js] and [haml][haml].

[index]: http://github.com/unspace/misadventure/tree/master/index.html
[js]: http://github.com/unspace/misadventure/tree/master/javascripts
[haml]: http://github.com/unspace/misadventure/tree/master/haml

`index.html` contains the web page you see when you open Misadventure for the first time. Here's the source:

    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>Misadventure</title>
        <meta charset="utf-8">
        <link href="./stylesheets/application.css" rel="stylesheet">
        <!-- hard requirements for Faux -->
        <script src="./javascripts/vendor/jquery.1.4.2.js"></script>
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
        <!--misadventure's javascript -->
        <script src="./javascripts/models.js"></script>
        <script src="./javascripts/views.js"></script>
        <script src="./javascripts/controller.js"></script>
      </head>
  
      <body>
    
        <div id="container">
          <h1>Misadventure</h1>
          <div class="content"></div>
  
        </div>    
    
        <small id="get-code">Read about Misadventure and browse the code on <a href="http://github.com/unspace/misadventure">Github</a>.</small>
  
      </body>

      <!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.

      To the extent possible under law, Unspace Interactive has waived all copyright 
      and related or neighboring rights to the software, except for those portions
      that are otherwise licensed.

      This work is published from Canada. -->

    </html>
    
A few points of interest:

1. We include jQuery, Underscore, Backbone.js, amd haml-js before we include Faux;
2. Misadventure's own files are [models.js][mjs], [views.js][vjs], and [controller.js][cjs];
3. There's a very interesting DOM element, `<div class="content"></div>`.

Looking in the [haml][haml] directory, we see three [Haml][haml-lang] templates: `wake.haml`, `location.haml`, and `bed.haml`. We're going to see where those are used shortly.

**controller.js**

Let's look at [controller.js][cjs]. It's the last file to be loaded, and it starts the application for us. Eliding the comments, we have:

    ;(function () {

    var controller = new Faux.Controller({
      location: true,
      model_clazz: true,
      element_selector: '.content',
      partial: 'haml',
      partial_suffix: '.haml',
      title: 'Misadventure'
    });

    controller

      .begin({
        'seed=': {
          locations: function (locations) { return locations.seed; }
        },
        'locations=': {
          seed: function (seed) { return LocationCollection.find_or_create({ seed: seed }); }
        }
      })

        .method('wake', {
          'locations=': function () { return LocationCollection.find_or_create(); }
        })

        .begin({
          route: ':seed'
        })

          .method('bed')

          .method('location', {
            route: ':location_id'
          })
    
          .end()
    
        .end()
  
        ;


    $(function() {
      Backbone.history.start();
      window.location.hash || controller.wake();
    });
	
    })();

The first statement creates a new instance of `Faux.Controller`. Faux controllers extend Backbone.js's [controllers][bc]. When the program is running, they parse fragments and manage the history so that invoking an URL through a link results in calling a controller method.

Faux the library is nothing more than a backbone controller that has a bunch of helpers for writing Backbone.js controller methods for us. The most important such helper is the `.method` method. Looking at `controller.js`, you can se that we call `.method` three times:

    .method('wake', { ...configuration... })

    .method('bed')

    .method('location', { ...configuration... })
    
We now have enough information to explain Misadventure's basic structure:

1. There are three controller methods invoked during gameplay: `.wake(...)`, `.location(...)`, and `.bed(...)`
2. Each of those controller methods has a route, and Backbone.js will invoke the controller method when the browser invokes the URL.
3. The controller methods that Faux writes will use the templates `wake.haml`, `location.haml`, and `bed.haml` to display content in the page.
4. The content will be injected into the `<div class="content"></div>` DOM element on the page.

We haven't explained anything else about views, models, parsing parameters out of URL, or even defining which URLs invoke which methods yet. All of these things are driven by convention and configuration (preferring convention over configuration, of course).

Let's look at how each method is configured.

**in the beginning**

Faux methods are configured with objects, usually object literals. 

[bc]: http://documentcloud.github.com/backbone/#Controller

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