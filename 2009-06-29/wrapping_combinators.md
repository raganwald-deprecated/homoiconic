Wrapping Combinators
===

I received a nice email which asked, in essence:

> Which combinator says "For every time you do A, remember to do C after you've done B?" Which combinator codifies the problems like freeing memory (C) after using it (B) whenever we have allocated it (A), or stuff like opening files and sockets (A), reading and/or writing from/to them (B), then closing them (C). Or accessing mutexen (A), working therein (B), and leaving (C)?

This is an interesting question. In essence, we are looking for a combinator that takes a function and imposes some side effects before and after the function.

**The purely combinatorial answer**

We want a combinator, "?" where:

    ?xyz = y
    
Meaning, "compute x, then y, then z, and return the value of y." Now right away the "canonical" list of combinators does not include any such thing. However, there is the rule of *composition*, meaning that for any two combinators A and B, there exists a combinator C such that:

    Cx = A(Bx)

The rule of composition defines the operation of chaining functions together, where the output of one function is fed as the input to another. So what we are seeking is the appropriate composition of existing combinators that will produce the result we seek. 

Let's look at our desired combinator again:

    ?xyz = y

We've already seen something a little like this: A [Kestrel](http://github.com/raganwald/homoiconic/blob/master/2008-10-29/kestrel.markdown "Kestrels") is a combinator that looks like this:

    Kxy = x

The Kestrel takes a value, "x," and another value, "y," and returns "x" while ignoring "y." In a language with side-effects, and pass-by-value, the Kestrel expresses the idea of computing a value, "x" for the result and then performing some computation, "y" strictly for side-effects after computing "x."

This seems useful: It's half of what we want. Let's rewrite it slightly:

    Kyz = y

This is the latter half of what we want. The first half will look something like this, given a combinator "\_":

    _xyz = yz
    
And then we would be able to compose a Kestrel with "\_":

    ?xyz = K(_xyz) = y

So what is "\_"? We have already decided:

    _xyz = yz

Which is the same as:

    _xy = y

There are a couple of ways to derive this combinator. One way is to compose a [Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme) with a Kestrel:

    Txy = yx, therefore:
    K(Txy) = Kyx = y

(Another easy derivation uses a Kestrel and an Identity to produce the same result.) But let's verify that our composition of Kestrel and Thrush gets the job done:

    K(Txy) = Kyx = y
    K(Txyz) = Kyxz = yz
    K(K(Txyz)) = K(Kyxz) = Kyz = y
  
So composing two Kestrels and a Thrush gives us a combinator that computes three values "x," "y," and "z" and returns "y" while throwing away the results of computing "x" and "z." In a world where side effects matter, this allows us to sandwich the computation of "y" in between "x" and "z."

**Ruby**

This is a fairly common pattern in Ruby, thanks to the convenience of blocks and the **yield** keyword. It looks a little different than the combinatorial version, but the most popular expression of this idea is probably the syntax for invoking a database transaction in Ruby on Rails:

    Campaign.transaction do
      campaign = Campaign.create!(:created_by => current_user)
      campaign.versions.init! params, current_user
      redirect_to presentation_path(:id => campaign.id, :version => 1)
    end

The #transaction method starts a database transaction using the connection owned by Campaign, yields to the block to execute the code in the block, and if all is successful it will commit the transaction. The results of starting and committing the transaction are discarded, and the #transaction method returns whatever the block returns. This is just like our K(K(Txyz))) combinator above.

(The source is obviously a little more complicated because it needs to roll the transaction back if there is an exception thrown, but the basic principle applies.)

While the syntax of invoking a transaction is nice and clean, the implementation is a little arbitrary. Using the **yield** keyword in any arbitrary method brings a Perlisism to mind: *Beware the Turing Tar Pit, where everything is possible, but nothing of interest is easy.* The yield keyword makes wrapping code in a transaction possible, as well as iterating over a collection possible, implementing a Kestrel, and many other idioms.

Here's the source for #transaction in Rails' ActiveRecord::ConnectionAdapters::DatabaseStatements module:

     def transaction(options = {})
       options.assert_valid_keys :requires_new, :joinable

       last_transaction_joinable = @transaction_joinable
       if options.has_key?(:joinable)
         @transaction_joinable = options[:joinable]
       else
         @transaction_joinable = true
       end
       requires_new = options[:requires_new] || !last_transaction_joinable

       transaction_open = false
       begin
         if block_given?
           if requires_new || open_transactions == 0
             if open_transactions == 0
               begin_db_transaction
             elsif requires_new
               create_savepoint
             end
             increment_open_transactions
             transaction_open = true
           end
           yield
         end
       rescue Exception => database_transaction_rollback
         if transaction_open && !outside_transaction?
           transaction_open = false
           decrement_open_transactions
           if open_transactions == 0
             rollback_db_transaction
           else
             rollback_to_savepoint
           end
         end
         raise unless database_transaction_rollback.is_a?(ActiveRecord::Rollback)
       end
     ensure
       @transaction_joinable = last_transaction_joinable

       if outside_transaction?
         @open_transactions = 0
       elsif transaction_open
         decrement_open_transactions
         begin
           if open_transactions == 0
             commit_db_transaction
           else
             release_savepoint
           end
         rescue Exception => database_transaction_rollback
           if open_transactions == 0
             rollback_db_transaction
           else
             rollback_to_savepoint
           end
           raise
         end
       end
     end

If you study it, you can see the **yield** buried in the middle and work out that this method exists to do some work before and after the block, just like the combinator we constructed. This is the (current) idiomatic way to wrap some work with side effects executed before and after your code: write a method that takes a block and does the wrapping around the yield keyword.

The obvious challenge with this approach is that it is so ad hoc. having written code for database transactions, if you want to do something similar for persistent file storage (like open a file before using it and then close it when you're done), you need to write the wrapping code all over again. For example, if you wanted to write your own wrapper around Ruby's IO class that opened a file for writing before executing your block then flushed its buffers and closed the file at the end, you'd have to repeat the entire pattern.

As we saw in [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md) and [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md), it is also possible to write Ruby combinators to encapsulate the pattern of wrapping a block explicitly when writing methods. We also saw in [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown) that you can declaratively wrap a method using method advice. There are many roads to the summit :-)

_More on combinators_: [Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme), [Finding Joy in Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-16/joy.md#readme), [Refactoring Methods with Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-23/recursive_combinators.md#readme), [Practical Recursive Combinators](http://github.com/raganwald/homoiconic/tree/master/2008-11-26/practical_recursive_combinators.md#readme), [The Hopelessly Egocentric Blog Post](http://github.com/raganwald/homoiconic/tree/master/2009-02-02/hopeless_egocentricity.md#readme), [Wrapping Combinators](http://github.com/raganwald/homoiconic/tree/master/2009-06-29/wrapping_combinators.md#readme), and [Mockingbirds and Simple Recursive Combinators in Ruby](https://github.com/raganwald/homoiconic/blob/master/2011/11/mockingbirds.md#readme).

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