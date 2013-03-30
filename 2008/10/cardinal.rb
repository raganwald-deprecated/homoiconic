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
  
def cardinal_define(name, &proc_over_proc)
  define_method_taking_block(name) do |a_value, a_proc|
    proc_over_proc.call(a_proc).call(a_value)
  end
end

# method_body_proc should expect (a_value, a_proc)
# see http://coderrr.wordpress.com/2008/10/29/using-define_method-with-blocks-in-ruby-18/
def define_method_taking_block(name, &method_body_proc)
  self.class.send :define_method, "__cardinal_helper_#{name}__", method_body_proc
  eval <<-EOM
    def #{name}(a_value, &a_proc)
      __cardinal_helper_#{name}__(a_value, a_proc)
    end
  EOM
end