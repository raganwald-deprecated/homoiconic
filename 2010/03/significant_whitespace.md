Significant Whitespace
======================

I've always been a big fan of JavaScript's good parts. But for various reasons, I "disappeared myself" whenever the subject of writing DOM manipulation browser code came up in a project. Sure, I did some interesting things with JavaScript, like a complex form with dynamic field generation and a validation engine that ran in the browser and on the server using Rhino. (Would you believe there was nitpicking over whether this was "J2EE-compliant?") But overall, I must admit that I've not liked dealing with browser quirks and fussing with the DOM.

But times change and we must change with them. So I decided it was time to get off the couch and embrace the DOM. My latest hobby project is a small [Goban program](http://github.com/raganwald/wood_and_stones "Wood & Stones") written for Mobile Safari on the iPad. I'm trying to really use JavaScript to give the game play more of an app feel than a web page feel. That seemed to require a little more oomph than Prototype supplies, especially since I have no particular interest in making my JavaScript behave more "class-like." I went in search of a new library to learn.

The word on the street was that there were a bunch of powerful JavaScript libraries kicking around, but the one thing I consistently heard about John Resig's [jQuery](http://jquery.com/ "jQuery: The Write Less, Do More, JavaScript Library") was that it "Changes the way you think about programming." And while I am far from done learning new things, I will admit that I have been provoked into wondering whether significant whitespace could be a really good thing.

Let me show you what I am thinking about. One of jQuery's consistent styles is for most 'methods' to return the receiver, which allows you to chain method calls. For example:

    message_dialog_instance
      .text(text)
      .dialog({...})
      .dialog('open');

This code invokes `text` once and `dialog` twice on `message_dialog_instance`. In JavaScript, it's exactly the same as writing:

    message_dialog_instance.text(text).dialog({...}).dialog('open');
    
This works because each method does something to its receiver and then returns the receiver so you can invoke another method on it. That's way nicer than writing:

    message_dialog_instance.text(text)
    message_dialog_instance.dialog({...})
    message_dialog_instance.dialog('open');
    
Since DOM manipulation is all about side effects, this is a common case, and jQuery makes it easy. Of course, not all jQuery methods return their receiver. There are a number of selection methods that traverse, filter, or otherwise modify a selection of DOM nodes you want to manipulate. For example:

    $(event.target).parents('body > *').find('.wants_close').trigger(event);
          
This code takes the target of an event, rises up in the DOM to the immediate child of the body, does a find for all nodes with the class `wants_close`, then finally triggers the event on all of those nodes. It's used to allow gestures like drawing an "X" to be drawn anywhere on the screen and nodes like a dialog or text bubble can choose to handle the event by hiding themselves. (This may be a terrible design, I'm working this out for myself without studying code written by experienced jQuery developers. Don't make my mistake!)

Anyhoo, the point is that `parents` and `find` do not return the receiver. To keep the logic clear I've been using the following style guideline: When I'm returning the receiver, I do not indent. So as you saw above:

    message_dialog_instance
      .text(text)
      .dialog({...})
      .dialog('open');
      
When I return something else, I increase the level of indent:

    $(event.target)
      .parents('body > *')
        .find('.wants_close')
          .trigger(event);
          
I combine the two for the simplest case of refining a selection and then doing more than one thing with it:

    $(selector)
      .find('.board')
        .bind('gesture_left', function (event) {
            return forwards_in_time(this);
          })
        .bind('gesture_right', function (event) {
            return backwards_in_time(this);
          })
        .bind('gesture_close', function (event) {
            return clear_current_play(this);
          })

But more complex cases require breaking the method invocations up:

    var move_data = $('body').data('moves')[target_move_number];
    var next_move = memoized_move(target_move_number + 1);
    var this_move = next_move
      .clone(true)
      .removeClass()
      .addClass('move')
      .attr('id', id_by_move_number(target_move_number))
      .data('number', target_move_number)
      .data('player', move_data.player)
      .data('position', move_data.position)
      .data('removed', move_data.removed);
    this_move
      .find('.toolbar h1 .playing')
        .text('Move ' + target_move_number)
        .removeClass()
        .addClass('playing');
    this_move
      .find('.board .valid')
        .removeClass('valid');
    this_move
      .find('h1 .gravatar')
        .empty();
    this_move
      .find('.toolbar #heyButton')
        .attr('src', '/images/tools/empty-text-green.png');

I don't like this. What I want is to write these methods just like I write my [haml](http://haml-lang.com/) and especially [sass](http://sass-lang.com/ "Sass - Syntactically Awesome Stylesheets") code (Thank you [Hamp](http://hamptoncatlin.com/ "Hampton Catlin | Ruby, Haml, Wikipedia, iPhone Development")!). I'd like to write something like:

    var move_data = $('body').data('moves')[target_move_number];
    var next_move = memoized_move(target_move_number + 1);
    next_move
      .clone(true)
      .removeClass()
      .addClass('move')
      .attr('id', id_by_move_number(target_move_number))
      .data('number', target_move_number)
      .data('player', move_data.player)
      .data('position', move_data.position)
      .data('removed', move_data.removed)
      .find('.toolbar h1 .playing')
        .text('Move ' + target_move_number)
        .removeClass()
        .addClass('playing')
      .find('.board .valid')
        .removeClass('valid')
      .find('h1 .gravatar')
        .empty()
      .find('.toolbar #heyButton')
        .attr('src', '/images/tools/empty-text-green.png');

In other words, I want JavaScript to know that when I have multiple invocations at the same level of indentation, I am invoking them on the same receiver. When I indent one more level, I am invoking them on the result of the last method invocation.

As I found out after publishing an earlier version of this post, jQuery does provide some help in the form of [end()](http://api.jquery.com/end). End "undoes" a selection method, restoring the previous selection. So I can now rewrite my code like this:

    var move_data = $('body').data('moves')[target_move_number];
    var next_move = memoized_move(target_move_number + 1);
    next_move
      .clone(true)
      .removeClass()
      .addClass('move')
      .attr('id', id_by_move_number(target_move_number))
      .data('number', target_move_number)
      .data('player', move_data.player)
      .data('position', move_data.position)
      .data('removed', move_data.removed)
      .find('.toolbar h1 .playing')
        .text('Move ' + target_move_number)
        .removeClass()
        .addClass('playing')
        .end()
      .find('.board .valid')
        .removeClass('valid')
        .end()
      .find('h1 .gravatar')
        .empty()
        .end()
      .find('.toolbar #heyButton')
        .attr('src', '/images/tools/empty-text-green.png')
        .end()
      .end();

This isn't exactly what I want but I'll take it. The final two calls to `end` are unnecessary, but they do make it more consistent and if you re-arrange to code a little you're less likely to omit one.

It may seem like perhaps I should break this up into smaller methods to make it easier to understand. I am thinking that we want to break long functions up into short functions *because our languages don't give us a good way to express a verbose idea clearly in a single function*. We are not talking about 20+ lines of conditional execution here, we are talking about manipulating something that can naturally be expressed as a tree. Why not express the idea in code that looks like a tree?

I like [writing programs for people to read](http://raganwald.com/2007/04/writing-programs-for-people-to-read.html). Code that resembles what it consumes (sass), what it produces (haml), or what it manipulates (my hypothetical significant whitespace variation of JavaScript) is easy to read.

As it happens, [the last time I asked about a language feature](http://github.com/raganwald/homoiconic/blob/master/2010/01/beautiful_failure.markdown "Beautiful Failure"), I was told that Smalltalk did it in 1981. Well, this time I happen to know that Smalltalk already does this. In Smalltalk, you can write:

    | window |
      window := Window new.
      window label: 'Hello'.
      window open

Or you can write:

    Window new
      label: 'Hello';
      open
      
The semicolon allows you to send multiple messages to the same receiver. I know that Smalltalk code is often more readable with the liberal use of semicolons. I'm now of the opinion that a lot of other languages could use a similar mechanism, generalized to allow arbitrary trees of message invocations.

I admire John Resig for making a smart API design choice that enables me to write code that is more elegant. But I would like a language that gives me a mechanism where the programmer using a method decides how to write her code. In other words, this design choice should be in the programmer's hands, not the API designer's hands. I have some other reasons for wanting this in the language that have to do with destructuring assignment, pattern matching, and other uses for code that looks like the data it manipulates.

For now, I'm settling for `end()`.

----

New for 2011: "[Sans Titre](https://github.com/raganwald/homoiconic/blob/master/2011/11/sans-titre.md#readme)."
  
NEW! [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators), all of my writing about combinators, collected into one conevnient and inexpensive e-book!

---

(Spot a bug or a spelling mistake? This is a Github repo, fork it and send me a pull request!)

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)