require './spec/unit/unit_spec_helper'

describe "The Arsenal Module" do
  subject { Arsenal }
  after { Object.send(:remove_const, :Example) rescue nil }

  it { should respond_to :collection_for }
  it { should respond_to :persisted_for }
  it { should respond_to :model_for }
  it { should respond_to :nil_for }
  it { should respond_to :repository_for }

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

    context "generated classes" do
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

    context 'generated model accessors' do
      describe "#collection_for" do
        subject { Arsenal.collection_for(Example) }
        it { should be Example::Collection }
      end

      describe "#persisted_for" do
        subject { Arsenal.persisted_for(Example) }
        it { should be Example::Persisted }
      end

      describe "#model_for" do
        subject { Arsenal.model_for(Example) }
        it { should be Example }
      end

      describe "#repository_for" do
        subject { Arsenal.repository_for(Example) }
        it { should be Example::Repository }
      end
    end

    describe '#drivers' do
      before do
        class Example
          attribute :flibble, :driver => :some_driver
          attribute :flobble, :driver => :some_driver
          attribute :weeble, :driver => :some_other_driver
        end
      end

      subject { Example.drivers }

      it { should_not be_nil }
      it { should respond_to :each }
      it { should be_an Enumerable }

      it { should =~ [:some_driver, :some_other_driver] }

      it 'does not contain nils' do
        subject.all? { |e| e.should_not be_nil }
      end
    end
  end

end
