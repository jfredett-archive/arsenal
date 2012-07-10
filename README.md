# Arsenal

A Repository-pattern based ORM

---------------------
_*Obligatory Badges*_

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jfredett/arsenal)
[![Build Status](https://secure.travis-ci.org/jfredett/arsenal.png)](http://travis-ci.org/jfredett/arsenal)
[![Dependency Status](https://gemnasium.com/jfredett/arsenal.png)](https://gemnasium.com/jfredett/arsenal)

---------------------

## What is Arsenal?

Arsenal is a Repository-pattern based ORM with support for user-modifiable
Collection and Nil classes for models. It also supports (through the use of
fine-grained 'driver' specification) multiple storage systems, with fine-grained
control over which attributes of a model are stored in which systems.

It allows for a Rack-like interface to storage tools, which means you can easily
support middleware between your models and your databases.

Finally, the goal of Arsenal is to be not just threadsafe, but
concurrent-out-of-the-box, using Celluloid to provide support for non-blocking,
asynchronous interactions (through futures and async calls) with your databases,
with no cost to you.


## Installation

Add this line to your application's Gemfile:

    gem 'arsenal'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arsenal

## Usage

To use Arsenal, simply do:

    class Example
      include Arsenal
    end

This will automatically create the `Example::*` classes used by arsenal to
represent different model-states. These extra models are _designed to be
patched_, so rip them open and add more methods. 

There are presently 5 classes that matter when talking about an Arsenal Model:

### The original including class

This class represents a model not-yet-persisted to the database(s) it is backed
by. In this class, you add attributes to track via the `attribute` macro. You
further must provide a call to the `id` macro with the name of a method you want
to use as the primary key for your model. Both the `attribute` and `id` macros
take method names (given as symbols) as arguments. These methods are called when
saving, and are expected to be populated by the hash passed to the initialize
method. You should implement `#initialize` to populate appropriately, and do any
pre-instantiation error checking you like.

Arsenal does _not_ invade your model with lots of methods, in fact, it only
provides a very few, which you can find in the API documentation.

### The ::Persisted class

This class is namespaced beneath your original including class (henceforth: the
model). It represents a model already persisted in the database. It too can have
methods loaded on it freely. 

###The ::Nil class

This class represents the absence of a model. It's what you get when the
Repository can't find a class matching your conditions, or generally any
situation which would return `nil` in the case of active record. The primary
philosophy of Arsenal is that you should never return a bare object when you can
return a wrapper which is safe to load methods on. The Model::Nil class
represents the essence of that goal. Like every other Arsenal class, you are
free to load methods on it.

In particular, Model::Nil class responds to `#nil?` with `true` -- but due to
limitations in ruby, it cannot act as falsey, so make sure to explicitly call
`#nil?` when using Model::Nil in boolean contexts.

Further, Model::Nil responds to `#each`, you can essentially treat the ::Nil
as a collection, which is useful for iterating over in a view, since you can
always just `#each` over the result of a `#find` and count on the same interface
being provided across all the models. 

### The ::Collection class

This class contains collections of the previous three classes. It's a subclass
of Array, so you can treat it exactly like that. The Repository finders will
always return this or a Model::Nil class

### The ::Repository class

This is the class responsible for managing the saving, updating, destroying, and
finding of model instances in the given databases associated with the model.
Instance of this class are threadsafe, and share connections in the form of
instances of Drivers (which are an implementation detail).

In particular, you will primarily interact with this class through the `#find`,
`#save`, and `#destroy` -- they do precisely as they sound.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
