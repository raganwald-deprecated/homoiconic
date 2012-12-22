# Programming's Walled Gardens

This essay is about my own personal programming anti-pattern. Well, not personal in the sense of me being the only person who does this, but personal in the sense of this being a recurring problem. I call this anti-pattern **Walled Gardens**. Others, especially colleagues, have less printable ways to describe it.

[![Entrance to the old walled garden.. by ronsaunders47, on Flickr](http://farm9.staticflickr.com/8209/8200129155_31c282579e.jpg)](http://www.flickr.com/photos/ronsaunders47/8200129155/)

A "Walled Garden" is a web site or application that lives within an interoperable, open ecosystem but it presents a collection of proprietary tools and services that have very limited interaction with the open, free standards outside. The usual way these things get built is that the walled garden offers some advantages over free alternatives, and users choose the walled garden out of a practical need to have the best tools.

But over time, the open, free alternatives catch up to and eventually surpass the tools provided inside the garden, however users find it difficult to leave because of some lock-in effect such as all the other users in the garden, or data that is in proprietary formats. Gradually the garden lags the open marketplace. Development slows, leaving the trapped users stuck in an unproductive, difficult environment.

### walled gardens in the marketplace

Proprietary walled gardens in software development are easy to spot. In the 1980s, there was a huge category of development environments called "4GLs." They were integrated systems that included a database of some sort, a visual designer, a proprietary scripting language, and some kind of distribution runtime or compiler mechanism. They were very good for putting together small business applications.

![Modify Style in Tableau](http://i.minus.com/iobFOZr9kZLZ9.gif)

I used one called [4th Dimension](http://www.4d.com) to create software that managed classified advertising for desktop publishers. Apple's HyperCard was discontinued, but now lives on as [Runtime Revolution](http://www.runrev.com) in mobile devices. I remember building a configuration wizard for some shrink-wrapped software with it. I had a cross-platform desktop app with a GUI running in less than an hour. Rumour has it that the largest ecosystem for programmers is Microsoft Excel. Access probably isn't far behind. And there's some thingummy called Flash that people seem to like when they want to break your browser, make undeletable tracking cookies, or inject a virus into your operating system.

Please note that I am not talking about developing for a platform, like developing for iPhone as opposed to developing for the "mobile web." I'm talking about the tools used to do the development. It's very easy to have walled garden tools that target an open platform. Runtime Revolution, for example, can deliver Unix applications. 

These commercial walled gardens are easy to spot. It's difficult to call them an anti-pattern: They help people make things people like. Eventually the free market catches up to these things, but in 1988 it was no good sticking your nose up in the air and telling everyone to write classified advertising software in C++.

So you have to, as Sean Kelly would say, "Make the calculation," and decide for yourself if the ease of use today trumps the eventual dead end your software will fall into. If so, you may choose to build for the walled garden. The calculation is plain, and one of the reasons most people stop to at least think about the consequences of developing for a walled garden is that it is very clear that you are developing for someone else's walled garden. You may decide it's a good idea, you may decide to do something else, but you're keenly aware that you are adding a dependency on some other organization to your software.

### walling yourself in

Although I have used commercial walled gardens, I don't consider that an anti-pattern. The anti-pattern is where you build *yourself* a walled garden. Meaning, you are designing a piece of software and you build yourself a platform for building the software. The most famous examples of this escape to the outside world and become successful, like Ruby on Rails or Backbone.js.

But typically, they do not escape to the outside world and become an extra layer of complexity in your architecture. Someone learning to work with your code (like you after a long absence) must learn the application, the domain, *and* your platform. Unlike popular platforms, your platform does not benefit from having "many eyes" making its bugs shallow. There are no screencasts or books explaining how to use it. Nothing in StackOverflow. It exists in its own tiny bubble, lagging further and further behind the state of the art in the open development world with every passing day.

I would never do this. [Not even once](https://github.com/raganwald-deprecated/faux).

YouAreDaChef
CoffeeScript
Partial

I've been interested in Combinators for a very long time. It started with the amazing book [To Mock a Mockingbird][mock], and from there I've looked for ways to incorporate them into my programming.

[mock]: http://www.amazon.com/gp/product/0192801422?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0192801422