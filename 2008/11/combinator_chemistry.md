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
7. [COMBINATORS VIII](http://www.mail-archive.com/everything-list@eskimo.com/msg05959.html)

(There is no VII, to the best of my knowledge, it was combined with VI.)

The texts are reproduced below with Bruno's permission. I have added some wikipedia links to the introduction. Any brilliance is his, any errors are mine. I will post more as I find time.

[COMBINATORS I](http://www.mail-archive.com/everything-list@eskimo.com/msg05920.html): The Chemistry of Combinators
---

Hi,

For those who are interested in the comp hypothesis, it is hardly a luxury to dig a little bit in computer science. If only to go toward explicit definition of notion like computations, computational history, consistent extensions, models, etc. I open this thread for the very long term.

One of the jewel of computer science is the theory of [combinators](http://en.wikipedia.org/wiki/Combinators "Combinatory logic - Wikipedia, the free encyclopedia").

They have been discovered and presented in a talk by [Moses Schoenfinkel](http://en.wikipedia.org/wiki/Schoenfinkel "Moses Schönfinkel - Wikipedia, the free encyclopedia") (from Moscow) in 1920. And rediscovered independently by [Haskell Curry](http://en.wikipedia.org/wiki/Haskell_Curry "Haskell Curry - Wikipedia, the free encyclopedia") (USA) in 1930. [Church](http://en.wikipedia.org/wiki/Alonzo_Church "Alonzo Church - Wikipedia, the free encyclopedia") rediscovered them too under the form of closed lambda _expression_, for which he will postulate his famous "Church thesis": the closed lambda _expression_ are enough to define all computable functions (from N to N, where N = the set of positive integers).

There is no "Schoenfinkel thesis" nor any "Curry thesis", as opposed to "Church thesis". Indeed the goal of both Schoenfinkel and Curry was to "rebuild" an alternative to the whole of mathematics. One of Schoenfinkel's motivation was to eliminate all variables. Curry's motivation was to find the most elementary finitary operations rich enough to (re)build mathematics, and this preferably without formal sets, but only a finite set of primitive operations.

Actually Combinatory Logic can "easily" be shown rich enough to represent the partial recursive function, so that the combinators gives a nice and pleasant computer programming language. (And indeed LISP and functionnal programming languages are all descendants or cousins of the combinators/lambda calculus). But at some fundamental level combinatory logic is much more than a programming language: it is really a possible road to tackle the problem of the nature of mathematics, and with comp: the nature of reality. Also, combinatory logic is very fine grained, and this will enable us to introduce at a very cheap price important nuances.

Here is a short description of combinatory logic (beware: in the preceding post I made a typo error):

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

[COMBINATORS II](http://www.mail-archive.com/everything-list@eskimo.com/msg05949.html) (solution of exercises)
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


[COMBINATORS III](http://www.mail-archive.com/everything-list@eskimo.com/msg05953.html)
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

[COMBINATORS IV](http://www.mail-archive.com/everything-list@eskimo.com/msg05954.html)
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
* T is the thrush. It is a crude permutator. It permutates its arguments: Txy = yx.
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

[COMBINATORS V](http://www.mail-archive.com/everything-list@eskimo.com/msg05955.html)
---

We have seen how to program the blue bird B, the cardinal C and the Warbler W with the kestrel K and the starling S. Could you define the starling S from B, W and C? It is not so simple. Now if we succeed, this will give us a second equivalent theory.

I mean the sets:

	{S K}

	{W B C K}

generates by composition the same set of birds. Later we will see those sets are maximal. They generate all the birds. It is two equiavlent presentations of the same "everything theory". The first has two primitive bird, the second has 4 primitives birds (because it can be shown you cannot define W from B C K, nor B from W C K, etc.)

To show the sets {S K} and {W B C K} generate the same combinators (birds) we must show how to define W, B, C and K from {S K}. But this has been done (see previous post), for example W = SS(KI), B = S(KS)K and C = S(BBS)(KK).

So it remains to show inversely that S can be defined from W, B, and C (and K except S does not eliminate any input and it is thus doubtless we need K).

I gave you the first line:

	Sxyz = xz(yz) 
	     = Cx(yz)z 
	
Ah someone asks me why? Recall Cxyz= xzy, with x y z arbitrary combinators, thus Cx(yz)z = xz(yz) (the first argument of C was x, the second was (yz) and the third was z).

Oops students are coming. I let you do the following more easy exercise:

Verify that S = B(BW)(BBC). That is verify that B(BW)(BBC)xyz = xz(yz). This should be much easier.

[COMBINATORS VI](http://www.mail-archive.com/everything-list@eskimo.com/msg05957.html)
---

I will provide a detailed solution of the last problem for those who have perhaps missed the beginning.

Verify that S = B(BW)(BBC). That is verify that B(BW)(BBC)xyz = xz(yz) This should be much easier.

One awful solution would be, reminding that B = S(KS)K, and that W = SS(KI) and that C = S(BBS)(KK), that is S((S(KS)K)(S(KS)K)S)(KK), to substitute those the occurence of B, W and C by they SK-programs, giving:

	S = B(BW)(BBC) = 
	S(KS)K((S(KS)K)SS(K(SKK)))((S(KS)K)(S(KS)K)(S((S(KS)K)(S(KS)K)S)(KK)))

... and then applying that _expression_ on xyz.

Obviously we have not programmed the elementary compositor B, the elementary permutator C and the elementary duplicator W for not using them. Yet this gave an interesting definition of S in term of itself and this rises the question if there is not some general recursion phenomenon there and indeed there will be a very general such phenomenon captured by a combinator which is neither an eliminator, nor a permutator, nor a duplicator, nor even an identificator (like Ix = x) and which was called the paradoxical combinators by Curry and Feys and is known today as the fixed point combinator but that's for later.

So I recall:

	Bxyz = x(yz)
	Wxy = xyy
	Cxyz = xzy

And 'course:

	Kxy = x
	Sxyz = xz(yz)

And let us verify that S = B(BW)(BBC) I recall "=" means "act similarly"; thus we must show that:

	B(BW)(BBC)xyz = Sxyz = xz(yz)

Well Bxyz = x(yz) and please remember that Bxyz abbreviates (((B x) y) z) and in particular

B(BW)(BBC)x abbreviates (((B (BW)) (BBC)) x) and that that matches!

Another practical way (more practical than by adding the left parenthesis!) is to fully abbreviate the _expression_ (like I do usually) and remember that B (here) is trigged by its dynamic when presented with three arguments and that argument are *arbitrary* combinators:

so the _expression_ B(BW)(BBC)xyz is

	B (BW) (BBC) x y z
	   1     2   3

and you can write the dynamic of B by B123 = 1(23), meaning that 1 denotes its first argument (BW), 2 its second (BBC) and 3 denotes x, so that

	B(BW)(BBC)x gives (BW)((BBC)x) that is (fully abbreviated)

	BW(BBCx). We must yet apply it to y and then z:

	BW(BBCx)y

Oh! here we have a choice! Indeed the B-dynamic match the first occurrence of B and the second one. A famous result, known as Church Rosser Theorem tells us that as far as thereduction will converge on some stable molecule, the path, and thus those choice does not matter: we will get the same stable molecule. Soon or later we will come back on this, but let us just choose the leftmost reduction (another theorem will make some advertising for that strategy, but things will appear to be non trivial though ...). So we apply the B-rule on leftmost B in: B W (BBCx) y giving W((BBCx)y) that is (fully abbrev.) W(BBCxy), and now we have also a choice: either we apply W(BBCxy) directly on z, or we reduce it further. You could verify those alternate path as exercise; let us apply W(BBCxy) directly on z. This gives W(BBCxy)z (and Wab = abb) thus W(BBCxy)z gives (BBCxy)zz = (fully abbrev.) BBCxyzz, and this gives by the B-rule B123 = 1(23), (where 1, the first argument of B is B itself, and 2 is C and 3 is x) B(Cx)yzz which by the B rule again (with 1 = (Cx), 2 = y, 3 = z) gives (Cx)(yz)z, which by the C-rule C123= 132 (with 1 = x, 2 = (yz) 3 = z gives xz(yz). That's Sxyz and so we have shown that B(BW)(BBC) behaves like S.

To sum up: S = B(BW)(BBC) because

	B(BW)(BBC)xyz
	= BW(BBCx)yz
	= W(BBCxy)z
	= (BBCxy)zz
	= B(Cx)yzz
	= Cx(yz)z
	= xz(yz) which what Sxyz gives.



Of course the original exercise I gave was harder: program S from B, W and C. It consisted in finding that B(BW)(BBC) or something similar. But how could we have found such _expression_? A nice thing is that the verification above, which just use the dynamics of B, C and W gives us the answer: just copy the execution above in the reverse order (cf programming here is inverse execution). I do it and I comment:

	?xyz = &lt; B, C, ...&gt;xyz = xz(yz)

xz(yz) so this is what we want as the result of B C W application on xyz. So we must transform xz(yz) as &lt;B,C ..&gt;xyz, that is get those final "x)y)z)", or xyz in fully abb. form.

Cx(yz)z what a clever move! we are at once close to xyz, except that we have two parentheses too much, and one z to much. To suppress one z we will isolate it by moving the right parenthesis to the left. That's the inversion of the B-rule, so we arrive at:

B(Cx)yzz and applying again the B-rule, we get

(BBCxy)zz I let some left parenthesis so that the W-rule applicability is highlightened

W(BBCxy)z And now there just remains a right parenthesis we would like to push on the left, which we can do by two successive inverse B rule: The first gives (with 1 = W, 2 = (BBCx) and 3 = y:

BW(BBCx)yz the second gives with 1 = (BW), 2 = (BBC) and 3 = x:

	B(BW)(BBC)xyz we got what we wanted: S = B(BW)(BBC).

Both gives xz(yz) when given x y and z (in that order!).

COMBINATORS VI (sequel)
---

*Question*: is there a systematic method such that giving any behavior like

	Xxyztuv = x(yx)(uvut) (or what you want)

can generate systematically a corresponding SK or BWCK -combinator? The answer is yes. I let you meditate the question. (This point will be made clear when we will meet the terrible little cousins of the combinators which are the *lambda _expression_*, (and which in our context will just abbreviate complex combinators), but I propose to progress and make sure that the SK combinator are Turing Universal.

I am not yet decided when I really should introduce you to the paradoxical combinators, which are rather crazy. Smullyan call them wise birds, but I guess it is an euphemism!

Mmhhh... Showing turing-universality through the use of some paradoxical combinator is easy (once we have defined the numbers), but there is a risk you take bad habits! Actually we don't need the paradoxical combinators to prove the turing universality of the SK forest, mmmmh...

Well actually I will be rather busy so I give you the definition of a paradoxical combinator and I let you search one.

First show that for any combinator A there is a combinator B such that AB = B. B is called a fixed point of A. (like the center of a wheel C is a fixed point of the rotations of the wheel: RC = C). It is a bit amazing that all combinators have a fixed point and that is what I propose you try to show. Here are hints for different arguments. 1) Show how to find a fixed point of A (Arbitrary combinator) using just B, M and A. (Mx = xx I recall). 2) The same using just the Lark L (Lxy = x(yy) I recall). Now, a paradoxical combinator Y is just a combinator which applied on that A will give the fixed point of A; that is YA will give a B such that AB = B, that is A(YA) gives YA, or more generally Y is a combinator satisfying Yx = x(Yx).

[COMBINATORS VIII](http://www.mail-archive.com/everything-list@eskimo.com/msg05959.html)
---

Be sure you have understood the preceding posts before reading this one. For archives and even better archives, see the links below.

**The Paradoxical combinators**

I recall that a combinator X is a fixed point of a combinator Z if ZX = X. For example, all combinators (birds) are fixed point of the identity combinator, given that for any x Ix = x. Curiously enough in many forest all combinators have a fixed point.

The "paradoxical combinator", or "fixed point combinator" is a combinator which find that fixed point of any given combinators.


PROPOSITION 1: *if a forest contains a bluebird B, where Bxyz = x(yz), and a MockingBird M, that is Mx = xx, then ALL birds have indeed a fixed point P.*

Proof: All bird x have BxM(BxM) as a fixed point, that is BxM(BxM) is always a fixed point of x, indeed:

	BxM(BxM) = x(M(BxM)) = x(BxM(BxM)). OK?


PROPOSITION 2: *If a forest contains a lark L, i.e. Lxy = x(yy), then again ALL birds will have a fixed point. Indeed all birds x have Lx(Lx) as a fixed point:*

	Lx(Lx) = x(Lx(Lx)) (directly from the dynamic of L). OK?


Saying that all birds in a forest have a fixed point is not the same as saying that there is, in the forest a bird capable of finding that fixed point. Let us show that if the forest contains a starling and a lark, then there is such a bird (called a paradoxical combinator, or a fixed point combinator. raymond called them "wise bird", and I was used to call them "crazy bird" given that they can have some crazy behavior).

To find a fixed point combinator, it is enough, for example, to find a bird which on x will generate Lx(Lx).

But Lx(Lx) is just SLLx

And thus SLL is a fixed point combinator. SLLx = x(SLLx) given that SLLx = Lx(Lx). OK?

(Of course SLL is an abbreviated name for combinator 

	S(S(S(KS)K)(KS(SKK)(SKK)))(S(S(KS)K)(KS(SKK)(SKK))) 

given that we have shown L = SB(KM); and B = S(KS)K, and M = SI I= S(SKK)(SKK) cf solution 2 in COMBINATORS IV (see links below).

Obviously, a forest which contains S and K, like our current "everything theory", contains L (or a B and a M) and, thus, is such that all birds have a fixed point. Such a forest also contains fixed point combinators. Some day we will justify why any SK-forest contains really all possible birds.


**WHAT'S the USE of PARADOXICAL combinators?**

Well, you should be able to solve an exercise like finding a combinator A such that its dynamics is described by Axyz = y(yx)zz. Some other day we will make this precise by giving an *algorithm* for solving such problem (which solutions exist in all "sufficiently rich forest like the SK or BWCK forest). With the fixed point combinators you should be able to solve "recursive equations" like: find a A such that its dynamics is described recursively by Axyz = xxA(Ayy)z. How? Just find a B such that Baxyz = xxa(ayy)z (A has been replaced by a variable a). This is a traditional (non recursive) exercise. Then YB gives the solution of the recursive equation. (Y is the traditional name for a paradoxical combinator). Exercise: why?


**EXERCISES**:

Find an infinite eliminator E, that is a bird which eliminates all its variables: Ex = E, Exy = E, etc. Find an perpetual permutator, that is a bird which forever permutes its two inputs: its dynamics is as follow: Pxy =: Pyx =: Pxy =: Pyx etc. (I recall "=:" is the reduction symbol of the dynamics; it is the left to right reading of the "dynamics"). Etc. I mean: solve the following equations (little letters like x, y z are put for any combinator, A is put for the precise combinator we are ask searching for):

	Ax = A
	Ax = xA
	Axy = Ayx
	Ax = AAx
	A = AA
	Ax = AA
	Ax = x(Ax)

Obviously, Y is useful for the recursive programming. This will be illustrate when when we will do some logic and some arithmetic (soon on a screen near you). After that you should be able to program any function with a combinator. And after that we will make a move enabling us to come back to our basic problems: where does mind and matter come from, ..., how to put a reasonable measure on the set of all computations, ...

Summary:

1. [COMBINATORS I](http://www.mail-archive.com/everything-list@eskimo.com/msg05920.html)
2. [COMBINATORS II](http://www.mail-archive.com/everything-list@eskimo.com/msg05949.html)
3. [COMBINATORS III](http://www.mail-archive.com/everything-list@eskimo.com/msg05953.html)
4. [COMBINATORS IV](http://www.mail-archive.com/everything-list@eskimo.com/msg05954.html)
5. [COMBINATORS V](http://www.mail-archive.com/everything-list@eskimo.com/msg05955.html)
6. [COMBINATORS VI](http://www.mail-archive.com/everything-list@eskimo.com/msg05957.html)
7. [COMBINATORS VIII](http://www.mail-archive.com/everything-list@eskimo.com/msg05959.html)

(There is no VII, to the best of my knowledge, it was combined with VI.) Also:

* abc abbreviates ((a b) c)
* Kxy = x 
* Sxyz = xz(yz)
* Combinators combine.

Bruno

*(c) 2005-2008, Bruno Marchal.*

---

*If you enjoyed Bruno's posts, may I suggest a few of my own explaining some Ruby programming ideas in terms of combinators?*

[Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-10-29/kestrel.markdown#readme), [The Thrush](http://github.com/raganwald/homoiconic/tree/master/2008-10-30/thrush.markdown#readme), [Songs of the Cardinal](http://github.com/raganwald/homoiconic/tree/master/2008-10-31/songs_of_the_cardinal.markdown#readme), [Quirky Birds and Meta-Syntactic Programming](http://github.com/raganwald/homoiconic/tree/master/2008-11-04/quirky_birds_and_meta_syntactic_programming.markdown#readme), [Aspect-Oriented Programming in Ruby using Combinator Birds](http://github.com/raganwald/homoiconic/tree/master/2008-11-07/from_birds_that_compose_to_method_advice.markdown#readme), and [The Enchaining and Obdurate Kestrels](http://github.com/raganwald/homoiconic/tree/master/2008-11-12/the_obdurate_kestrel.md#readme).

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