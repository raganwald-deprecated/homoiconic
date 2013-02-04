# Effective JavaScript Reviewed

[![Effective JavaScript](http://i.minus.com/ibjveCleaJzli1.png)](http://effectivejs.com)

**The Book**: David Herman's [Effective JavaScript](http://effectivejs.com) is an in-depth look at the JavaScript programming language and how to use it effectively to write more portable, robust, and maintainable applications and libraries. Using the concise, scenario-driven style of the [Effective Software Development Series](http://www.informit.com/esds), this book brings together tips, techniques, and realistic code examples to explain the important concepts in JavaScript.

**My Recommendation**: [Buy it][buy], read it, and keep it as a reference work.

## When ASI met IIFE

Some time ago I was asymmetrically pairing with a colleague, and I begun a new JavaScript file like this:

```javascript
;(function ($) {
	// ...
})(jQuery);
```

"What," she asked, "is the purpose of the opening semicolon?"

The truth is, I didn't really know. I'd read *somewhere* that when JavaScript loads your files, if you had  some buggy code in file A, then file B could be corrupted by whatever was last in file A if the environment loaded A before B. In other words, the environment behaved as if all the code was concatenated together.

But I was hazy on the details, and admitted as much. She may have felt she learned something, then again she's rather bright and productivity focused, so perhaps she knew what was going on but didn't want to take time out to discuss it.

She didn't ask about the [Immediately Invoked Function Expression][iife], so we moved along and I don't think I've thought about why I start files with an opening semicolon since. Until the other day, when I was reading *Effective JavaScript*.

[iife]: http://www.benalman.com/news/2010/11/immediately-invoked-function-expression/

*Item 6, "Learn the Limits of Semicolon Insertion,"* began with what I thought I knew about Automatic Semicolon Insertion ("ASI"), such as the rule that ASI is error correction, so semicolons are only ever inserted when the next input token cannot be parsed.

But it also explained some of the *implications* of what I thought I knew: That there are five problematic characters `(`, `[`, `+`, `-`, and`/`. That each of these characters can acts either as an expression operator or as the prefix of a statement, and therefore that any statement beginning with one of these characters could be trouble if you are depending on ASI.

### Implications

This is the crux of the value that *Effective JavaScript* provides. The behaviour of programming languages and environments is a little like mathematics or physics. There are certain axioms, facts if you will, that are freely available to all for free. It is not difficult to find out what the rules are for ASI. And the specification for valid sequences of tokens in JavaScript is also easy to discover, for free, with a web browser.

And so it goes for everything, the rules about how functions are expressed, about how names are bound, about prototypes, about the context for a function that is extracted from an array  with `arr[3]`, and so on. These axioms are all known.

> "Genius is an African who dreams up snow."--Vladimir Nabokov

But like mathematics or physics, it is the interactions between the axioms that gives rise to an extraordinarily complex set of behaviours. From quantum physics arise all sorts of physical behaviours, but can you really "dream up snow" from the Standard Model on first principles alone?

What we get from *Effective JavaScript* is a brief explanation of the base principles, and then a curated set of implications. What makes one such book brilliant and another pedestrian is the balance it strikes between two opposing qualities: *Familiarity* and *Surprise*.  The topics discussed must be familiar to us, they must cover problems we encounter and can recognise. And there must be some surprises, some "Whoa, I never thought of that" moments.

When a book is too familiar, it fails to add value. "Yes, yes," we say, "I know all about prototypes. Tell me something I don't know." When a book is too surprising, it also fails to add value. We say, "It's a richly entertaining exercise in [theoretrics], nothing more."

[theoretrics]:https://twitter.com/raganwald/status/286670901905342464 "Portmanteau of 'Theory' and 'Theatrics,' a highly entertaining explanation of theory with little practical value."

For this reason, what we need from a book is not just a knowledgable author able to dive deeply into the subject matter, but also someone able to carefully choose when to briefly explain, secure that we grasp the point, and when to dive into implications that are sure to surprise us.

Without expert curation, we either get a brief book that fails to strike the proper balance, or we get a book that runs to 600 pages and still fails to strike the proper balance because in his zeal, the writer lurches from obvious to arcane without rhyme or reason.

### Back to the Leading Semicolon

As you by now expect, *Effective JavaScript* explained why I was inserting that leading semicolon. When file A and file B both use an IIFE, and when each file is loaded separately, a semicolon is automatically inserted at the end. So they look like this to the interpreter:

```javascript
(function ($) {
	// ... A
})(jQuery);

(function ($) {
	// ... B
})(jQuery);
```

No problem. But one day you add naïve concatenation to your asset streaming, and now the code is all in one big file:

```javascript
(function ($) {
	// ... A
})(jQuery)(function ($) {
	// ... B
})(jQuery);
```
Instead of two IIFEs, you now have one function expression being called with `jQuery` as its argument. You then call the result it returns with a big function expression as its argument. You then call what that returns with `jQuery` as its argument. That's a bug.

It wouldn't have been a bug if every file included was terminated with a semicolon, but you can only control the code you write. Let's say you wrote B, and you terminated yours with a semicolon and prefixed it with a semicolon defensively. After concatenation, you end up with:

```javascript
(function ($) {
	// ... A
})(jQuery);(function ($) {
	// ... B
})(jQuery);
```

And that works fine. Now, *this is not the only way to solve this problem*. JavaScript has moved along since I first saw that idiom, and there are plenty of minification libraries and module management libraries that solve this problem for you whether you include an extra semicolon or not. Some of them solve the scoping issues that the IIFE is intended to solve.

*Effective JavaScript* didn't tell me this is a "best practice." It told me how a few things (that I thought I already knew) interacted in an unusual way. And thus some programmer, at some time in the past, recommended the leading semicolon and IIFE as sensible given the tools of the day. Now that I understand the issue properly, I'm no longer blindly using the idiom out of... I can't think of a better word than *faith*.

I value this kind of enlightenment from a book, a lecture or a course. I'm now in a much better position to evaluate alternate approaches to breaking JavaScript into multiple files. I now know something I didn't really know I didn't know.

## Whoa, That's Important

That is an awful lot of words for, "Effective JavaScript explained why prefacing files that contain an IIFE with a semicolon fixes a problem that ASI could introduce when you concatenate files with old-school tools," but I wanted to provide a taste of what it felt like for me to read David Herman's book.

I was constantly saying to myself, "Of course, of course, I know that, well that follows from that, and yes, therefore that follows from that," and then suddenly: *"Whoa! That's important!"*

Whether it was insights into writing constructors that worked with or without the `new` keyword, the perils of the Array Constructor, or repeated forays into iteration and its subtleties, I was pleased by the fine balance David Herman struck between familiarity and surprise. I felt like I knew more than half of what he wrote. But the other half... Solid gold. And the half I knew helped me understand the value of the half I didn't know.

Of course, what is surprising to Bob may be familiar to Carol. And what Ted thinks is useless language trivia may be a pearl of wisdom to Alice. So one can reasonably ask, should every JavaScript programmer own a copy of *Effective JavaScript*?

I think Effective JavaScript is going to be an important text for all but the complete neophyte. That being said, beginners may find that the more experience they obtain writing JavaScript software, the more value they obtain from the book. While it touches on functional programming, objects and so-called classes in JavaScript, and even writing good APIs in JavaScript, each of these topics is also well-served by a more didactic book presenting the subject matter within the context of a larger framework or approach to programming.

But with that experience in hand, Effective JavaScript's approach of picking a topic and explaining the crucial implications and consequences adds enormous value to the reader's hands-on experience and to the knowledge delivered in other books or courses.

And there are sixty-eight topics! This is not a couple of blog posts fleshed out, formatted into chapters, and reprinted as a book. It's a substantial work covering the entire JavaScript language from functions and closures to asynchronous programming. The coverage of asynchronous JavaScript would justify buying and reading this book on its own, it's that good.

## My Bottom Line

*Effective JavaScript* feels like more than just a good read, it feels like a book I'll dip into again and again. If you're working with JavaScript and feel like you have a good grasp of the language, I recommend it.

[Effective JavaScript][buy], 200 pages. This review is based on the [Kindle Edition][kindle] on iOS and OS X.

(Discuss this review on [hacker news](http://news.ycombinator.com/item?id=5002439) and [r/javascript](http://www.reddit.com/r/javascript/comments/15w0ab/effective_javascript_reviewed/))

[buy]: http://www.amazon.com/gp/product/0321812182/ref=as_li_ss_tl?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321812182 "Buy on Amazon.com"
[kindle]: http://www.amazon.com/gp/product/B00AC1RP14/ref=as_li_ss_tl?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=B00AC1RP14
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

