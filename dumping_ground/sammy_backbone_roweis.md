Sammy, Backbone, and Roweis
===

> Hi,

> Roweis was my best bet for a better [Sammy](http://code.quirkey.com/sammy/index.html). I was just about to message you when Backbone came out. Have you looked at the lib yet? I believe it's bound for client-side greatness. It seems to be missing a router though... Could Roweis be what makes it perfect, or are you on diverging paths?

> I'm about to refactor this [http://staging.astrolet.net/charts](http://staging.astrolet.net/charts) (a Padrino api / site design) into a single-page js app. Glad to have waited and not in a great hurry, as I think the client-side is on the verge of becoming obvious... I'm guessing you may already be stuck with a bunch of made choices, so another question is if you'd do anything differently today (i.e. if you were starting fresh rather than extracting from existing apps)?

> Cheers,  
> Orlin

Thanks your your email, Orin! And thank you for permission to answer your question in a public forum. The short answer is, although the [Backbone](http://documentcloud.github.com/backbone/ "Backbone.js") library provides excellent support for building Models, Views, and Controllers in Javascript, and although it also provides support for routing and history, we are very happy to continue to work on Roweis.

We don't think Roweis supplants Backbone or Sammy. We do think Roweis *complements* Backbone for a certain class of [Single Page Interface](http://itsnat.sourceforge.net/php/spim/spi_manifesto_en.php) ("SPI") applications.

The problem trying to solve is how to structure applications with two characteristics: First, applications with a strong sense of location (which you describe in terms of the implementation, namely a router), and second, applications backed by a RESTful domain server.

As you know, Backbone implements MVC and what we call "PVC," an abbreviation for [Model Proxies, Views and Controllers](https://github.com/raganwald/homoiconic/blob/master/2010/10/vc_without_m.md#readme). Backbone has recently added routing, so that problem is solved. Roweis extends Backbone's functionality by prov

Our experience with Domain-Specific Languages and with [Convention over Configuration](http://en.wikipedia.org/wiki/Convention_over_configuration "Convention over configuration - Wikipedia, the free encyclopedia") has been very positive. What Roweis provides for us is a way of building a Backbone-based application using declarations rather than writing code that wires up the application through side-effects. We are not trying to provide an "abstraction" that hides Backbone's models, views, or controllers from programmers.

Our application is built in two "layers:" Most of the base is a collection of "locations." Locations are places in the applications that behave like web pages: They have bookmarkable URLs, they appear in the history, they have human-readable titles. We think of "routing" as a description of part of the implementation needed to make locations work. The other layer is a collection of Backbone views.

Most of what Roweis does is interpret declarations and build views from the declarations the are wired to routes. Given that our declarations are a kind of domain-specific language, you will not be surprised to know we have added a bunch of conveniences such as scopes, aspects (a/k/a `before_` and `after_` methods), and much more convenience around using templates in the form of partials.

I wrote that most of the base layer is a collection of locations built with a declarative syntax. We also introduce the notion of an "unobtrusive view." Backbone views are associated with elements. Roweis unobtrusive views are a way of binding a view to a jQuery selector and then having the view be instantiated and its model populated automatically when a DOM element matching the selector is rendered in the page.

We use unobtrusive views a lot to build user interfaces that have nested views. It's a practice we actually [snarfed](http://snarfed.org/ "snarfed.org | Ryan Barrett&#039;s blog") from the 