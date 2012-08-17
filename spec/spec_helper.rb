require 'bundler/setup'

require 'pry'

require 'arsenal'

#include helpers
Dir["./spec/helpers/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.before do
    allow_message_expectations_on_nil #because we're making proper nullclasses.
  end

  config.include(CustomMatchers)
end
