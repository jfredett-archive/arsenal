require 'bundler/setup'

require 'pry'

RSpec.configure do |config|
  config.before do
    allow_message_expectations_on_nil #because we're making proper nullclasses.
  end
end

#include helpers
Dir["./spec/helpers/*.rb"].each { |file| require file }
