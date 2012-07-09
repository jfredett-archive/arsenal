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

    describe 'Example::Nil', 'instance' do
      before {
        class Example
          attribute :foo, :default => :bar
          attribute :flurm, :default => :slurm
        end

        class Example::Nil
          def flurm ; :thing ; end
        end
      }


      subject { Example::Nil.instance } 

      it { should respond_to :nil? }
      it { should be_nil } 
      it { should be_a Singleton } 

      it { should respond_to :persisted? }
      it { should_not be_persisted }

      it { should respond_to :savable? }
      it { should_not be_savable } 

      it { should respond_to :attributes } 
      it { should respond_to :id }
      its(:id) { should be_nil }

      # respects overrides of defaulted attribute methods
      its(:flurm) { should == :thing }
      # gives the attributes' default value it the attribute name is called as a method 
      its(:foo) { should == :bar } 

      describe "#attributes" do
        subject { nil_example.attributes } 
        its(:keys) { should include(:id) }
        its(:keys) { should be_a_subset_of(Example.attributes.keys) } 
      end

      describe 'nil_<model_name>' do
        subject { nil_example }

        it { should be_the Example::Nil } 
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
