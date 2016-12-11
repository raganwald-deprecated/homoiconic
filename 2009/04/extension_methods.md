My Objection to Extension Methods
===

The other day I pushed an update to Rewrite Rails. The new functionality supports writing [extension methods](http://en.wikipedia.org/wiki/Extension_method "Extension method - Wikipedia, the free encyclopedia") in your Ruby on Rails projects ([documentation here](http://github.com/raganwald-deprecated/rewrite_rails/blob/master/doc/extension_methods.md#readme "Extension Methods in Rewrite Rails")). To grossly oversimplify, let's say you are writing some sort of scuba dive planning program, and you want to write things like:

    33.fsw.in_ata
    (4.5).ata.in_fsw

No doubt you were inspired by a popular web development framework. You could write something like this:

    module FeetSeawater
      def in_ata
        ata = self.to_f / 33.0
        ata.extend(AtmospheresAbsolute)
        ata
      end
      def in_ata
        self
      end
      def ata
        raise 'Logic error, you cannot take fsw and treat them as ata, use #in_ata to convert'
      end
    end
    
    module AtmospheresAbsolute
      def in_fsw
        fsw = self.to_f * 33.0
        fsw.extend(FeetSeawater)
        fsw
      end
      def in_ata
        self
      end
      def fsw
        raise 'Logic error, you cannot take atas and treat them as fsw, use #in_fsw to convert'
      end
    end
    
    module ScubaPlanner::CoreExtensions::Numeric::Conversions
      def fsw
        self.extend(FeetSeawater)
        self
      end
      def ata
        self.extend(AtmospheresAbsolute)
        self
      end
    end
    
    class Numeric
      include CoreExtensions::Numeric::ScubaPlanning
    end

Now you have the seeds of a little DSL for writing a scuba planning application. Have fun with m-values, compartments, bubble formation, gradients, and everything else that makes decompression a nerd's paradise :-)

The known problem with the approach above is that changes to the Numeric class are global. And by global, I mean really, really global. If somebody else writes a gem that implements #fsw or #ata for Numeric, you code is incompatible with their code. You really only need those changes for your code, but classic Ruby meta-programming forces you to make those changes for everybody.

Here are two questions to ask yourself:

* If you think it's a bad idea to write your application with global variables ($foo, $bar), why is it a good idea to write your application with global monkey-patches?
* If you think that it is a bad idea to write your application using global procedures and functions instead of encapsulating methods in classes, why is it a good idea to write your application with global monkey-patches?

[![Rumpole of the Bailey](http://github.com/raganwald/homoiconic/raw/master/2009-04-28/rumpole.jpg)](http://www.amazon.com/gp/product/014006768X?ie=UTF8&tag=raganwald001-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=014006768X "Rumpole of the Bailey") 

**So what about extension methods?**

By way of contrast, extension methods allow you to write something roughly like this:

    module ScubaPlanner
    
      module ExtensionMethods
    
        class Numeric
          def self.fsw(feet)
            feet.extend(FeetSeawater)
            feet
          end
          def self.ata(atmospheres)
            atmospheres.extend(AtmospheresAbsolute)
            atmospheres
          end
        end
      
      end

      module FeetSeawater
        def in_ata
          ata = self.to_f / 33.0
          ata.extend(AtmospheresAbsolute)
          ata
        end
        def in_ata
          self
        end
        def ata
          raise 'Logic error, you cannot take fsw and treat them as ata, use #in_ata to convert'
        end
      end
    
      module AtmospheresAbsolute
        def in_fsw
          fsw = self.to_f * 33.0
          fsw.extend(FeetSeawater)
          fsw
        end
        def in_ata
          self
        end
        def fsw
          raise 'Logic error, you cannot take atas and treat them as fsw, use #in_fsw to convert'
        end
      end
      
    end
    
Now any code *within* the ScubaPlanner module can write `33.fsw.in_ata` and it will work, but code outside of the ScubaPlanner module is unaffected. That code can have its own extension methods doing different things, or it can use monkey-patches, it doesn't matter.

Presto, the conflict is gone. So, why am I not boasting that I have cut Ruby's [Gordian Knot](http://en.wikipedia.org/wiki/Gordian_Knot "Gordian Knot - Wikipedia, the free encyclopedia")?

**DSLs and OOP are orthogonal approaches**

Regardless of whether we use monkey-patching or extension methods, what we have done is write a DSL. Let's look at how it works in OOP terms. The monkey-patching implementation looks OOP. You send the #fsw method to a Numeric and it returns something that knows about feet of seawater. So in a Scuba Planning application, numbers know how to convert themselves to feet of seawater and to atmospheres absolute.

I have previously said that I consider this highly suspect. Numeric is an *implementation* class, not a semantically valid class. If we think that a number ought to know how to do anything related to numbers, we seriously weaken one of the OOP principles I hold dear: [Single Responsibility](http://en.wikipedia.org/wiki/Single_responsibility_principle "Single responsibility principle - Wikipedia, the free encyclopedia"). A class ought to be responsible for one, clearly defined thing. Numerics know about basic arithmetic. Writing a #fsw method for Numeric takes the responsibility of creating a FeetSeawater object and stuffs it into Numeric.

And let's face it, you don't *really* think numbers know anything about Scuba, do you? It's just a case of thinking that the DSL reads more clearly writing `33.fsw` instead of `33.extend(FeetSeawater)` or `FeetSeawater.new(33)`. That's a win, and we don't need to pretend it's good OO to do it.

It's okay to like OOP, and it's okay to like DSLs. Sometimes good DSLs are also good OOP. Sometimes they aren't. I personally reconcile their differences by thinking that I want to *implement* a DSL with good OOP, but I don't necessarily want to write a DSL that actually *is* good OOP.

**The responsibility side of the coin** 

Let's take a different view. Instead of thinking of `33.fsw` as a DSL that isn't meant to be canonically good OOP, let's presume we are trying to write canonically good OOP. There are folks who think Numeric ought to be responsible for knowing about feet of seawater and days and minutes and (for all I know) gallons of pond water per hour. Let's look at it from their point of view.

So we want to have Numeric know how to convert itself to feet of seawater. This seems to do it:

    class Numeric
      def fsw
        self.extend(FeetSeawater)
        self
      end
      def ata
        self.extend(AtmospheresAbsolute)
        self
      end
    end
    
    33.respond_to?(:fsw)
      => true

At run time, there is a Numeric class and it knows about conversion to feet of sea water. If you have a Smalltalk-style inspector, your view of the Numeric class is fully reconciled with its behaviour. You can see the methods it implements and the code for each method. Life is good.

However. Ruby is not Smalltalk. In Smalltalk, you primarily interact with your code through the live inspectors at runtime. So there is one canoncial source of information about the Numeric class. Ruby is still very much a text file based language. If we write the above code and stick it in our Scuba Planning application, there are now multiple sources of information about the Numeric class: The standard library, the methods you added, the methods other gems or frameworks added, and anything else that happens at run time.

(In the above example, the code for Numeric#fsw is ephemeral: it is discarded after it is interpreted and cannot be recovered without [white magic](http://gilesbowkett.blogspot.com/2008/02/activerecord-ruby2ruby-this-is-where.html "Giles Bowkett: ActiveRecord & Ruby2Ruby: This Is Where The Magic Happens").)

If you are using Ruby on Rails, you could organize yourself so that the code for Numeric would be found in:

1.  The Standard library
2.  ActiveSupport::CoreExtensions::Numeric::Bytes
3.  ActiveSupport::CoreExtensions::Numeric::Conversions
4.  ActiveSupport::CoreExtensions::Numeric::Time
5.  ActiveSupport::CoreExtensions::Pathname::CleanWithin
6.  ScubaPlanner::CoreExtensions::Numeric::Conversions

So we are saying "Numeric is responsible for W and X and Y and Z and so forth," but we are also saying "We are dividing Numeric's responsibilities into separate chunks and putting each chunk in a separate place and then aggregating our chunks at runtime."

This is roughly the same as using composition and delegation. The Numeric class is no longer a nice, clean piece of OOP with a single well-understood responsibility. However, modules like ActiveSupport::CoreExtensions::Numeric::Bytes and ScubaPlanner::CoreExtensions::Numeric::Conversions each have a single, well-understood responsibility. Numeric is now a composite of responsibilities just like an ActiveRecord::Base instance that delegates most of its methods to related models.

This is a valid way to do things, provided you honestly think Numerics need to know about time and conversions to feet of seawater.  Things get interesting when you have cross-cutting concerns. For example, if you want conversions between six different classes (A, B, C, D, E, and F), each of the six classes has to know how to convert itself to the other five classes, creating a monster of coupling dependency at run time.

The solution for this is evident in the code samples above: By aggregating classes from modules, you can write (A, B, C, D, E, and F) without conversions and move the conversions into separate modules. This is the approach taken by the popular framework. If you are looking at the class at runtime, it is a confusing jumble of methods. For example:

    33.methods.sort
      => ["%", "&", "*", "**", "+", "+@", "-", "-@", "/", "<", "<<", "<=", "<=>", "==", "===", "=~", ">", ">=", ">>", "JSON", "[]", "^", "__id__", "__send__", "`", "abs", "acts_like?", "ago", "b64encode", "between?", "blank?", "breakpoint", "byte", "bytes", "ceil", "chr", "class", "class_eval", "clone", "coerce", "copy_instance_variables_from", "daemonize", "day", "days", "dclone", "debugger", "decode64", "decode_b", "deep_clone", "denominator", "display", "div", "divmod", "downto", "dup", "duplicable?", "enable_warnings", "encode64", "enum_for", "eql?", "equal?", "even?", "exabyte", "exabytes", "extend", "extend_with_included_modules_from", "extended_by", "floor", "fortnight", "fortnights", "freeze", "from_now", "frozen?", "gcd", "gcdlcm", "gigabyte", "gigabytes", "hash", "hour", "hours", "id", "id2name", "inspect", "instance_eval", "instance_exec", "instance_of?", "instance_values", "instance_variable_defined?", "instance_variable_get", "instance_variable_names", "instance_variable_set", "instance_variables", "integer?", "is_a?", "is_haml?", "j", "jj", "kilobyte", "kilobytes", "kind_of?", "lcm", "load_with_new_constant_marking", "megabyte", "megabytes", "metaclass", "method", "methods", "minute", "minutes", "modulo", "month", "months", "multiple_of?", "next", "nil?", "nonzero?", "numerator", "object_id", "odd?", "ordinalize", "petabyte", "petabytes", "power!", "prec", "prec_f", "prec_i", "present?", "pretty_inspect", "pretty_print", "pretty_print_cycle", "pretty_print_inspect", "pretty_print_instance_variables", "private_methods", "protected_methods", "public_methods", "quo", "rdiv", "remainder", "remove_subclasses_of", "require", "require_association", "require_dependency", "require_library_or_gem", "require_or_load", "respond_to?", "returning", "round", "rpower", "second", "seconds", "send", "silence_stderr", "silence_stream", "silence_warnings", "since", "singleton_method_added", "singleton_methods", "size", "step", "subclasses_of", "succ", "suppress", "taguri", "taguri=", "taint", "tainted?", "tap", "terabyte", "terabytes", "times", "to_a", "to_bn", "to_enum", "to_f", "to_i", "to_int", "to_json", "to_param", "to_query", "to_r", "to_s", "to_sym", "to_utc_offset_s", "to_yaml", "to_yaml_properties", "to_yaml_style", "truncate", "try", "type", "unloadable", "untaint", "until", "upto", "week", "weeks", "with_options", "xchr", "year", "years", "zero?", "|", "~"]
      
However, if you are looking at the *source code*, the methods are actually implemented by modules that have much more defined responsibilities:

    33.class.ancestors
      => [Fixnum, Integer, JSON::Ext::Generator::GeneratorMethods::Integer, ActiveSupport::CoreExtensions::Integer::Time, ActiveSupport::CoreExtensions::Integer::Inflections, ActiveSupport::CoreExtensions::Integer::EvenOdd, Precision, Numeric, ActiveSupport::CoreExtensions::Numeric::Conversions, ActiveSupport::CoreExtensions::Numeric::Bytes, ActiveSupport::CoreExtensions::Numeric::Time, Comparable, Object, JSON::Ext::Generator::GeneratorMethods::Object, PP::ObjectMixin, ActiveSupport::Dependencies::Loadable, InstanceExecMethods, Base64::Deprecated, Base64, Kernel]

So from a responsibility perspective, if you think of objects and classes in Ruby as being aggregates of modules that have well-defined single responsibilities, all is well with this approach. For most people, the only irritation about doing this is that with global scope for changes to Numeric, it all goes pear-shaped when applications start including lots of gems each of which is strongly opinionated about what to aggregate into the same shared global classes.

**Is responsibility all there is to OO?**

The principle we've discussed so far is the Single Responsibility Principle. Another of interest is Encapsulation. Encapsulation often reveals itself in an OO program though Polymorphism. If you send an #in\_ata method to an object and it might divide itself by 33 (feet of seawater) or 34 (feet of fresh water), you have polymorphism, and you have encapsulated the conversion in the object.

The monkey-patching approach above preserves this property of a program: We can easily write a FeetFreshWater module and add a #ffw method to Numeric so that we can handle fresh water dive plans as well as sea water dive plans. Code calling #in\_ata will never know the difference.

Polymorphism is an important property of OO programs, and polymorphism in Ruby comes from method calls.

**So what's wrong with Extension Methods?**

As discussed above, extension methods solve an implementation problem by allowing you to scope your extensions. However, they aren't real methods, they are syntactic sugar for helper methods. When you use an extension method to write this:

    33.fsw.in_ata

Rewrite Rails turns it into something roughly like this:

    ScubaPlanner::ExtensionMethods::Numeric.fsw(33).in_ata

The implementation leaks badly if you think of an extension method as a method:

    33.respond_to?(:fsw)
      => false
    Numeric.instance_methods.include?('fsw')
      => false

It also leaks very badly when you try to use polymorphism. This is true in Rewrite Rails, and it's also true in languages like C#. This is because at compile time/rewrite time, we don't know the exact class of the object. Rewrite Rails tries its best. For example, you could write something like:

    module ScubaPlanner
    
      module ExtensionMethods
    
        class Numeric
          def self.fsw(feet)
            feet.extend(FeetSeawater)
            feet
          end
          def self.ata(atmospheres)
            atmospheres.extend(AtmospheresAbsolute)
            atmospheres
          end
        end
    
        class String
          def self.fsw(feet)
            feet.to_f.extend(FeetSeawater)
            feet
          end
          def self.ata(atmospheres)
            atmospheres.to_f.extend(AtmospheresAbsolute)
            atmospheres
          end
        end
      
      end
      
Now when you write `foo.fsw`, RewriteRails goes wild:

    begin
      __1234567890__ = foo
      if __1234567890__.respond_to?(:ata)
        __1234567890__.ata
      elsif __1234567890__.kind_of?(Numeric)
        ScubaPlanner::ExtensionMethods::Numeric.ata(__1234567890__)
      elsif __1234567890__.kind_of?(String)
        ScubaPlanner::ExtensionMethods::String.ata(__1234567890__)
      else
        __1234567890__.ata
      end
        
Nice try, but even hand-waving over its gruesome appearance (old timers will remember when compilers were criticized for producing sub-optimal and unreadable code), this approach will break badly for inheritance hierarchies. An extension method really cannot emulate polymorphism.

An extension method isn't a tool for writing OO code, it's a tool for writing safe DSLs. With a DSL, you aren't pretending that `33.fsw.in_ata` says anything about the responsibilities of the Numeric class, you're just saying that it reads nicely for sharing with domain experts.

But if you want to write well-factored object-oriented code, an extension method is **not** the way to go. Either take your gem conflict lumps, or campaign for better scoping in the language.

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