Bruno Marchal's Combinator Chemistry
===

![Bruno Marchal](http://iridia.ulb.ac.be/~marchal/courses/Saturday_20070602_LNash/t_blackboard_1.png)

[Bruno Marchal](http://iridia.ulb.ac.be/~marchal/ "Bruno Marchal&rsquo;s Home Page") wrote up a concise and challenging introduction to combinatory logic, in the form of a series of emails:

1. [COMBINATORS I](http://www.mail-archive.com/everything-list@eskimo.com/msg05920.html)
2. [COMBINATORS II](http://www.mail-archive.com/everything-list@eskimo.com/msg05949.html)
3. [COMBINATORS III](http://www.mail-archive.com/everything-list@eskimo.com/msg05953.html)
4. [COMBINATORS IV](http://www.mail-archive.com/everything-list@eskimo.com/msg05954.html)
5. [COMBINATORS V](http://www.mail-archive.com/everything-list@eskimo.com/msg05955.html)
6. [COMBINATORS VI](http://www.mail-archive.com/everything-list@eskimo.com/msg05957.html)
7. [COMBINATORS VI (sequel)](http://www.mail-archive.com/everything-list@eskimo.com/msg05958.html)
8. [COMBINATORS VIII](http://www.mail-archive.com/everything-list@eskimo.com/msg05959.html)

*The first post text is reproduced below with Bruno's permission. I have added some wikipedia links to the introduction. Any brilliance is his, any errors are mine. I will post more as I find time.*

The Chemistry of COMBINATORS
---

Hi,

For those who are interested in the comp hypothesis, it is hardly a luxury to dig a little bit in computer science. If only to go toward explicit definition of notion like computations, computational history, consistent extensions, models, etc. I open this thread for the very long term.

One of the jewel of computer science is the theory of [combinators](http://en.wikipedia.org/wiki/Combinators "Combinatory logic - Wikipedia, the free encyclopedia").

They have been discovered and presented in a talk by [Moses Schoenfinkel](http://en.wikipedia.org/wiki/Schoenfinkel "Moses Schönfinkel - Wikipedia, the free encyclopedia") (from Moscow) in 1920. And rediscovered independently by [Haskell Curry](http://en.wikipedia.org/wiki/Haskell_Curry "Haskell Curry - Wikipedia, the free encyclopedia") (USA) in 1930. [Church](http://en.wikipedia.org/wiki/Alonzo_Church "Alonzo Church - Wikipedia, the free encyclopedia") rediscovered them too under the form of closed lambda _expression_, for which he will postulate his famous "Church thesis": the closed lambda _expression_ are enough to define all computable functions (from N to N, where N = the set of positive integers).

There is no "Schoenfinkel thesis" nor any "Curry thesis", as opposed to "Church thesis". Indeed the goal of both Schoenfinkel and Curry was to "rebuild" an alternative to the whole of mathematics. One of Schoenfinkel's motivation was to eliminate all variables. Curry's motivation was to find the most elementary finitary operations rich enough to (re)build mathematics, and this preferably without formal sets, but only a finite set of primitive operations.

Actually Combinatory Logic can "easily" be shown rich enough to represent the partial recursive function, so that the combinators gives a nice and pleasant computer programming language. (And indeed LISP and functionnal programming languages are all descendants or cousins of the combinators/lambda calculus). But at some fundamental level combinatory logic is much more than a programming language: it is really a possible road to tackle the problem of the nature of mathematics, and with comp: the nature of reality. Also, combinatory logic is very fine grained, and this will enable us to introduce at a very cheap price important nuances.

Here is a short descrition of combinatory logic (beware: in the preceding post I made a typo error):

STATIC:

1. K is a molecule (called the "kestrel" is Smullyan's terminology)
2. S is a molecule (the "Starling")
3. if x and y are molecules then (x y) is a molecule. From this you can easily enumerate all possible molecules: K, S, (K K), (K S), (S K), (S S), ((K K) K), ((K S) K) ...

DYNAMICS:  (X and Y are put for any molecules)

1. ((K X) Y) = X    (Law of the Kestrel)
2. (((S X) Y) Z)  = ((X Z) (Y Z))  (Law of the Starling)

1) means that on any molecules X the molecules (K X) is stable and does not evolves (except by the evolution of X perhaps). I will say that a molecules of the shape (K X) is a charged Kestrel.
Now if (K X) comes to interact with some other molecules Y giving ((K X) Y) you get an explosion leaving as result of the reaction just the molecule X.

So for example:

K is stable  
(K K) is stable  
(K (K K)) is stable  
((K K) K) is unstable, indeed it matches the law "1)", with X = K, and Y = K, so the reaction is trigged giving K.

((K (K K)) (K K)) gives (K K), ok?



Well the price of having a conceptually very simple syntax (static) is that the notation can be very quickly a little bit cumbersome. The tradition is to neglect the left parenthesis abbreviating
(((a b) c) d) by abcd. The laws becomes:

KXY = X  
SXYZ = XZ(YZ)

The examples becomes

K is stable  
KK is stable  
K(KK) is stable  
KKK is unstable and "decays" into K, and finally

K(KK)(KK) gives (KK) ok?

What gives S(KK)(KK) ? Solution: it remains S(KK)(KK). It is stable because S needs "three" molecules to trigger its dynamic. So S(KK)(KK)(KK) gives KK(KK)(KK(KK)), as SKKK gives KK(KK) which is still unstable and gives K.

Exercises (Taken from the course "My First Everything Theory" Primary school Year 2127 :)

Evaluate:

(SS)KKK = ?  
KKK(SS) = ?  
(KK)(KK)(KK) = ?  
(KKK)(KKK)(KKK) = ?

Evaluate:

K  
KK  
KKK  
KKKK  
KKKKK  
KKKKKK  
KKKKKKK  
KKKKKKKK  
KKKKKKKKK  
KKKKKKKKKK

A little more advanced exerciaes: is there a molecule, let us called it I, having the following dynamic: (X refers to any molecule).

IX = X

So a solution is some molecule made up from K and S which applied on any molecule give as result of the reaction that very molecule unchanged.

For example KXS is not a solution, although it gives X, it is not of the shape (molecule  X).


Of course you can learn a lot by searching "combinators" or "lambda calcul" on the net. Two samples: For those "who knows", [here is a paper on Kolmogorov Complexity viewed through the combinators](http://homepages.cwi.nl/~tromp/cl/CL.pdf). It can be used as a quick introduction to combinators.

*(c) 2005-2008, Bruno Marchal.*

---

*If you enjoyed Bruno's posts, may I suggest a few of my own explaining some Ruby programming ideas in terms of combinators?*

[Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown), and [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md).

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub")
	
Subscribe here to [a constant stream of updates](http://github.com/feeds/raganwald/commits/homoiconic/master "Recent Commits to homoiconic"), or subscribe here to [new posts and daily links only](http://feeds.feedburner.com/raganwald "raganwald's rss feed").

<a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>