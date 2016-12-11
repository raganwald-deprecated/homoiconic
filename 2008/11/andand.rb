# The MIT License
# 
# All contents Copyright (c) 2004-2008 Reginald Braithwaite
# <http://braythwayt.com>  except as otherwise noted.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# http://www.opensource.org/licenses/mit-license.php

module AndAnd
  
  # This module is included in Object, so each of these methods are added
  # to Object when you require 'andand'. Each method is an *adverb*: they are
  # intended to be enchained with another method, such as receiver.adverb.method
  #
  # The purpose of an adverb is to modify what the primary method returns.
  #
  # Adverbs also take blocks or procs, passing the receiver as an argument to the
  # block or proc. They retain the same semantics with a block or proc as they
  # do with a method. This behaviour weakly resembles a monad.
  module ObjectGoodies
    
    # Returns nil if its receiver is nil, regardless of whether nil actually handles the
    # actual method ot what it might return. 
    #
    #    'foo'.andand.size => 3
    #    nil.andand.size => nil
    #    'foo'.andand { |s| s << 'bar' } => 'foobar'
    #    nil.andand { |s| s << 'bar' } => nil
    def andand (p = nil)
      if self
        if block_given?
          yield(self)
        elsif p
          p.to_proc.call(self)
        else
          self
        end
      else
        if block_given? or p
          self
        else
          MockReturningMe.new(self)
        end
      end 
    end

    # Invokes the method and returns the receiver if nothing is raised. Therefore,
    # the purpose of calling the method is strictly for side effects. In the block
    # form, it resembles #tap from Ruby 1.9, and is useful for debugging. It also
    # resembles #returning from Rails, with slightly different syntax.
    #
    #    Object.new.me do |o|
    #      def o.foo
    #        'foo'
    #      end
    #    end
    #      => your new object
    #
    # In the method form, it is handy for chaining methods that don't ordinarily
    # return the receiver:
    #
    #    [1, 2, 3, 4, 5].me.pop.reverse
    #      => [4, 3, 2, 1]
    def me (p = nil)
      if block_given?
        yield(self)
        self
      elsif p
        p.to_proc.call(self)
        self
      else
        ProxyReturningMe.new(self)
      end
    end
    
    unless Object.instance_methods.include?('tap')
      alias :tap :me
    end
    
    # Does not invoke the method or block and returns the receiver.
    # Useful for comemnting stuff out, especially if you are using #me for
    # debugging purposes: change the .me to .dont and the semantics of your
    # program are unchanged.
    #
    #    [1, 2, 3, 4, 5].me { |x| p x }
    #      => prints and returns the array
    #    [1, 2, 3, 4, 5].dont { |x| p x }
    #      => returns the array without printing it
    def dont (p = nil)
      if block_given?
        self
      elsif p
        self
      else
        MockReturningMe.new(self)
      end
    end
    
  end
  
end

class Object
  include AndAnd::ObjectGoodies
end
  
unless Module.constants.include?('BlankSlate')
  if Module.constants.include?('BasicObject')
    module AndAnd
      class BlankSlate < BasicObject
      end
    end
  else
    module AndAnd
      class BlankSlate
        def self.wipe
          instance_methods.reject { |m| m =~ /^__/ }.each { |m| undef_method m }
        end
        def initialize
          BlankSlate.wipe
        end
      end
    end
  end
end

module AndAnd
  
  # A proxy that returns its target without invoking the method you
  # invoke. Useful for nil.andand and #dont
  class MockReturningMe < BlankSlate
    def initialize(me)
      super()
      @me = me
    end
    def method_missing(*args)
      @me
    end
  end

  # A proxy that returns its target after invoking the method you
  # invoke. Useful for #me
  class ProxyReturningMe < BlankSlate
    def initialize(me)
      super()
      @me = me
    end
    def method_missing(sym, *args, &block)
      @me.__send__(sym, *args, &block)
      @me
    end
  end
  
end