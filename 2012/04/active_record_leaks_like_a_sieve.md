# Captain Obvious says, "ActiveRecord Leaks Like a Sieve"

Well, not ActiveRecord itself, but rather the abstraction it presents. Today I had the pleasure of laughing at my PHP-using colleagues, who inhabit a world where `'9223372036854775807' == '9223372036854775808'`. I was wrong to laugh, because not minutes later I found myself trying to isolate some unexpected behaviour in Ruby on Rails.

Here's how to reproduce it. First, set up a plain jane vanilla rails project (Don't ask *me* how, I looked the other way, and when I looked back you needed to know all about Bundler and RVM and a bunch of other ways to reinvent the Virtual Machine wheel). Anyhow, when you've got that done:

```
[tryit] rails g scaffold SomeTable some_column:string
      invoke  active_record
      create    db/migrate/20120413010253_create_some_tables.rb
      create    app/models/some_table.rb
      invoke    test_unit
      create      test/unit/some_table_test.rb
      create      test/fixtures/some_tables.yml
       route  resources :some_tables
      invoke  scaffold_controller
      create    app/controllers/some_tables_controller.rb
      invoke    erb
      create      app/views/some_tables
      create      app/views/some_tables/index.html.erb
      create      app/views/some_tables/edit.html.erb
      create      app/views/some_tables/show.html.erb
      create      app/views/some_tables/new.html.erb
      create      app/views/some_tables/_form.html.erb
      invoke    test_unit
      create      test/functional/some_tables_controller_test.rb
      invoke    helper
      create      app/helpers/some_tables_helper.rb
      invoke      test_unit
      create        test/unit/helpers/some_tables_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/some_tables.js.coffee
      invoke    scss
      create      app/assets/stylesheets/some_tables.css.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.css.scss
[tryit] rake db:migrate
==  CreateSomeTables: migrating ===============================================
-- create_table(:some_tables)
   -> 0.0012s
==  CreateSomeTables: migrated (0.0013s) ======================================
[tryit] rails c
Loading development environment (Rails 3.2.3)
ruby-1.9.2-p290 :001 > SomeTable.create! some_column: 'ten'
   (0.0ms)  begin transaction
  SQL (59.4ms)  INSERT INTO "some_tables" ("created_at", "some_column", "updated_at") VALUES (?, ?, ?)  [["created_at", Fri, 13 Apr 2012 01:03:55 UTC +00:00], ["some_column", "ten"], ["updated_at", Fri, 13 Apr 2012 01:03:55 UTC +00:00]]
   (1.9ms)  commit transaction
 => #<SomeTable id: 1, some_column: "ten", created_at: "2012-04-13 01:03:55", updated_at: "2012-04-13 01:03:55"> 
ruby-1.9.2-p290 :002 > SomeTable.all
  SomeTable Load (0.2ms)  SELECT "some_tables".* FROM "some_tables" 
 => [#<SomeTable id: 1, some_column: "ten", created_at: "2012-04-13 01:03:55", updated_at: "2012-04-13 01:03:55">] 
ruby-1.9.2-p290 :003 > SomeTable.find(1)
  SomeTable Load (0.2ms)  SELECT "some_tables".* FROM "some_tables" WHERE "some_tables"."id" = ? LIMIT 1  [["id", 1]]
 => #<SomeTable id: 1, some_column: "ten", created_at: "2012-04-13 01:03:55", updated_at: "2012-04-13 01:03:55"> 
ruby-1.9.2-p290 :004 > SomeTable.find(10)
  SomeTable Load (0.1ms)  SELECT "some_tables".* FROM "some_tables" WHERE "some_tables"."id" = ? LIMIT 1  [["id", 10]]
ActiveRecord::RecordNotFound: Couldn't find SomeTable with id=10 ...
ruby-1.9.2-p290 :005 > SomeTable.find('1')
  SomeTable Load (0.1ms)  SELECT "some_tables".* FROM "some_tables" WHERE "some_tables"."id" = ? LIMIT 1  [["id", "1"]]
 => #<SomeTable id: 1, some_column: "ten", created_at: "2012-04-13 01:03:55", updated_at: "2012-04-13 01:03:55"> 
ruby-1.9.2-p290 :006 > SomeTable.find('1x')
  SomeTable Load (0.1ms)  SELECT "some_tables".* FROM "some_tables" WHERE "some_tables"."id" = ? LIMIT 1  [["id", "1x"]]
 => #<SomeTable id: 1, some_column: "ten", created_at: "2012-04-13 01:03:55", updated_at: "2012-04-13 01:03:55"> 
ruby-1.9.2-p290 :007 > SomeTable.find('10')
  SomeTable Load (0.1ms)  SELECT "some_tables".* FROM "some_tables" WHERE "some_tables"."id" = ? LIMIT 1  [["id", "10"]]
ActiveRecord::RecordNotFound: Couldn't find SomeTable with id=10 ...
```

**tl;dr**

Let me summarize. We have one record with an `id` of `1`. If we do a `.find`, we get the following:

`1`: Finds the record.  
`'1'`: Finds the record. Okay, I guess.  
`10`: Does not find the record.  
`'10'`: Does not find the record (one-zero).  
`'1x'`: Finds the record. WTF!  

Here's what api.rubyonrails.org has to say about `find by id`: "This can either be a specific id (1), a list of ids (1, 5, 6), or an array of ids ([5, 6, 10]). If no record can be found for all of the listed ids, then RecordNotFound will be raised." Nothing about coercing strings. It could be something trying to be helpful in ActiveRecord, or it could be SQL behaviour leaking through the abstraction. I don't care because I'm not supposed to care!

Oh well, another arbitrary "gotcha" that I'll just have to remember.

> “I consider that a man's brain originally is like a little empty attic, and you have to stock it with such furniture as you choose. A fool takes in all the lumber of every sort that he comes across, so that the knowledge which might be useful to him gets crowded out, or at best is jumbled up with a lot of other things, so that he has a difficulty in laying his hands upon it. Now the skillful workman is very careful indeed as to what he takes into his brain-attic. He will have nothing but the tools which may help him in doing his work, but of these he has a large assortment, and all in the most perfect order. It is a mistake to think that that little room has elastic walls and can distend to any extent. Depend upon it there comes a time when for every addition of knowledge you forget something that you knew before. It is of the highest importance, therefore, not to have useless facts elbowing out the useful ones.”—Sir Arthur Conan Doyle, *A Study in Scarlet*

---

Recent work:

* [Kestrels, Quirky Birds, and Hopeless Egocentricity](http://leanpub.com/combinators) and my [other books](http://leanpub.com/u/raganwald).
* [Cafe au Life](http://recursiveuniver.se), an implementation of Bill Gosper's HashLife in CoffeeScript in the "Williams Style."
* [Katy](http://github.com/raganwald/Katy), a library for writing fluent CoffeeScript and JavaScript using combinators.
* [YouAreDaChef](http://github.com/raganwald/YouAreDaChef), a library for writing method combinations for CoffeeScript and JavaScript projects.

---

[Reg Braithwaite](http://braythwayt.com) | [@raganwald](http://twitter.com/raganwald)