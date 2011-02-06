Misadventure, Part IV: Class Loading
===

*Misadventure is a little game written on top of Faux and Backbone.js*

**introduction**

[Misadventure][play] is a little game in the style of [Adventure][a]. Misadventure is written in Javascript and runs entirely in the browser. Misadventure is written in standard Model-View-Controller style, making heavy use of the [Faux][f] and [Backbone.js][b] libraries. In this series of posts I will give you a tour of Misadventure's [code][source], showing how it uses Faux to structure its routes and templates as well as how it uses Backbone.js to organize its models and interactive view code.

<a target="_blank" href="http://min.us/mvkEt6y#1"><img src="http://i.min.us/jeaApo.png" border="0"/></a>

This is Part IV, wherein we'll do a double-take and talk about loading classes. In [Part I][pi], we had an introduction to the game and its controller, and in [Part II][pii], we looked at controller methods and a simple view-free template. In [Part III][piii], we dived into controller methods that wire models, collections, views, and templates together with a look at `controller.location(...)`

index.html
---

Let's flash back to [index.html][index]: `index.html` contains the web page you see when you open Misadventure for the first time. Here's the source:

    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>Misadventure</title>
        <meta charset="utf-8">
        <link href="./stylesheets/application.css" rel="stylesheet">
        <!-- hard requirements for Faux -->
        <script src="./javascripts/vendor/jquery.1.4.2.js"></script>
        <script src="./javascripts/vendor/async.js"></script>
        <script src="./javascripts/vendor/documentcloud/underscore.js"></script>
        <script src="./javascripts/vendor/documentcloud/backbone.js"></script>
        <script src="./javascripts/vendor/haml-js.js"></script>
        <!-- fixes for using haml-js with IE -->
        <script src="./javascripts/vendor/ie.js"></script>
        <!-- Faux -->
        <script src="./javascripts/vendor/faux.js"></script>
        <!-- other libraries we happen to like -->
        <script src="./javascripts/vendor/seedrandom.js"></script>
        <script src="./javascripts/vendor/functional/to-function.js"></script>
        <script src="./javascripts/vendor/jquery.combinators.js"></script>
        <script src="./javascripts/vendor/jquery.predicates.js"></script>
        <!--misadventure's controller -->
        <script src="./javascripts/controller.js"></script>
      </head>
  
      <body>
    
        <div id="container">
          <h1>Misadventure</h1>
          <div class="content"></div>
  
        </div>    
    
        <small id="get-code">Read about Misadventure and browse the code on <a href="http://github.com/unspace/misadventure">Github</a>.</small>
  
      </body>

      <!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.

      To the extent possible under law, Unspace Interactive has waived all copyright 
      and related or neighboring rights to the software, except for those portions
      that are otherwise licensed.

      This work is published from Canada. -->

    </html>

You'll notice we load exactly one file for Misdaventure itself, [controller.js][cjs]. We've read about the controller, that's fine. But we've also read about some other backbone classes in the application like `Location`, `LocationCollection`, `LocationView`, and `BedView`. Where are they?

The answer is that `Location`, `LocationCollection`, and `LocationView` are in the file [location.js][ljs], and `BedView` is in the file [bed_view.js][bvjs], which Faux loaded for us. But we haven't loaded these Javascript files. How does Faux know to load them?

loading javascript by convention
---

Faux is able to load Javascript files automatically, provided they are named appropriately. Faux may try to load a Javascript file if it is looking for a class but that class hasn't been defined. Let's say Faux is looking for a class named `WunderBar` while defining a method named `show_bar`. Faux's rules are:

1. If there is a class named `WunderBar`, use it.
2. If there is no class named `WunderBar`, but there is a file named `show_bar.js`, load that file.
3. If there is no a file named `show_bar.js`, or there is a file but loading it doesn't define a class named `WunderBar`, look for a file named `wunder_bar.js` and load it.

Misadventure takes advantage of two of these rules to demonstrate how they work. There is a file named `location.js`, so Faux loads it when defining `controller.location(...)`. There is no file named `wake.js` or `wake_view` or anything else like that, so Faux doesn't find any classes associated with `controller.wake()`. There is no file named `bed.js`, but there is a file named `bed_view.js`, so Faux is able to load it and define the `BedView` class.

**loading javascript by configuration**

Perhaps you want to put all your views in a file named `view.js` and your models in a file named `models.js` and you don't want dozens of little files in your project. No problem, simply use HTML or perhaps `jQuery.getScript(...)` to explicitly load the files you want to use.

**summary**

If you place your classes in files named after your methods or after the classes themselves, Faux will load them for you and save you the trouble of explicitly loading every file.


[index]: http://github.com/unspace/misadventure/tree/master/index.html
[js]: http://github.com/unspace/misadventure/tree/master/javascripts
[pi]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_i.md#readme
[pii]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_ii.md#readme
[piii]: http://github.com/raganwald/homoiconic/tree/master/2011/01/misadventure_part_iii.md#readme
[piv]: http://github.com/raganwald/homoiconic/tree/master/2011/02/misadventure_part_iv.md#readme
[cjs]: http://unspace.github.com/misadventure/docs/controller.html