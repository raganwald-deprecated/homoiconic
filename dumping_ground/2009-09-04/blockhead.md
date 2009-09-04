Blockhead
===

I am a blockhead. Specifically, I like block-structured code. What is "Block Structured" code? Quite simply, block-structured code is structured as a tree. If block-structured code was written out in Ruby, it would look like a nested set of arrays: `["something", ["something", "else"], ["something", ["more", "complicated"]], "again"]`. It's a little easier to understand as an outline:

    root
      one
        one_a
        one_b
          one_b_eye
          one_b_eye_eye
          one_b_eye_eye_eye
          one_b_eye_vee
      two
      three
        three_a
        three_b
      four


his seems to be a matter of taste: Lots of very smart people strongly *dislike* block-structured code. They prefer what I would call "Highly Factored" code: code 