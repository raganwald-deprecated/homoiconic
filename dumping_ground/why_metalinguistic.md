Why Metalinguistic Programming?
===

*The following discussion is extracted from a forthcoming talk--"The Revised, Revised Ruby.rewrite(Ruby)" or "R5"--to be be delivered at [Stack Overflow Dev Days](http://www.amiando.com/stackoverflowdevdays-toronto-can.html "Stack Overflow Dev Days Toronto - Carsonified"). I apologize for the lack of surrounding context in this format.*

**metalinguistic programming**

Wikipedia notes that [metalinguistic programming](http://en.wikipedia.org/wiki/Metalinguistic_abstraction "Metalinguistic abstraction - Wikipedia, the free encyclopedia") is "The process of solving complex problems by creating a new language or vocabulary." So metalinguistic abstractions are new languages we create to solve problems. My first reaction is to observe that the Ruby culture strongly embraces the creation of new domain-specific languages" or "DSLs?" For example, [Webrat](http://github.com/brynary/webrat) allows you to write code such as:

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

That's Ruby, all we are adding are new words like "visit" and new phrases like "fill\_in" or "click\button." But we are not creating a new language. It's the same old language with the same old semantics and metaphor. I don't think that's a bad thing, I think it's brilliant! That's the whole point of creating an API, creating a rich domain-specific vocabulary that encodes an important abstraction.

But let's compare that to Rails and Shoulda. To refresh your memory:

    has_many :opinions
    validates_presence_of :ego
    should_render_template :show

Here we have new vocabulary. But we have something else as well, *new semantics*. All three examples communicate declarative semantics rather than imperative semantics. Ruby the language doesn't work in a declarative way, or at least not very much (things like class definitions, mixins, and attribute definitions look very declarative even if they are actually imperative). And that, to me, is one of the distinctions between creating a new vocabulary and a new language: When you introduce new semantics, you are creating a new language.

Now to consider a straw man argument against my suggestion. Ruby on Rails and Shoudla don't actually have declarative semantics, they are imperative. They just *fake* declarative semantics. So if you know what's going on behind the scenes, the line `has_many :opinions` might not mean, "There is a has-many relationship between instances of this class and instances of the Opinion class." It might mean instead, "Create the following thirteen methods in this class for manipulating instances of Opinion..."

My thought in response is that while it's true that these declarative semantics are *implemented* imperatively, that's true of everything: No matter what programming language you write high up the abstraction tower on general purpose hardware, your program is implemented on a [Von Neumann](http://en.wikipedia.org/wiki/John_von_Neumann "John von Neumann - Wikipedia, the free encyclopedia") piece of hardware at the bottom of the abstraction tower. If someone wants to ignore the abstraction and think in assembler, that does not detract from the value of the abstraction for those who readily accept it.

So in summary, metalinguistic abstractions have two flavours. The first is the creation of a rich vocabulary that is used with Ruby's existing semantics, the second is the creation of a new language with new semantics including but not limited to programming in a declarative way.

**a brief word about vocabularies**

Quite obviously programming in almost every programming language involves naming things. You name classes, modules, attributes, variables and many other things in Ruby. In a sense you are creating an ad hoc vocabulary as your program even if you aren't deliberately attempting to create a vocabulary.

However, most forms of software design formalize this with a little more ceremony. For example, a common analysis strategy is to start by listing all of the entities in the problem domain the program is intended to address. An analyst might write down nouns like "Employee" and "Hire Date" when designing an HR application, then later come up with verb phrases like "Issue Pay" or "Dehire" (an amusing digression is to note that the modern style of programming [subordinates verbs to nouns](http://weblog.raganwald.com/2007/10/too-much-of-good-thing-not-all.html "Too much of a good thing: not all functions should be object methods")).

Even though many domain entities are named, simply choosing names for nouns and phrases for verbs on an ad hoc basis is not metalinguistic programming. Metalinguistic programming involves designing a vocabulary much as one would design software. For example, vocabularis should have consistent layers just as software should have consistent layers. At each layer of abstraction there should be a complete vocabulary: There should be a complete set of verbs and nouns, programmers should never need to mix verbs and nouns from different levels of abstraction.

A common example of incomplete vocabularies is when you see programs that mix nouns form the implementation layer with nouns from the domain layer. This often happens with collections. An "Employee" is a noun from the domain layer. An "Array" is a noun from the implementation layer. A program that constructs an array of employees is mixing the two layers. A program that creates specific collective nouns such as a "Team" or "Layoff Group" is maintaining separation between the layers of abstraction.

*to be continued...*

---
	
Subscribe to [new posts and daily links](http://feeds.feedburner.com/raganwald "raganwald's rss feed"): <a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>

Reg Braithwaite: [Home Page](http://reginald.braythwayt.com), [CV](http://reginald.braythwayt.com/RegBraithwaiteGH0909_en_US.pdf ""), [Twitter](http://twitter.com/raganwald)