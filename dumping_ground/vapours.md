From interview questions to production code
===

Things are a little slow with me career-wise, so I have some cycles to eat a little of my own [dog food](http://en.wikipedia.org/wiki/Eating_one%27s_own_dog_food "Eating one's own dog food - Wikipedia, the free encyclopedia"). Specifically, I'm writing a server for playing [Go](http://github.com/raganwald/homoiconic/blob/master/2009-10-20/high_anxiety.md "High Anxiety") online. What does this have to do with dogfooding? Two things. First, I'm using [rewrite_rails](http://github.com/raganwald-deprecated/rewrite_rails "raganwald's rewrite_rails at master - GitHub"). That's great and I'm actually filing issues as I run into them.

Second, and this is the point of my quick post here, I have a chance to write a game you play online. If you've been reading some of my early dreck, this will sound familiar: It is the subject of [my favourite interview question](http://raganwald.com/2006/06/my-favourite-interview-question.html "My favourite interview question")! Mind you, my favourite interview question is allegedly about Monopoly, and this is Go. There are some important differences. First, Go is way easier: The rules are not poorly defined for the game itself. The rules are much smaller, simpler, and more elegant. But second, just like Monopoly there is the challenge of writing the program such that it documents the rules of the game. To quite myself liberally:

> Now let’s ask a question about Monopoly (and Enterprise software). Where do the rules live? In a noun-oriented design, the rules are smooshed and smeared across the design, because every single object is responsible for knowing everything about everything that it can ‘do’. All the verbs are glued to the nouns as methods.

> Let’s take a look at a simple rules question. If a player owns Baltic Avenue, can she add a house to it?

> Well, there’s a bunch of stuff about whether she can afford it and whether there is a house available in the bank. Where does that live? In the bank object? And there is a bunch of stuff about whether it is either the player’s turn or between turns. Where does that live?

> And there is a bunch of stuff about whether the property already has four houses. Where does that live? Somewhere in the property hierarchy? Sounds reasonable. Now what about mortgaged property? If Baltic is mortgaged, the answer is no. That’s easy. But what if Mediterranean Avenue is mortgaged? And what if, for example, Baltic has one house but Mediterranean has none? Where does that logic live? Both of these last two questions involve knowing something about the other properties of a colour group.

> Now you can debate which verbs belong to which nouns, but here is an opportunity to step back a bit and consider the larger implications of maintaining such a ‘classical’ OO design.

> Consider a ‘noun and verb’ design. First, an easy question. How well does the design document the actual game of Monopoly? If someone were to read the source code, do you think they could learn how to play the actual game?

So there's my personal challenge: Write the game such that someone unfamiliar with Go could learn the rules by looking at the source code. 

**From interview question to production code**

The problem of writing code that documents its requirements is central to software development. It's somewhat practical to do in an interview. But in production, we have a two additional challenges. First, the code has to survive changes and maintenance. All too often, the clarity and readability degrades over time much the way a legal agreement becomes incomprehensible as clauses are scratched out and new ones inserted without redrafting it from scratch.

The second challenge of writing code that documents its requirements in a production environment is the problem of *optimization*. To simplify the problem dramatically, optimization is the practice of finding the fastest possible code that satisfies the functional requirements. Readability and speed are sometimes antithetical to each other. In fact, the fastest possible algorithm or expression of code may be almost entirely unrelated to the human-readable expression of the requirements: It may not document the requirements at all, except it happens to fulfill them by coincidence.

Let me give you an example from Go. My fledgling understanding of something called the [Rule of Ko](http://en.wikipedia.org/wiki/Rules_of_go#Ko "Rules of Go - Wikipedia, the free encyclopedia") is that: **A play is illegal if it would have the effect (after all steps of the play have been completed) of creating a position that has occurred previously in the game.** Expressing this requirement in code is fairly straightforward. Here's an early example from my prototype:

    class Game < ActiveRecord::Base
  
      # ...
      
      has_many :actions, :class_name => "Action::Base", :foreign_key => "game_id"
      has_many :before_boards, :through => :actions, :source => :before
  
      validates_each :current_board do |game, attr, current_board|
        game.errors.add_to_base "a game cannot repeat itself" if begin
          game.before_boards.map(&:to_a).include?(current_board.to_a)
        end
      end
      
      # ...
      
    end

So in Rails parlance, a game is invalid if its current position ("current board") expressed as an array is included in a list of its previous positions ("before boards"). This is somewhat directly expressing the rule given above. But how frightfully inefficient!

With some thought, we can optimize this check. For example, I have a hunch that any move that does not capture a stone cannot violate the Rule of Ko. (If you aren't a Go player, never mind understanding the hunch, just nod and play along, it isn't essential to understand my hunch or whether I'm right to get the gist of my argument about code.) So a possible optimization is to only check previous boards if the last action involved a capture. Lets say my hunch is correct.

So one option is to implement some conditional logic in the Game model. Does this conditional logic express anything about the Rule of Ko? Or just something about how to efficiently check for violating the Rule of Ko? Does this conditional add understanding for someone reading the code or obscure it?

You might consider getting polymorphic and moving the check into the Action model. That's the model that knows what kind of move was just made. So now instead of saying roughly that a valid game consists of a set of boards that are unique, we can say that a move that captures one or more stones is valid if it produces a board that does not duplicate any previous board. Again, this is logically correct but not as simple as the rule expressed in English without optimization.

From an implementation perspective, This has a Rails [code smell](http://en.wikipedia.org/wiki/Code_smell "Code smell - Wikipedia, the free encyclopedia"). If you want to associate validity with uniqueness... You ought to be using `validates_uniqueness_of`. This would require organizing the model such that each board has a single field expressing its position so that the ActiveRecord infrastructure can do the checking for you and so that your database can do the optimization.

This is entirely possible, but now you have reorganize things a little. Judging by my prototype code above, that would be a good thing. But like any reorganization, there is the potential to obscure the simple rule with bookkeeping and contortions designed to make one line of code simple (`validates_uniqueness_of :boards`) but making other things more complex. You may not be able to get rid of the tension between what is clearest to communicate and what performs well in production.

**A flight of fancy**

I think about this issue a lot when coding. When I'm mixing code that expresses requirements with code that expresses optimization, it feels like I'm mixing interface with implementation. Our languages and tools work hard to separate interfaces from implementation when talking about function or method signatures, but we really don't have a great way of expressing the idea that *this* is a simple way of expressing the algorithm we want and *that* is an optimization that has the exact same behaviour but runs twice as fast.

We do have some tools that help. For example, automated tests. One approach is to discard the idea that the working code expresses the rules of the game and instead, write tests that express the rules of the game. Any code satisfying the unit tests is acceptable. 

Another thing that occurred to me is to 
