**Preamble**

*Thank you, thank you. I am really grateful to hear such enthusiastic applause from people I admire so much. And thank you, Curator [Pete Forde](http://www.peteforde.com/ "Pete Forde"), for inviting me back to speak at **RubyFringe 2.0**. Last year I kind of invited myself to give a presentation at [RubyFringe](http://rubyfringe.com/ "RubyFringe: Deep nerd tech with punk rock spirit."), and as I said at the time, I wasn't sure if the conference was about the fringe of Ruby Culture or about the fringe of Ruby itself.*

*I went with discussing the fringe of the Ruby Language, namely [Ruby.rewrite(Ruby)](http://www.infoq.com/presentations/braithwaite-rewrite-ruby "InfoQ: Ruby.rewrite(Ruby)"). So I think I had pretty much the most boring talk of the conference. And I did so with slides that consisted entirely of screen shots from inside TextMate. On top of that, I didn't get much sleep before my talk and I had to follow [Giles Bowkett](http://gilesbowkett.blogspot.com/ "Giles Bowkett") and [Damien Katz](http://damienkatz.net/ "Damien Katz").*

*After that, I considered myself lucky to get out of the room without having to duck any flying produce, much less be invited back for another round. But here we are, and this time I'm determined to give the most unexciting talk of the conference again. There are no slides, I'm just going to read a speech the old fashioned way.*

[![Reginald Braithwaite](http://reginald.braythwayt.com/images/reg_at_meshu.png)](http://reginald.braythwayt.com/ "Reginald Braithwaite") 

Optimism
===

I must start by apologising for not having a cute title. I also don't think you're going to find any really catchy clichés you can quote from this talk. I know you're supposed to have these things, but there's something I want to share with you, and I can't think of a way to make it catchy and sexy and viral in a way that you will tweet it in real time. But nevertheless, it's One True Thing in my mind and in my heart, so here goes and I hope you forgive me for being sincere instead of slick.

The One True Thing is this. I am a [Bipolar Lisp Programmer](http://www.lambdassociates.org/blog/bipolar.htm "The Bipolar Lisp Programmer"), and struggling with both afflictions has taught me some things that might help you out even if you are refreshingly happy in your life and write code that is parenthesis-free.

Some years ago I was in an especially low point and I happened upon a book that changed my life. I cannot guarantee it will change your life. "Chance favors the prepared mind," they say, and perhaps it can only change your life if you happen upon it at an inflection point, at a time when your life is ready to change. I needed some change, and this book did it.

**Learned Optimism**

The book is "[Learned Optimism](http://www.amazon.com/gp/product/1400078393?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=1400078393 "Amazon.com: Learned Optimism: How to Change Your Mind and Your Life: Martin E. P. Seligman: Books")," by Dr. Martin Seligman. I'm not going to stand here and read the book aloud, you know that. But I am going to simplify it down to a few points, and you might very well think the book is too simplistic to be worth reading. Trust me on this one, you should not judge a book solely by whether you like what I said about it. Read it for yourself and decide.

So Dr. Seligman did some research on optimism and success, and the results surprised him, and after a lot of back-and-forth with colleagues and more research, he came up with a theory and a side-business of selling tests that predict whether salespeople are going to be successful. I want to emphasize the word **research**, because the plural of anecdote is not data. No matter how many nice people like me tell you something from our experience, it is not the same thing as what Dr. Seligman does to come up with this stuff.

Dr. Seligman's theory is all about how people explain things to themselves. We all do this, it's part of the whole sentience thing we have going on. Something happens, and we make up a little theory about why it happened. I look at my friend Joey while I'm talking and smile, and Joey decides it's because I like him, or because I want something from him, or maybe Joey decides it's because a Dark Horse Americano tastes so damn good. Whether we are aware of it or not, we're making up these explanations for events that concern us all the time.

Dr. Seligman has two claims. The first is that we have patterns for our explanations, and that by testing our explanations, he can come up with a prediction for our behaviour. He gives us a test, he computes a number with the result, and he calls the resulting scalar "optimism," and he claims that people with high optimism are more successful and happier and whatever else that is nice than people with low optimism. And he thinks he has the numbers to prove it.

His second claim is that with cognitive therapy you can increase your optimism. And again, he went out and tested his claim and again he has research he claims proves it.

**Three Axes Pronounced Ax-ees**

In his book, he explains that when we make up an explanation for things, we have three fairly binary properties or axes of each explanation. First, we decide something is personal or impersonal. For example, when I was registering for the first RubyFringe, someone I respect very much walked up to me and introduced himself, then told me that he didn't like the [andand gem](http://andand.rubyforge.org/ "Object#andand") I wrote.

So how do I explain his not liking my work? If I though there was something inherently wrong with andand, or even more personally, something inherently wrong with me as a developer that I could write something like andand, that's personalizing the explanation. "He didn't like it because **I** something-something-something."

On the other hand, if I explain his not liking my work as reflecting upon him and his values--and I don't mean this in a  negative way--that's depersonalizing the explanation. "He didn't like it because **he** something-something-something." For the record, I depersonalize criticism of andand very easily, so feel free to tell me what you think. Mostly, I think that people who don't like andand have a particular thing they want to do with their code, it is definitely not about me. Maybe they just think that [pervasive null checks are a code smell](http://avdi.org/devblog/2008/10/30/self-confident-code/ "Writing Self-Confident Code | Virtuous Code"). Hell, *I* think that, sometimes I write [hopelessly egocentric](http://github.com/raganwald/homoiconic/blob/master/2009-02-02/hopeless_egocentricity.md "The Hopelessly Egocentric Blog Post") blog posts about the trouble with nil.

So there's the first thing, *personal vs. impersonal*. So are optimists more or less likely to "take things personally?" I'm not going to say what he says just yet, but when I was looking at that, I didn't know what to think. If you read books by self-help gurus, a lot of them talk quite a bit about taking responsibility for everything that happens in your life. It seems they advocate taking everything personally. Yet people who "take things too personally" are often morose, depressed, and defensive.

So we'll come back to Dr. Seligman's answer after discussing the other two axes. The second axis or binary property was *general vs. specific*. Remember the fellow who didn't like andand? Did I take this as a suggestion that he doesn't like my programming? Or me? Or do I conclude he doesn't like one little thing I wrote, maybe twenty or thirty lines of code? Sometimes something happens and we generalize the explanation. Sometimes we make it really specific. For example, I have a really specific explanation for the success of my blog posts back when I was blogging. Some were popular, some not. I would never write a turd and then ruminate about what a terrible writer I was. Each post would fly or fall on its own in my mind.

On the other hand, I have a terribly general attitude towards my own ability as a weekend athlete. I'm not a world-class anything, but if I put my mind to something physical and work hard, I can be pretty good. That's a really general statement about athleticism, it's not like I tell you I'm a good climber and a reasonable diver and a good Ultimate player and I used to be a good cyclist and once I was a good runner. No, I'm a decent athlete, if I work on something I won't embarrass myself or my team mates. And thus it is with our explanations of things that happen to us. Some explanations are general. Some explanations are specific.

The final axis--thanks for your patience with my explanations--is temporal. Some explanations are temporary, some permanent. Here's an example from just before I started composing my speech. I was struggling with the testing framework for an application, but some weird gem dependencies kept biting me. I could have explained it thus: "Fuck, gems are always a pain in the ass in Ruby," **or**, I could have explained it thus: "I had a problem with gems today." One is a kind of permanent, "it always was this way, it will always be this way" explanation, the other is a very temporary, "it was a problem this one time" thing. So our third axis is *permanent vs. temporary*.

Let's recap. When we explain something in our heads, our explanations have three properties that matter to whether we are optimistic or not: Whether we explain things in a personal or impersonal way, whether we explain things in a specific or general way, and whether we explain things in a permanent or temporary way.

**Pause**

So I know I just sprung this on you, but I am going to take a drink of water right now, and while I do that, those of you who are still awake and not twittering your drinking plans might want to try to decide for yourself whether optimistic people tend to explain the world personally or impersonally, whether they tend to explain the world generally or specifically, and whether they tend to explain the world permanently or temporarily.

If you happen to think that the answer to one or more of those questions is "*Sometimes one, sometimes the other*," don't forget to come up with a theory of when one and when the other.

**Asymmetry in Natural Law**

For what it's worth, I took a little test in his book at the time, and had someone told me they didn't like andand then, I would have taken it personally, thought it was all about my talent as a developer, and figured things weren't going to change.

And the test revealed something else. Had someone told me I scored a particularly athletic goal in Ultimate, I would have put it down to my opponent being out of shape, explained that I really focus on being a good ultimate player who specializes in receiving goals, and remembered that on the play before I had run in one direction while my team mate threw the disk in the other, so it was just a one-off. I would have explained the compliment as being impersonal, specific, and temporary.

See the asymmetry? This surprised me, I was not consistent. I didn't always explain things one way or the other. More interestingly, I was consistently inconsistent: I explained *bad things* as being personal, general, and permanent, but I explained away the good things as being impersonal, specific, and temporary.

This may not seem rational. Logically, each of us ought to be consistent in how we explain the world. But we aren't, or at least some of us aren't.

The moment this was revealed to me I could guess what came next. I was a *pessimist*. No kidding, according to me all the bad things in my life were everywhere, they followed me around because they were about me, and they lasted forever, while the good things were all about other people, and they only came into my life for short moments.

Do I need to explain that optimists are the opposite, cheerfully inconsistent? That's what Dr. Seligman discovered. Like the pessimists, optimists do not always explain the world the same way. But to an optimist, someone not liking andand is simply one person (impersonal, specific) not liking that one thing (specific again), for their own reasons (impersonal), and it was just a few word in the middle of a long day (extremely temporary). And to the optimist, they're a good athlete (personal, general) and have been all their life (permanent). That one goal was just another scene in their long-playing movie of game highlights.

Optimists explain good things as being personal, general, and permanent, and explain away bad things as being impersonal, specific, and temporary. And if you point out the contradiction in their explanations, they see no contradiction. To them, the bad stuff really isn't about them, it's just that one thing that one time.

The book shocked me, I read it a bunch of times and actually bought copies for other people. Besides myself, I knew lots of people who fit Dr. Seligman's pessimist theory, I knew this because they cried on my shoulder about their long-running, personal flaws that affected every part of their lives. They were personal, general, and permanent on the subject of unhappiness. And on the subject of happiness, they were impersonal, specific, and temporary.

So there you have it. One predictor of success is this characteristic Dr. Seligman calls optimism, which he measures by testing whether you explain good or bad events as being personal, general, and permanent.

(By the way, he goes on to explain how to change your explanations, to become more optimistic, and to become more successful. I don't need to explain that to you now. I've already told you to read the book, so I won't say it again. But if you think it could help you in your life, please buy it. If you can't afford it, get a copy from your library. If that's too much trouble, ask me and I'll loan you a copy. If what I just said resonated with you in a personal way, I hope it can help you as it has helped me.)

**Let's Treat Each Other Like Children**

But whether you are happy with your life or not, whether you are a bipolar lisp programmer or a well-adjusted Rubyist, there's another application of Dr. Seligman's theory I want to share with you. Most of you are probably acquainted with  the expression, "*Praise the child and criticize the behaviour*."

For example, you say "Reg, you are a consistently intelligent guy, but relating a personal anecdote is not the most persuasive form of rhetoric, try again." Let's think about that one for a moment. It's really Dr. Seligman's theory, isn't it? You say something positive, and you make it personal, general, and permanent. Then you say something negative, but it's impersonal, it's specific, and ideally it's temporary.

This makes other people feel good, and it gets your point across, and we need to do more of that in our technical community. Most of the ad hominem flame wars I see do the reverse: They criticize people in a very personal, general, and permanent way, like saying "So-and-so is a douchebag," and the little praise they hand out is impersonal, specific and temporary "The framework he created was interesting when it first appeared, but so much has happened since then."

Honestly, what the fuck? This is a recipe for making people depressed. It's also bad for *us*. When we criticize other people in a general and permanent way, we close ourselves off from learning from them. Saying that so-and-so is a permanent bozo is a subtle way of explaining that your life always has had a bozo in it and always will have a bozo in it. When we criticize that person's specific actions, we are saying that there was something temporary and specific and impersonal in our life, but it's over now. That's a win for ourselves as people.

So here's my specific call to action:

Let's think about those three things whenever we look at someone or something. Let's think of the positives as personal, general, and permanent. Let's think of the negatives as impersonal, specific, and temporary. Let's actually go out of our way to inject these three things into our discussions and debates and flame wars.

And let's do it when we talk about things as well as about people. For example, I can say that *Ruby is a great language, it has changed the world. Mind you, I am not a fan of this or that specific feature of Ruby, and here's what I'm doing to change it, which pretty much demonstrates that I think the problem is temporary.*

**Praise the language, criticize the features, then fix them**. Isn't that the essence of hacking, an optimism that the state of the world is not permanent, that we can change things and we will? That we can invent new and better ways to do things? Optimism is what drives us forward to create and change. The pessimists are the ones who cling to legacy technologies and old ways of doing things. They accept the bad things as permanent and deny themselves the ability to change things, to fix things.

But we believe the good things, our curiosity, our ability to tinker and hack and create, we believe those things are permanent and are ours, we believe it is personal and general. And we believe we take those personal and general and permanent hacking and changing skills and apply them to making specific bad things that other people foist on us go away, we make them temporary, we isolate them in specific silos where they don't weigh upon our spirit.

THIS spirit of confidence and change is optimism, and it's what I hope we will all practice between now and when I see you again at RubyFringe 3. Thank you so much for listening. I'm optimistic that **we**--*pause*--**will continue**--*pause*--to change **the world**.

---

*Of course, there will not be a RubyFringe 2.0 conference, so I am sharing the speech I wrote with you in my unblog. Instead, Pete Forde is curating a different unconference, [FutureRuby](http://futureruby.com/ "FutureRuby"). Check it out!*

*Also, if this sounds vaguely familiar to you, thank you for reading my old blog "raganwald." One of my personal favourite posts was called "[How to use a blunt instrument to sharpen your saw](http://weblog.raganwald.com/2007/10/how-to-use-blunt-instrument-to-sharpen.html "How to use a blunt instrument to sharpen your saw")." The whole point of the article was to approach things with the confidence that you could get something positive out of them. Well, now you know how to have that confidence, it's to be an optimist and to think about the world in an optimistic way, and here's a very specific plan of action for being optimistic.*

---

*Mike Davenport from Hacker News comments-*

"What I really enjoyed about this essay was that it talked about using research to come to an explicit algorithm for learning optimism. I could never swallow the advice of many optimistic people in my life since they [through no fault of their own, mind you ;)] were not usually hackers. As such, they would explain in broad and nebulous terms how they achieved said happiness, which makes sense, since--according to the essay--they see positives as general and permanent. I would always focus on their seemingly obvious contradictions, without really noticing my own. I'm glad someone finally pointed that out to me."

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0109_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)
