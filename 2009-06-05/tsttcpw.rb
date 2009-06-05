# The MIT License
# 
# All contents Copyright (c) 2004-2009 Reg Braithwaite except as otherwise noted.
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
#
# tsttcpw.rb
#
# See http://github.com/raganwald/homoiconic/blob/master/2009-06-05/tsttcpw.md#readme

    def test_suite(model_class)
      test0(model_class) rescue false
    end

    def test0(model_class)
      model = model_class.new(:name => 'Reginald')
      model.name == 'Reginald'
    end

    class Reginald
  
      def initialize(attributes)
      end
  
      def name
        'Reginald'
      end
  
    end

    test_suite(Reginald) # => true
    
    #----------
    
    def test_suite(model_class)
      test0(model_class) && test1(model_class) rescue false
    end

    def test1(model_class)
      model = model_class.new(:name => 'Braythwayt')
      model.name == 'Braythwayt'
    end

    class ReginaldBraythwayt
      
      attr_accessor :first_not_last
  
      def initialize(attributes)
        self.first_not_last = attributes[:name] == 'Reginald'
      end
      
      def name
        self.first_not_last ? 'Reginald' : 'Braythwayt'
      end
  
    end
    
    test_suite(Reginald) # => false
    test_suite(ReginaldBraythwayt) # => true

    class AnyName
      
      attr_accessor :name
      
      def initialize(attributes)
        self.name = attributes[:name]
      end
      
    end
    
    test_suite(AnyName) # => true
