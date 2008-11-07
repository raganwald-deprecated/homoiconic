# The MIT License
# 
# All contents Copyright (c) 2004-2008 Reginald Braithwaite
# <http://reginald.braythwayt.com>  except as otherwise noted.
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

# This code contains ideas snarfed from:
#
# http://github.com/up_the_irons/immutable/tree/master
# http://blog.jayfields.com/2006/12/ruby-alias-method-alternative.html
#
# And a heaping side of http://blog.grayproductions.net/articles/all_about_struct

module ComposableMethods 
  
  # Random ID changed at each interpreter load
  UNIQ = "_#{object_id}"
  
  Compositions = Struct.new(:before, :between, :after)
  
  module ClassMethods
    
    def __composed_methods__
      ancestral_composer = ancestors.detect { |ancestor| ancestor.instance_variable_defined?(:@__composed_methods__) }
      if ancestral_composer
        ancestral_composer.instance_variable_get(:@__composed_methods__)
      else
        @__composed_methods__ ||= Hash.new { |hash, method_sym| hash[method_sym] = ComposableMethods::Compositions.new([], self.instance_method(method_sym), []) }
      end
    end
    
    def before(method_sym, &block)
      old_method = self.instance_method(method_sym)
      __composed_methods__[method_sym].before << block
      __rebuild_method__(method_sym)
    end
    
    def after(method_sym, &block)
      old_method = self.instance_method(method_sym)
      __composed_methods__[method_sym].after << block
      __rebuild_method__(method_sym)
    end
    
    def method_added(method_sym)
      unless instance_variable_get("@#{UNIQ}_in_method_added")
        __safely__ do
          __composed_methods__[method_sym].between = self.instance_method(method_sym)
          @old_method_added and @old_method_added.call(method_sym)
          __rebuild_method__(method_sym)
        end
      end
    end
    
    def __rebuild_method__(method_sym)
      __safely__ do
        old_method = __composed_methods__[method_sym].between
        __composed_methods__[method_sym].before.each do |block|
          __before__(method_sym, old_method, block)
          old_method = self.instance_method(method_sym)
        end
        __composed_methods__[method_sym].after.each do |block|
          __after__(method_sym, old_method, block)
          old_method = self.instance_method(method_sym)
        end
      end
    end
    
    def __before__(method_sym, old_method, block)
      if old_method.arity == 0
        define_method(method_sym) do
          block.call
          old_method.bind(self).call
        end
      else
        define_method(method_sym) do |*params|
          old_method.bind(self).call(*block.call(*params))
        end
      end
    end 
    
    def __after__(method_sym, old_method, block)
      if old_method.arity == 0
        define_method(method_sym) do
          old_method.bind(self).call
          block.call
        end
      else
        define_method(method_sym) do |*params|
          block.call(*old_method.bind(self).call(*params))
        end
      end
    end 
    
    def __safely__
      was = instance_variable_get("@#{UNIQ}_in_method_added")
      begin
        instance_variable_set("@#{UNIQ}_in_method_added", true)
        yield
      ensure
        instance_variable_set("@#{UNIQ}_in_method_added", was)
      end 
    end
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.instance_variable_set("@#{UNIQ}_in_method_added", false)
    receiver.instance_variable_set(:@old_method_added, receiver.public_method_defined?(:method_added) && receiver.instance_method(:method_added))
  end
  
end

	class SuperFoo

	  def one_parameter(x)
	    x + 1
	  end
  
	end

	class Foo < SuperFoo

	  include ComposableMethods

	  after :one_parameter do |x|
	    x * 2
	  end

	end
	
	class Bar < Foo

	  def one_parameter(x)
	    x + 100
	  end
	  
  end

p Bar.new.one_parameter(1)