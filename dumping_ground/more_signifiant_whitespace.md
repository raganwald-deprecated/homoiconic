Given `framework.use(Sammy.Haml)`, `framework` is a first class object. Why isn't `.use(Sammy.Haml)` a first class object? Using [Functional JavaScript](http://osteele.com/sources/javascript/functional/), you can kinda-sorta fake it with a string lambda, but there are scoping issues: `".use(Sammy.Haml)"` is equivalent to `function (_) { return _.use(Sammy.Haml); }`.

Implicit mapping is kind of interesting. Maybe a cascade is really a way of saying "apply this object to all of these functions. This implies widening and destructuring. So:

    foo
      .bar
      .baz
      .bash

Would be interpreted as "widen `foo` and apply it to each of these functions"

    foo
      .bar = 'bar'
      .bash = 'bash'
      
    foo
      [.bar, .bash] = ['bar', 'bash']

