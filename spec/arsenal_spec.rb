require 'spec_helper'

describe "The Arsenal Module" do
  subject { Arsenal } 
  after { Object.send(:remove_const, :Example) }

  context "before it's included" do
    before do
      class Example 
      end
    end

    it "hasn't yet defined the Example::Repository class" do
      "Example::Repository".should be_undefined
    end

    it "hasn't yet defined the Example::Nil class" do
      "Example::Nil".should be_undefined
    end

    it "hasn't yet defined the Example::Persisted class" do
      "Example::Persisted".should be_undefined
    end

    it "hasn't yet defined the Example::Collection class" do
      "Example::Collection".should be_undefined
    end
  end

  context "after it's included" do
    before do
      class Example
        include Arsenal 
        id :identifier

        def identifier
          $identifier_number ||= 0
          $identifier_number += 1
        end
      end 
    end

    it "defines the Example::Repository class" do
      "Example::Repository".should be_defined
    end

    it "defines the Example::Nil class" do
      "Example::Nil".should be_defined
    end

    it "defines the Example::Persisted class" do
      "Example::Persisted".should be_defined
    end

    it "defines the Example::Collection class" do
      "Example::Collection".should be_defined
    end
  end
end
