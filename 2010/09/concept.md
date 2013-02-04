Why I Write Concept Software (Revised)
===

One of the best technology business essays I've ever read is [Why Apple doesn’t do "Concept Products"](http://counternotions.com/2008/08/12/concept-products/ "Why Apple doesn&#8217;t do &#8220;Concept Products&#8221; &laquo; counternotions"), written by the mononymous "Kontra."

Kontra's thesis is that real products have constraints, and that creating a real product is making a bet that the right set of compromises can be made between all of the conflicting constraints on product design. Making a phone's battery larger increases battery life but makes the phone heavier and larger. Supporting Flash makes the product more popular but undermines your control over the development platform. Every choice has ramifications and the genius is in finding a solution to the problem of satisfying all of the constraints simultaneously while making a product people want to use.

I hope that Kontra does not object to my quoting one of the best pieces of technology writing I've read in the past few years:

> **Real artists ship, dabblers create concept products**

> Pretenders don’t quite understand that design is born of constraints. Real-life constraints, be they tangible or cognitive: Battery-life impacts every other aspect of the iPhone design — hardware and software alike. Screen resolution affects font, icon and UI design. The thickness of a fingertip limits direct, gestural manipulation of on-screen objects. Lack of a physical keyboard and WIMP controls create an unfamiliar mental map of the device. The iPhone design is a bet that solutions to constraints like these can be seamlessly molded into a unified product that will sell. Not a concept. Not a vision. A product that sells.

> It turns out that when capable designers are given real constraints for real products they can end up creating great results. In Apple’s case, groundbreaking products like the iMac, the iPod and the iPhone. Constraints have a wonderful way of focusing the mind on the fundamentals, whereas concept products can often have the opposite affect.

> Concept products are like essays, musings in 3D. They are incomplete promises. Shipping products, by contrast, are brutally honest deliveries. You get what’s delivered. They live and die by their own design constraints. To the extent they are successful, they do advance the art and science of design and manufacturing by exposing the balance between fantasy and capability.

I think this is correct. Successful shipping products "advance the art and science of design and manufacturing by exposing the balance between fantasy and capability."

**software products and concepts**

I hope you'll agree that software can be a product, even when you don't charge money for it. And every product has a mission, a purpose. Paul Graham once suggested that startups pose their mission statement as a question. Google's question might have been "Will the PageRank algorithm deliver results that are so good that they lure users away from Altavista?"

Products have a user or a decision maker in their question. Product questions are expressions of curiosity about human behaviour. Will people buy this phone? Will people share personal details with each other on the Internet? Will people submit and rank content for each other to read and discuss? Product questions ultimately boil down to, *What does it take to get people to change their behaviour?*

Shipping a product is a bet that someone, somewhere will change what they're doing. Making money shipping a product is a bet that there's a way to extract a net positive value out of that change. Shipping a product forces you to answer all six of the key questions: Who, what, where, when, how, and most especially, **why**.

![Courier PC](http://blogs.msdn.com/blogfiles/innov8showcase/WindowsLiveWriter/MicrosoftsCourierdigitaljournalexclusive_CDBA/image_6.png)  
_(image gleefully snarfed from Engadget)_

Concept products, on the other hand, are expressions of curiosity about what is and isn't possible with design, technology, styling, or anything else that doesn't have a person making a decision in it. How would a tablet work if it unfolded like a book? What would a computer look like if it could talk to you? There may be people in the question, but the question is never about the transition between now and the future, the question is never about what it takes to get them to change. Concept product leap into the future without addressing the pesky question of how to get there from here.

Naturally, if software can be a product, we can also have "concept software." Software that exists to answer a question about who, what, where, when, and how, *but not why*. Concept products are sometimes just musing, sometimes just sketching, sometimes just aimless dabbling. But sometimes concept products are focused attempts to answer a specific question. Naturally, a question that doesn't include reasons why people will change their behaviour is an easier question to answer.

But nevertheless, concept products can be judged by the degree to which they express the answer to a specific question. Is it possible to manufacture a racing bicycle that weighs under three kilograms and is strong enough to complete a stage race? Can a human-powered ornithopter fly?

Concept software can be judged by the same metric, by whether it answers a specific question. Can cellular automata reproduce themselves using a blueprint or description of themselves? Could program behaviour be denoted using CSS-like classes instead of OO-like classes?

**some of my experience with concept software**

I've written software products and I've also written concept software. To give two very minor examples, when I was working with Benjamin Stein from [Mobile Commons](http://mcommons.com/), we kept running into the same problem of checking for null values. After some discussion, we settled on writing [andand](http://github.com/raganwald/andand/ "Object#andand") for our own use. Ben was kind enough to allow me to make it free software, and it turned out to be a minor success. I later discovered that we had inadvertently reinvented `#ergo` from Ruby Facets, not to mention rediscovered the [Maybe Monad](http://moreindirection.blogspot.com/2010/04/brilliance-of-maybe-and-utility-of.html "more indirection: The Brilliance of Maybe and the Value of Static Type Checking").

To me, andand is a very small software product. It has users, it has a very well defined path for adoption, even its name was chosen to ease adoption by giving a hint of how to use it.

After andand, I became curious about monads and about modifying the way Ruby invoked methods on objects. I wondered to myself, *If andand was imply a specific case of a more general things, what would that thing look like?*. That question, you will note, has no "why" in it, no transition from what came before to what will come after. Answering that question creates concept software, not a software product.

And indeed, I created the [Invocation Control Kit](http://github.com/raganwald-deprecated/ick "raganwald's ick at master - GitHub"), "an ad hoc, informally-specified, bug-ridden, slow implementation of half of Monads" to answer the question. If you listen carefully, you can hear the crickets chirping around its download link.

When I wrote Ick, I had no illusions that it would become a product. I deliberately discarded any notion that I needed to make it easy to learn, or popular, or even superior for solving certain problems. I set out to find out how far I could abstract and generalize the idea of andand. I was working with a software deign the way a materials engineer might destructively test a piece of carbon fibre: I was abusing it to find out how far it would go before breaking.

With andand and Ick, I went from product to concept. I later went in reverse: I created a concept called [Rewrite](http://github.com/raganwald-deprecated/rewrite "raganwald's rewrite at master - GitHub"). I had a specific problem I wanted to solve, namely the egregious monkey-patching common in Ruby programs. However, I wrote Rewrite without any concern for making it adoptable. I set out to determine what and how without saying who, when, or why.

I even presented my concept product at [Rubyfringe](http://www.infoq.com/presentations/braithwaite-rewrite-ruby "InfoQ: Ruby.rewrite(Ruby)"), an un-conference. I didn't ask people to use it, I held it up as proof that there was at least one alternative to monkey-patching, and challenged the community to invent a better way.

Well, inspirational speaking is nice, but as a professional programmer I needed a product. So I started from scratch and used what I learned from writing Rewrite to--ummm--rewrite it as [Rewrite Rails](http://github.com/raganwald-deprecated/rewrite_rails "raganwald's rewrite_rails at master - GitHub"). Rewrite Rails was a product: It was written specifically to make it easy to add to existing projects. I used it myself on a shipping product. My mission for Rewrite Rails very definitely addressed the questions of who and why.

So here we have two products and two concepts. In one case, the product inspired the concept. In the other, the concept inspired the product. Although they might seem to be inverses of each other, in both cases the impetus for the concept was *curiosity*.

> Curiosity demands that we ask questions, that we try to put things together and try to understand this multitude of aspects as perhaps resulting from the action of a relatively small number of elemental things and forces acting in an infinite variety of combinations.--Richard P. Feynman, [Essentials of Physics](http://www.yorktech.com/science/craig/PHS/Work/Feynman.htm "Essays on Science")

**curiosity and dabbling**

There. I've freely confessed that I create concept software for no more reason than that I am curious to see how it turns out. Does it pay off one day in better products or better skills on my part? I don't know and I'd be surprised if someone can make a good case for it. Lots of people make lots of money without a shred of curiosity about implementing half of monads in Ruby or adding combinators to jQuery.

Is curiosity some noble, lofty purpose? I don't think so, and there's a lot of curiosity out there. Curiosity about whether jQuery Mobile will catch on is no less important than curiosity about whether PHP programmers can be induced to write more elegant OO programs. Curiosity about whether someone can bank a few million dollars a week from a game written in Java is no less noble than curiosity about whether JavaScript applications on the client can have a simple, Sinatra-like architecture.

Ultimately, I happen to be curious about certain things, and my curiosity demands that I get some answers. There's no other lofty, admirable explanation for why I write on things like [Recursive Combinators](http://github.com/raganwald/froobie/blob/master/lib/froobie/recursive_combinators.rb "lib/froobie/recursive_combinators.rb at master from raganwald's froobie - GitHub") when I could be contributing to a software product.

However, just because I create concept software out of curiosity, that doesn't mean I'm off the hook for having some direction, some means of judging how well I'm doing. I've found that the key is to articulate a question to answer, just like any other concept product. WhenI'm curious about something, the next step is to be specific about precisely what I'd like to discover.

When I am able to articulate a specific question, my curiosity leads to concept software that advances my own understanding of software design and manufacturing. When I fail to articulate a specific question, I wind up dabbling without direction.

And this brings us to a satisfactory answer to the question. I write concept software to satisfy my curiosity, and when I am able to focus on answering a specific question, I am able to advance my understanding of software development.

---

p.s. My recent little product releases include [Wood &amp; Stones](http://github.com/raganwald/wood_and_stones "raganwald's wood_and_stones at master - GitHub"), [jQuery Combinators](http://github.com/raganwald/JQuery-Combinators "raganwald's JQuery-Combinators at master - GitHub"), [jQuery Predicates](http://github.com/raganwald/jQuery-Predicates "raganwald's jQuery-Predicates at master - GitHub"), and [iGesture](http://github.com/raganwald-deprecated/iGesture "raganwald's iGesture at master - GitHub"). Feedback about "why" or "why not" is always welcome... I wrote these things to be used!

----

NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)
