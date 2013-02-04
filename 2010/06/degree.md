A Degree of Understanding
===

I recently released [jQuery Combinators][jqc], a very simple jQuery plugin that adds two methods to every jQuery object: `K` and `T`. Can you guess what they do from their names? How about if we include the fact that they are the K and T combinators?

You probably know exactly what they do, but let's be honest with each other: People who read my [Homoiconic][h] "un-blog," or people who read [Hacker News][hn], or people who read programming.reddit.com are not exactly representative of the larger community of professional programmers. I wrestled with naming them `returning` and `into`, but decided against such a "marketing" move in the end because it's so d\*\*n easy for programmers to rename them if they don't like `K` and `T`.

But I am left scratching my head about something. If we grant my strawman argument that most programmers have no idea what `K` or `T` stand for, if most programmers have never heard of [Kestrels][k] or [Thrushes][t], why is a degree in Computer Science one of the basic requirements for most entry-level programming jobs?

If someone came to me and asked me why programming jobs required a degree, I might answer that although it is clearly quite common for people to have a great deal of aptitude as a programmer without any formal education in the subject, working with other programmers requires an ability to speak and understand the jargon. If I use a method like `.K(...)`, I want you to know at a glance what it does. If you can figure it out after fifteen minutes of studying the source code, that's great, but fifteen minutes times hundreds of such conventions adds up to a lot of wasted time when you first come to work.

Likewise, if you are given the job of writing some code that parses a certain file, I don't want you inventing your own terms. It's great if you can independently invent [Parser Combinators][pc] (to continue with the combinator theme here), but if you call them "translator functions" I'm going to have to spend some time reading your code. And even if I've never heard of a Parser Combinator, a quick web search will set me straight.

All in all, a degree might be a very useful thing. Maybe not more useful than experience or talent, but certainly useful if it means everyone with the same degree shares the same basic knowledge of what terms like "K Combinator" or "Parser Combinator" mean.

So I'm genuinely puzzled... Why is it a bad idea to call my jQuery plugin "jQuery Combinators," and why are `K` and `T` such terrible names for its methods?

----
  
Discuss this post on [Hacker News][hn], NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[jqc]: http://github.com/raganwald/JQuery-Combinators
[k]: http://github.com/raganwald/homoiconic/blob/master/2008-10-29/kestrel.markdown#readme
[t]: http://github.com/raganwald/homoiconic/blob/master/2008-10-30/thrush.markdown#readme
[h]: http://github.com/raganwald/homoiconic/#readme
[pc]: http://en.wikipedia.org/wiki/Parser_combinator "Parser combinator - Wikipedia, the free encyclopedia"
[hn]: http://news.ycombinator.com/item?id=1449777