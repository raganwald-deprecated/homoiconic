Williams, Master of the "Come From"
---

In this business, you meet more than your fair share of eccentric developers with their own idiosyncratic ideas about software development. (If you're like me, you need go no further than a mirror to see what one looks like.) One of the most iconoclastic fellows I ever met was a grizzled veteran named Jim Kelly. For reasons of interest only to cultural antiques, everyone called him "Williams."

Williams claimed to have gotten started when using punch cards and random access memory was considered effete by the [drum memory wizards of the previous generation][mel]. Like many retro-grouches, he would fondly recall rites of passage such as booting computers by toggling the three bootstrap instructions into a CPU's front panel. If his eccentricity stopped at recounting tales from days of yore, I'd probably have forgotten him years ago.

[mel]: http://www.pbm.com/~lindahl/mel.html "The Story of Mel"

However, Williams was unique. Most veterans cling to whatever beliefs about software development were in vogue when they were cutting their teeth. Be it the utility of Lisp, the superiority of the VAX architecture, or the string-theory-like perfection of Smalltalk, most veterans cling to technology and ideas that were cutting edge back in their day. Not Williams. Williams had invented his own software development methodology, and he espoused it with the fervour of an evangelist on a street corner.

He had long ago accepted that the rest of the world was not about to change to do things the "right way," but he likewise refused to submit to fashion, no matter what the costs to his reputation or career. So he bounced from job to job, constantly being let go for "lack of fit with the team," until he wound up at ThinkWare, a contracting firm. The partners at ThinkWare specialized in finding ways for square pegs to write software that fit in round holes, and they carefully walled Williams off so that he could write software his own way with very little interference from anyone else.

Williams had a style that ThinkWare described as "unorthodox, but effective." 

**I'll take you, darling. And you. And you. And. You.**

Typically, ThinkWare would give Williams a list of features to implement. Williams was very big on dependencies, and he would very carefully draw a graph of feature dependencies. For example, if he was going to write a Facebook Clone, his diagram would show that commenting on a wall post depended on wall posts, which in turn depended on walls.

Williams would then work along the graph, not starting any feature until all of its dependencies were fully implemented. And he would work on a single feature at a time, completing the feature in its entirety before staring another. Williams loathed developing infrastructure that would "pay off later," he preferred to write the simplest and least amount of code required to get the current feature to work.

In that respect, his style resembled many agile developers. And in another respect, he appeared "agile" to those who never read his code: Williams loved to write tests. When Williams delivered a feature, there was much, much more test code than working code. Williams had been taught to write automated unit tests at a time when the standard architecture for making code "testable" consisted of writing a command-line wrapper so that the tests could be baked into a shell script, and he never wavered from his belief that if you haven't tested it, it doesn't work.

So Williams' process was simple: Work on features one at a time, write the minimum amount of code to get the feature to work, practise [YAGNI][y], and write comprehensive tests for each feature.

[y]: http://en.wikipedia.org/wiki/You_ain't_gonna_need_it "You ain't gonna need it"

**Too busy looking good**

Although Williams' style seemed contemporary, it was his heterodox practices that drove a wedge between him and his colleagues. Unlike every other agilist on this or any planet, Williams disdained refactoring. It wasn't that he saw no value in refactoring: Scrolling through his checkins revealed that he would write and rewrite the code for each feature numerous times.

However, once WIlliams delivered a feature, he liked to move on to the next feature and leave the code for existing features unchanged as much as possible. For example, if he delivered a wall post feature, it might include an ActiveRecord model class:

		# wall_post.rb

		class WallPost < ActiveRecord::Model
			# ...
		end

Once the Wall Posts were delivered with tests, he might work on comments. But instead of changing `wall_post.rb` to read:

		# wall_post.rb

		class WallPost < ActiveRecord::Model
			has_many :comments
			# ...
		end

Williams would isolate all of the code for comments into a module or plugin, and "monkey patch" the `WallPost` class:

		# vendor/plugins/comments/lib/railtie.rb

		WallPost.class_eval do
			has_many :comments
			# ...
		end

Since none of the code written so far needed to know that a wall post could have comments, he saw no value in cluttering up those files with comment-handling code. Instead, he put the relationship between wall posts and comments in the code that was responsible for doing something with comments. His code was uniformly organized so that the code dependencies were exactly isomorphic to the feature dependencies.

Williams used every decoupling technique in the book and several he invented himself, from monkey-patching to method combinators to writing observers on classes. Inexperienced developers would often be completely bewildered as to how anything worked at all, and would search in vain for signs of a heavyweight [Dependency-Injection][di] framework.

[di]: http://en.wikipedia.org/wiki/Dependency_injection

Features are fairly coarse-grained, so after getting over the shock of Williams's style, most developers could adjust. However, Williams also used these decoupling techniques for fine-grained cross-cutting concerns as well. So instead of writing:

		# wall_post.rb

		class WallPost < ActiveRecord::Model

			def doSomething
				WallPost.transaction do
					# ...
				end
			end

 		end

Williams would write:

		# wall_post.rb

		class WallPost < ActiveRecord::Model

			def do_something
				# ...
			end

 		end

And:

		# wall_post_persistence.rb

		WallPost.class_eval do

			def do_something_with_db_transaction
				WallPost.transaction do
					do_something_without_db_transaction
				end
			end

			alias_method_chain :do_something, :db_transaction

		end

The net result was that his models were always small and directly concerned with business logic, while implementation details like error handling and persistence were moved out into separate modules and plugins.

**How sloppy your man works**

Of course, his colleagues rioted at the thought of working with his code.

> In Smalltalk, everything happens somewhere else--Adele Goldberg

When looking at one of Williams' model classes, all you would see is the basic, bare bones minimum functionality. Other features would be entirely implemented elsewhere, often in plugins of one kind or another. That made following the code annoying for developers used to the "One model class to rule them all" style of coding.

And the one or two folks who prayed at the [Big Church][spring] were aghast at the lack of an Injection Container and the complete absence of XML configuration. As one educated wag put it:

> Williams has elevated the [computed][comp], non-local [COMEFROM][cf] to an art form

Worse, Williams' style made it obvious how little work he really did. His methods were short and simple and to the point. It looked as if he was bored and making work for himself with all the decoupling, because the decoupling was easily the most advanced code in any of his projects.

It seemed like a code smell to have infrastructure code that was more advanced than the domain code, as if he was an [architecture astronaut][aa] intent on making life hard for himself and his colleagues.

[cf]: http://en.wikipedia.org/wiki/COMEFROM
[comp]: http://en.wikipedia.org/wiki/Goto#Computed_GOTO
[spring]: http://www.springsource.org/ "Spring Framework"
[aa]: http://www.joelonsoftware.com/articles/fog0000000018.html "Don't Let Architecture Astronauts Scare You"

**Unorthodox, but effective**

Meanwhile, the ThinkWare partners had adopted a tolerant attitude towards Williams and his code. Despite the objections from his colleagues, they had noticed that his code really did work and tend to stay working, mostly because it really was decoupled. New features could always be backed out simply by removing their plugins or modules.

This was most evident when examining his mountains of test code. Very little of it was concerned with mocking and stubbing functionality, because he could always test his models without persistence layers or error handling frameworks to stub in.

Williams, they had discovered, was a good developer... Within his limitations. Those limitations being, as well as he worked and as well as his code worked, when handed off to someone else his dependency decoupling would invariably erode away. Entropy would rot his architecture, as developers would work around it to get things done quickly.

**Ghettoes are the same all over the world.**

It wasn't that his colleagues were unimaginative or lazy, but Williams' style clashed with an environment that celebrates YAGNI and refactoring. Decoupling was, most developers reasoned, something they weren't going to need, and if they did, it could be refactored in later.

So the ThinkWare partners put Williams in charge of small projects where he could practice his own brand of architecture in peace, and largely left him to his own devices. The clients were happy, and he was happy. Once in a while another developer would work with him on a limited basis, and after getting up to speed on how things worked in his particular corner of the Universe, they'd fall in line and get a lot of stuff done.

Sometimes they'd return to another project and try to implement some of his ideas, with middling success. But as long as the developers learned something from the experience, the ThinkWare partners figured that pairing Williams with a colleague from time to time was a win.

The last time I saw Williams, he had grown an afro and was carrying a tennis racket, obviously on his way to a game. We chatted for a while, and he excitedly told me about a framework he was developing for implementing really [lightweight decoupling][yadc] in some weird dialect of JavaScript.

I never saw him again, but I like to imagine that he's still at ThinkWare, writing solid code and evangelizing his ideas to anyone who will listen.

[yadc]: https://github.com/raganwald/YouAreDaChef "YouAreDaChef"

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