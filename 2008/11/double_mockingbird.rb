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

m2 = lambda do |x|
  lambda do |y|
    x.call(y).call(x.call(y))
  end
end

conquer_or_divide_and_try_again = lambda do |conquer_if_divisible|
  lambda do |myself|
    lambda do |value|
      conquer_if_divisible.call(value) or begin
		  	recursor = myself.call(myself)
        value.map { |sub_value| recursor.call(sub_value) }.inject { |a, b| a + b }
      end
    end
  end
end

conquer_if_divisible = lambda do |value|
  value ** 2 unless value.kind_of?(Enumerable)
end

sum_the_squares = m2.call(conquer_or_divide_and_try_again).call(conquer_if_divisible)