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

def rotate(square)
  if square.kind_of?(Enumerable) && square.size > 1
    half_sz = square.size / 2
    sub_square = lambda do |row, col|
      square.slice(row, half_sz).map { |a_row|a_row.slice(col, half_sz) }
    end
    upper_left = rotate(sub_square.call(0,0))
    lower_left = rotate(sub_square.call(half_sz,0))
    upper_right = rotate(sub_square.call(0,half_sz))
    lower_right = rotate(sub_square.call(half_sz,half_sz))
    upper_right.zip(lower_right).map { |l,r| l + r } +
      upper_left.zip(lower_left).map { |l,r| l + r }
  else
    square
  end
end

p rotate([[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,16]])

public

def rotate_2(value)
  if rotate_divisible?(value)
    rotate_recombine(
      rotate_divide(value).map { |sub_value| rotate_2(sub_value) }
    )
  else
    rotate_conquer(value)
  end
end

private

def rotate_divisible?(value)
  value.kind_of?(Enumerable) && value.size > 1
end

def rotate_conquer(value)
  value
end

def rotate_divide(value)
  half_sz = value.size / 2
  sub_square = lambda do |row, col|
    value.slice(row, half_sz).map { |a_row| a_row.slice(col, half_sz) }
  end
  upper_left = sub_square.call(0,0)
  lower_left = sub_square.call(half_sz,0)
  upper_right = sub_square.call(0,half_sz)
  lower_right = sub_square.call(half_sz,half_sz)
  [upper_left, lower_left, upper_right, lower_right]
end

def rotate_recombine(values)
  upper_left, lower_left, upper_right, lower_right = values
  upper_right.zip(lower_right).map { |l,r| l + r } +
  upper_left.zip(lower_left).map { |l,r| l + r }
end

p rotate_2([[1,2,3,4], [5,6,7,8], [9,10,11,12], [13,14,15,16]])