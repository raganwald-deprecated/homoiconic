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

# This code contains ideas snarfed from:
#
# http://github.com/up_the_irons/immutable/tree/master
# http://blog.jayfields.com/2006/12/ruby-alias-method-alternative.html
#
# And a heaping side of http://blog.grayproductions.net/articles/all_about_struct

module NaiveBeforeAdvice

  module ClassMethods
  
    def before(method_sym, &block)
      old_method = self.instance_method(method_sym)
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
  
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
  end

end