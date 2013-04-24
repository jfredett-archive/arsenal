require 'rspec/expectations'

RSpec::Matchers.define :be_the do |expected|
  match do |obj|
    expected = expected.class unless expected.is_a?(Class)
    # This may only work on rubinius...
    obj.is_a? expected and expected.include? Singleton
  end
end
