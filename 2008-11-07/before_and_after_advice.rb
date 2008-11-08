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
# http://eigenclass.org/hiki.rb?bounded+space+instance_exec
#
# And a heaping side of http://blog.grayproductions.net/articles/all_about_struct

module BeforeAndAfterAdvice 
  
  # Random ID changed at each interpreter load
  UNIQ = "_#{object_id}"
  
  Compositions = Struct.new(:before, :between, :after)
  
  module InstanceExecHelper; end
  
  module InstanceMethods
    
    def instance_exec(*args, &block)
      begin
        old_critical, Thread.critical = Thread.critical, true
        n = 0
        n += 1 while respond_to?(mname="__instance_exec#{n}")
        InstanceExecHelper.module_eval{ define_method(mname, &block) }
      ensure
        Thread.critical = old_critical
      end
      begin
        ret = send(mname, *args)
      ensure
        InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
      end
      ret
    end
    
  end
  
  module ClassMethods
    
    def __composed_methods__
      ancestral_composer = ancestors.detect { |ancestor| ancestor.instance_variable_defined?(:@__composed_methods__) }
      if ancestral_composer
        ancestral_composer.instance_variable_get(:@__composed_methods__)
      else
        @__composed_methods__ ||= Hash.new { |hash, method_sym| hash[method_sym] = BeforeAndAfterAdvice::Compositions.new([], self.instance_method(method_sym), []) }
      end
    end
    
    def before(*method_symbols, &block)
      method_symbols.each do |method_sym|
        __composed_methods__[method_sym].before.unshift(block)
        __rebuild_method__(method_sym)
      end
    end
    
    def after(*method_symbols, &block)
      method_symbols.each do |method_sym|
        __composed_methods__[method_sym].after.push(block)
        __rebuild_method__(method_sym)
      end
    end
    
    def reset_befores_and_afters(*method_symbols)
      method_symbols.each do |method_sym|
        __composed_methods__[method_sym].before = []
        __composed_methods__[method_sym].after = []
        __rebuild_method__(method_sym)
      end
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
        composition = __composed_methods__[method_sym]
        old_method = composition.between
        if composition.before.empty? and composition.after.empty?
          if old_method.arity == 0
            define_method(method_sym) { old_method.bind(self).call }
          else
            define_method(method_sym) { |*params| old_method.bind(self).call(*params) }
          end
        else
          arity = old_method.arity
          if old_method.arity == 0
            define_method(method_sym) do
              composition.before.each do |block|
                self.instance_eval(&block)
              end
              composition.after.inject(old_method.bind(self).call) do |ret_val, block|
                self.instance_eval(&block)
              end
            end
          else
            define_method(method_sym) do |*params|
              composition.after.inject(
                old_method.bind(self).call(
                  *composition.before.inject(params) do |acc_params, block|
                    self.instance_exec(*acc_params, &block)
                  end
                )
              ) do |ret_val, block|
                self.instance_exec(ret_val, &block)
              end
            end
          end
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
    receiver.send :include, InstanceExecHelper
    receiver.send :include, InstanceMethods
    receiver.instance_variable_set("@#{UNIQ}_in_method_added", false)
    receiver.instance_variable_set(:@old_method_added, receiver.public_method_defined?(:method_added) && receiver.instance_method(:method_added))
  end
  
end