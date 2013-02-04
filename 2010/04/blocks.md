The Use Case for Blocks
===

A colleague asked me to explain the use case for blocks in Ruby. He's perfectly familiar with them, of course, and he can explain how they differ from lambdas. But what he was looking for was a simple explanation for why a language really needed both. So the question isn't really "how are they different," but "What is there you can't do with lambdas such that you need to add blocks?"

> A design is finished, not when there is nothing left to add, but when there is nothing left to take away &#8212;Antoine de Saint-Exupery

As it happens, I was working on [iGesture][ig], and I had the following for loop in this JavaScript code:

    var gesture = {
      
        // ...
      
      getName: function () {
        
        // ...

        for (i in half_close_gestures) {
          var e = half_close_gestures[i];
      
          if ( (Number(g.moves.charAt(0))== e.start) &&
              (Number(g.moves.charAt(g.moves.length-1)) == e.finish) &&
              (g.moves.indexOf('' + e.connect) != -1)
          ) return 'close';
      
          if ( (Number(g.moves.charAt(0))== e.finish) &&
              (Number(g.moves.charAt(g.moves.length-1)) == e.start) &&
              (g.moves.indexOf('' + e.connect) != -1)
          ) return 'close';
        }
        
        // ...
        
      }
      
    }

What this code does is recognize a 'close' gesture, which is  an "X" drawn as three strokes. There are eight different ways to draw an X with three strokes when you include the rotations reflections, so this code stores an array of the four rotations and has two tests for each reflection. If the gesture drawn matches, the `getName` function returns the string "close." If none of them match, it falls through and performs some other tests like checking to see if the user has drawn a circle.

I took one look at this code and reasoned I could replace the `for` with jQuery's [`each`][each]:

    jQuery.each(half_close_gestures, function (i, e) {
  
      if ( (Number(g.moves.charAt(0))== e.start) &&
          (Number(g.moves.charAt(g.moves.length-1)) == e.finish) &&
          (g.moves.indexOf('' + e.connect) != -1)
      ) return 'close';
  
      if ( (Number(g.moves.charAt(0))== e.finish) &&
          (Number(g.moves.charAt(g.moves.length-1)) == e.start) &&
          (g.moves.indexOf('' + e.connect) != -1)
      ) return 'close';
      
    });
    
But it broke, `getName` would *never* return "close" no matter how I drew an X. What went wrong?
        
Let's simplify the whole thing. Here's our function and loop:

    function outer () {

      for (i in something_or_other) {
        if ( test(something_or_other[i]) ) return 'close';
      }
      
    }

Let's look this line of code: `if ( test(e) ) return 'close';`. Clearly, this line of code returns the string "close" from the function `outer` if `test(something_or_other[i])` evaluates truthy. Fine.

Now here's our refactored use of `.each`:

    function outer () {

      jQuery.each(something_or_other, function(i, e) {
        if ( test(e) ) return 'close';
      });
      
    }

As you can see, we have a new anonymous "inner" function. Let's look this line of code: `if ( test(e) ) return 'close';` again. Does it still return the string "close" from the function `outer` if `test(something_or_other[i])` evaluates truthy? *Or does it now return from the anonymous inner function?*

Because JavaScript has functions but no blocks, you can write things like `map` or `each`, but you cannot use them in a case like this where you want to return from an outer function. `return` always returns from the innermost function, which in this simple case is the function we are using in our iterator.

![Blocks][blocks]

**blocks**

In Ruby, we could write an implementation of `each` that takes a lambda for its iteration. But the standard implementation takes a block as its argument. In Ruby, we write:

    def outer ()

      something_or_other.each do |e|
        return 'close' if test(e) 
      end
      
    end
    
The block has a different semantic than a lambda. When you return from a block, you return from the method that encloses it, not from the block. This makes blocks far more useful than lambdas for writing new kinds of syntax, because they act like blocks of statements in the current method, rather than acting like blocks of statements in the `call` method of a lambda object.

And thus endeth the lesson: An important use case for blocks is when you want to write methods that emulate control structures and other syntax. In this case, you want blocks of statement that do not alter the behaviour of things like `return`. Blocks work. Functions and lambdas do not.

**postscript: can we do away with blocks?**

In Ruby you could avoid a block containing non-local return:

    def outer ()

      return 'close' if something_or_other.any?(&test)
      
    end

This "functional style" is far more elegant than short-circuiting evaluation of `.each`. That being said, Ruby and JavaScript both provide built-in syntactic constructs like `for` and `if` that have block behaviour, not function behaviour. The use case for blocks is that you can write your own constructs with the same behaviour as the built-in constructs.

It's perfectly valid to avoid the built-in blocks in a program, or to choose a language that doesn't have built-in blocks. But just so we're clear, if a language has built-in blocks, I think it out to allow programmers to use them for their own constructs. If a language allows arbitrary short-circuit `return`, it ought to allow the programmer to use it anywhere.

(This postscript was inspired by some excellent comments in [Hacker News][hn].)

----
  
NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)

[ig]: http://github.com/raganwald-deprecated/iGesture
[each]: http://api.jquery.com/jQuery.each/ "jQuery.each()"
[blocks]: http://sphotos.ak.fbcdn.net/hphotos-ak-snc3/hs506.snc3/26589_10150173040005714_835045713_12122576_6398063_n.jpg
[hn]: http://news.ycombinator.com/item?id=1270842