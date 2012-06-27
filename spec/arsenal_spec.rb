require 'spec_helper'

describe "The Arsenal Module" do
  subject { Arsenal } 

  it { should be_a Module } 

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
    before { class Example ; include Arsenal ; end }


    it "hasn't yet defined the Example::Repository class" do
      "Example::Repository".should be_defined
    end

    it "hasn't yet defined the Example::Nil class" do
      "Example::Nil".should be_defined
    end

    it "hasn't yet defined the Example::Persisted class" do
      "Example::Persisted".should be_defined
    end

    it "hasn't yet defined the Example::Collection class" do
      "Example::Collection".should be_defined
    end

    describe 'Example' do
      context 'class' do

      end

      context 'instance' do
        subject { Example.new } 
        
        it { should respond_to :persisted? }
        it { should_not be_persisted }

        it { should respond_to :savable? }
        it { should be_savable } 
      end
    end

    describe 'Example::Persisted' do
      context 'class' do
        subject { Example::Persisted } 

        its(:superclass) { should be Example }
      end

      context 'instance' do
        subject { Example::Persisted.new } 
        
        it { should respond_to :persisted? }
        it { should be_persisted }

        it { should respond_to :savable? }
        it { should be_savable } 
      end
    end

    describe 'Example::Collection', 'class' do
      subject { Example::Collection } 

      its(:superclass) { should be Array } 
    end

    describe 'Example::Nil', 'instance' do
      subject { Example::Nil.instance } 

      it { should respond_to :nil? }
      it { should be_nil } 
      it { should be_a Singleton } 

      it { should respond_to :persisted? }
      it { should_not be_persisted }

      it { should respond_to :savable? }
      it { should_not be_savable } 

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
