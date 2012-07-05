# Arsenal

Everything starts at the model. A model is plain-old-ruby-code (PORC), which
includes the Arsenal Module. This module does two things:

- Grants access to the Arsenal macros for defining attributes and the like
- Creates the Arsenal Derived classes

The former includes macros like: "#attribute", "#id", etc. These will be
described in the 'Macros' section

The latter creates the `<Model>::Persisted`, `<Model>::Nil`, and
`<Model>::Collection` classes. These will be desribed in detail in the
'Arsenal Classes' section.

Finally, the latter also generates the `<Model>::Repository` class, which
manages interfacing with the various adapters you specify.

Arsenal allows multiple drivers to be associated with each attribute on the
class, per attribute. This allows fine-grained storage of attributes across
multiple storage devices. We'll talk in detail about these in the sections
'Drivers', 'Macros', and 'Storage strategies'

## Models

## Macros

## Arsenal Classes

## Repositories

## Drivers

Drivers come in two flavors

- Adapters
- Middleware

### Adapters

These actually write data to an external service. They expect a hash, and
potentially a 'location' (which generalizes over DB tables, key prefixes,
document indicies, etc), and writes to the storage device appropriately.

They also define #execute, which takes a block. This implementation may be a
noop. In particular, a SQL driver might define `#execute` to require a block
which returns a string, which is then interpreted as raw sql to the backend.

### Middleware

A middleware adapter is actually just a normal adapter, but with the caveat that
it internally delegates each of it's calls onto another driver. This allows us
to stack cross-cutting concerns onto the datalayer's stack.

### Notes on Drivers

One problem with a middleware model is the propensity for the stack size to
grow. In particular, Rails has an incredibly deep stack trace, mostly due to the
quantity of middleware it loads. One way to avoid long stacktraces is to handle
middleware asynchronously. In particular, if each adapter is also an
_asynchronous_ adapts, eg - a Celluloid actor - then callers can regard calls to
the stack as futures which can be dealt with in the normal way. We can still
support 'synchronous' calls by simply wrapping the future in blocking logic at
the adapter level. In this way, we never have a stack that's deep, because we
are wholly exiting the function at the end of our part of the execution, merely
handing back a future.

As a fringe benefit, if it were the case that futures were cancellable, so would
database queries.

### Middleware

## Storage Strategies

**This section is presently a lie**

A storage strategy is a object which represents a method for determining how to
prioritize storage devices when retrieving objects. The object is normally
defined through a DSL. 

Example:

    strategy :read, :redis_cache do
      skip if $convienent_example
      if redis.updated_at - Date.today > 1.day 
        use sql
      else
        use redis, sql
      end
    end

This specifies a 'read' strategy, which means it's invoked when we need to read
an object from the drivers. Strategies may be registered per-attribute or
specified as a default for a model using the `default_strategy` macro. 

The default strategy for every model is the `majority` strategy, which chooses
the driver that is used the most in the model (to minimize queries).

The above strategy specifies how and where to read data. Notably, it specifies
a simple caching strategy, using a 1-day timeout. In particular. It requires
that an attribute exists in both redis and sql, however, when used as a default
caching strategy for a whole model, the minimum requirement is that everything
lives in sql, since both sides of the branch specify it as an available driver.

So, to make clear how strategies work:

- A read strategy tells Arsenal where to look for data
  - Does so via a DSL
  - DSL returns an ordered list of driver names
  - if there are multiple entries, it will use them in order to look up that
    attribute, batching where it can to save requests.
- A write strategy specifies how to determine where to write elements to a
  storage adapter.
  - Does so via a DSL
  - DSL again returns an ordered list of driver names
  - if there are multiple entries, the attribute is written in sequence to each
    such entry.

An example of a write strategy might be:

    require 'enviable' #shameless plug
    strategy :write, :duplex_data do
      if Environment.duplex?
        #where 'custom adapter' does some reformatting/migrating or something.
        uses :mysql, :postgres_custom_adapter
      else 
        uses :mysql
      end
    end

This specifies a 'duplexing' strategy where we write to both mysql and a custom
adapter to postgres (which may do some complicated logic in-and-of-itself).


