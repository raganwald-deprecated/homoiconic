module Kernel
  
  def inside(value, &block)
    value.instance_eval(&block)
    value
  end
  
end