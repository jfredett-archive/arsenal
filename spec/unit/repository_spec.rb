require './spec/unit/unit_spec_helper'

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
  let(:persisted_example) { Example::Persisted.new }

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

      context "save successful" do
        it "returns an Example::Persisted if the save was successful" do
          fake1_driver.stub(:write => true)
          fake2_driver.stub(:write => true)
          subject.save(example).should be_a Example::Persisted
        end
      end

      context "save failed" do
        it "returns false if the save was unsuccessful" do
          fake1_driver.stub(:write => false)
          fake2_driver.stub(:write => true)
          subject.save(example).should be_false
        end
      end
    end

    context "updating a persisted Example" do
      it "calls #update on the driver when it updates a model" do
        fake1_driver.should_receive(:update).with(:id => example.id, :foo => example.foo).at_most(:once)
        fake2_driver.should_receive(:update).with(:id => example.id, :bar => example.bar).at_most(:once)
        subject.save(persisted_example)
      end

      context "update successful" do
        it "returns an Example::Persisted if the update was successful" do
          fake1_driver.stub(:update => true)
          fake2_driver.stub(:update => true)
          subject.save(persisted_example).should be_a Example::Persisted
        end
      end

      context "update failed" do
        it "returns false if the update was unsuccessful" do
          fake1_driver.stub(:update => true)
          fake2_driver.stub(:update => false)
          subject.save(persisted_example).should be_false
        end
      end
    end

    context "saving a collection" do
      let (:savable_collection) { Example::Collection.new([example]) }
      let (:unsavable_collection) { Example::Collection.new([example, nil_example]) }

      it "returns a collection of persisted examples if the saving/updating was successful for all elements" do
        subject.save(savable_collection).tap do |new_coll|
          new_coll.should be_a Example::Collection
          new_coll.each do |e|
            e.should be_a Example::Persisted
          end
        end
      end

      it "returns false if any of the saves/updates fails" do
        subject.save(unsavable_collection).should be_false
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
  describe '#find' do
    context "delegation to drivers" do
      describe "cases where delegation occurs" do
        context "hashes and regular models send all the attributes" do
          before do
            fake1_driver.should_receive(:find).with("examples", example.attributes)
            fake2_driver.should_receive(:find).with("examples", example.attributes)
          end

          it "delegates with the model name as the location, pluralized, for a raw model" do
            subject.find(example)
          end

          it "delegates with the model name as the location, pluralized, for a hash of attributes" do
            subject.find(example.attributes)
          end
        end

        context "persisted models only delegate the id" do
          before do
            fake1_driver.should_receive(:find).with("examples", id: persisted_example.id)
            fake2_driver.should_receive(:find).with("examples", id: persisted_example.id)
          end

          it "delegates with the model name as the location, pluralized, for a persisted model" do
            subject.find(persisted_example)
          end
        end
      end

      describe "cases where delegation does not occur" do
        before do
          fake1_driver.should_not_receive(:find).with("examples", example.attributes)
          fake2_driver.should_not_receive(:find).with("examples", example.attributes)
        end

        it "does not delegate when the given the nil model" do
          subject.find(nil_example)
        end

        it "does not delegate when given an empty hash" do
          subject.find({})
        end
      end
    end

    it "returns the nil model when given the nil model" do
      subject.find(nil_example).should be_the nil_example
    end

    describe 'looking up a collection of items' do
      let (:collection) { Example::Collection.new([example, persisted_example]) }

      pending "hard to mock" do
        #hard because rspec's mocking sucks, not because the code is bad, i
        #think.
        it 'delegates the #find to each contained element'
      end
    end

    describe 'return values' do
      let (:criterion) { double('search criteria') }
      let (:driver1) { double('fake driver #1') }
      let (:driver2) { double('fake driver #2') }
      let (:attributes) { double('fake returned attributes') }

      before do
        criterion.stub(:drivers => [driver1, driver2])
        criterion.stub(:attributes => attributes)
      end

      subject { Example::Repository.find(criterion) }

      context 'when nothing is found' do
        before do
          driver1.stub(:find => nil)
          driver2.stub(:find => nil)
        end

        it { should respond_to :each }
        it { should be_the nil_example }
      end

      context 'when one or more records are found' do
        before do
          driver1.stub(:find => attributes)
          driver2.stub(:find => attributes)
        end

        it { should be_a Example::Collection }

        it 'contains no duplicates' do
          #this is douchey
          Example::Persisted.should_receive(:new).with(attributes).once
          subject
        end

        it 'aggregates attributes from multiple stores by id'
      end
    end
  end

  it { should respond_to :destroy }
  describe "#destroy" do
    # if given a raw hash, looks up all the models with the given atributes,
    #  calls #delete on all the drivers associated with the model
    # if the hash specifies and identifier key, it should end up that it only
    #  deletes one
    # if given a raw model, looks up all the models matching that models
    #  attributes, calls #delete on all the drivers associated with the model
    # if given a persisted model, looks up the record and calls delete on all
    #  drivers to delete just that model
    # if given a collection of models, delegate the destroy to each model in the
    #  collection, following the normal rules
  end
end
