MVC, PVC and (¬M)VC
===

**preamble**

This essay gives some background on two separate architecture patterns: The separation of domain logic from application logic, and the implementation of an application using the model-view-controller ("MVC") pattern. The integration of the two patterns is discussed and two alternatives to MVC are described. In the first alternative, the models in the application are proxies for resources in the domain logic server. In the second alternative, the application's controllers make RESTful calls directly to the domain logic server omitting models entirely.

This essay's thesis is that when separating domain logic from application logic, domain logic can be implemented as a RESTful domain logic server. When doing so, the application can be implemented as an application server with models replaced by proxies to the domain server's resources such as with ActiveResource in Rails.

The application can also be implemented as a single page interface in JavaScript. SPI applications can use the PVC architecture to create proxies. In simple, coarse-grained cases, SPI applications can forgo models and tightly couple the controllers to the domain logic server, a practice known as the (¬M)VC architecture. MVC and/or PVC is a better fit for SPI applications that are fine-grained and resemble desktop applications rather than web applications.

**a long and barely relevant anecdote** (feel free to skip this or come back to it later)

A long time ago, I worked on the development of a Java programming tool called JProbe Threadalyzer. Threadalyzer instrumented some running Java code and watched it for certain patterns of behaviour that indicated the possible presence of a threading bug. For example, if one thread were to obtain locks A and B in that order before accessing a shared resource and then at a later time any thread were to obtain locks B and A in that order (note the difference), Threadalyzer would alert the programmer that there was a possible bug. Although the code did not enter a deadlock, *if* two different threads were to try to obtain locks A, B, and B, A there might be a deadlock where one thread held A while waiting for B and another held B while waiting for A.

There were a number of independent "analyzers" with little descriptions of scenarios they were awaiting. The above analyzer was called "Lock Ordering," and the programmer using the tool could turn it off, only analyze certain code with it, and so on. Threadalyzer was a kind of lint that observed running programs rather than inspecting static code.

<img src="http://australia.quest.com/japan/java_and_portals/jprobe/images/jp40_launchpad.gif" height="532" width="705"/>

Although test-first or test-driven development was not a wide-spread practice at the time, we were enamoured of the idea because at its core, Threadalyzer had very specific documentable test cases to work with that ought to be easy to automate. We also perceived a large risk of regressions as we built Threadalyzer out. We were doing things like mutating Java byte codes code on the fly, and we worried that the modifications we made for one analyzer might break the behaviour of another.

At that time, C++ testing frameworks were rather [grody][valspeak], so we kept automated testing simple: We built the core of Threadalyzer as a command-line application, even though command-line functionality was *not* a business requirement. All configuration was done through a configuration file. Our test suite was written as shell scripts.

Threadalyzer had a UI that was built by a colleague. Early versions of the user interface actually talked to the core application through the command line. The user interface was written using Java Swing because our company's policy was to eat the Java dog food whether it was palatable or not. As an aside, I also recall writing a UI for editing Threadalyzers configuration files using a cross-platform implementation of Hypercard called [Metacard][mc]. Despite working perfectly, it was later rewritten with Java Swing by a coöp student.

Although we didn't have a grand architectural desire to "use best practices," we ended up with an application strongly factored into two components: A domain logic engine and a user interface.

**domain logic vs. application logic**

Flash forward to today and many enterprise-scale business applications are built with a similar architecture. An internal domain logic server talks to various resources like databases or legacy, screen-scraped applications. The domain logic server exposes an API for performing queries and updates in XML or JSON over a mechanism like MQ or perhaps HTTP. The domain logic server enforces business rules and atomicity. For example, an online bank might have a certain rules about eligibility for opening a new type of account. If the applicant fails these automated rules, they must speak to a customer service representative. Those rules are enforced by the domain logic server.

![servers](http://github.com/raganwald/homoiconic/raw/master/2010/10/servers.png)

Sitting on front of the domain logic server are various application servers. In an online shopping company, there might be a web application server for customers to shop, while an entirely different server is used for internal customer service staff, and a third server is used for fulfillment applications. All of the application servers talk to the domain logic server, not directly to databases. Therefore, they concern themselves with implementing a user interface, not with enforcing business rules.

> **An example domain logic rule**: If a banking application is built as a traditional domain logic server, transferring funds from one account to another must be implemented in a single call. The domain logic rule that funds debited from one account must exactly correspond to funds credited to another account must be enforced by the domain server, not by an application server. The domain logic server is the one that must use the database's transaction mechanism to ensure that the operation is atomic.

**REST**

Meanwhile, outside of the enterprise, there has been a grassroots movement towards [REST][rest]ful web services. A RESTful server exposes a set of resources and a fixed vocabulary of verbs that express operations on those resources. If the server makes the guarantee that each operation performed on resource transitions the server from one valid state to another, a RESTful server is indistinguishable from a traditional domain logic server.

> Clients are separated from servers by a uniform interface. This separation of concerns means that, for example, clients are not concerned with data storage, which remains internal to each server, so that the portability of client code is improved. Servers are not concerned with the user interface or user state, so that servers can be simpler and more scalable. Servers and clients may also be replaced and developed independently, as long as the interface is not altered. --Wikipedia

In the example given above, the domain logic server must expose a transfer as a single operation. This can be implemented in REST by treating transactions as resources. A client can attempt to create a new transfer, and the transfer is either created or not in what appears to be a single operation. If the transfer is created, the balances of the account resources change as a side effect.

RESTful servers are also unconcerned with user interfaces. Thus, domain logic servers can easily be implemented RESTfully, with the user interfaces being managed by application servers.

**MVC**

The dominant architecture for building non-web interactive applications is [Model-View-Controller][mvc], or MVC. It is at least thirty years old, having been incorporated into Smalltalk. Quoting liberally from Wikipedia:

* The **model** is used to manage information and notify observers when that information changes. The model is the domain-specific representation of the data upon which the application operates. Domain logic adds meaning to raw data (for example, calculating whether today is the user's birthday, or the totals, taxes, and shipping charges for shopping cart items). When a model changes its state, it notifies its associated views so they can be refreshed.
* The **view** renders the model into a form suitable for interaction, typically a user interface element. Multiple views can exist for a single model for different purposes. A viewport typically has a one to one correspondence with a display surface and knows how to render to it.
* The **controller** receives input and initiates a response by making calls on model objects. A controller accepts input from the user and instructs the model and viewport to perform actions based on that input.
* An MVC application may be a collection of model/view/controller triads, each responsible for a different UI element.

![MVC](http://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/ModelViewControllerDiagram2.svg/500px-ModelViewControllerDiagram2.svg.png)

MVC has become very popular with web developers. Frameworks like [Ruby on Rails][rails] provide support for MVC "out of the box."

**the MVC/REST impedance mismatch**

MVC is a good thing. Or at least, it's a good thing until you want to combine MVC with REST in the same server. A RESTful server does not know anything about the views and controllers used to build a client application. This is implicit in the REST architecture: The RESTful server simply exposes an API for operations on resources, and a client of that server implements the user interface.

If you're *very* careful you can essentially build two servers in one process, where the resources are implemented as models and the client-facing controllers limit themselves to ONLY interacting with resources. This design invariably degrades over time as programmers take shortcuts. Domain logic creeps into interface controllers, and you're hosed.

Another fragile way out is to build your UI around the RESTful API. In the case of an online bank, since a transfer is implemented as the creation of a transfer resource, there would be one form for transferring funds on the screen and submitting the form would send a POST to the server.

This works up to the point where your user interface no longer maps 1:1 to the RESTful interface. For example, you may wish to have one page in the user interface make multiple calls to the RESTful server, e.g. a view that displays an account's meta-information (obtained with `GET /accounts/42`). Another view might have the list of transfers: `GET /accounts/42/transfers`. If you wish to combine the meta-information with the list of transfers, you could bundle the list of transfers in with the meta-information, but again you've leaked user interface logic into a domain logic server.

The robust way to combine MVC and REST is to fall back on the traditional domain logic/application logic separation and build two servers, where the application logic server is entirely disjoint from the domain logic server. The two can run inthe same process if need be, and communicate via any handy mechanism, e.g. `curl`, HTTP, or a [message queue][mq].

**whither the model?**

Given a RESTful domain logic server and an MVC application server, who owns the models? Clearly, the RESTful server owns the domain logic, and therefore the logic that is traditionally thought of as "model logic." So if we look in the application server, what models do we expect to find?

First, the trivial case is that the application server omits models. In a Rails application server, the controllers that handle user actions and populate views with data can communicate directly with a RESTful domain logic server. In an application server, this is usually an anti-pattern, and while you could call it a "VC Architecture," I reserve that term for technical architectures that are driven by what the architect thinks will play well when raising money. Instead, I use the term "(¬M)VC," pronounced "not M, VC" to describe an architecture where the views and controllers are tightly coupled to the notion that the models are managed by a separate server.

**PVC**

An improved architecture for application servers is that the models in the application server are proxies for the resources exposed by the RESTful domain logic server. Ruby on Rails supports this pattern with [ActiveResource][active_resource]. The application server is built using pure MVC, however the models don't contain business logic, all operations on them are forwarded to the domain logic server through REST. I personally nickname this pattern "PVC" for Proxy-View-Controller.

![proxy-view-controller](http://github.com/raganwald/homoiconic/raw/master/2010/10/pvc.png)

The benefit of using PVC is that the concern of how to communicate with the domain logic server or servers is separated from controller logic. What if communication is over HTTP but you want to change it to RabbitMQ when loads increase? PVC manages this transition easily. Likewise, if the application grows and some resources are obtained from one server and some from another, this distinction is managed by the proxies and not by the controllers that use them.

Up to now we've discussed a two server architecture. There's a domain server and there's an application server. Implied in this architecture is a third entity, a client web browser. Another architecture choice is a domain server and a client web *application*, where the application is written in JavaScript, ActionScript, or some other technology. This essay will confine itself to talking about JavaScript [Single Page Interface][spi] ("SPI") applications.

If the SPI application features certain types of interactivity, implementing PVC makes sense. For example, if the application polls for model changes and may update a variety of view with the updated data, models are necessary and a proxy library such as [backbone.js][backbone] will do the trick. Such an application still benefits from separating controllers and views from models, so you end up with proxies, views, and controllers as separate entities with separate responsibilities.

![proxy-view-controller in an SPI application](http://github.com/raganwald/homoiconic/raw/master/2010/10/spi_pvc.png)

**(¬M)VC**

In an SPI application, the transport mechanism used to talk to the domain logic server is fixed, it's HTTP. In simple applications, there is less incentive to use model proxies. Under those circumstances, hard-wiring controllers to talk directly to the domain logic server is less painful. Removing the model proxy layer of indirection may be a win.

An SPI application using (¬M)VC will have separate views and controllers, however the controllers will talk directly to the domain server. For example, here is some code that uses a pre-release prototype of [Unspace Interactive][u]'s [Roweis][roweis] SPI framework to configure a view in (¬M)VC style:

    .view('institution', { 
      route: 'institution/:_id',
      gets: {
        institution: '/institutions/:_id',
        m_and_e_list: '/institutions/:_id/me'
      },
      partial: 'singular'
    })
      
With this definition, when the browser hash is changed to `#/institution/42`, the framework performs a `GET /institutions/42` and a `GET /institutions/42/me` from the domain logic server and populates the local variables `institution` and `m_and_e_list` with the results. The template `singular` (likely found at `/haml/institutions/singular.haml` for reasons not shown in this snippet) displays the result.

![(¬M)VC](http://github.com/raganwald/homoiconic/raw/master/2010/10/vc.png)

In many simple cases, the programmer writing the application is working with a fixed domain logic server. Writing the RESTful URL is simpler than using a Collection Proxy and indirectly performing the GET by calling `.fetch` on the proxy.

**(¬M)VC's greatest hit**

(¬M)VC's greatest strength is its greatest weakness. (¬M)VC pushes the access of resources into controllers. It's a great fit for SPI applications that begin their life as ports of a standard web-backed MVC application server: The controllers that would normally be written in the server are written in the client, the view templates are also pushed down into the client, and there is an inherent idea of a loop where the user invokes an URL (by using a link to change the hash or by submitting a form), and the SPI application runs the action through a controller, exchanges data with a RESTful domain server as appropriate, then displays the appropriate view.

We say that the controllers and views of an (¬M)VC application are *coarse-grained* because they operate on large views and in a big looping cycle based on user clicks and submits.

This basic (¬M)VC pattern is thus a very good fit for applications that have an interface that strongly resemble a web application. The UI maps well to web "pages." Of course, it is superior to a traditional server-based web application in many ways: It need only fetch and refresh portions of a page, it can perform certain refreshes in the background, and so on.

And such an application is easy for the web-centric programmer to build and maintain. After all, it looks a lot like a standard web application. A Roweis application is instantly familiar to a Rails programmer. That's often a good thing.

However, if you want to take full advantage of the interactivity possible in a client-side application, you may want to do things that are impractical with a constant looping through controllers and views. You want  *fine-grained* controllers. For example, if your application has a video player with controls for playback, the (¬M)VC notion of a controller that talks to a domain server before populating a view with data is a poor fit.

Likewise, if you have the possibility of updating multiple different views when a single resource changes, (¬M)VC is a poor fit: (¬M)VC is based around controllers that fetch and populate.

When you have these fine-grained interface elements, a true MVC architecture is a better fit. Controllers update models, and views update themselves when the models change. Some models may be proxies for domain logic resources. They may also have additional logic of their own that is only relevant in the client user interface. The controls for playing a video are of no interest to a domain logic server. A fine-grained application like this is very different from a web application. While it may not be familiar to the web specialist, a desktop programmer such as a Smalltalk expert will be right at home. 

> Be careful of tying your JavaScript applications (SPI, in the essay's parlance) too tightly to specific URLs and HTTP requests, ... what happens if you want to load a handful of institutions in the background, without changing the URL? What happens if you'd like to not repeat the institution request if the data has already been loaded once? Being able to work with model data in sophisticated ways is the heart of JavaScript applications&#8212;if you omit models from a JS app, it might feel like a simplification at the beginning, but as soon as you want to perform an interesting computation, optimization, or rendering trick, you'll start to regret it. &#8212;[Jeremy Ashkenas](http://news.ycombinator.com/item?id=1804570)

Thus, (¬M)VC is a good fit when the controllers and interaction is expected to be coarse-grained, but PVC and/or MVC is a better fit when the controllers and interaction are expected to be fine-grained.

**summary: moving from MVC to PVC or (¬M)VC**

We've had a brief look at two separate architecture patterns: The separation of domain logic from application logic, and the implementation of an application using the model-view-controller ("MVC") pattern. We've looked more closely at implementing domain logic in a RESTful domain logic server and implementing the UI in an MVC application server with models replaced by proxies.

We've also seen that the application can be implemented as a single page interface in JavaScript. In simple, coarse-grained cases, SPI applications can forgo models and tightly couple the controllers to the domain logic server in (¬M)VC style. Applications that are fine-grained and resemble desktop applications rather than web applications should prefer PVC style.

---

Discuss this post on [Hacker News](http://news.ycombinator.com/item?id=1803432). NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[u]: http://unspace.ca
[spi]: http://itsnat.sourceforge.net/php/spim/spi_manifesto_en.php "The Single Page Interface Manifesto"
[valspeak]: http://en.wikipedia.org/wiki/Valspeak "Valspeak"
[mc]: http://www.metacard.com/ "MetaCard: Cross Platform Multimedia Authoring and Application Development"
[rest]: http://en.wikipedia.org/wiki/Representational_State_Transfer "Representational State Transfer"
[mvc]: http://en.wikipedia.org/wiki/Model%E2%80%93View%E2%80%93Controller "Model–View–Controller - Wikipedia, the free encyclopedia"
[rails]: http://rubyonrails.org "Ruby on Rails"
[impedance_mismatch]: http://duckduckgo.com/Object-relational_impedance_mismatch "Object-relational impedance mismatch - Wikipedia, the free encyclopedia"
[mq]: http://en.wikipedia.org/wiki/Message_queue
[active_resource]: http://api.rubyonrails.org/files/activeresource/README_rdoc.html
[backbone]: http://documentcloud.github.com/backbone/
[roweis]: http://github.com/raganwald/roweis#readme