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
# The above Copyright notice and this permission notice shall be included in
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

module Fibonacci
  
  Matrix = Struct.new(:a, :b, :c) do
    
    alias :d :a
    alias :e :b
    alias :f :c
    
    def * other
      Matrix.new(
        self.a * other.d + self.b * other.e, 
        self.a * other.e + self.b * other.f,
        self.b * other.e + self.c * other.f
      )
    end
    
    def ^ n
      if n == 1
        self
      elsif n == 2
        self * self
      elsif n > 2
        if n % 2 == 0
          self ^ (n / 2) ^ 2
        else
          (self ^ (n / 2) ^ 2) * self
        end
      end
    end
    
  end
  
  def self.[] n
    return n if n < 2
    (Matrix.new(1,1,0) ^ (n - 1)).a
  end
  
end

(0..20).map { |n| Fibonacci[n] } # => [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765]

start = Time.now
Fibonacci[100000]
x = (Time.now - start) # => 0.321296
