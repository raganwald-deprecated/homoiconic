Metalinguistic Abstractions in Ruby
===

> The following discussion is extracted from a forthcoming talk--"The Revised, Revised Ruby.rewrite(Ruby)" or "R5"--to be be delivered at [Stack Overflow Dev Days](http://www.amiando.com/stackoverflowdevdays-toronto-can.html "Stack Overflow Dev Days Toronto - Carsonified"). I apologize for the lack of surrounding context in this format.

Wikipedia notes that [metalinguistic abstractions](http://en.wikipedia.org/wiki/Metalinguistic_abstraction "Metalinguistic abstraction - Wikipedia, the free encyclopedia") are the idea behind "The process of solving complex problems by creating a new language or vocabulary." So metalinguistic abstractions are new languages we create to solve problems. My first reaction is to observe that the Ruby culture strongly embraces the creation of new domain-specific languages" or "DSLs?" For example, [Webrat](http://github.com/brynary/webrat) allows you to write code such as:

    def test_trial_account_sign_up
      visit home_path
      click_link "Sign up"
      fill_in "Email", :with => "good@example.com"
      select "Free account"
      click_button "Register"
    end

Similarly, [Ruby on Rails](http://rubyonrails.org/ "Ruby on Rails") allows you to write:

    has_many :opinions
    validates_presence_of :ego

While [Shoulda](http://www.thoughtbot.com/projects/shoulda "Projects - Shoulda") allows you to write:

    should_render_template :show

Aren't these all examples of new languages?

**vocabularies and languages**

Let's start with Webrat. Ruby is an object-oriented language with imperative semantics. You send messages to objects and things happen. State is changed. This is the pervasive metaphor everywhere. Webrat code clearly follows this form: You are telling Webrat to do something, and something will happen as a side effect of the commands you issue. In this case, there is a simulated session in a web application being used for testing.

That's Ruby, all we are adding are new words like "visit" and new phrases like "fill\_in" or "click\_button." But we are not creating a new language. It's the same old language with the same old semantics and metaphor. I don't think that's a bad thing, I think it's brilliant! That's the whole point of creating an API, creating a rich domain-specific vocabulary that encodes an important abstraction.

But let's compare that to Rails and Shoulda. To refresh your memory:

    has_many :opinions
    validates_presence_of :ego
    should_render_template :show

Here we have new vocabulary. But we have something else as well, new semantics. All three examples communicate *declarative* semantics rather than imperative semantics. Of course, there is nothing actually declarative going on here. The line `has_many :opinions` seems to say, "There is a has-many relationship between instances of this class and instances of the Opinion class," but what actually happens is that Rails creates thirteen helper methods in this class for manipulating a collection of opinions.

Adding non-imperative, non-OO semantics on top of Ruby is nothing surprising. As [Peter Jaros](http://peeja.com/ "Play On - Play On") noted, Ruby does this itself, out of the box. For example, Ruby's core libraries permit you to write:

    attr_reader :balderdash
    
This look remarkably like you are declaring a property. But no, you are actually calling a method that in turn imperatively defines another method:

    def balderdash
      @balderdash
    end
    
The same is true of Ruby's support for "functional programming:" While you can write `idiot_bird = lambda { |x| x }`, you are not actually creating a function, you are creating an object that happens to have a method named `call` and a synonymous method invoked using `[]`. It's another linguistic abstraction, faking functional semantics with Ruby's objects-all-the-way-down semantics. It's also a very leaky abstraction, you cannot write `idiot_bird(foo)` and expect it to work.

Thus, metalinguistic abstractions have two flavours. The first is the creation of a rich vocabulary that is used in conjunction with Ruby's existing semantics, the second is the creation of a new language with new semantics including but not limited to programming in a declarative way. Ruby itself provides examples of both kinds of metalinguistic abstraction.

**vocabularies**

Quite obviously programming in almost every programming language involves naming things. You name classes, modules, attributes, variables and many other things in Ruby. In a sense you are creating an ad hoc vocabulary as your program even if you aren't deliberately attempting to create a vocabulary.

However, most forms of software design formalize this with a little more ceremony. For example, a common analysis strategy is to start by listing all of the entities in the problem domain the program is intended to address. An analyst might write down nouns like "Employee" and "Hire Date" when designing an HR application, then later come up with verb phrases like "Issue Pay" or "Dehire" (an amusing digression is to note that the modern style of programming [subordinates verbs to nouns](http://weblog.raganwald.com/2007/10/too-much-of-good-thing-not-all.html "Too much of a good thing: not all functions should be object methods")).

Even though many domain entities are named, simply choosing names for nouns and phrases for verbs on an ad hoc basis is not metalinguistic programming. Metalinguistic programming involves designing a complete vocabulary much as one would design a complete piece of software. To conduct metalinguistic programming, vocabularies should have consistent layers just as software should have consistent layers. At each layer of abstraction there should be a complete set of verbs and nouns. Programmers should never need to mix verbs and nouns from different levels of abstraction to express themselves.

A common example of an incomplete vocabulary is when you see programs that mix words from the implementation layer with words from the domain layer. This often happens with collections. An "Employee" is a noun from the domain layer. An "Array" is a noun from the implementation layer. A program that constructs an array of employees is mixing the two layers, and the choice of words from the different layers reveals that the language of the abstraction layer is missing important words and ideas. A program that creates specific collective nouns such as a "Team" or "Layoff Group" is maintaining separation between the layers of abstraction by providing words for ideas at the correct level of abstraction.

It is not necessarily poor practice to mix words from different abstraction layers or to deliberately limit a vocabulary's size. Rather, there is a continuum of programming style stretching from naming a few abstractions at one end to creating a metalinguistic abstraction with a complete vocabulary at the other end.

**semantics, schmantics**

As noted, popular Ruby frameworks like Rails "fake" declarative semantics in the sense of [worse is better](http://www.jwz.org/doc/worse-is-better.html "The Rise of ``Worse is Better''"). The "worse" issue is that they are a [leaky abstraction](http://www.joelonsoftware.com/articles/LeakyAbstractions.html "The Law of Leaky Abstractions - Joel on Software"). Likewise Ruby itself fakes functional programming and declarative semantics with its own leaky abstractions built on top of objects.

There are other kinds of semantics that can be implemented on top of an existing programming language like Ruby. For example, [Rake](http://rake.rubyforge.org/ "Rake -- Ruby Make") adds semantics for expressing dependencies:

    task :do_something => [:prereq1, :prereq2] do |t|
      # actions...
    end
    
    task :prereq1 => [:pre_prereq] do |t|
      # actions...
    end
    
    task :pre_prereq => [:prereq2] do |t|
      # actions...
    end

Behind the scenes, of course, there is an engine that sorts out the prerequisites, runs them in order, and makes sure that each prerequisite is only run once. This is a very different set of semantics than Ruby (or most other popular languages) provides out of the box. If you want to run `prereq1`and `prereq2` before `do_something`, the Ruby way is to write:

    def do_something
      prereq1
      prereq2
      # actions 

    def prereq1
      pre_prereq
      # actions ...
    end

    def pre_prereq
      prereq2
      # actions ...
    end
    
As run in Ruby, `prereq2` is executed *twice* when you want to execute `do_something`. But if this is a pre-requisite, if we are trying to express a dependancy, `prereq2` should only be run once, not twice. While Rake's semantics express a dependancy relationship in the large, Rails' semantics express an imperative to execute methods before other methods in the small.

And that's why Rake's dependency notation is a metalinguistic abstraction and not just a question of vocabulary, not just a new way to write Ruby's existing OOP imperative semantics.

**another kind of linguistic abstraction**

> There is an unwritten rule that says every Ruby programmer must, at some point, write his or her own [AOP](http://github.com/raganwald/homoiconic/blob/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme "Aspect-Oriented Programming in Ruby using Combinator Birds") implementation --[Avdi Grimm](http://avdi.org)

As described above, Rake's semantics describe dependancies rather than imperatives to execute methods. Rake actually provides another linguistic abstraction. Instead of writing:

    task :do_something => [:prereq1, :prereq2] do |t|
      # actions...
    end
    
    task :prereq1 => [:pre_prereq] do |t|
      # actions...
    end
    
    task :pre_prereq => [:prereq2] do |t|
      # actions...
    end
    
You could also write:

    task :do_something => [:prereq1, :prereq2]
    task :prereq1 => [:pre_prereq]
    task :pre_prereq => [:prereq2]

    task :do_something do |t|
      # actions...
    end
    
    task :prereq1 do |t|
      # actions...
    end
    
    task :pre_prereq do |t|
      # actions...
    end
    
This separates the declaration of dependancies from the declaration of actions to execute. (Separating "stuff that's part of a task" from "stuff that should be done before a task" and "stuff that should be done after a task" is a very common linguistic abstraction. Lisp added this abstraction several times, most notably as [Flavors](http://en.wikipedia.org/wiki/Flavors_\(computer_science\)) which evolved into [CLOS](http://en.wikipedia.org/wiki/Common_Lisp_Object_System "Common Lisp Object System").)

In Rails, this is expressed in (at least) two different ways. In its controller methods, you can define before and after filters, and the declaration of which filters apply to which methods is separate from the definition of the controller method themselves. This (amongst other similar things) is implemented with [alias\_method\_chain](http://weblog.rubyonrails.org/2006/4/26/new-in-rails-module-alias_method_chain "Riding Rails: New in Rails: Module#alias_method_chain"), a way of extending a method's functionality separate from the method itself.

This can be a very useful abstraction. For example, the following line describes authentication requirements in a fictional Rails controller:

    before_filter :authenticate, :except => [:login, :about_us]
    
This says that every method in the controller should call the `authenticate` method except for the `login` and `about_us` methods (which presumably are available to the public). Having a way to declare that without having to tediously write methods such as:

    def show
      authenticate
      # actions ...
    end
    
    def index
      authenticate
      # actions ...
    end
    
Is a win because it separates two orthogonal concerns: How to perform a certain action is one concern, how and when to authenticate users is another. Giving methods single responsibilities is a core principle of effective software design, and this linguistic abstraction makes it possible.

**abstractioneering**

To return to the start, metalinguistic abstractions are abstractions that focus on creating a new language based on a new vocabulary or new semantics. This is a part of Ruby culture, and several popular frameworks derive their power from providing metalinguistic abstractions for programmers.

But how do we choose an appropriate metalinguistic abstraction? How do we know when it is appropriate to write our own? I have a rule of thumb for choosing or developing metalinguistic abstractions. I apply the "Keynote Test." I think about the problem I am trying to solve and the solution I wish to describe, then I imagine a keynote presentation describing the program.

Let's take AOP for example. Would I really have a single slide somewhere describing in detail every step required to show a foobar record from authentication to transaction? Or would there be a slide talking about foobars, another slide somewhere else talking about authentication, and another slide somewhere else talking about databases and transactions? The imaginary organization of my slides informs the organization of my program, which in turn informs some of the linguistic abstractions I need.

Likewise, would I create slides talking about dependancies between things in my program? If so, my program ought to have an abstraction expressing dependancies. This extends to however you would describe the program when talking to humans. The way you organize your imaginary slides is the way your program should be organized, and you ought to select or build the abstractions necessary to do so.

Likewise, the jargon you use in your presentation must be supported in your program. If you use a consistent set of abstract terms in slides, your program's vocabulary should be complete enough to express those same ideas at the same level of abstraction without dropping down into implementation. If you talk about "teams" in your slides, don't write code for "arrays of employees" in your program.

**fin**

I hope this post has given you some ideas to think about how and when to choose and write metalinguistic abstractions in Ruby.

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0909_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)