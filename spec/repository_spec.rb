require 'spec_helper'

describe 'Example::Repository' do
  let(:fake1_driver) { double('fake1_driver').as_null_object } 
  let(:fake2_driver) { double('fake2_driver').as_null_object } 

  before do
    class Example
      include Arsenal 
      id :identifier
      attribute :bar, :driver => :fake1_driver
      attribute :foo, :driver => :fake2_driver

      def identifier
        @id ||= rand(10000)
      end

      def foo
        "Flurm!"
      end

      def bar
        "mrulF!"
      end
    end 

    Example.attributes[:foo].stub(:driver => fake1_driver)
    Example.attributes[:bar].stub(:driver => fake2_driver)
  end 

  let(:example) { Example.new } 
  
  after { Object.send(:remove_const, :Example) }

  subject { Example::Repository } 

  it { should respond_to :save }
  describe '#save' do
    context "saving a raw Example" do
      it "calls #write on the driver when it saves a model" do
        fake1_driver.should_receive(:write).with(:id => example.id, :foo => example.foo).at_most(:once)
        fake2_driver.should_receive(:write).with(:id => example.id, :bar => example.bar).at_most(:once)
        subject.save(example)
      end

      it "returns an Example::Persisted if the save was successful" do 
        fake1_driver.stub(:write => true)
        fake2_driver.stub(:write => true)
        subject.save(example).should be_a Example::Persisted
      end

      it "returns false if the save was unsuccessful" do
        fake1_driver.stub(:write => false)
        fake2_driver.stub(:write => true)
        subject.save(example).should be_false
      end
      
      pending "this is an integration test, where should it go?" do
        #in particular, it integrates drivers (through #find and #write), models
        #(through comparing #id's) and repositories (the primary actor in all
        #this). it's nasty to stub, and really probably shouldn't be. Where
        #should it go?
        it "throws an error if there is an exact duplicate of the #id of the object it's trying to save" do
          expect { 
            subject.save(example)
            subject.save(example)
          }.to raise_error Arsenal::DuplicateRecord
        end
      end
    end

    context "updating a persisted Example" do
      it "calls #update on the driver when it updates a model" 
      it "returns true if the update was successful"
      it "returns false if the update was unsuccessful"
    end

    context "saving a collection" do
      let (:savable_collection) { Example::Collection.new([example]) } 
      let (:unsavable_collection) { Example::Collection.new([example, nil_example]) }

      #crappy test
      it "returns a collection of persisted examples if the saving/updating was successful for all elements" do
        subject.save(savable_collection).tap do |new_coll|
          #new_coll.should be_a Example::Collection
          #new_coll.each do |e|
            #e.should be_a Example::Persisted
          #end
        end
      end

      it "returns false if any of the saves/updates fails" do
        subject.save(unsavable_collection).should be_false
      end

      pending "transactions" do
        it "doesn't save anything if any of the saves/updates fail" 
      end
    end

    context "saving a NilExample" do
      it "does nothing" do
        fake1_driver.should_not_receive(:write)
        fake2_driver.should_not_receive(:write)
        subject.save(nil_example)
      end

      it "returns false" do
        subject.save(nil_example).should be_false
      end
    end
  end

  it { should respond_to :find }
  it { should respond_to :destroy }
end
