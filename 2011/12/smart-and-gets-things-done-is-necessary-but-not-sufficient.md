# "Smart and Gets Things Done" is necessary, but not sufficient

*TL;DR: Programming languages, libraries, tools, and toolchains contain independent systems that interact in complex but unpredictable ways. There is no substitute for experience with the actual system you actually work with.*

### a funny thing happened over drinks last night

I was having a few drinks with Evan Light, Austin Ziegler, Sean Miller, and some other Toronto folken. At our end of the table, the subject of differences between procs and lambdas in Ruby came up. Someone piped up, "One difference is that `return` in a lambda returns from the lambda, but `return` in a proc returns from the enclosing method."

"That can't be right," I said.

"Oh?" someone else continued, "I'm pretty sure I read this exact thing earlier today. What's your reasoning for why that can't be right?"

"Well," I explained, "Procs are objects. Say you create a proc with a return in a method *and return it from the method*. What happens when you call the proc now? How can it return from a method that has already returned? You'd have a continuation!"

[![In the long run, nobody cares](http://i.minus.com/iueb4lrtNpASx.png)](https://twitter.com/rbxbx/status/218496684148260865)

We pondered this for a while and the conversation meandered elsewhere, no doubt because my companions were embarrassed on my behalf. I had committed one of the basic errors of inexperience with the state of programming: Assuming that you're smart and you can work things out from first principles.

### math is fucked up, man

Computer Science is, of course, Mathematics. If you work out that you can build a [Turing Machine in Conway's Game of Life][tm], and you work out that a Turing Machines can compute anything computable, and you work out that Conway's Game of Life is computable, you don't need to actually try to build [Conway's Game of Life in Conway's Game of Life][golgol]: You've proved that it must be so, and that's that.

[tm]: http://www.youtube.com/watch?v=My8AsV7bA94
[golgol]:http://www.youtube.com/watch?v=xP5-iIeKXE8

Mathematics teaches you that facts are not as important as being able to reason from facts. Amongst other things! But still... This is what mathematics celebrates, the primacy of working consequences out from axioms.

Why is this fucked up? Because programming is the art of having humans build things, for humans, using tools humans have built, for other humans. Programming does not operate according to the rules of mathematics, it operates according to the rules of human behaviour. If there are such rules.

Some programming tools attempt to stay very close to the behaviour of mathematics. They are a delight to use.... If you are a mathematician. It is not important to the thesis of this essay whether these tools are so much better than other tools that all programmers should become mathematicians.

Perhaps programmers should [HTFU] and become mathematicians. But today, many or even most are not, and tools are built that cater to non-mathematicians, and languages are created where you cannot reason from facts how everything works, and these things become embedded in organizations, and it is non-trivial to it all out and reimplement everything using [Agda] compiling to JavaScript.

[HTFU]: http://www.youtube.com/watch?v=unkIVvjZc9Y
[Agda]: http://en.wikipedia.org/wiki/Agda_(programming_language)

So today, you must live with having to know how programming languages actually work, how the tools actually work, how the libraries actually work, and so forth.

### where smart interferes with gets things done

The great conceit of thinking you are "smart" is believing that because you are very good at working out consequences from axioms, you needn't know everything. If you know the axioms and the rules, that's it, you know everything. If someone tells you there are limits to this approach, you think they are starting a conversation about Incompleteness.

Whereas what they are actually saying is that these messy things we work with are, well, messy. If you try to write [Fizzbuzz in the Lambda Calculus][pwn], you will have a program that is very slow. If you claim that a "sufficiently smart compiler" can make it run fast, you will be right in theory, but grow old in practice waiting for that compiler to be written.

[pwn]: http://experthuman.com/programming-with-nothing

This conceit manifests itself in several ways. For starters, making unfounded claims about how Ruby procs and lambdas work over drinks. Another manifestation is the old chestnut, "I don't have *any* C++ experience, but I'm smart, I can learn on the job. I'd like $115K to start."

I'd like to say that this applies to the great demand for "Learn JavaScript in 21 Days" books, but I suspect that many of the people buying these books are not fooled into thinking they can learn as much in 21 days as [Peter Norvig learned in ten years][ten]. I think those folks have the far humbler goal of being good enough to get a job from someone who read "Learn to Interview Programmers in 21 Days."

[ten]: http://norvig.com/21-days.html

### in conclusion

The great truth is, it is necessary to be smart. It is necessary to get things done. And it is necessary to constantly learn, to try things, to get your hands dirty, to gain experience. There is no substitute and no shortcut for actual experience actually doing actual things with the actual languages, tools, and libraries you are actually using on the actual code base that solves a problem in the actual problem domain.

Speaking of which... Less blogging, more slogging. Thanks for listening!

(discuss on [hacker news](http://news.ycombinator.com/item?id=4882428) or [proggit](http://www.reddit.com/r/programming/comments/14e0nh/smart_and_gets_things_done_is_necessary_but_not/))

---

p.s. So what *does* happen when a proc attempt to return from a method that has already returned? Does this prove through reduction ad absurdum that it cannot return from that method? Does it create a continuation? No and no. It throws an exception. Kapow! Thanks go to [Yehuda Katz](https://plus.google.com/106300407679257154689/posts): He is an entire mining industry of wisdom about the subtleties of exiting from blocks and procs.

---

My recent work:

![](http://i.minus.com/iL337yTdgFj7.png)[![JavaScript Allongé](http://i.minus.com/iW2E1A8M5UWe6.jpeg)](http://leanpub.com/javascript-allonge "JavaScript Allongé")![](http://i.minus.com/iL337yTdgFj7.png)[![CoffeeScript Ristretto](http://i.minus.com/iMmGxzIZkHSLD.jpeg)](http://leanpub.com/coffeescript-ristretto "CoffeeScript Ristretto")![](http://i.minus.com/iL337yTdgFj7.png)[![Kestrels, Quirky Birds, and Hopeless Egocentricity](http://i.minus.com/ibw1f1ARQ4bhi1.jpeg)](http://leanpub.com/combinators "Kestrels, Quirky Birds, and Hopeless Egocentricity")

* "[CoffeeScript Ristretto](http://leanpub.com/coffeescript-ristretto)", "[Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators)" and "[JavaScript Allongé](http://leanpub.com/javascript-allonge)."
* [allong.es](http://allong.es), practical function combinators and decorators for JavaScript.
* [Method Combinators](https://github.com/raganwald/method-combinators), a CoffeeScript/JavaScript library for writing method decorators, simply and easily.
* [jQuery Combinators](http://github.com/raganwald/jquery-combinators), what else? A jQuery plugin for writing your own fluent, jQuery-like code.  

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)