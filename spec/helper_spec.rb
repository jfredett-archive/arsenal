require 'spec_helper'

describe "be_defined, be_undefined" do
  after do
    Object.send(:remove_const, "Foo") rescue nil #igore failures
  end

  it "properly detects and undefined class" do
    "Foo".should_not be_defined
    "Foo".should be_undefined
  end

  it "properly detects a defined class" do
    class Foo
    end

    "Foo".should be_defined
    "Foo".should_not be_undefined
  end
end
