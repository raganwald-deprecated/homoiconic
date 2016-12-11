# The MIT License
# 
# All contents Copyright (c) 2004-2009 Reg Braithwaite except as otherwise noted.
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
#
# all_yall.rb
#
# Adds #with_ids and #with named scopes to ActiveRecord. To use in Rails, place
# this file in config/initializers.
#
# #with is a replacement for #all. Since it is a named scope, it cleanly
# composed with other named scopes, because it returns a scope proxy instead
# of an array.
#
# #with_ids is a replacement for #find's by id mode. Since it is a named scope, it cleanly
# composed with other named scopes, because it returns a scope proxy instead
# of an array.
#
# See http://github.com/raganwald/homoiconic/blob/master/2009-05-20/surprising.md#readme

module ActiveRecord
  
  class Base
    
    named_scope :with_ids, lambda {|*ids|
      {:conditions => {:id => ids}}
    }

    named_scope :with, lambda {|*args|
      args.first || {}
    }

  end
  
end