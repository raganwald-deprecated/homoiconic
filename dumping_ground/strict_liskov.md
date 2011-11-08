Strict Liskov Equivalence
===

The strict interpretation of the Liskov Equivalence principle is the notion that if we say that "Every B is-an-a A," we imply that *anywhere* an A is valid, you could replace the A with a B and the program would still be correct. Some of the implications of Strict Liskov Equivalence are:

* Specialization through exceptions are prohibited. If you say that birds can fly, you cannot have a Penguin that is-a Bird except that it cannot fly. You must re-arrange your type hierarchy such that the class Bird says nothing about flight and perhaps you have FlightedBird and FlightlessBird as sub-types of Bird.

* Narrowing specialization of method parameters, *including initialization parameters*, are prohibited. Widening specialization is allowed. For example, if you may initialize a new bird with a weight between 1 gram and 100 kilograms, you cannot create a penguin that can only be initialized with a weight between 1 and 3 kilograms. This is because you could have some code somewhere that initializes a new Bird with a weight of 100 kilograms, and it would fail if it attempted to initialize a new Penguin.

* Widening specialization of method results is prohibited. Narrowing specialization of method results is permitted.

* Narrowing specialization of state is prohibited. Meaning, if a Penguin is-a Bird, for every valid Bird object there must be a valid Penguin object that is indistinguishable from the valid Bird object using Bird's interface. Consider the possibility that every Bird has a weight. If it is possible to create a Bird object and somehow get it into a state where calling #weight returns 100 kilograms, then it must likewise be valid to create a penguin object and get it into a state where calling #weight returns 100 kilograms as well.

  This does not mean that you cannot create a hierarchy where birds could weight from 1 gram to 100 kilograms, with some birds like the Ostrich weighing from 70 to 100 kilograms but others, such as Cuba's Bee Hummingbird weighing no more than 2 grams. However, Bird's interface cannot permit a Bird object to get into a state where its weight is 50 kilograms. That would mean that you could make an Ostrich weight 50 kilograms (too little) or likewise make a Bee Hummingbird weight 50 kilograms (much too much!).
  
  The solution is that if subtypes of Bird have different ranges in weight validity, the sub-types must manage the weight of a bird, not the Bird class itself.