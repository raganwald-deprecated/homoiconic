A Modal Interface Combining Gestures and Direct Manipulation
===

Last night I pushed a new [iGesture][ig] demo to Github, [Combining Gestures with Dragscrolling][drag]. As usual for me, it looks like rubbish. What you see is a 500px square portion of a Star Wars wallpaper image, something like this:

![Slave I in Low Earth Orbit][slave]

Use the mouse (or your finger on iPhone) to swipe the image to the left or the right. You'll see one of nine other Star Wars images slide into the viewport. So far, we have exactly the same swipe to navigate interface as in my [Go][go] project. In Go, swiping moves forward and backwards in time so you can review the moves that led up to the current position. In the demo, swiping moves around a ring of ten images.

The problem we need to solve is that the image is larger than its "viewport." Go has the same problem when you use an iPhone (or iPod Touch, but I'm not going to keep saying that) to play on a board larger than eleven by eleven. You need a mechanism to move between boards and another mechanism to pan or scroll around within a single board.

Swiping the board is an example of *direct manipulation*. If you are able to establish a "mental model" in the user's mind of a horizontal timeline stretching from left to right, swiping to move will seem natural. Go help by animating the transitions between boards. The demo helps by sliding the image into the viewport.

We could establish controls of some kind, but there are two problems with controls. The first is that although a good control is also a visible [affordance][affordance], it takes up valuable space that is in short supply on an iPhone. The second is that controls like buttons are small and difficult to manipulate. The gesture interface solves the problem by turning the entire board or image into a control.

But what about panning the image? Google Maps solves this problem with direct manipulation as well: You can drag the map around inside of its viewport. Once again the entire subject area becomes the control. It's a good solution, but our challenge is that we're already using direct manipulation for moving between images.

**modal jazz**

When you want to use the same thing in two different ways, you want a modal interface: Sometimes direct manipulation will navigate with gestures, sometimes direct manipulation will pan the image by dragging. In essence, there is a "navigation" mode and a "panning" mode.

The challenge is that modal interfaces can be confusing. There are two well-known exceptions. The first is when the modes replicate a well-understood real-world modal behaviour and there is appropriate feedback for the user, such as selecting the colour of ink for drawing. The second is exception is a "rubber-band mode," a mode that is temporary and 'snaps back' to the normal behaviour as soon as the user stops whatever is currently happening.

![Rubber Band][band]

Keyboard modifier keys and mouse buttons are good examples of rubber-band modes: As soon as you release them, the special behaviour stops. These kinds of things are easy to understand. The caps lock key is a good example of a mode that is annoying because it isn't a rubber-band mode. Panning mode in this demo is a rubber-band mode: As soon as you stop dragging the image and release the mouse button, you return to the normal behaviour.

The demo solves the problem by making "panning" a rubber-band mode. Here's how to pan the image: Hold your mouse button down on the image without moving. After a few seconds, the image shakes signaling you can drag it around. Pan the image without releasing the button, and the image pans around within the viewport. Release the button when you are done. You are now back in "navigation" mode and can swipe to your heart's content.

![iPhone Home Screen][home]

> The hold and shake behaviour was inspired by the behaviour of the iPhone's home screen: When you hold your finger down on an icon, after a delay all the icons start jiggling. You are now in edit mode and can re-arrange the icons. This is not a rubber-band mode, so on the iPhone's home screen you have to tap the home button to return to the normal mode. But I like the hold and shake, because the shaking implies movement.

Like gestures, there are no visual affordances suggesting that swiping or holding the mouse button down does anything. After you have done so, the sliding image or shaking image give you some feedback, so this kind of interface represents an extreme tradeoff between functionality and discoverability. But it is an option to consider for metaphors that are naturally spatial.

**implementing the modal interface**

The code for the demo is available to anyone who can view source, but it's also in [Github][code]. The principle idea is to create two modes and there is a function for each mode that binds the appropriate handlers for the mode while unbinding the handlers for the other mode.

(This approach probably doesn't scale well to zillions of modes: You might want to look at decorating event handlers using [jQuery Special Events][special] if you're building something like this in production.)

First, I had to do a little [yak shaving][yak] (also [this][dont_yak]).

The `hold` gesture, where you hold the mouse down without moving it, required something a little more fancy than iGesture supported, in that it had to trigger after a delay. The Timers jQuery plugin is ideal, but if you don't use hold, there shouldn't be a dependency. I [added the hold gesture][hold] with the proviso that you must include Timers to use hold. If you don't use hold, the timer code is never invoked.

Next, I noticed was that iGesture doesn't have a `.removegesture` method for unbinding gesture handling from a DOM element. I sent a [swift kick in the pants to the developer][catch_22], and the feature was added. And when I downloaded a copy of the [Dragscrollable][dsble] plugin for jQuery, I found that it also lacked a method to unbind its handler support. A similar plugin, [Dragscroll][ds], provides this functionality. It took me a few minutes, but I was able to implement `.removedragscrollable` on a [local copy][dsjs] of the plugin.

At last I could write the two functions that implemented the navigation and panning modes, starting with defining the elements:

	var navigation_mode;
	var panning_mode;
	var viewport_element = $('.viewport');
	var dragger_element = $('.viewport .dragger')
		.bind({
			'gesture_right.drag': function () {
				return bring_image_from('left');
			},
			'gesture_left.drag': function () {
				return bring_image_from('right');
			},
			'gesture_hold.drag': function (event) {
				panning_mode();
				$(this)
					.effect("shake", { times:3 }, 100, function () {
						$(this)
							.trigger(event.gesture_data.originalEvent);
					})
			}
		});

Then the `navigation_mode` function:

	navigation_mode = function () {
		dragger_element
			.gesture(['left', 'right', 'hold']);
		viewport_element
			.removedragscrollable()
			.unbind('.drag');
	}

And finally the `panning_mode` function:

	panning_mode = function () {
		viewport_element
			.dragscrollable()
			.bind('mouseup.drag', function () {
				navigation_mode();
				return false;
			});
		dragger_element
			.removegesture();
	};

The actual navigation sliding is not particularly cromulent, but that isn't really the point of the demo:

	var img_src = function (num) {
		return 'star_wars/' + num + '.jpeg';
	};
	
	var image_number = Math.floor(Math.random() * 10);

	var image_element = $('.viewport .dragger img')
		.attr('src', img_src(image_number));
	
	var bring_image_from = function (show_direction) {
		var hide_direction;
		if (show_direction == 'left') {
			image_number = (--image_number + 10) % 10;
			hide_direction = 'right';
		} else {
			image_number = ++image_number % 10;
			show_direction = 'right';
			hide_direction = 'left';
		}
		image_element
			.hide("slide", { direction: hide_direction }, 1000, function () {
				$('<img/>')
					.attr('src', img_src(image_number))
					.hide()
					.prependTo($('.dragger'))
					.show("slide", { direction: show_direction }, 1000);
			})
			.remove();
		return false;
	};
	
And that, as they say, is that. A modal interface alternates between gestures for navigation and direct manipulation for panning. As mentioned above, the demo is [Combining Gestures with Dragscrolling][drag] and the [code][code] is in Github. Naturally, you can discuss this post on [Hacker News][hn].

---

NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[drag]: http://raganwald.github.com/iGesture/drag.html
[slave]: /raganwald/homoiconic/raw/master/2010/04/slave_i.png "Slave I in Low Earth Orbit"
[ig]: /raganwald-deprecated/iGesture "iGesture is a jQuery plugin for adding gesture support to web applications"
[affordance]: http://en.wikipedia.org/wiki/Affordance
[go]: http://github.com/raganwald/wood_and_stones "Go"
[band]: /raganwald/homoiconic/raw/master/2010/04/rubberband.jpg
[home]: /raganwald/homoiconic/raw/master/2010/04/home_screen.png
[code]: http://github.com/raganwald-deprecated/iGesture/tree/gh-pages
[special]: http://benalman.com/news/2010/03/jquery-special-events/
[catch_22]: http://github.com/raganwald-deprecated/iGesture/issues/closed/#issue/22 "iGesture Issue #22"
[dsble]: http://plugins.jquery.com/files/jquery.dragscroll.js.txt
[ds]: http://plugins.jquery.com/files/jquery.dragscroll.js.txt
[dsjs]: http://github.com/raganwald-deprecated/iGesture/blob/gh-pages/dragscrollable.js
[dont_yak]: http://sethgodin.typepad.com/seths_blog/2005/03/dont_shave_that.html "Don't Shave That Yak!"
[yak]: http://www.catb.org/~esr/jargon/html/Y/yak-shaving.html
[hold]: http://github.com/raganwald-deprecated/iGesture/issues/closed/#issue/20 "iGesture Issue #20"
[hn]: http://news.ycombinator.com/item?id=1277481 "Discuss this post"