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
  
  four_steps = lambda do |steps|
    if steps.length == 4
      steps.map { |step| step.to_proc }
    else
      named_params = steps.first
      [
        if named_params[:divisible?]
            divisible_q = named_params[:divisible?].to_proc
            lambda { |value| !divisible_q.call(value) }
          else
            named_params[:cond].to_proc
          end,
        (named_params[:conquer] || named_params[:then]).to_proc,
        (named_params[:divide] || named_params[:before]).to_proc,
        (named_params[:recombine] || named_params[:after]).to_proc
      ]
    end
  end

  multirec_recursor = lambda do |value, cond_proc, then_proc, before_proc, after_proc|
    if cond_proc.call(value)
      then_proc.call(value)
    else
      after_proc.call(
        before_proc.call(value).map do |sub_value|
           multirec_recursor.call(sub_value, cond_proc, then_proc, before_proc, after_proc)
        end
      )
    end
  end

  define_method :multirec do |value, *steps|
    multirec_recursor.call(value, *four_steps.call(steps))
  end
  
  define_method :linrec do |value, *steps|
    cond_proc, then_proc, before_proc, after_proc = four_steps.call(steps)
    trivial_parts, sub_problem = [], value
    while !cond_proc.call(sub_problem)
      trivial_part, sub_problem = before_proc.call(sub_problem)
      trivial_parts.unshift(trivial_part)
    end
    trivial_parts.unshift(then_proc.call(sub_problem))
    trivial_parts.inject { |recombined, trivial_part| after_proc.call(trivial_part, recombined) }
  end

  alias :divide_and_conquer :multirec
  alias :linear_recursion :linrec
  module_function :multirec, :divide_and_conquer, :linrec, :linear_recursion

end