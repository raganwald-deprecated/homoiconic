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

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one e-book.
* [What I've Learned From Failure](http://leanpub.com/shippingsoftware), my very best essays about getting software from ideas to shipping products, collected into one e-book.
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

Follow [me](http://reginald.braythwayt.com) on [Twitter](http://twitter.com/raganwald). I work with [Unspace Interactive](http://unspace.ca), and I like it.