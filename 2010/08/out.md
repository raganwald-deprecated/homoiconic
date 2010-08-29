Just when I thought I was out... they pull me back in.
===

For some little time I've been [disquieted][sick] by Ruby's global environment for classes and modules. Class definitions are the ultimate global variables: Any monkey patch you make in your code affects all the other code running anywhere in the same instance of the interpreter.

Naturally, you';re a careful programmer and you have close to 100% code coverage, so you don't mind working with really sharp tools. This is find when you're a leaf node: If your application uses other code but is not used by other code, if your manipulation of the global class definitions breaks one of the gems or libraries you're using, you have the power to work around things, change libraries, or change approaches.

The problem comes in when you are writing code for other people to use. If you decide that it's cool to implement `#try` in your library, you might break the code for anyone implementing `#try` downstream of you. Okay, they can decide whether to use your version of `#try` or whether they prefer another library. But what happens when your definition of `#try` breaks some code in another library or gem you've never heard of and therefore never tested?

Much hilarity ensues if one of your hapless users decides to use your library and the other library, of course. Two reasonable programmers&#8212;you and the other library author&#8212;each did reasonable things with close to 100% code coverage and nevertheless their code can't work together.

![Godfather, Part III](http://gallery.sendbad.net/data/media/68/godfather_part_iii_ver1.jpg)

I've said this before, and even then it was hardly a grand revelation. But this morning I found myself writing this Javascript in a [tiny little framework][roweis] I'm writing with some colleagues for a projhect at [Unspace Interactive][unspace]:

    if (controller.target) {
      controller.render_target = (function (render_target_context) {
        return function (selection) {
          selection
            .find(controller.target)
              .ergo(function (element) {
                controller.render(render_target_context, function (rendered) {
                  element.append(rendered);
                });
              });
        };
      };
    }
    
Notice the use of [jQuery Combinators][comb]'s `ergo`? I'm the author of `ergo`, and I want to use my own tools. But jQuery plugins work just like Ruby's global class definitions. If I extend `jQuery.fn` to include `ergo`, every user of my framework gets it whether they like it or not.

So... No jQuery Combinators in Roweis[roweis]. So if you look at my code and wonder why I don;t seem to be eating my own dog food, the reason is that although I like the taste, I don;t want to force-feed it to everyone else.

Harrumph.

----
	
Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald) or [RSS](http://feeds.feedburner.com/raganwald "raganwald's rss feed"). I work with [Unspace](http://unspace.ca), and I like it.

[sick]: http://github.com/raganwald/homoiconic/blob/master/2009-04-08/sick.md#readme "I'm Sick Of This Shit"
[unspace]: http://unspace.ca
[comb]: http://github.com/raganwald/jQuery-Combinators
[roweis]: http://github.com/raganwald/Roweis