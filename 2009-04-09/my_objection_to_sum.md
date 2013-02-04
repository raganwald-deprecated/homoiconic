My Objection to Array#Sum
===

A few years back I worked with ING Direct, the online bank. ING Direct is famous for its high interest, no-fee [Orange Savings](http://home.ingdirect.com/products/products.asp?s=OrangeSavingsAccount "Savings Account rate information from ING DIRECT") accounts. When I first started working with ING, they only offered Orange Savings accounts, and as you might expect, there was an `Account` class in the application to represent them.

Well, one day I found out that ING Direct would start offering [ElectricOrange](http://home.ingdirect.com/products/products.asp?s=ElectricOrange "High Yield Checking Account from ING DIRECT") accounts, a new high-yield chequing account product. (Notice how I spell it "chequing," the British/Canadian way? I strongly suspect that if you look at the source code today, you will see my fingerprints in there. My American colleagues might prefer to describe such things as my droppings, of course. Sorry!)

So back to ElectricOrange accounts. Clients can do things with ElectricOrange accounts that are not possible with Orange Savings accounts, such as writing virtual cheques. So at some point, we need to be able to write something like:

    electric_orange_account.write_cheque(
      :amount    => 100.00,
      :recipient => "Reg Braithwaite",
      :address   => Address.parse("26 Woodfield Road, Toronto, ON M4L 2W3")
    )

So how do we implement this? What about the following design: *We add a #write\_cheque method to the Account class, and if the account is an Electric Orange account, it writes a cheque. If the account is an Orange Savings account, it tries to execute the method, but the method fails.* Well? How's my design? If this were a job interview, do I get the job? Or would you tell me that although I have proven an ability to write workable programs using languages with OO features, I really don't [grok](http://en.wikipedia.org/wiki/Grok "Grok - Wikipedia, the free encyclopedia") OO?

[![Monk Debate (c) 2007 Laura (silverlinedwinnebago), some rights reserved](http://farm2.static.flickr.com/1038/1424137472_d7bfcc9f08_d.jpg)](http://www.flickr.com/photos/silverlinedwinnebago/1424137472/ "Monk Debate (c) 2007 Laura (silverlinedwinnebago), some rights reserved") 

**The Debate**

In case you haven't guessed from the tone of my narration so far, I think this has a strong and pungent OO smell. When a software entity is specifically engineered to map to a real-world entity, its interface ought to map closely to real-world verbs and actions of the real-world entity it is modeling. Orange Savings and Orange Chequing accounts should implement completely separate interfaces.

Now in a language like Ruby, they may or may not be implemented as separate classes. In idiomatic Ruby, classes and modules are for *implementation*, and the methods an instance handles are for *interface*. So I would accept using one class for both kinds of account, provided that:

    electric_orange_account.respond_to?(:write_cheque)
      => true
    orange_savings_account.respond_to?(:write_cheque)
      => false

It's probably easiest to refactor the existing Account class so that it becomes a superclass of OrangeSavingsAccount and ElectricOrangeAccount, but you could also turn it into a module that both account classes mix in, individual accounts could extend themselves with OrangeSavingsAccount or OrangeChequeingAccount modules or even use an approach where account instances delegate methods to a strategy object. Ruby provides a lot of flexibility as to how you get there. (The fancier things I'm describing might be a better fit for a more complex business domain such as modeling cell phone billing plans.)

Now let's step back and try to describe the smell. The smell is where objects implement methods that make no sense for them. The fancy way to say this is that the object's interface is not semantically coherent. Now this is a smell, not an anti-pattern. It isn't something that is always, inevitably, has-to-be-wrong. But let's ask ourselves: Is this a good principle? Should we look for this smell and try to remove it when we find it?

I suggest it is a smell and while there are exceptions, we generally want to avoid this. The reasoning I offer you is this: OO design is all about deciding who ought to be responsible for things and being able to discern those responsibilities. So... Who ought to know whether an account can write a cheque? The account, obviously. And how can it tell us whether it can write a cheque? Through its interface. In Ruby, we query an interface using #respond_to?. (In Java, we would use an interface.)

If we write:

    some_account.respond_to?(:write_cheque)
      => true
    some_account.write_cheque(
      :amount    => 100.00,
      :recipient => "Reg Braithwaite",
      :address   => Address.parse("26 Woodfield Road, Toronto, ON M4L 2W3")
    )
      => InvalidAccountTypeError('Orange Savings Accounts Cannot Write Cheques')

What we are seeing is the account lying to us about its responsibilities.

**Array#sum**

The other day I was [grousing](http://github.com/raganwald/homoiconic/blob/master/2009-04-08/sick.md#readme "I'm Sick of This Shit") about collisions between different people implementing Array#sum. However, even if you had a good way to implement Array#sum such that various gems don't conflict with each other, I still have objections to implementing Array#sum as I've seen it implemented. In short, the Array#sum I've seen works like this:

    [1,2,3].respond_to?(:sum)
      => true
    [1,2,3].sum
      => 6
      
    [1, 2, 'three'].respond_to?(:sum)
      => true
    [1, 2, 'three'].sum
      => TypeError: String can't be coerced into Fixnum
      
    [1, [2, 3]].respond_to?(:sum)
      => true
    [1, [2, 3]].sum
      => TypeError: Array can't be coerced into Fixnum
      
That's our code smell. Not all arrays can be summed, but they all claim to respond to #sum. This is extremely broken. You could attempt to fix this by updating Array#respond\_to? to respond `false` if it cannot be summed, but let's step back and think about responsibilities.

What is an Array? A container, nothing more. That's its responsibility, that's what it does. Operations like #inject and #map are part of its responsibility, that's stuff you can do to all containers, and the container itself knows how to implement them. Good.

But what about #sum? This requires knowing something about the contents of a container. Who ought to be responsible for knowing how to do things with the contents of containers? How about the entities that put things into the container and take things out of the container?

Instead of writing Array#sum, we could be writing:

* Methods like Client#sum\_account\_balances.
* Or perhaps the Client entity ought to be injecting a #sum method into some arrays.
* Or perhaps we need an ArrayOfBalances class that knows how to sum itself.
* Or perhaps we could call `ArrayGoodies.sum(an_array)`.

Not all accounts write cheques, so only some account instances should implement #write\_cheque. Likewise, *not all arrays can be summed, so at most some arrays should implement #sum*.

Someone asked wither `an_array_instance.sum()` is really necessary given that we can write a convenience method `sum(an_array_instance)`. Now you know my answer: `sum(an_array_instance)` is a better choice than `an_array_instance.sum()`, however `an_array_instance.map(...)` is a better choice than `map(an_array_instance, ...)`. So to put an final exclamation point on things, *I think it is a smell to implement Array#sum for all arrays, even if it were being added to the standard core libraries and no metaprogramming hijinkery were involved.*

(And yes, I feel exactly the same way about adding inflections and escapes and all sorts of other convenience methods to the String class. If #titlecase is not a semantically valid method to send to a string that represents a part code, why does `part_code.respond_to?(#titlecase)` return true? We either need to arrange things such that only *some* strings implement #titlecase, or we need to have the code that wknows whether a string is titlecase-worthy know how to convert a string to titlecase.)

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