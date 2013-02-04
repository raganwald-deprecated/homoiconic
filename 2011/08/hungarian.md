Hungarian PBKAC
---

Hungarian notation (whether apps or systems) is useful, especially when you want some of the benefits of an untyped language but want to make [wrong code look wrong][1]. The trouble with it is just like the trouble with any documentation that isn't checked or enforced automatically: Over time the words diverge from the code, making it worse than useless because it actively deceives.

Here is some actual code I found in a current project today.

    def self.to_a_by_based_on
      all.inject({}) do |hash, edit|
        hash.tap { |h| (h[edit.based_on] ||= []) << edit }
      end
    end

    def self.to_a_by_scope
      all.inject({}) do |hash, edit|
        hash.tap { |h| (h[edit.scope] ||= []) << edit }
      end
    end

Sure, a generator could be used to DRY up the code. But before we get there... What do the method names promise and what do the methods deliver?  Need I say that a quick "blame" in git revealed that these lines were written by the usual suspect?

[1]: http://www.joelonsoftware.com/articles/Wrong.html "Making Wrong Code Look Wrong - Joel on Software"

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