Rewriting Returning in Rails
===

One of the most useful tools provided by Ruby on Rails is the #returning method, a simple but very useful implementation of the K Combinator or [Kestrel](http://github.com/raganwald/homoiconic/blob/master/2008-10-29/kestrel.markdown#readme). For example, this:

    def registered_person(params = {})
      person = Person.new(params.merge(:registered => true))
      Registry.register(person)
      person.send_email_notification
      person
    end

Can and should be expressed using #returning as this:

    def registered_person(params = {})
      returning Person.new(params.merge(:registered => true)) do |person|
        Registry.register(person)
        person.send_email_notification
      end
    end

Why? Firstly, you avoid the common bug of forgetting to return the object you are creating:

    def broken_registered_person(params = {})
      person = Person.new(params.merge(:registered => true))
      Registry.register(person)
      person.send_email_notification
    end
    
This creates the person object and does the initialization you want, but doesn't actually return it from the method, it returns whatever #send\_email\_notification happens to return. If you've worked hard to create fluent interfaces you might be correct by accident, but #send\_email\_notification could just as easily return the email it creates. Who knows?

Second, in methods like this as you read from top to bottom you are declaring what the method returns right up front:

    def registered_person(params = {})
      returning Person.new(params.merge(:registered => true)) do # ...
        # ...
      end
    end
      
It takes some optional params and returns a new person. Very clear. And the third reason I like #returning is that it logically clusters the related statements together:

    returning Person.new(params.merge(:registered => true)) do |person|
      Registry.register(person)
      person.send_email_notification
    end

It is very clear that these statements are all part of one logical block. As a bonus, my IDE respects that and it's easy to fold them or drag them around as a single unit. All in all, I think #returning is a big win and I even look for opportunities to refactor existing code to use it whenever I'm making changes.

**DWIM**

All that being said, I have observed a certain bug or misapplication of #returning from time to time. It's usually pretty subtle in production code, but I'll make it obvious with a trivial example. What does this snippet evaluate to?

    returning [1] do |numbers|
      numbers << 2
      numbers += [3]
    end

This is the kind of thing that sadistic interviewers use in coding quizzes. The answer is **[1, 2]**, not [1, 2, 3]. The `<<` operator mutates the value assigned to the numbers variable, but the `+=` statement overwrites the reference assigned to the numbers variable without changing the original value. #returning remembers the *value* originally assigned to numbers and returns it. If you have some side-effects on that value, those count. But assignment does nothing to the value.

This may seem obvious, but in my experience it is a subtle point that causes difficulty. Languages with referential transparency escape the confusion entirely, but OO languages like Ruby have this weird thing where we have to keep track of references and labels on references in our head.

Here's something contrived to look a lot more like production code. First, without #returning:

    def working_registered_person(params = {})
      person = Person.new(params.merge(:registered => true))
      if Registry.register(person)
        person.send_email_notification
      else
        person = Person.new(:default => true)
      end
      person
    end
    
And here we've refactored it to use #returning:

    def broken_registered_person(params = {})
      returning Person.new(params.merge(:registered => true)) do |person|
        if Registry.register(person)
          person.send_email_notification
        else
          person = Person.new(:default => true)
        end
      end
    end

Oops! This no longer works as we intended. Overwriting the `person` variable is irrelevant, #returning returns the unregistered new person no matter what. So what's going on here?

One answer is to "blame the victim." Ruby has a certain well-documented behaviour around variables and references. #returning has a certain well-documented behaviour. Any programmer who makes the above mistake is--well--mistaken. Fix the code and set the bug ticket status to Problem Between Keyboard And Chair ("PBKAC").

Another answer is to suggest that the implementation of #returning is at fault. If you write:

    returning ... do |var|
      # ...
      var = something_else
      # ...
    end

You intended to change what you are returning from #returning. So #returning should be changed to do what you meant. I'm on the fence about this. When folks argue that designs should cater to programmers who do not understand the ramifactions of the programming language or of the framework, I usually retort that you cannot have progress and innovation while clinging to familiarity, [an argument I first heard from Jef Raskin](http://raganwald.com/2008/01/programming-language-cannot-be-better.html "A programming language cannot be better without being unintuitive"). The real meaning of "The Principle of Least Surprise" is that a design should be *internally consistent*, which is not the same thing as *familiar*.

Ruby's existing use of variables and references is certainly consistent. And once you know what #returning does, it remains consistent. However, this design decision isn't really about being consistent with Ruby's implementation, we are debating how an idiom should be designed. I think we have a blank canvas and it's reasonable to at least *consider* a version of #returning that handles assignment to the parameter.

So I did.

**Rewriting #returning**

The [RewriteRails](http://github.com/raganwald-deprecated/rewrite_rails/tree/master) plug-in adds syntactic abstractions like [Andand](http://github.com/raganwald-deprecated/rewrite_rails/tree/master/doc/andand.textile "") and [String to Block](http://github.com/raganwald-deprecated/rewrite_rails/tree/master/doc/string_to_block.md#readme "") to Rails projects [without monkey-patching](http://avdi.org/devblog/2008/02/23/why-monkeypatching-is-destroying-ruby/ "Monkeypatching is Destroying Ruby"). RewriteRails now includes its own version of #returning that overrides the #returning shipping with Rails.

When RewriteRails is processing source code, it turns code like this:

    def registered_person(params = {})
      returning Person.new(params.merge(:registered => true)) do |person|
        if Registry.register(person)
          person.send_email_notification
        else
          person = Person.new(:default => true)
        end
      end
    end
    
Into this:

    def registered_person(params = {})
      lambda do |person|
        if Registry.register(person)
          person.send_email_notification
        else
          person = Person.new(:default => true)
        end
        person
      end.call(Person.new(params.merge(:registered => true)))
    end

Note that in addition to turning the #returning "call" into a lambda that is invoked immediately, it also makes sure the new lambda returns the `person` variable's contents. So assignment to the variable does change what #returning appears to return.

Like all processors in RewriteRails, #returning is only rewritten in `.rr` files that you write in your project. Existing `.rb` files are not affected, including all code in the Rails framework: RewriteRails will never monkey with other people's expectations. RewriteRails doesn't physically modify the .rr files you write: The rewritten code is put in another file that the Ruby interpreter sees. So you see the code you write and RewriteRails figures out what to show the interpreter. This is a little like a Lisp macro. 

**Why is this version of #returning implemented with RewriteRails?**

Perhaps the reason is that "When you're holding a hammer, every problem looks like a thumb." It seemed difficult to implement a version of #returning that respected assignment to the variable without rewriting.

**So tell me again, why bother?**

Curiosity. It's easy to dismiss programmers who accidentally misuse features like #returning. But what if catering to them makes the feature more useful? I plant to try this version of #returning and see if I come up with a useful way to use it. Perhaps it will turn out to be mere novelty. Then again, perhaps it will turn out to be innovation. It's hard to predict without trying it.

**More**

* [RewriteRails](http://github.com/raganwald-deprecated/rewrite_rails/tree/master/README.md)
* [returning.rb](http://github.com/raganwald-deprecated/rewrite_rails/tree/master/lib/rewrite_rails/returning.rb "")

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