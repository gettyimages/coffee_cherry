
# CoffeeCherries

A RubyGems-ish Library Scheme for the Coffeescript World

## Introduction
---------------------------------------------------------------------------

I recently started coding single-page webapps using
[CoffeeScript](http://coffeescript.org/),
[Backbone.js](http://backbonejs.org/), [Brunch](http://brunch.io/),
and [CommonJS](http://www.commonjs.org/).  As soon as I started
creating code that belonged within multiple webapps, I found myself
looking for a [RubyGems](http://rubygems.org/) type of library
management scheme for Javascript.  Didn't have any luck so I cooked up
this CoffeeCherries project.

I wanted to be able to create standalone Javascript libraries using:

* Coffeescript as the source language
* Modular Java namespace control (CommonJS or AMD)
* [Docco](http://jashkenas.github.com/docco/)-based documentation
* A built-in test suite
* Standard locations for example files and helper scripts

I believe my CoffeeCherries idea appeals as a general concept.  What I
present here and now is a specific implementation of this idea as a
[Brunch
skeleton](http://brunch.readthedocs.org/en/latest/skeletons.html).

Brunch's behavior is governed by the skeleton you specify when you
make it generate a new webapp project tree.  All of the skeletons I
found in the wild were designed to setup a whole webapp -- not just a
standalone library component.  But after digging into what a skeleton
can be made to do, I was able to create one which supports standalone
library creation.

Where did the name come from? From travels in Hawaii, where coffee
farms dot the landscape, I came to know that 'cherries' are the small
fruits which grow on coffee plants.  What folks commonly call a
[coffee bean](http://en.wikipedia.org/wiki/Coffee_bean) is actually
the seed of this fruit.

## Phases of a Project
---------------------------------------------------------------------------

### Setup of Requisite Tooling

You'll need to install [Node.js](http://nodejs.org/), and then use its
[npm](https://npmjs.org/) package manager to install Coffeescript,
Brunch, and Docco.

### Cherry Creation

Each time you want to create a new cherry, you invoke [brunch
new](http://brunch.readthedocs.org/en/latest/commands.html#brunch-new-rootpath),
specifying the project's name and the skeleton which this repo holds.
That could either be:

      brunch new {project_name} --skeleton {this repo's github path}

or:

      brunch new {project_name} --skeleton {your local clone-out location for this repo}

### Name Binding

This is a one-time follow-on process to creating a cherry.  The set of
files you inherit from the skeleton (via the 'brunch new' process)
need some edits to have your project's name embedded into them.  A
Ruby script is provided for this (bin/name_fixer.rb).

### Cherry building

You will use Brunch to rebuild your project after each source update.
It converts your set of .coffee sources files into a collective stream
of Javascript all bundled together into {project_name}.js along with
the CommonJS or AMD modular Javascript boilerplate.

### Triggering your Test Suite

You can retrigger your tests after each edit/build cycle by reloading
the test index.html file in a browser.

### Regenerating Documentation

You can retrigger a Docco build whenever you like using a provided
Ruby script (bin/gen_docs.rb).  It builds a 'docs' tree with a
subdirectory structure which mirrors the shape of your source and test
trees, invokes Docco to populate said structure, and then generates a
table-of-contents index.html file.

### Reap the Benefit

Push a copy of the generated {project_name}.js file off to the webapp
projects that count on it, and rejoice!

## Generating a Cherry and Binding in its Name
---------------------------------------------------------------------------

Making up names is hard (right up there with cache invalidation) --
but you gotta deal with it.  When you first set out to create a new
cherry, you will need to come up with a name for it, in two forms
no-less:

* A lowercase version to be used for the generated .js file, the source subdirectory, and the namespace segment.
* A capitalized camel-case version of the name suitable for your library's main Class.

Say, for example, you need a cherry to deal with forming a layout of
rectangular regions using HTML div tags given a data structure
oriented in a row-and-column fashion.  You come up with 'rctiler' for
the lowercase version, and RCTiler for the Class-name version.
Setting up that new project would go like this:

      cd ~/my_projects/
      brunch new rctiler --skeleton {this repo's github path}

The 'brunch new' process will create an 'rctiler' directory for you
and fill it with files from the skeleton.

Now you need to deal with the name-binding step.  If you were to scan
the directories and file content within your newly minted tree you
would find a number of occurrences of the string 'fixme' and a couple
of cases of 'Fixme'.  These need renamed to the corresponding
lowercase and Class-name versions of your project name.

Using find and grep as below would show the subdirectory involved --
to which the lowercase version of your project name needs applied:

      find ~/my_projects/rctiler/ -type f | grep -e "fixme" | grep -v -e "/docs/"

Likewise, this would reveal file content points where the lowercase
name needs applied:

      find ~/my_projects/rctiler/ -type f -print0 | xargs -0 -e grep -n -e "fixme" | grep -v -e "/docs/"

Finally, file content points where the Class-name version must be
imposed:

      find ~/my_projects/rctiler/ -type f -print0 | xargs -0 -e grep -n -e "Fixme" | grep -v -e "/docs/"

On peeking within your project's 'bin' subdir you will find one
'bin/name_fixer.rb'.  Running this script for this 'rctiler' sample
case, would go like:

      cd ~/my_projects/rctiler/
      ./bin/name_fixer.rb rctiler RCTiler

## Building a Cherry
---------------------------------------------------------------------------

Given how Brunch works, you have two choices:

Use [brunch
build](http://brunch.readthedocs.org/en/latest/commands.html#brunch-build)
to manually rebuild of all your source and test .coffee files:

      cd ~/my_projects/rctiler/
      brunch build

Use [brunch
watch](http://brunch.readthedocs.org/en/latest/commands.html#brunch-watch)
to setup continuous rebuilds triggered each time you update any of
your source or test .coffee files:

      cd ~/my_projects/rctiler/
      brunch watch

The outcome of the build process is none other than a populated
'build' subdirectory tree.

## Test Suite
---------------------------------------------------------------------------

Once you've done a build, try loading 'test/index.html' in a browser:

* file:///home/me/my_projects/rctiler/build/test/index.html

(Most likely you will need to adjust that path, unless you happen to
be 'me')

As you may discover, Brunch has a [strong leaning
towards](https://github.com/brunch/brunch/issues/158) the
[Mocha](http://mochajs.org/) testing framework.

## Docco Generation
---------------------------------------------------------------------------

Peeking once again within your project's 'bin' subdir you become aware
of another helpful bit of Ruby: 'bin/gen_docs.rb'.  Running this
script for this 'rctiler' sample case, would go like:

      cd ~/my_projects/rctiler/
      ./bin/gen_docs.rb

Once you get that working, try browsing thusly:

* file:///home/me/my_projects/rctiler/docs/index.html

## Example Files
---------------------------------------------------------------------------

You can setup example .html files within your project.  An example
example file is provided here (once you trigger a build):

      ~/my_projects/rctiler/build/examples/example1.html

Spin it up:

* file:///home/me/my_projects/rctiler/build/examples/example1.html

## Namespace Conventions
---------------------------------------------------------------------------

Within a project produced by brunch and this skeleton you will notice
a 'coffeecherries' subdirectory at a parent level to the source for
your project's specific source code.  Why?  So that the require
statements you write within some client layer look like this:

      RCTilerFactory = require('coffeecherries/rctiler/factory');

This makes cherries use a distinct part of the namespace from internal
modules you may have.  This way, if you happened to have an internal
module named 'foo' and then also wanted to make use of a cherry named
'foo', there would be no conflict:

      FooCherryFactory = require('coffeecherries/foo/factory');
      ...
      FooFactory = require('foo/factory');

Now, if you are pulling in a cherry named 'foo' from author X, and
another one named 'foo' by author Y, you will have a conflict.  Maybe
author names should be factored into the namespace, similar to github
urls.

## Bottom Line
---------------------------------------------------------------------------

Based on our 'rctiler' project case-study, the standalone Javascript
library that all this is about.... lives here:

      ~/my_projects/rctiler/build/js/rctiler.js

With its modular Javascript wrapper such libraries are all ready for
inclusion in webapps of all flavors.  They will fit right into one
based on Backbone.js via Brunch, but, as you can see from studying
'examples/example1.html', even a dead-simple client-layer can use
them.

Boom!
