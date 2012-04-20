# The confusing similarity between fat arrows and an infix comparator

Due to [popular demand][cs], in ES6 you will be able to write *either*:

    x >= x - 2
    
Or:

    x => x - 2
    
No doubt there will be some folks who complain that it would be confusing if these two similar expressions meant different things. After all, they look *almost* alike. By that logic, the following two statements should mean the same thing:

    x = y

And:

    y = x
    
Alas, that ship has sailed. Yet somehow, [a language that got this wrong helped us put men on the moon][fortran]. Of course, that may say more about the heroics of the programmers than it does about the brilliance of their tool. After all, the men into space were guided by slide rule and longhand calculations.

[fortran]: http://www.lahey.com/nl00apr.htm#Fortran_and_the_Space_Program
[cs]: http://coffeescript.org