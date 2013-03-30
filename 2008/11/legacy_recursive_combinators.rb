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

module LegacyRecursiveCombinators

  def multirec(steps, optional_value = nil)
    worker_proc = lambda do |value|
      if steps[:cond].call(value)
        steps[:then].call(value)
      else
        steps[:after].call(
          steps[:before].call(value).map { |sub_value| worker_proc.call(sub_value) }
        )
      end
    end
    if optional_value.nil?
      worker_proc
    else
      worker_proc.call(optional_value)
    end
  end

  def linrec(steps, optional_value = nil)
    worker_proc = lambda do |value|
      if steps[:cond].call(value)
        steps[:then].call(value)
      else
        trivial_part, sub_problem = steps[:before].call(value)
        steps[:after].call(
          trivial_part, worker_proc.call(sub_problem)
        )
      end
    end
    if optional_value.nil?
      worker_proc
    else
      worker_proc.call(optional_value)
    end
  end

  module_function :multirec, :linrec

end