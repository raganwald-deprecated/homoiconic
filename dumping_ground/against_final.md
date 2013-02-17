Against Effectively Final by Default
===

[Effectively Final by Default][final] is an ambitious essay that attempts to invent a bold new style of object -oriented design called [Strict Liskov Substitutability][liskov] and takes a stab at describing a new kind of automated test framework to validate programs written in this style.

It is easy to criticize the essay for being overly long and slightly confusing. It does take too long to establish the problems it is trying to address, and alternates confusingly between explaining the benefits of Strict Liskov Substitutability and criticizing Java's use of final methods to solve the same problems. These criticisms can easily be addressed. For example, the essay could be split into two essays, one on the benefits of Strict Liskov Substitutability and the other on the shortcomings of final methods. Each would have the focus and punch to be superior to the original.

However, these are flaws in style, not in ideas. What about the essay's central idea? Is Strict Liskov Substitutability a good idea, and if so, is "Duck Correctness" a useful way to validate Strict Liskov Substitutability?

**strict liskov substitutability**

The [Liskov Substitution Principle][sub] is that

----

Discuss on [Hacker News][hn] and [reddit.com][reddit].
  
NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[p2p]: http://www.yes-minister.com/ypmseas2b.htm
[raf]: http://raganwald.com/2006/05/ready-aim-final.html
[leaks]: http://steve-yegge.blogspot.com/2010/07/wikileaks-to-leak-5000-open-source-java.html
[clothes]: http://scifac.ru.ac.za/cspt/hoare.htm
[template]: http://en.wikipedia.org/wiki/Template_method_pattern "Template method pattern - Wikipedia, the free encyclopedia"
[liskov]: http://raganwald.com/2008/04/is-strictly-equivalent-to.html "IS-STRICTLY-EQUIVALENT-TO-A"
[inference]: http://en.wikipedia.org/wiki/Type_inference "Type inference - Wikipedia, the free encyclopedia"
[elharo]: http://www.elharo.com/ "Elliotte Rusty Harold"
[hn]: http://news.ycombinator.com/item?id=1592556
[reddit]: http://www.reddit.com/r/programming/comments/czlll/final_by_default/
[final]: http://github.com/raganwald/homoiconic/blob/master/2010/08/final.md#readme
[sub]: http://en.wikipedia.org/wiki/Liskov_substitution_principle