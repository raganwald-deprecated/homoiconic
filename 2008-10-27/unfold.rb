# unfold.rb
#
# see Really simple anamorphisms in Ruby:
# http://weblog.raganwald.com/2007/11/really-simple-anamorphisms-in-ruby.html, and:
#
# Really useful anamorphisms in Ruby:
# http://weblog.raganwald.com/2007/11/really-useful-anamorphisms-in-ruby.html
#
# The MIT License
# 
# Copyright (c) 2007 Mobile Commons
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

class Object
  # unfold takes a "seed" argument and a incrementor. It returns an array. The first element of the array is the
  # seed, every subsequentelement is the result of applying the incrementor to the previous element.
  # so in pretentious quasi-math: result[n] = incrementor(result[n-1]).
  # the array ends when the incrementor returns nil, so unfold(0) { |n| n+1 } is a bad idea in Ruby
  # to add terminating conditions, use if not logic, because false does not terminate unfold.
  #
  # example: 10.unfold { |n| n-1 unless n == 1 }.inspect => [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  # example: 10.class.unfold(&:superclass).inspect => [Fixnum, Integer, Numeric, Object] # using Symbol#to_proc
  #
  # See also: NilClass#unfold
  def unfold options = {}, &incrementor
    return [] unless options[:while].nil? || options[:while].to_proc.call(self)
    transformed = options[:map] && options[:map].to_proc[self] || self
    return [transformed] if options[:to] && options[:to].to_proc.call(self)
    incrementor.call(self).unfold(options, &incrementor).unshift(transformed)
  end
end

class NilClass
  # See: Object#unfold
  def unfold options = {}, &incrementor
    []
  end
end