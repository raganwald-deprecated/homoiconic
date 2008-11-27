# The MIT License
# 
# All contents Copyright (c) 2004-2008 Reginald Braithwaite
# <http://reginald.braythwayt.com>  except as otherwise noted.
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

module RecursiveCombinators
  
  separate_args = lambda do |args|
    if ![1,2,4,5].include?(args.length)
      raise ArgumentError
    elsif args.length <= 2
      steps = [:cond, :then, :before, :after].map { |k| args.first[k].to_proc }
      steps.push(args[1]) unless args[1].nil?
      steps
    else
      steps = args[0..3].map { |arg| arg.to_proc }
      steps.push(args[4]) unless args[4].nil?
      steps
    end
  end

  define_method :multirec do |*args|
    cond_proc, then_proc, before_proc, after_proc, optional_value = separate_args.call(args)
    worker_proc = lambda do |value|
      if cond_proc.call(value)
        then_proc.call(value)
      else
        after_proc.call(
          before_proc.call(value).map { |sub_value| worker_proc.call(sub_value) }
        )
      end
    end
    if optional_value.nil?
      worker_proc
    else
      worker_proc.call(optional_value)
    end
  end

  define_method :linrec do |*args|
    cond_proc, then_proc, before_proc, after_proc, optional_value = separate_args.call(args)
    worker_proc = lambda do |value|
      trivial_parts, sub_problem = [], value
      while !cond_proc.call(sub_problem)
        trivial_part, sub_problem = before_proc.call(sub_problem)
        trivial_parts.unshift(trivial_part)
      end
      trivial_parts.unshift(then_proc.call(sub_problem))
      trivial_parts.inject do |recombined, trivial_part|
        after_proc.call(trivial_part, recombined)
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