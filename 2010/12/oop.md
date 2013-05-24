OOP practiced backwards is "POO"
===

Over on [Hacker News](http://news.ycombinator.com/item?id=1991949), there's a small discussion about OOP and specifically about inheritance. "lyudmil" pointed out:

> The way inheritance is always taught is through the "is-a" rule of thumb and I think that's so detrimental to the students that they'd be better off if they didn't know inheritance existed. The phrase "X is-a Y" often appears to make sense because of the real world (e.g. "Cat is-an Animal"), but it makes people forget that it may not make sense in the world they are trying to model. It may be that the relationship between a Cat object and an Animal object is completely different in your system than in the real world.

The "Cat and Animal" example is a perfect one to illustrate what is so fundamentally broken about trying to model software systems as an ontology where the definition of each "object" is encoded in its "class." Consider a Naturalist. He goes into the wild, observes things, and over time creates an ontology starting with animal, vegetable, and mineral at the top and subdivides downwards in a directed acyclic graph. This is not a strict tree, it allows for things like [carniferns](http://everything2.com/title/Carnifern), bats, and penguins.

Let's talk about Cats being Animals. For starters, there is no such thing as "Cat" and especially no such thing as "Animal." There is this cat and that cat and this dog and that elephant. "Cat" and "Animal" are abstract concepts we derive from observations of concrete, real instances. I will repeat the two key words: abstract and derived. Leaving creationism out of it, DNA is a program that builds a specimen creature. Certain particular programs produce things we lump into a classification we call "animals," and a subset of those things we call "cats." 

Now, our understanding of DNA is imperfect. But we seem to be certain that it is not arranged the way we arrange a program using "OOP." Animals have lots of genes in common with each other, cats more so, jaguars more so, and down until we have the maximum possible commonality between any two instances, a pair of identical twin Jaguars.

The DNA does not have one strand for animals, another for cats, and a third for jaguars. It does not compose these specializations together to produce the final specimen individual. DNA is a chaotic, unstructured mess. Einstein once said that "God does not play dice." I will say that "God does not use OOP" in the same spirit. The result of mutation and sexual combination and all the other factors driving specialization of life on earth ends up having a form that can be organized into an ontology, but the important thing to remember is that **the abstract ontology is derived from the behaviour of the individual specimens, the ontology does not define the behaviour of the individual specimens**.

OOP gets this backwards. In OOP you define the ontology up front in the form of classes or prototypes. You then derive individual instances or objects from the ontology. The OOP ontology isn't a way of sketching what we observe, it's blueprint for building what we observe, nearly the exact opposite of the naturalist's ontology.

I've said that OOP's ontology is the opposite of the naturalist's ontology. Is this a problem? Yes, and here is why. The naturalist's ontology is resilient to new discoveries. If we know nothing of penguins and we discover a bird that cannot fly but pursues its prey by swimming, we can re-arrange our ontology without disturbing any existing birds. The ontology is abstract, so it is decoupled from existing nature.

Not so for the OOP ontology. Changes and re-arrangements break existing code, because all of the specimens, the instances and objects, depend on the various classes, interfaces, and other constructs that define their behaviour. is this a problem? Yes again, because computer programs change constantly. Discovery of new requirements, and new information is the norm, not the exception. OOP programs built as towering hierarchies of classes are like perfect crystals, to be admired by architects everywhere but loathed by the programmers responsible for maintaining them.

> In Smalltalk, everything happens somewhere else.—Adele Goldberg, “

An OOP ontology is more than a blueprint for the way a program must function today, it's a nearly all-in bet on how it will change in the future. The ontology must define the objects, but it must also be factored such that future changes will neatly fit into the ontology as written. If not, everything must be re-arranged and that is absolute hell on earth. Because every change to the ontology to accommodate a new requirement ripples down affecting all of the dependent objects and instances.

**another way forward**

There is another way forward. What if objects exist as encapsulations, and the communicate via messages? What if code re-use has nothing to do with inheritance, but uses composition, delegation, even old-fashioned helper objects or any technique the programmer deems fit? The ontology does not go away, but it is *decoupled from the implementation*. Here's how.

These days we have all embraced automated testing. It's a pragmatic, worse-is-better embracement of Design-by-Contract (also, DBC is protected by various business restrictions so it has nobody but itself to blame for its unpopularity). So in addition to our program that doesn't use inheritance, we have a massive test suite. Unlike the implementation part of the program, we organize the test suite into an ontology, using inheritance with glee. 

Here it makes sense. If we say there is such a thing as an `Animal` in the testing ontology, we're saying that anything that passes the following suite of tests is an animal. If we say a `Cat` is an `Animal`, we're saying that the set of tests for a `Cat` is a superset of the set of tests for an `Animal`. It's irrelevant to us how objects in the program are written, just that those we want to use as cats must pass our tests for a Cat.

As we discover new requirements, we have two parallel tasks. The first is to refactor our testing ontology as appropriate. The second is to update our program to pass the new tests. The two activities are decoupled. This saves us much trouble.

For example, let's say that our animals all run on four legs. Then we decide we need bats, and bats are animals, so we create a `Bat` suite of tests and say a `Bat` is an `Animal`. Well, that breaks our testing ontology because bats don't run and a `Bat` would fail the test for an `Animal`, so we move the test for running on four legs into `Cat` (or some new class like `Runner`). This doesn't disturb our existing program in the least, and we are free to implement objects that pass the test for a `Bat` any way we like. It may be that in the program, bats borrow code from birds even though in the testing oncology, `Avian` is very different from `Animal`.

In this system, our ontology is observed from nature just like the naturalist's ontology. And you can start using it today with almost any programming language, you just have to decide that the inheritance provided "out of the box" is best ignored for implementing things, and that you should think of the ontology as defining the behaviours you observe as expressed in tests rather than defining the implementations and definitions that create objects.

fin.

**interesting further reading**

* [InfoQ: Book Excerpt and Interview: The Joy of Clojure](http://www.infoq.com/articles/the-joy-of-clojure "InfoQ: Book Excerpt and Interview: The Joy of Clojure")
* Loren Segal, [Too Lazy to "Type"](http://gnuu.org/2010/12/13/too-lazy-to-type/ "Too Lazy to &quot;Type&quot; (gnuu.org)")
* Robert Martin's [Response](http://thecleancoder.blogspot.com/2010/12/too-lazy-to.html "Too Lazy to &quot;Type&quot;. - Uncle Bob's Blog")

*([Alan Kay](http://duckduckgo.com/Alan_Kay) coined the phrase Object-Oriented Programming, but this is not his fault. He has repeatedly said that to him, OOP is about encapsulation and message passing, not inheritance and ontologies of types. But like so many other Cargo Cults in Computer Programming culture, OOP and inheritance are enchained like ancient mariner and albatross.)*

---

[Discuss this post](http://news.ycombinator.com/item?id=1993129) on Hacker News. NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)
