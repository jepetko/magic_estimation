Magic Estimation
=============

# what is it?

http://campey.blogspot.co.at/2010/09/magic-estimation.html

# features

* product owner creates the backlog and the items
* every item is assigned to a team member
* the team member needs to estimate the assigned item initially
* another team members add their estimations to the item

# log-ins

* boss/boss (product owner)
* bob/bob (member)
* jeff/jeff (member)

# deployment procedure (heroku)

## create the application

katarina@leanetic:~/RubymineProjects/magic_estimation$ heroku create leanetic-magic-estimation --stack cedar --buildpack https://github.com/heroku/heroku-buildpack-ruby.git
Creating leanetic-magic-estimation... done, stack is cedar-10
Buildpack set. Next release on leanetic-magic-estimation will use https://github.com/heroku/heroku-buildpack-ruby.git.
https://leanetic-magic-estimation.herokuapp.com/ | https://git.heroku.com/leanetic-magic-estimation.git
Git remote heroku added


## deploy

Unfortunately, ```git push heroku master``` returns the following error:

```
Issue:

remote: -----> Writing config/database.yml to read from DATABASE_URL
remote: -----> Preparing app for Rails asset pipeline
remote:        Running: rake assets:precompile
remote:        rake aborted!
remote:        PG::ConnectionBad: could not connect to server: Connection refused
remote:        Is the server running on host "127.0.0.1" and accepting
remote:        TCP/IP connections on port 5432?
```

Note: these solutions are outdated:
* config.assets.initialize_on_precompile = false
* heroku labs:enable user-env-compile

Solution grabbed from (see next step):
* https://github.com/spree/spree/issues/3749

## add heroku-postgresql

This will return an environment variable.

```
katarina@leanetic:~/RubymineProjects/magic_estimation$ heroku addons:add heroku-postgresql
Adding heroku-postgresql on leanetic-magic-estimation... done, v4 (free)
Attached as HEROKU_POSTGRESQL_NAVY_URL
Database has been created and is available
 ! This database is empty. If upgrading, you can transfer
 ! data from another database with pgbackups:restore.
Use `heroku addons:docs heroku-postgresql` to view documentation.
```

## set the DATABASE_URL

```
katarina@leanetic:~/RubymineProjects/magic_estimation$ heroku pg:promote HEROKU_POSTGRESQL_NAVY_URL
Promoting HEROKU_POSTGRESQL_NAVY_URL (DATABASE_URL) to DATABASE_URL... done
```
## deploy

```
katarina@leanetic:~/RubymineProjects/magic_estimation$ git push heroku master
remote: Compressing source files... done.
remote: Building source:
remote:
remote: -----> Fetching custom git buildpack... done
remote: -----> Ruby app detected
remote: -----> Compiling Ruby/Rails
remote: -----> Using Ruby version: ruby-2.0.0
remote: -----> Installing dependencies using 1.7.12
remote:        Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin -j4 --deployment
remote:        Fetching gem metadata from https://rubygems.org/...........
remote:        Installing minitest 4.7.5
remote:        Installing i18n 0.7.0
remote:        Installing rake 10.4.2
remote:        Installing multi_json 1.11.0
remote:        Installing thread_safe 0.3.5
....
remote:        Depending on your version of ruby, you may need to install ruby rdoc/ri data:
remote:        <= 1.8.6 : unsupported
remote:        = 1.8.7 : gem install rdoc-data; rdoc-data --install
remote:        = 1.9.1 : gem install rdoc-data; rdoc-data --install
remote:        >= 1.9.2 : nothing to do! Yay!
remote:        Bundle completed (45.23s)
remote:        Cleaning up the bundler cache.
remote: -----> Writing config/database.yml to read from DATABASE_URL
remote: -----> Preparing app for Rails asset pipeline
remote:        Running: rake assets:precompile
remote:        I, [2015-04-07T19:46:45.711095 #1270]  INFO -- : Writing /tmp/build_c192bcc7f1c417cce9d573a48a3d0c7b/public/assets/application-849660e2b6e210c6c497a2d9e761cbbc.js
remote:        I, [2015-04-07T19:46:56.348429 #1270]  INFO -- : Writing /tmp/build_c192bcc7f1c417cce9d573a48a3d0c7b/public/assets/application-6177f782ba15c3632c2fc221d33ac348.css
remote:        I, [2015-04-07T19:46:56.354133 #1270]  INFO -- : Writing /tmp/build_c192bcc7f1c417cce9d573a48a3d0c7b/public/assets/bootstrap/glyphicons-halflings-regular-b21092b8fbcd707a1af4e5c491788a88.eot
remote:        I, [2015-04-07T19:46:56.354694 #1270]  INFO -- : Writing /tmp/build_c192bcc7f1c417cce9d573a48a3d0c7b/public/assets/bootstrap/glyphicons-halflings-regular-8b164394b83117e1127e17bef7c224b2.svg
remote:        I, [2015-04-07T19:46:56.355196 #1270]  INFO -- : Writing /tmp/build_c192bcc7f1c417cce9d573a48a3d0c7b/public/assets/bootstrap/glyphicons-halflings-regular-6957c4911ce71088e03af494952b72d3.ttf
remote:        I, [2015-04-07T19:46:56.355576 #1270]  INFO -- : Writing /tmp/build_c192bcc7f1c417cce9d573a48a3d0c7b/public/assets/bootstrap/glyphicons-halflings-regular-d100d875f8f41645831e9b982667dd40.woff
remote:        I, [2015-04-07T19:46:56.355934 #1270]  INFO -- : Writing /tmp/build_c192bcc7f1c417cce9d573a48a3d0c7b/public/assets/bootstrap/glyphicons-halflings-regular-5840366f483f32e8e39f6d867b9dccd3.woff2
remote:        Asset precompilation completed (22.59s)
remote:        Cleaning assets
remote:        Running: rake assets:clean
remote:
remote: ###### WARNING:
remote:        You have not declared a Ruby version in your Gemfile.
remote:        To set your Ruby version add this line to your Gemfile:
remote:        ruby '2.0.0'
remote:        # See https://devcenter.heroku.com/articles/ruby-versions for more information.
remote:
remote: ###### WARNING:
remote:        No Procfile detected, using the default web server (webrick)
remote:        https://devcenter.heroku.com/articles/ruby-default-web-server
remote:
remote: -----> Discovering process types
remote:        Procfile declares types -> (none)
remote:        Default types for Ruby  -> console, rake, web, worker
remote:
remote: -----> Compressing... done, 25.0MB
remote: -----> Launching... done, v6
remote:        https://leanetic-magic-estimation.herokuapp.com/ deployed to Heroku
remote:
remote:  !   Cedar-10 will reach end-of-life on November 4th, 2015.
remote:  !   Upgrade to Cedar-14 at your earliest convenience.
remote:  !   For more information, check out the following Dev Center article:
remote:  !   https://devcenter.heroku.com/articles/cedar-14-migration
remote:
remote: Verifying deploy.... done.
To https://git.heroku.com/leanetic-magic-estimation.git
 * [new branch]      master -> master
```

## run the migrations

```
katarina@leanetic:~/RubymineProjects/magic_estimation$ heroku run rake db:migrate
Running `rake db:migrate` attached to terminal... up, run.5492
Migrating to CreateUsers (20150317205618)
==  CreateUsers: migrating ====================================================
-- create_table(:users)
   -> 0.0133s
==  CreateUsers: migrated (0.0146s) ===========================================

Migrating to CreateBacklogs (20150317210134)
==  CreateBacklogs: migrating =================================================
-- create_table(:backlogs)
   -> 0.0144s
==  CreateBacklogs: migrated (0.0146s) ========================================

....
```

## run custom rake tasks

```
katarina@leanetic:~/RubymineProjects/magic_estimation$ heroku run rake db:create_story_points
Running `rake db:create_story_points` attached to terminal... up, run.3682
Story point 1 created.
Story point 2 created.
Story point 3 created.
Story point 5 created.
Story point 8 created.
Story point 13 created.
Story point 21 created.
Story point 34 created.
Story point 55 created.
Story point 89 created.

katarina@leanetic:~/RubymineProjects/magic_estimation$ heroku run rake db:create_default_users
Running `rake db:create_default_users` attached to terminal... up, run.6173
User boss (role: admin) created.
User bob (role: member) created.
User jeff (role: member) created.
```



