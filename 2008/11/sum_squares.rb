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

def sum_squares(value)
  if value.kind_of?(Enumerable)
    value.map do |sub_value|
      sum_squares(sub_value)
    end.inject() { |x,y| x + y }
  else
    value ** 2
  end
end

p sum_squares([1, 2, 3, [[4,5], 6], [[[7]]]])

public

def sum_squares_2(value)
  if sum_squares_divisible?(value)
    sum_squares_recombine(
      sum_squares_divide(value).map { |sub_value| sum_squares_2(sub_value) }
    )
  else
    sum_squares_conquer(value)
  end
end

private

def sum_squares_divisible?(value)
  value.kind_of?(Enumerable)
end

def sum_squares_conquer(value)
  value ** 2
end

def sum_squares_divide(value)
  value
end

def sum_squares_recombine(values)
  values.inject() { |x,y| x + y }
end

p sum_squares_2([1, 2, 3, [[4,5], 6], [[[7]]]])