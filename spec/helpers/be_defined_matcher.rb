require 'rspec/expectations'

def __is_defined?(obj, expected_type)
  klass = eval(obj)
  return true if klass.is_a?(expected_type)
rescue NameError
  return false
end

RSpec::Matchers.define :be_defined do |expected_type = Class|
  match do |obj|
    __is_defined?(obj, expected_type)
  end
end

RSpec::Matchers.define :be_undefined do |expected_type = Class|
  match do |obj|
    not __is_defined?(obj, expected_type)
  end
end


