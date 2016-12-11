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

require 'rubygems'
require 'spec'

require File.expand_path(File.join(File.dirname(__FILE__), 'before_and_after_advice.rb'))

class Parent

  def one(x)
    x + 1
  end

  def two(x, y)
    x * y
  end

end

class Child < Parent
  include BeforeAndAfterAdvice
end

class Grandchild < Child
  include BeforeAndAfterAdvice
end

describe BeforeAndAfterAdvice do
  
  describe "before" do
    
    before(:each) do
      class Child
  
        before :one do |x|
          x * 2
        end
  
        before :two do |x, y|
          [x + y, x - y]
        end
      
      end
    end
    
    it "should handle a case with one parameter" do
      Child.new.one(5).should == 11
    end
    
    
    it "should handle a case with two parameters" do
      Child.new.two(3,1).should == 8
    end
    
  end
  
  describe "side-effects only" do
    
    before(:each) do
      class Child

    	  before :one, :two do ||
    	    # nothing
    	  end
	  
      end
    end
    
    it "should handle a case with one parameter" do
      Child.new.one(5).should == 6
    end
    
    
    it "should handle a case with two parameters" do
      Child.new.two(3,1).should == 3
    end
    
  end
  
  after(:each) do
    Child.reset_befores_and_afters :one, :two
    Grandchild.reset_befores_and_afters :one, :two
  end
  
end