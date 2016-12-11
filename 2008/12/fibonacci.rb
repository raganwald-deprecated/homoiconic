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

class Integer

  def iter_fib
    return self if self < 2
    oldest, newest = 1, 1
    (self-2).times do
      oldest, newest = newest, oldest + newest
    end
    newest
  end
  
  include(Module.new do
    
    times = lambda do |*ems|
      ems.inject do |product, matrix|
      	a,b,c = product; d,e,f = matrix
      	[a*d + b*e, a*e + b*f, b*e + c*f]
      end
    end
    
    power = lambda do |m, n|
      if n == 1
        m
      else
        halves = power.call(m, n / 2)
        if n % 2 == 0
          times.call(halves, halves)
        else
          times.call(halves, halves, m)
        end
      end
    end
    
    define_method :matrix_fib do
      return self if self < 2
      power.call([1,1,0], self - 1).first
    end
    
  end)
  
  include(Module.new do
  
    fibonacci_cache = Hash.new do |hash, key|
      subkey = key.div(2)
      case key.modulo(4)
        when 1
          hash[key] = (2*hash[subkey] + hash[subkey - 1])*(2*hash[subkey] -
  hash[subkey - 1]) + 2
        when 3
          hash[key] = (2*hash[subkey] + hash[subkey - 1])*(2*hash[subkey] -
  hash[subkey - 1]) - 2
        else
          hash[key] = hash[subkey] * (hash[subkey] + 2*hash[subkey - 1])
      end
    end
    fibonacci_cache[0] = 0
    fibonacci_cache[1] = 1

    define_method :fast_fib do
      return fibonacci_cache[self]
    end
    
  end)
  
end

(0..20).map { |n| n.matrix_fib } # => [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765]

start = Time.now
1000000.iter_fib
Time.now - start # 301.944032

start = Time.now
1000000.matrix_fib
Time.now - start # 30.70117

start = Time.now
1000000.fast_fib
Time.now - start # 6.692861