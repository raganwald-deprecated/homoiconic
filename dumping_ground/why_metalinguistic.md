Why Metalinguistic Programming?
===

*The following discussion is extracted from a forthcoming talk--"The Revised, Revised Ruby.rewrite(Ruby)" or "R5"--to be be delivered at [Stack Overflow Dev Days](http://www.amiando.com/stackoverflowdevdays-toronto-can.html "Stack Overflow Dev Days Toronto - Carsonified"). I apologize for the lack of surrounding context in this format.*

**metalinguistic programming**

Wikipedia notes that [metalinguistic programming](http://en.wikipedia.org/wiki/Metalinguistic_abstraction "Metalinguistic abstraction - Wikipedia, the free encyclopedia") is "The process of solving complex problems by creating a new language or vocabulary." So metalinguistic abstractions are new languages we create to solve problems. My first reaction is to observe that the Ruby culture strongly embraces the creation of new domain-specific languages" or "DSLs?" For example, [Cucumber](http://cukes.info/ "Cucumber - Making BDD fun") allows you to write code such as:

    visit "/login" 
    fill_in("login", :with => login) 
    
Similarly, [Ruby on Rails](http://rubyonrails.org/ "Ruby on Rails") allows you to write:

    has_many :opinions
    validates_presence_of :ego

While [Shoulda](http://www.thoughtbot.com/projects/shoulda "Projects - Shoulda") allows you to write:

    should_render_template :show

Aren't these all examples of new languages?

**a question of degree**

Let's start with the first two examples. Ruby is an object-oriented language with imperative semantics. You send messages to objects and things happen. State is changed. This is the pervasive metaphor everywhere. The first two examples clearly follow this form: You are telling Ruby to do something, and something will happen. In this case, there is a simulated session in a web application being used for testing.

That's Ruby, all we are adding are new words ("visit" and "fill\_in") to Ruby, but we are not creating a new language. It's the same old language with the same old semantics and metaphor. I don't think that's a bad thing, I think it's brilliant! That's the whole point of creating an API, creating a rich domain-specific vocabulary that encodes an important abstraction.

But let's compare that to the next three examples. To refresh your memory:

    has_many :opinions
    validates_presence_of :ego
    should_render_template :show

Here we have new vocabulary. But we have something else as well, *new semantics*. All three examples communicate declarative semantics rather than imperative semantics. Ruby the language doesn't work in a declarative way, or at least not very much (class definitions and mixins look very declarative even if they are actually imperative). And that, to me, is one of the distinctions between creating a new vocabulary and a new language: When you introduce new semantics, you are creating a new language.

Now to consider a straw man argument against my suggestion. Ruby on Rails and Shoudla are written in Ruby. They don't actually have declarative semantics, they are imperative. They just *fake* declarative semantics. So if you know what's going on behind the scenes, the line `has_many :opinions` might not mean, "There is a has-many relationship between instances of this class and instances of the Opinion class." It might mean instead, "Create the following thirteen methods in this class for manipulating instances of Opinion..."

My thought in response is that while it's true that these declarative semantics are *implemented* imperatively, that's true of everything: No matter what programming language you write high up the abstraction tower on general purpose hardware, your program is implemented on a [Von Neumann](http://en.wikipedia.org/wiki/John_von_Neumann "John von Neumann - Wikipedia, the free encyclopedia") piece of hardware at the bottom of the abstraction tower. If someone wants to ignore the abstraction and think in assembler, that does not detract from the value of the abstraction for those who readily accept it.

So in summary, my suggestion is that metalinguistic abstractions have two flavours. The first is the creation of a rich vocabulary that is used with Ruby's existing semantics, the second is the creation of a new language with new semantics including but not limited to programming in a declarative way.

*to be continued...*