In Gregory Chaiten [Meta Math! The Quest for Omega](http://www.amazon.com/gp/product/1400077974?ie=UTF8&amp;tag=raganwald001-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=1400077974), he gives his complexity-based proof there are an infinite number of primes. Consider this question: *For each number N, what is the smallest computer program required to print it out?* Although we can name many numbers that can be printed with extremely concise programs, e.g.

    puts '9' * 999

The simple fact is that there are infinitely many numbers that cannot be printed by such trivial means. In general, the smallest program that prints a number *N* looks like this:

    puts '19620614' # explicitly listing each digit
    
Given base ten notation, the size of the program to print *N* is roughly log*N*. So what about prime numbers? Well, we know that any number *N* can be expressed as a prime factorization, e.g. 19620614 can be expressed as 2^1 times 13^1 times 754639^1. If there are an infinite number of numbers *N* and an infinite number of primes, programs that look like this:

    puts '19620614'
    
And like this:

    2**1 * 13**1 * 754639**1

Will both require roughly log*N* characters to print any number *N*. But what if there are only a *finite* number of primes? Now things get interesting! The number of characters required to print any number *N* is now only loglog*N*, not log*N*. (Exercise for readers: Prove this is the case.)

    TODO: Prove this is a problem!