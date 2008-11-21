

def SplitRecursiveFactorial( n)
  
    if ( n < 0 ) raise ArgumentError, "Factorial: n has to be >= 0, but was #{n}" 
    if ( n < 2 ) return 1 
     
    big_n = 1 
     
    p= 1 
    r= 1 
     
    h = 0 
    shift = 0 
    high = 1 
    log2n = int( Math.log( n )/Math.log( 2 ) ) 
  
    product = lambda do |inner_n|
      m = inner_n / 2 
      if ( m == 0 ) 
        big_n += 2
      elsif ( inner_n == 2 )
        ( big_n += 2 ) * ( big_n += 2 ) 
      else
        product.call( inner_n - m ) * product.call( m ) 
      end
    end 
     
    while( h != n ) 
    { 
        shift += h 
        h = n >> log2n-- 
        len= high 
        high = (( h & 1 ) == 1) ? h : (h - 1) 
        len = ( high - len ) / 2 
         
        if ( len > 0 ) 
        { 
            p *= product.call( len )  
            r *= p 
        } 
    } 
    r * Math.pow( 2, shift ) 
end