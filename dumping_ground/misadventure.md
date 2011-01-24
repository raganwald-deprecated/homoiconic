Misadventure
---

*A little game written on top of Faux and Backbone.js*

**introduction**

[Misadventure][play] is a little game in the style of [Adventure][a]. Misadventure is written in Javascript and runs entirely in the browser. Misadventure's code makes use of the [Faux][f] and [Backbone.js][b] libraries. In this essay I will give you a brief tour of Misadventure's [code][source], showing how it uses Faux to structure its routes and templates as well as how it uses Backbone.js to organize its models and interactive view code.

**the game**

Open [http://unspace.github.com/misadventure][play] in your browser.

Misadventure starts inauspiciously:

<a target="_blank" href="http://min.us/mvkEt6y"><img src="http://i.min.us/jeaApo.png" border="0"/></a>

You notice that a *fragment* of [#/wake][wake] has been added to the URL. You have two options. If you experiment, you discover that closing your eyes doesn't appear to do anything at this point, but if you stand up and look around, you'll get something like this:

<a target="_blank" href="http://min.us/mvkEt6y#2"><img src="http://i.min.us/jefdsa.png" border="0"/></a>

The fragment has changed again, now it's [#/42492610216140747/7624672284554068][l1]. You can move North by clicking the link or pressing the up arrow on the keyboard. Things appear to be the same, but the fragment has changed again, now it's [#/42492610216140747/5682321739861935][l2]. Moving North one more time takes you to what appears to be a different page:

<a target="_blank" href="http://min.us/mvkEt6y#3"><img src="http://i.min.us/jeflO8.png" border="0"/></a>

And the fragment has changed yet again, now it's [#/42492610216140747/3916709493533819][l3]. We just moved North. What happens if we move South? Let's investigate. First, each possible move is a standard HTML link. There's no magic Javascript. Let's look at the link to move South. It's the same URL, but the fragment looks familiar: [#/42492610216140747/5682321739861935][l2]. That's interesting, it's the exact same fragment that we were on a move ago.

And looking at the page, we see that the link to move South is colored <font color='red'>red</font>. There's no special magic going on. It's a standard link and it goes to a place that's still in the browser's history, so it is styled differently, just like any other link. We'll see how that works later, but let's try something else.

Use the back button or back command in your browser. It takes you to your previous location, just as if each location int he maze is a standard web page with its own unique link. That's because each location does have a unique link and behaves exactly like a standard web page. This means that all of the things you or any user expects from a page in a browser work here. You can navigate forward and back, bookmark locations, even mail links to friends.

Did you notice that in this document we're using links for the fragments? If you travel to the game through the links, you wind up in exactly the same maze in exactly the same location. The links are *stable*. We'll come back to how that works when we look at the code, but it's a key point, so we'll emphasize it:

> Everything you see in Misadventure has a unique URL and works with your browser's existing mechanisms like bookmarks or navigating backwards and forwards. The URLs are stable and are not tied to a temporary "session."

You can continue to navigate your way through the corn maze. With patience and a little knowledge of how to recursively search a tree, you may eventually find your way to the exit and leave the corn maze:

<a target="_blank" href="http://min.us/mvkEt6y#4"><img src="http://i.min.us/jbJZZ8.png" border="0"/></a>

And by now you will not be surprised to discover that the final page has a fragment too: [#/42492610216140747/bed][bed]. Do you want to play again? Simply click [close your eyes][wake], and you'll find yourself playing in a brand new maze, with all different fragments. Have fun and when you come back, we'll take a look at the code that makes this work.

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