Can tools sink a software project?
===

Moishe Lettvin summarizing [The Windows Shutdown crapfest](http://moishelettvin.blogspot.com/2006/11/windows-shutdown-crapfest.html "moblog: The Windows Shutdown crapfest"):

> I'd also like to sketch out how actual coding works on the Windows team.

> In small programming projects, there's a central repository of code. Builds are produced, generally daily, from this central repository. Programmers add their changes to this central repository as they go, so the daily build is a pretty good snapshot of the current state of the product.

> In Windows, this model breaks down simply because there are far too many developers to access one central repository. So Windows has a tree of repositories: developers check in to the nodes, and periodically the changes in the nodes are integrated up one level in the hierarchy. At a different periodicity, changes are integrated down the tree from the root to the nodes. In Windows, the node I was working on was 4 levels removed from the root. The periodicity of integration decayed exponentially and unpredictably as you approached the root so it ended up that it took between 1 and 3 months for my code to get to the root node, and some multiple of that for it to reach the other nodes. It should be noted too that the only common ancestor that my team, the shell team, and the kernel team shared was the root.

> So in addition to the above problems with decision-making, each team had no idea what the other team was actually doing until it had been done for weeks.

> The end result of all this is what finally shipped: the lowest common denominator, the simplest and least controversial option.

This isn't the pathological edge case you might think. It's a classic example of the behaviour described by [Conway's Law](http://en.wikipedia.org/wiki/Conway%27s_Law "Conway's Law - Wikipedia, the free encyclopedia"), which says roughly that **organizations which design systems ... are constrained to produce designs which are copies of the communication structures of these organizations.**

Note here that the constraint comes through the tools: The source code repository structure and protocol is driven by the communication structure of the organization. That in turn constrains the design of features in the software, because features that require communication between groups that don't communicate cannot survive the source code protocol.

I don't think we should blame the tools for failure. Likewise I don't think we should idealize tools and pin our hopes of success on them. Tools are constrained by the organization. Give up on using wikis, git, or Ruby on Rails as a means of fixing communication problems in an organization that designs software. Instead, fix the communication problems directly and the tools and designs will naturally follow.

---

NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[Reg Braithwaite](http://braythwayt.com): [CV](http://braythwayt.com/reginald/RegBraithwaite20120423.pdf ""), [Twitter](http://twitter.com/)