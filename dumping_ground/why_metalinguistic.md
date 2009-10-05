Why Metalinguistic Programming?
===

*The following discussion is extracted from a forthcoming talk--"The Revised, Revised Ruby.rewrite(Ruby)" or "R5"to be be delivered at [Stack Overflow Dev Days](http://www.amiando.com/stackoverflowdevdays-toronto-can.html "Stack Overflow Dev Days Toronto - Carsonified"). I apologize for the lack of surrounding context in this format.*

---

What is Metalinguistic Programming? And why do we care about it? Let's start with what Wikipedia has to say about [Metalinguistic Abstractions](http://en.wikipedia.org/wiki/Metalinguistic_abstraction "Metalinguistic abstraction - Wikipedia, the free encyclopedia"): "In computer science, metalinguistic abstraction is the process of solving complex problems by creating a new language or vocabulary." So the "what" is creating entirely new languages or vocabularies. I'm going to get arbitrary and say that we are only interested in metalinguistic abstractions 

In Ruby, don't we already do this with domain-specific languages" or "DSLs?" Don't we create a new language for solving a complex problem? For example, plug-ins in the Rails ecosystem allow you to write code such as:

    visit "/login" 
    fill_in("login", :with => login) 
    
Ruby on Rails itself and plug-ons like Shoulda allow you to write things such as:

    has_many :opinions
    validates_presence_of :ego
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

It's true that these declarative semantics are *implemented* imperatively, but that's true of everything: No matter what programming language you write high up the abstraction tower on general purpose hardware, your program is implemented on a Von Neuman piece of hardware at the bottom of the abstraction tower. If someone wants to ignore the abstraction and think in assembler, that's fine.

The Wikipedia definition suggests

Let's start with the canonical explanation given for metalinguistic programming:

> In computer science, metalinguistic abstraction is the process of solving complex problems by creating a new language or vocabulary to better understand the problem space. It is a recurring theme in the seminal MIT textbook, the Structure and Interpretation of Computer Programs, which uses Scheme as a framework for constructing new languages. --[Metalinguistic abstraction](http://en.wikipedia.org/wiki/Metalinguistic_abstraction) in Wikipedia

Grossly oversimplifying, a meta-syntactic variable is a placeholder or stand-in variable used when you are talking about some higher relationship between classes of things rather than specific things. Likewise, a meta-syntactic program is a placeholder or stand-in program  used when you are talking about some higher relationship between classes of programs rather than specific programs.

Examples of meta-syntactic 