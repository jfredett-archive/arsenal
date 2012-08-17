require './spec/unit/unit_spec_helper'

describe "The Arsenal Module" do
  subject { Arsenal } 
  after { Object.send(:remove_const, :Example) rescue nil }

  it { should respond_to :collection_for } 
  it { should respond_to :persisted_for } 

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

    describe '#collection_for' do
      subject { Arsenal.collection_for(Example) }
      it { should be_nil }
    end

    describe '#persisted_for' do
      subject { Arsenal.persisted_for(Example) }
      it { should be_nil }
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

    describe "#collection_for" do
      subject { Arsenal.collection_for(Example) }
      it { should be Example::Collection }
    end

    describe "#persisted_for" do
      subject { Arsenal.persisted_for(Example) }
      it { should be Example::Persisted }
    end
  end
end
