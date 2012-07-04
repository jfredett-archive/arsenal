# -*- encoding: utf-8 -*-
require File.expand_path('../lib/arsenal/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joe Fredette"]
  gem.email         = ["jfredett@gmail.com"]
  gem.description   = %q{A Repository-pattern based ORM}
  gem.summary       = %q{

    Arsenal is a Repository-pattern based ORM with support for user-modifiable
    Collection and Nil classes for models. It also supports (through the use of
    fine-grained 'driver' specification) multiple storage systems, with fine-grained
    control over which attributes of a model are stored in which systems.

    It allows for a Rack-like interface to storage tools, which means you
    can easily support middleware between your models and your databases.

    Finally, the goal of Arsenal is to be not just threadsafe, but
    concurrent-out-of-the-box, using Celluloid to provide support for
    non-blocking, asynchronous interactions (through futures and async calls)
    with your databases, with no cost to you.

  }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "arsenal"
  gem.require_paths = ["lib"]
  gem.version       = Arsenal::VERSION
end
