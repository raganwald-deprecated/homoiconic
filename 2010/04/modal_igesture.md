A Modal Interface with iGesture
===

Last night I pushed a new [iGesture][ig] demo to Github, [Combining Gestures with Dragscrolling][drag]. As usual for me, it looks like rubbish. What you see is a 500px square portion of a Star Wars wallpaper image, something like this:

![Slave I in Low Earth Orbit][slave]

Swiping the image to the left or the right changes it to one of nine other Star Wars images. You'll see the new image slide into the viewport. So far, we have exactly the same swipe to navigate interface as in my [Go][go] project. In Go, swiping moves forward and backwards in time so you can review the moves that led up to the current position. In the demo, swiping moves around a ring of ten images.

The problem we need to solve is that the image is larger than its "viewport." Go has the same problem when you use an iPhone (or iPod Touch, but I'm not going to keep saying that) to play on a board larger than eleven by eleven. You need a mechanism to move between boards and another mechanism to pan or scroll around within a single board.

Swiping the board is an example of *direct manipulation*. If you are able to establish a "mental model" in the user's mind of a horizontal timeline stretching from left to right, swiping to move will seem natural. Go help by animating the transitions between boards. The demo helps by sliding the image into the viewport.

We could establish controls of some kind, but there are two problems with controls. The first is that although a good control is also a visible [affordance][affordance], it takes up valuable space that is in short supply on an iPhone. The second is that controls like buttons are small and difficult to manipulate. The gesture interface solves the problem by turning the entire board or image into a control.

But what about panning the image? Google Maps solves this problem with direct manipulation as well: You can drag the map around inside of its viewport. Once again the entire subject area becomes the control. It's a good solution, but our challenge is that we're already using direct manipulation for moving between images.

**modal jazz**

When you want to use the same thing in two different ways, you want a modal interface: Sometimes direct manipulation will navigate with gestures, sometimes direct manipulation will pan the image by dragging. In essence, there is a "navigation" mode and a "panning" mode.

The challenge is that modal interfaces can be confusing. There are two well-known exceptions. The first is when the modes replicate a well-understood real-world modal behaviour and there is appropriate feedback for the user, such as selecting the colour of ink for drawing. The second is exception is a "rubber-band mode," a mode that is temporary and 'snaps back' to the normal behaviour as soon as the user stops whatever is currently happening.

![Rubber Band][band]

Keyboard modifier keys and mouse buttons are good examples of rubber-band modes: As soon as you release them, the special behaviour stops. These kinds of things are easy to understand. The caps lock key is a good example of a mode that is annoying because it isn't a rubber-band mode. Dragscroll mode in this demo is a rubber-band mode: As soon as you stop dragging the image and release the mouse button or lift your finger, you return to the normal behaviour.

The demo solves the problem by making "panning" a rubber-band mode. Here's how to pan the image: Hold your mouse button or finger down on the image without moving. After a few seconds, the image shakes signaling you can drag it around . Pan the image without releasing the button or lifting your finger and the image pans around within the viewport. Release the button or lift your finger when you are done. You are now back in "navigation" mode and can swipe to your heart's content.

(The hold and shake behaviour was inspired by the behaviour of the iPhone's home screen: When you hold your finger down on an icon, after a delay all the icons start shaking. You are now in edit mode and can re-arrange the icons. This is not a rubber-band mode, so on the iPhone's home screen you have to tap the home button to return to the normal mode. But I like the hold and shake, because the shaking implies movement.)

Like gestures, there are no visual affordances suggesting that swiping or holding your finger down does anything. After you have done so, the sliding image or shaking image give you some feedback, so this kind of interface represents an extreme tradeoff between functionality and discoverability. But it is an option to consider for metaphors that are naturally spatial.

---

Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald) or [RSS](http://feeds.feedburner.com/raganwald "raganwald's rss feed").

[drag]: http://raganwald.github.com/iGesture/drag.html
[slave]: /raganwald/homoiconic/raw/master/2010/04/slave_i.png "Slave I in Low Earth Orbit"
[ig]: /raganwald/iGesture "iGesture is a jQuery plugin for adding gesture support to web applications"
[affordance]: http://en.wikipedia.org/wiki/Affordance
[go]: http://github.com/raganwald/go "Go"
[band]: /raganwald/homoiconic/raw/master/2010/04/rubberband.jpg