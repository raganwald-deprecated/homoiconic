Homoiconic
===

* _n_ compile-run cycles such that metaprogramming affects the compile and is static during the run. And the _n_ cycles are strictly leveled such that the only think cycle _n_ can do is meta-program cycle _n_-1.
  * Generalize this: like smalltalk, eliminate all keywords, everything is a method and some methods take code as arguments, producing more code.
  * metaprogramming is strongly functional: code can't modify itself, changes are local and produce a copy of the code. Strongly functionl is not the right phrase. "Immutable" is the right phrase.
  Modified code can be eval'd
* metaprogramming is always local
* metaprogramming always tied to the debugger/stack such that we don't have the debugging problem. we aren't just writing a new program, we're reprogramming the interpreter