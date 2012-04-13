We need the eggs
===

> It was great programming Ruby again and I realized what a terrific language it was and how much fun it was just knowing it and I thought of that old joke, you know, the, this, this guy goes to a psychiatrist and says, 'Doc, uh, my brother's crazy, he thinks he's a chicken,' and uh, the doctor says, 'well why don't you turn him in?' And the guy says, 'I would, but I need the eggs.' Well, I guess that's pretty much now how I feel about programming. You know, it's totally irrational and crazy and absurd and, but uh, I guess we keep going through it...because...most of us need the eggs.

(With apologies to [Woody Allen](http://www.youtube.com/watch?v=W-M3Q2zhGd4 "YouTube - Annie Hall ending"))

A colleague mentioned to me that he was having a problem with his Rails project. His project requires a certain version of a gem. He dutifully uses `config.gem` to load that version of the gem into his project and all was right with the world for a time.

But at some point, it stopped working because he was somehow loading a newer version of the gem. To cut a long story short, although he wanted version X of the gem, something else he was loading was loading version Y of the gem where X < Y, and this broke plugin Z, which works with X but not Y.

Confused? Or is this [vomitorium](http://www.straightdope.com/columns/read/2421/were-there-really-vomitoriums-in-ancient-rome) known as "gem dependencies" old hat to you?

I ordinarily wouldn't have done anything but try to utter a sympathetic grunt. Talking about someone's gem dependencies is a lot like talking about the perceived shortcomings of a friend's spouse. At a certain point, you realize that the advice to "Just walk away" will *not* be met with a hoarse cry of thanks and grateful pumping of your hand.

But I'm a pattern matching machine, and somehow this seemed darn familiar. At the core, if you have two pieces of code, and they each require a different version of the same gem, isn't that the exact same problem as [having two pieces of code, each of which wants to add a different #sum method to the Array class](http://github.com/raganwald/homoiconic/blob/master/2009-04-08/sick.md#readme "Sick of this Shit")?

Fix one and you fix the other.

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), an implementation of Bill Gosper's HashLife in CoffeeScript in the "Williams Style."
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)