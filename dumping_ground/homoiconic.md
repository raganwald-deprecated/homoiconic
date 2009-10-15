Homoiconic
===

* _n_ compile-run cycles such that metaprogramming affects the compile and is static during the run. And the _n_ cycles are strictly leveled such that the only think cycle _n_ can do is meta-program cycle _n_-1.
  * Generalize this: like smalltalk, eliminate all keywords, everything is a method and some methods take code as arguments, producing more code.
  * metaprogramming is strongly functional: code can't modify itself, changes are local and produce a copy of the code. Strongly functional is not the right phrase. "Immutable" is the right phrase.
  Modified code can be eval'd
* metaprogramming is always local
* metaprogramming always tied to the debugger/stack such that we don't have the debugging problem. we aren't just writing a new program, we're reprogramming the interpreter

Immutable Code
---

All code is "open to extension but closed to modification." This is especially true of classes. Every object in the system has an "extension class" similar to the eigenclass in Ruby. We enforce that extension classes can extend an object or class without modifying existing behaviour, likely though validations/contracts. So perhaps we mean "Open to extension but closed to modification modulo a test suite."

Local effects
---

Objects in Ruby have an eigenclass and a class. Objects in homoiconic have an extension class an a class. The trick is, the extension class is *always* local to the current scope. When the code is executed, all objects are looked up in the current scope, something like resolving a local variable in block scope.

Things like ActiveSupport and gems must then be imported into scopes to be used. It should work exactly like mixing a module into a class, just mixing extension classes into a scope.

Mixing In
---

Shadowing is always illegal, for the same reason that overriding is always illegal. We extend but we do not modify.

Extending a method
---

¿Methods can be extended but not modified, therefore traditional overriding is not allowed? --not sure, wondering whether validations handle this.

Validations and Examples
---

An example is an object held to be valid. Class validations always use validations for the class.

Validations in a superclass always apply to its subclasses, that's LSP. An example object in a superclass must be an example in a subclass. Therefore, an example in a subclass must extend an existing example in a superclass.

There is a many to many relationship between examples and class validations. The important idea is that a validation is run for every instance of its associated examples and the extended versions of those examples.

Local metasyntactic programming
---

Metasyntactic programming must be based on quotation transformation and evaluation. In essence, we must have transformations of programs as a first class operation. `begin` is really a form of `eval`.