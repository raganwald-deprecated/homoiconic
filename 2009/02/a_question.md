Um, I have a question!
===

Recently there has been some brouhaha about Test-Driven Development, SOLID, and the people advocating for or against said practices. I haven't jumped into the flamewar^H^H^H^H^H^H^H^H conversation for a couple of reasons. First, I'm trying to be code-centric in my life and this un-blog. The point of Homoiconic is to talk about code, not to talk about talking about code. Talking about people talking about other people talking about how to talk about code would be ridiculous.

> The point of Homoiconic is to talk about code, not to talk about talking about code. Talking about people talking about other people talking about how to talk about code would be ridiculous.

That being said, one little thing caught my attention that I hope you find interesting. The aforementioned brouhaha has often descended into people arguing about the colour of the bike shed. I saw a long exchange on a social bookmarking site arguing whether pair programming is a good idea or brain damaged. It was mostly "Yes it is! No it isn't!!"

But what caught my eye was when one person claimed that two people pair programming were less productive than two people programming separately. Some other folks argued that two people pair programming are actually *more* productive than the same two people programming separately, for various reasons. And one interesting argument was that productivity isn't the point.

But here's what gets me: Programmers talk about productivity *all the time*. They say they're more productive with static typing or without it. With Ruby or with Java. With Agile or with Waterfall. With Emacs or with Vim. On OS X, Linux, or Windows. Pairing or working separately. In offices or in a project room. And so forth. It seems every programmer I meet has strong opinions about when they are more productive and when they are not. So, here's my question:

**How are all these people measuring programmer productivity?**

Seriously. It's not exactly P=NP, but people have been trying to measure what programmers do for the better part of half a century. Evidence-based software development is a lot better at measuring extremely coarse things like whether a release hit a certain date or not. It's middling at measuring the quality of a release (Are all bugs equal? Or is it simply that the product manager who screams the loudest gets her bugs fixed first?). Evidence-based software development has nearly nothing to say about what individual programmers do.

> Evidence-based software development has nearly nothing to say about what individual programmers do.

You read me right. We are fairly good at measuring when entire projects are finished and whether they do what they are supposed to do. And on that basis we can figure out something akin to the productivity of an entire team of programmers, team leads, QA folks, product managers, and everyone else involved. More releases that do what they are supposed to do equals more productivity from the team. But we can only measure that on entire releases. When we try to figure out whether a team is productive or not in the middle of a release, we wind up scratching our heads. Have they written any code? Does that matter? Maybe they're designing architecture. Maybe they're using a really expressive language. We can only reliably measure the productivity of a team on a long scale involving entire releases of software.

Now we zoom in and focus on a single programmer. Measuring productivity seems hopeless! Every time we cook up a metric (function points per iteration divided by the trailing average number of WTFs per minute in code reviews), we find a convincing case for the metric being meaningless or even inversely correlated with the results of the team as a whole.

So how is it that every programmer seems to know *exactly* when they are being more productive, and why?

Does Joel Know?
---

> We all know that knowledge workers work best by getting into "flow", also known as being "in the zone", where they are fully concentrated on their work and fully tuned out of their environment. They lose track of time and produce great stuff through absolute concentration. This is when they get all of their productive work done. Writers, programmers, scientists, and even basketball players will tell you about being in the zone. The trouble is, getting into "the zone" is not easy. When you try to measure it, it looks like it takes an average of 15 minutes to start working at maximum productivity.

Joel Spolsky makes a [strong claim](http://www.joelonsoftware.com/articles/fog0000000043.html "The Joel Test: 12 Steps to Better Code") about working conditions that allow programmers to have productive development time. Or more specifically, he talks about ways to avoid having programmers spend unproductive time trying to get back into "the zone." He makes another point about giving programmers the best tools money can buy so that they aren't knocked out of the zone waiting for their compiler or fiddling with windows when they could see all of their work if they had a bigger screen.

Neither of these things says a lot about measuring productivity. They merely talk about giving programmers the very best opportunity to be productive. But measuring whether programmers have quiet working conditions and fast compilers is a little like measuring whether a baker uses the best ingredients: It says nothing about the results.

I am not criticizing Joel's test here: It summarizes some fabulous and valuable experience with software development teams. But I assert that articulating how to measure whether a process ought to produce productive programmers (like scoring a team on a scale of zero to twelve) is not the same thing as articulating how to measure whether a programmer is *actually* productive.

So when a developer talks about being "more productive," what do they mean? Do they mean having more uninterrupted time to perform activities they think lead to higher productivity? Or do they mean producing more results that can be measured objectively?

If someone can figure out what it means for a programmer to be more productive, I wish they would let me in on the secret. I'm not ashamed to admit that I haven't figured it out yet.

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)](http://leanpub.com/javascript-allonge "JavaScript Allongé")![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* [JavaScript Allongé](http://leanpub.com/javascript-allonge), [CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto), and my [other books](http://leanpub.com/u/raganwald).
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)