Why software estimates are garbage, why code is twice as difficult to read as it is to write, and other unintended consequences of \_\_\_\_\_
===

I have observed two phenomena in software development. I'm going to describe them both for you, and then I am going to explain why I think they're both manifestations of the same underlying dynamic.

The first phenomena is the utter failure of the "Throw it over the wall" style of software development. By this, I mean the idea that software can be developed on a kind of assembly line, with each station on the line consuming some sort of artefact and producing a different kind of artefact. The stations are staffed by different people or teams, thus the name "throw it over the wall," because there is a metaphorical wall between the stations, and there is distinct moment where one station has completed its work and "throws the artefact over the wall" to the next station.

> Disclaimer: "Throw it over the wall" is not synonymous with "Waterfall." Waterfall involves software being developed in distinct "phases," but it is silent on the subject of whether each phase is performed by a separate team. It can be helpful to think of "Throw it over the wall" as a particular _kind_ of waterfall development.

The two primary characteristics of throw it over the wall development are first, that the software is developed as a series of transformations of artefacts, and second, that each transformation is performed by a separate person or team. One of the simplest examples—and one that interest me greatly—is when one team analyzes the requirements, writes a specification, and then "throws the specification over the wall" to a different team of programmers to generate an estimate and perform the implementation.

**code is twice as difficult to read as it is to write**

* historical artefacts are accidental complexity
* no it isn't, really
* example: andand is difficult to read. why?
* need to understand the relationships and reasoning
* fallacy of the great rewrite http://www.joelonsoftware.com/articles/fog0000000069.html

See also:

* Software is not made of bricks