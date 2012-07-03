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

    describe 'Example' do
      context 'class' do
        subject { Example } 

        it { should respond_to :id }
        it { should respond_to :attribute } 

        describe '#id' do
          subject { Example.attributes[:id] } 

          after { Object.send(:remove_const, :ErrorExample) rescue nil } 

          it { should_not be_nil } 
          it { should be_required }
          it { should_not have_default } 

          it 'causes an error when instantiating if it is not provided' do
            expect { 
              class ErrorExample
                include Arsenal
              end
              ErrorExample.new
            }.to raise_error Arsenal::IdentifierNotGivenError
          end
        end

        describe '#attribute' do
          before do
            class Example
              attribute :foo, 
                default: :default_thing

              attribute :bar

              def foo
                :thing 
              end

              def bar ; end
            end
          end

          subject { Example.new } 

          it "optionally takes a default value, which is used by the nil-model to populate it's #attributes" do
            subject.foo.should == :thing
            nil_example.foo.should == :default_thing
          end
        end
      end

      context 'instance' do
        let(:example) { Example.new }
        subject { example } 

        it { should respond_to :persisted? }
        it { should_not be_persisted }

        it { should respond_to :savable? }
        it { should be_savable } 

        it { should respond_to :attributes } 
        it { should respond_to :id }

        describe "#attributes" do
          before do 
            class Example
              attribute :foo
            end
          end

          subject    { example.attributes   }
          its(:keys) { should include(:id)  }
          its(:keys) { should include(:foo) }
          its(:keys) { should =~ Example.attributes.keys }
        end
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

    describe 'Example::Collection' do
      context 'instance' do 
        subject { Example::Collection.new([Example.new, Example.new, Example::Persisted.new, nil_example]) }

        it { should respond_to :each } 

        it "delegates calls it doesn't understand to it's elements" do
          subject.each { |e| e.should_receive(:foo) } 
          subject.foo
        end

        it "takes methods of the form #any_<predicate>? and turns them into a .any? call" do
          subject.each { |e| e.should_receive(:predicate?).at_most(:once) } 
          subject.should_receive(:any?)
          subject.any_predicate?
        end

        it "takes methods of the form #all_<predicate>? and turns them into a .all? call" do
          subject.each { |e| e.should_receive(:predicate?).at_most(:once) } 
          subject.should_receive(:all?)
          subject.all_predicate?
        end

        it "aliases #savable? to #all_savable?" do
          subject.each { |e| e.should_receive(:savable?).at_most(:once) } 
          subject.should_receive(:all?)
          subject.savable?
        end

        it "aliases #persisted? to #all_persisted?" do
          subject.each { |e| e.should_receive(:persisted?).at_most(:once) } 
          subject.should_receive(:all?)
          subject.savable?
        end
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
