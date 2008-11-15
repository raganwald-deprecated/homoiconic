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

*The first through fourth texts are reproduced below with Bruno's permission. I have added some wikipedia links to the introduction. Any brilliance is his, any errors are mine. I will post more as I find time.*

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

COMBINATORS II (solution of exercises)
---

I recall all you need to know:


	Kxy = x  
	Sxyz = xz(yz)


That's all! (Well you are supposed to remember also that abc is an abbreviation of ((ab)c), and a(bc) is an abbreviation for (a(bc)).

I recall the exercices taken from "My First Everything Theory" Primary school Year 2127 :) Solution are below. Evaluate:

	(SS)KKK =  
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


A little more advanced exercices: is there a molecule, let us called it I, having the following dynamic: (X refers to any molecule).

	IX = X    I = ?


(Note I will use in this context the words molecules, birds, combinators, programs as synonymous).

**SOLUTIONS:**

	(SS)KKK = SK(KK)K = KK(KKK) = K
	KKK(SS) = K(SS)
	(KK)(KK)(KK) = KK(KK)(KK) = K(KK)
	(KKK)(KKK)(KKK) = KKK = K


Note that the passage (KK)(KK)(KK) = KK(KK)(KK) comes just from a use of the parentheses abbreviation rule which help to see the match with the dynamic of K : Kxy = x, and indeed KK(KK), when occuring at a beginning, matches Kxy with x = K and y = (KK) = KK.


	K    =  K
	KK    =  KK
	KKK    =  K
	KKKK   =  KK
	KKKKK    =  K
	KKKKKK   =  KK
	KKKKKKK    =  K
	KKKKKKKK   =  KK
	KKKKKKKKK    =  K
	KKKKKKKKKK   =  KK


ok? (this was easy! if you have not succeed it means you are imagining difficulties). The next exercise is slightly less easy, we are to program some identity operator.


	Ix = x    I = ?


We must find a program (that is a combinator, that is a combination of K and S) which applied on any X gives that X. We want for example that


	I(KK) = (KK)
	I(SSS) = SSS etc.


So we want that for all x Ix = x. But only Kxy is able to give x so x = Kx? and we want Kx? matching the rule for S (we have only this one), it is easy because whatever ? represents, Kx? gives x. So we can take ? = (K x) or (S x) or etc.

This gives x = Kx(Kx) (or x = Kx(Sx) ) so that the rule S can be applied so that


	x = Kx(Kx) = SKKx     (or x = Kx(Sx) = SKS)


Thus SKKx = x, and so a solution is

	I = SKK


It is our first program! Another one is I = SKS (actually SK&lt;anything stable&gt; would work).


Let us verify. i.e. let us test SKK and SKS on KK:


	SKK(KK) = K(KK)(K(KK)) = KK
	SKS(KK) = K(KK)(S(KK)) = KK


more general verification:

	SKKx = Kx(Kx) = x


Any problem?  You see that programming is really inverse-executing.


**New programming exercises:**


Find combinators M, B, W, L, T such that


	Mx = xx   (Hint: use your "subroutine" I, as a "macro" for SKK)

	Bxyz = x(yz)

	Wxy = xyy

	Lxy = x(yy)

	Txy = yx


COMBINATORS III
---

Resume:

	Kxy = x
	Sxyz = xz(yz)

That's all. (You are supposed to remember also that abc is an abbreviation of ((ab)c), and a(bc) is an abbreviation for (a(bc)), so Kxy is put for ((K x) y), and Sxyz is put for (((S x) y) z), and xz(yz) is put for ((x z)(y z)). We just don't write the left parentheses).

I recall the last exercises:

Find combinators M, B, W, L, T and C such that Mx = xx (Hint: use your "subroutine" I, as a "macro" for SKK)

	Bxyz = x(yz)
	Wxy = xyy
	Lxy = x(yy)
	Txy = yx
	Cxyz = xzy  (I add this one)

I solve the two firsts one: M and B:

I recall we have already program the identity combinator I, which is such that Ix = x for any combinators x. it is I = SKK, and we can use it as a "subroutine".

1) We want find a combinator M such that Mx = xx.

We reason again by inverse-execution. We must transform xx in a way such that it matches the right part of the dynamic of K or S. The simplest way is by using I. Indeed xx = Ix(Ix), and this match the S rule.

Thus:

	Mx = Ix(Ix)
	   = SIIx

and thus:
	M = SII
	  = S(SKK)(SKK).

2) We want to find a combinator B such that Bxyz = x(yz)

We need to find an expression equal (by the dynamic rule) to something matching the right part of the S dynamic. We can use I, M or K and S. Here K and S will be enough. Indeed

	Bxyz = x(yz)
         = (Kxz)(yz)     because x = Kxz
         = S(Kx)yz       verify with all the parentheses if you don't see it.
         = KSx(Kx)yz    because S = (KSx)
         = S(KS)Kxyz

Thus:
	B = S(KS)K
	
All right?

Note to understand what will follow it is not really necessary to develop skills in the art of finding those programs, but you should be able to verify them if you want to have the needed passive knowledge. Let us verify B on any x y z:

	Bxyz = S(KS)Kxyz = KSx(Kx)yz = S(Kx)yz = Kxz(yz) =x(yz).  OK?

Nevertheless I give you time (for the fun) to try to find W, L, T and C. Could you find a combinator called INFINITY which is perpetually unstable? That is INFINITY gives INFINITY, which gives INFINITY etc. (by the K S dynamical rule).

To sum up our work:

	I = SKK
	M = SII = S(SKK)(SKK)
	B = S(KS)K

Try to find W, with Wxy = xyy, L, with Lxy = x(yy), T with Txy = yx, C with Cxyz = xzy, and INFINITY, with INFINITY dynamically transform into INFINITY itself. No question? Soon (that is after we solve the last problems) we will have enough to make precise some nuances between "mind" and "matter". Already!

COMBINATORS IV
---

Resume:

	Kxy = x
	Sxyz = xz(yz)

That's all. (You are supposed to remember also that abc is an abbreviation of ((ab)c), and a(bc) is an abbreviation for (a(bc)), so Kxy is put for ((K x) y), and Sxyz is put for (((S x) y) z), and xz(yz) is put for ((x z)(y z)). We just don't write the left parentheses).

We have seen:

	Ix = x,   a solution for I is I = SKK
	Mx = xx,  a solution for M is M = SII = S(SKK)(SKK)
	Bxyz = x(yz), a solution for B is B = S(KS)K

I recall the last exercises:

Find combinators W, L, T, C and INFINITY such that

	Wxy = xyy
	Lxy = x(yy)
	Txy = yx
	Cxyz = xzy
	INFINITY gives INFINITY (by the dynamical rules for K and S).

SOLUTIONS:

One:

	Wxy = xyy
    	= (xy)y      because xyy abbreviates xyy   
    	= (xy)(Iy)    because y = Iy   
    	= SxIy        dynamics of S   
    	= (SxI)y        abbrev.   
    	= Sx(KIx)y    because I = KIx   
    	= (Sx(KIx))y  abbrev.   
    	= (SS(KI)x)y    dynamics of S   
    	= SS(KI)xy    abbrev.   

Thus:

	W = SS(KI) = SS(K(SKK))

Two:

	Lxy = x(yy)
      = x(My)   because My = yy (Mx = xx).
      = BxMy  dynamics of B
      = Bx(KMx)y  'cause KMx = M
      = SB(KM)xy  dyn. of S, on ((Bx)((KM)x)

Thus:

	L = SB(KM) = S(S(KS)K)(KS(SKK)(SKK))

Of course SB(KM) is a better presentation, giving that we know already B and M. But I give the (abbreviated) combinator (in term of S and K) to be sure you see it is indeed a combinator (a combination of S and K).

3)

	Txy = yx
	    = y(Kxy) 'cause x = Kxy
	    = (Iy)(Kxy) 'cause y = (Iy)
	    = SI(Kx)y dyn. of S (which explain the transformation just above btw)
	    = B(SI)Kxy dyn. of B

Thus:

	T = B(SI)K = S(KS)K(S(SKK))K

4)  

	Cxyz = xzy
	     = xz(Kyz)
	     = Sx(Ky)z
	     = B(Sx)Kyz
	     = BBSxKyz
	     = BBSx(KKx)yz
	     = (BBS)x(KKx)yz
	     = S(BBS)(KK)xyz

Thus:

	C = S(BBS)(KK)
	  = S((S(KS)K)(S(KS)K)S)(KK)    cf B = S(KS)K

5) INFINITY   Well this one is easy!

	Mx = xx, thus MM gives MM which gives MM, etc.

Thus:

	INFINITY = MM = SII(SII) = S(SKK)(SKK)(S(SKK)(SKK))

It is a simple example of a perpetually unstable molecule.

All right so far? To find those programs, the heuristic has been to use K and I to change some combination of variables (like xzy) into a form such that a known dynamic can be used (in general the one of S, or of B). B, for example, is useful to shift parentheses on the left. Such exercises need a bit of training and a taste for programming or puzzles. I hope that you are able to verify (at least) a solution. Let us verify that L admits another solution based on the use of C:

	L = CBM  (by which I mean CBM behaves like it is aked for L to behave, i.e. Lxy = x(yy)

Indeed:

	CBMxy = BxMy (because Cabc=acb, or Cxyz = xzy)
	      = x(My)
				= x(yy).

Such a sequence of application of the dynamical rules will be what I mean by the term "computation". This will be justify when we will see that the combinators are Turing-equivalent. Any program can be matched by a combinator.

Note also this. We see that SB(KM) and CBM are two different programs computing L. But SB(KM), that is S(S(KS)K)(KS(SKK)(SKK)), and CBM, that is S((S(KS)K)(S(KS)K)S)(KK)(S(KS)K)(S(SKK)(SKK)) are different combinators doing the same things. We will use the (extensionality) rule which identifies the combinators which have the same behavior. When two combinators are syntactically identical, we will use the expression "strictly identical" (written ==). A (more simple) example is:

	I = SKK = SKS = SK(KK) = ....

They all give an identity combinator. But none can be obtained from this other by a reduction, i.e. an application of the dynamical rule from left to right (like in a computation).

Finally, because the combinators we have met so far will play some persisting role in the sequel, they deserve names. I give you the (birdy) terminology of Smullyan:

* K is the kestrel. It is "the" eliminator. K(KK)(SSS) eliminates (SSS) for example.
* S is the starling. S does many things at once: it duplicates, composes, and permutates its arguments: Sxyz = xz(yz). Look carefully.
* T is the trush. It is a crude permutator. It permutates its arguments: Txy = yx.
* M is the mocking bird itself! It is just a crude duplicator: Mx = xx.
* C is the cardinal. C is called the elementary or regular permutator. It is less crude than the trush. Much more easy to use, like in general the regular combinators, which by definition are those combinators which leaves unchanged they first argument. All combinators seen so far are regular except the trush.
* W is the warbler. It is the elementary duplicator (less crude than the mocking bird!).
* B is the elementary compositor. Bxyz = x(yz). Suppose that f = log, and g = sin, then Bfgx = log(sin x), so that Bfg gives f * g. That is the composition of the functions f and g. I forget to say that B is called the blue bird.
* L is the lark: it is an hybrid of a warbler or a mocking bird and a compositor.

Exercise:

We have seen how to program the blue bird B, the cardinal C and the Warbler W with the kestrel K and the starling S. Could you define the starling S from B, W and C? I give you the first line:

	Sxyz = xz(yz)
	     = Cx(yz)z
			 = ...

Bruno

*(c) 2005-2008, Bruno Marchal.*

---

*If you enjoyed Bruno's posts, may I suggest a few of my own explaining some Ruby programming ideas in terms of combinators?*

[Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown), and [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md).

---

[homoiconic](http://github.com/raganwald/homoiconic/tree/master "Homoiconic on GitHub")
	
Subscribe here to [a constant stream of updates](http://github.com/feeds/raganwald/commits/homoiconic/master "Recent Commits to homoiconic"), or subscribe here to [new posts and daily links only](http://feeds.feedburner.com/raganwald "raganwald's rss feed").

<a href="http://feeds.feedburner.com/raganwald"><img src="http://feeds.feedburner.com/~fc/raganwald?bg=&amp;fg=&amp;anim=" height="26" width="88" style="border:0" alt="" align="top"/></a>