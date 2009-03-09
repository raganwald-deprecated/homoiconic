# The MIT License
# 
# All contents Copyright (c) 2004-2008 Reg Braithwaite except as otherwise noted.
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

Array.class_eval do

  def ^ numbers_to_the_right
    Number.new(self, numbers_to_the_right.kind_of?(Array) ? numbers_to_the_right : [numbers_to_the_right])
  end

end

class Number < Struct.new(:numbers_to_my_left, :numbers_to_my_right)
  
  def not_to_the_left_of?(other)
    !numbers_to_my_right.any? { |right| other.not_to_the_left_of?(right) } and !other.numbers_to_my_left.any? { |left| left.not_to_the_left_of?(self) }
  end
  
  def not_to_the_right_of?(other)
    other.not_to_the_left_of?(self)
  end
  
  def valid?
    numbers_to_my_left.all? { |left| left.valid? } and
    numbers_to_my_right.all? { |right| right.valid? } and
    numbers_to_my_left.all? do |left|
      !numbers_to_my_right.any? do |right|
        left.not_to_the_left_of?(right)
      end
    end
  end
  
  def initialize(*args)
    super
    raise ArgumentError unless self.valid?
  end
  
  def == (other)
    other.kind_of?(Number) && not_to_the_left_of?(other) && not_to_the_right_of?(other)
  end
  
  def to_the_right_of?(other)
    not_to_the_left_of?(other) && !not_to_the_right_of?(other)
  end
  
  def to_the_left_of?(other)
    not_to_the_right_of?(other) && !not_to_the_left_of?(other)
  end
  
  def ^ numbers_to_the_right
    [self] ^ numbers_to_the_right
  end
  
  def + (other)
    (numbers_to_my_left.map { |left| left + other } | other.numbers_to_my_left.map { |left| left + self }) ^
      (numbers_to_my_right.map { |right| right + other } | other.numbers_to_my_right.map { |right| right + self })
  end
  
  def -@
    numbers_to_my_right.map { |r| -r } ^ numbers_to_my_left.map { |l| -l }
  end

  def inspect
    "(#{numbers_to_my_left.inspect}^#{numbers_to_my_right.inspect})"
  end

end
