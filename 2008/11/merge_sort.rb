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

public

def merge_sort(list)
  divide_and_conquer(
    list,
    :divisible? => lambda { |list| list.length > 1 },
    :conquer    => lambda { |list| list },
    :divide     => lambda do |list|
      half_index = (list.length / 2) - 1
      [ list[0..half_index], list[(half_index + 1)..-1] ]
    end,
    :recombine  => lambda { |pair| merge_two_sorted_lists(pair.first, pair.last) }
  )
end

private

def merge_two_sorted_lists(*pair)
  divide_and_conquer(
    pair,
    :divisible? => lambda { |pair| !pair.first.empty? && !pair.last.empty? },
    :conquer => lambda do |pair|
      if pair.first.empty? && pair.last.empty?
        []
      elsif pair.first.empty?
        pair.last
      else
        pair.first
      end
    end,
    :divide => lambda do |pair|
      preceding, following = case pair.first.first <=> pair.last.first
        when -1: [pair.first, pair.last]
        when 0:  [pair.first, pair.last]
        when 1:  [pair.last, pair.first]
      end
      [
        [[preceding.first], []],
        [preceding[1..-1], following]
      ]
    end,
    :recombine => lambda { |pair| pair.first + pair.last }
  )
end

def divide_and_conquer(value, steps)
  if steps[:divisible?].call(value)
    steps[:recombine].call(
      steps[:divide].call(value).map { |sub_value| divide_and_conquer(sub_value, steps) }
    )
  else
    steps[:conquer].call(value)
  end
end

p merge_sort([8, 3, 10, 1, 9, 5, 7, 4, 6, 2])