A new way to think about programs
===

[CoffeeScript][coffee] is an excellent "little" programming language created by Jeremy Ashkenas. I've been meaning to write nice things about CoffeeScript for a while, but quite honestly it speaks for itself. Really! Have a look at it, and especially *try programming with it*. If you go to the CoffeeScript home page, you can try CoffeeScript right in your browser. CoffeeScript support is baked into [Node.js][node]. How much easier do you want it to be?

Going from JavaScript to CoffeeScript today feels a lot like going from Java to Ruby felt to me in early 2003. I know this may surprise people used to my wordiness, but I honestly can't think of anything to say that will be more persuasive than the experience of simply writing CoffeeScript code. But however exciting that is, I haven't written about it.

![Fiorenzato Coffee Machine Ducale](https://www.coffeeitalia.co.uk/prodimages/fiorenzato/professional/ducale/Ducale-fronte_300.jpg)

Every time I've started a blog post about CoffeeScript, it felt vaguely like I was recycling some old post about Ruby or about meta-programming, or about the power of writing and reading succinct code. Such things may be news to a new generation of programmers, but when I write them, I feel like one of those self-help Gurus who keep re-selling the same damn book over and over again: *The One Minute Manager's Seven Habits for Getting Chicken Soup for the Mars and Venus Bipolar Lisp Programmer's Soul Done, [The Hard Way][lpthw].*

So I keep putting off writing about Coffescript, hoping that one day I'll have something insightful to say about it, or hoping that I'll discover something about it that "piques my intellectual curiosity." It isn't that anything is missing, it's just that it works and works well.

**illiteracy**

Last week, I tried something else Jeremy has written, and I think it's even more exciting than CoffeeScript. If I were Steve Jobs, I'd tell you there's "one more thing." I'm talking about **[Docco][docco]**. Docco is a tool for writing code in the [Literate Programming][lp] style. You can read about literate programming for yourself, but the idea is to write a program in a conversational, narrative style. Your write it the way you would explain your idea to another human, and a tool converts your literate programming into the "tangled" representation that the computer understands.

> The literate programming paradigm... represents a move away from writing programs in the manner and order imposed by the computer, and instead enables programmers to develop programs in the order demanded by the logic and flow of their thoughts. Literate programs are written as an uninterrupted exposition of logic in an ordinary human language, much like the text of an essay, in which macros which hide abstractions and traditional source code are included. --[Wikipedia][lp]

This isn't translating English into machine instructions, you still write code (JavaScript or CoffeeScript in the case of Docco), this is actually a question of the way you organize your program. We programmers have many different forces acting on the way we organize a program.

One force acting on program organization is the *archeological accident*: We write our programs, make changes, add features, and if we do nothing else the resulting program's organization is strongly influenced by the chronology of our changes.This is why it's always easy to criticize an existing program. The existing program is usually adorned with the warts of its archeology, and in hindsight it's easy to see how if you were starting from scratch with the final "requirements," you would design something cleaner and more elegant than the program that evolved over time.

![Illuminated Manuscript](http://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Meister_des_Mar%C3%A9chal_de_Boucicaut_001.jpg/370px-Meister_des_Mar%C3%A9chal_de_Boucicaut_001.jpg)

Another force acting on program organization is the *responsibility architecture*. Programs are organized into modules or chunks based on their responsibilities. Whether those chunks are services, objects, methods, functions, modules, namespaces, or whatever, contemporary thinking emphasizes an architecture that optimizes for separation of responsibilities and concerns.

Although it may seem like separating concerns makes programs more readable, we must distinguish the readability of an encyclopedia from the readability of an essay. Sure, when you're looking for a function and you want to make a change, the responsibility-driven architecture is a win. But when you're first picking up a new library and trying to understand what it does, you have completely different needs. Optimizing the code for separation of responsibilities does not always produce the best code for reading and learning.

**essaying**

Blogging has helped me become a better programmer. Explaining ideas in essay form forces you to think things through and to organize your thoughts. This is as true of programs as it is of other ideas. A program may function correctly and it may embody a well-organized encyclopedia, but explaining how it works in essay form forces you to see the program through a new pair of eyes.

Explaining a program in essay form isn't the same thing as "documenting the program" it or "commenting the code." Those phrases lack any real meaning. Essays have a certain structure. Concepts must be introduced in a certain order, and it isn't always as simple as introducing an idea before using it. Essays sometimes hand-wave an idea and explain it later. They sometimes introduce an idea directly, sometimes parenthetically, and sometimes as a footnote or link to a longer explanation elsewhere.

It's true that an essay written about a program is an excellent tool for learning what the program does. But equally importantly, the very act of writing an essay about a program improves the author's understanding of the program. It guides the elimination of cruft and archeological artefacts.

Writing an essay about a program is an excellent way to refactor a program. It's a *forcing function*. If your program stinks, your essay stinks.

**docco**

Which brings me back to [Docco][docco]. I just spent an enormous amount of non-billable time rewriting the [Roweis][roweis] plugin using Docco. Have a look at the [code][roweis_code] and the resulting "[essay][roweis_docco]." As you know from perusing Docco's own documentation, the workflow for using Docco is pure simplicity:

1. You write your code;
2. You comment your code inline, and;
3. You run Docco to create an HTML page for each file in your project.

Docco's pages have two columns, text on the left and syntax-highlighted code on the right. Docco interprets your comments as [Markdown][md], so you can include all sorts of stuff like links, section headings, type formatting like bold, even example code.

I don't know if the docco page I just produced is any good as documentation. I don't think so, like many written things I suspect that I need to go away from it for a while and then come back and look at it with fresh eyes, then iterate again. But I know that the code behind the docco page is far, far better now than it was when I first ran `docco sammy.roweis.js`.

My workflow has been:

1. Run docco;
2. Start reading the resulting page from the top;
3. Decide that something doesn't make sense;
4. Make a bunch of changes to the code;
5. Document the changed code;
6. Go to step 1.

It's not just documenting what I have or even re-arranging its order. As I've tried to document it in literate form, I've had to change the underlying program. Some stuff that was perfectly happy being functions in a closure's scope have become helper functions placed elsewhere. A large collection of gnarly special cases became a collection of faux macros applied using an iterator (I have my eye on another collection of special cases that will shortly be getting the same treatment). And on it goes. I don't think the resulting code is good, but I know it's *better*.

And that, to close this essay, is my point. Alan Perlis [once said][perlis]:

> A language that doesn't affect the way you think about programming, is not worth knowing.

Docco has affected the way I think about programming. Literate programming may not be new, but it's new to me. And like many new ideas, sometimes it's the availability of a cheap and easy tool that unlocks the idea's potential. Docco introduced me to literate programming, and it's so easy to use that I have no excuse not to use it.

Thanks, Jeremy!

p.s. *CoffeeScript is about to get **even more interesting**. Be sure to check the [CoffeeScript site][coffee] for updates and/or announcements over the next few days...*

---

Discuss this post on [Hacker News](http://news.ycombinator.com/item?id=1883995) and [Reddit](http://www.reddit.com/r/programming/comments/e345e/a_new_way_to_think_about_programs_githubcom/). NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[coffee]: http://jashkenas.github.com/coffee-script/ "CoffeeScript"
[node]: http://nodejs.org/ "node.js"
[lpthw]: http://learnpythonthehardway.com/index
[docco]: http://jashkenas.github.com/docco/
[lp]: http://secure.wikimedia.org/wikipedia/en/wiki/Literate_programming
[roweis_code]: http://github.com/raganwald/Roweis/blob/master/lib/sammy.roweis.js
[roweis]: http://github.com/raganwald/Roweis
[roweis_docco]: http://raganwald.github.com/Roweis/
[md]: http://daringfireball.net/projects/markdown/ "Daring Fireball: Markdown"
[perlis]: http://www.cs.yale.edu/homes/perlis-alan/quotes.html