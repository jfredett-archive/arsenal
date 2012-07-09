require 'spec_helper'

describe 'Example::Nil', 'instance' do
  before do
    class Example
      include Arsenal 
      id :identifier

      attribute :foo, :default => :bar
      attribute :flurm, :default => :slurm

      def identifier
        $identifier_number ||= 0
        $identifier_number += 1
      end
    end 

    class Example::Nil
      def flurm ; :thing ; end
    end
  end
  after { Object.send(:remove_const, :Example) }


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

