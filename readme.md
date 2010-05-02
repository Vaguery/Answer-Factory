# Answer Factory: A system for pragmatic genetic programming projects

## Caveat

**DO NOT EXPECT ANYTHING TO WORK (AT ALL) UNTIL VERSION 0.1+**
This particular project is undergoing a lot of serious surgery right now. 

## What it does

The answer-factory gem includes scripting support for

* generating new design automation projects
* Nudge, a Turing-complete programming language for readable genetic programming
* standard genetic programming search operators
* a standard suite of powerful metaheuristics
* full automated archiving of all solutions
* analytics and reporting
* administrative tools for managing AnswerFactory daemons
* reporting tools for exploring and directing search

The AnswerFactory infrastructure has been designed to help _regular people_ build, run and manage technical experiments that use (among other things) genetic programming. There's a lot more in there... but that's the bottom line.

## Getting started

The `answer-factory` gem depends on Ruby 1.9 or higher. We recommend [rvm](http://rvm.beginrescueend.com/) if you'd like to maintain several Ruby installations.

You'll also need a working installation of [CouchDB](http://couchdb.apache.org/) available. This can be a remote instance, as long as you have the necessary permissions to create and manage databases.

Then:
    gem install answer-factory
    
This will automatically install several dependencies, including [nudge](http://github.com/Vaguery/Nudge), rspec, and others.

### Creating a new AnswerFactory project

Use this command line script to build an AnswerFactory project folder:
    answer-factory your-project-name-here

This will create a new directory called 'your-project-name-here', and install a rudimentary subtree of folders and files. Perhaps most important is the `Thorfile`, which contains most of the generators you can use to simplify project creation and management.

### Replicating a pre-existing project or demo

TBD

### Generating new Nudge type defintitions

The Nudge language gem installed along with `answer-factory` includes a full-featured programming language designed for genetic programming projects, with integer, floating-point, boolean, and code types.

Often your project's domain model will call for additional types. To generate some basic infrastructure for a new NudgeType subclass, navigate to the root of your project folder and invoke the thor script
    thor new_nudge_type your-nudge-type-name
This will create a template for your class definition in the `/lib/nudge/types` subdirectory (which you should edit as indicated in the comments to use), several standard nudge instruction classes in `/lib/nudge/instructions`, and rspec files.

### Activating the AnswerFactory daemon

Make sure CouchDB is running and available, navigate to your project's root folder, and invoke
    ruby activate.rb