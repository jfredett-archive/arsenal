require 'spec_helper'

describe "The Arsenal Module" do
  subject { Arsenal } 

  before { class Example ; end }
  after { Object.send(:remove_const, :Example) }

  context "before it's included" do
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

    before { 
      class Example
        include Arsenal 
        id :identifier

        def identifier
          $identifier_number ||= 0
          $identifier_number += 1
        end
      end 
    }

    describe 'Generated classes' do
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
    describe 'Example::Repository' do
      subject { Example::Repository } 

      it { should respond_to :save }
      it { should respond_to :find }
      it { should respond_to :destroy }
    end
  end
end
