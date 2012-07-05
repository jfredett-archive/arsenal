require 'spec_helper'

describe 'Example::Repository' do
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
  after { Object.send(:remove_const, :Example) }

  subject { Example::Repository } 

  it { should respond_to :save }
  describe '#save' do
    context "saving a raw Example" do
      it "calls #write on the adapter when it saves a model" 
      it "returns true if the save was successful"
      it "returns false if the save was unsuccessful"

      pending "impl" do
        it "throws an error if there is an exact duplicate of the #id of the object it's trying to save" do
          expect { 
            Example::Repository.save(example)
            Example::Repository.save(example)
          }.to raise_error Arsenal::DuplicateRecord
        end
      end
    end

    context "updating a persisted Example" do
      it "calls #update on the adapter when it updates a model" 
      it "returns true if the update was successful"
      it "returns false if the update was unsuccessful"
    end

    context "saving a collection" do
      it "proxies the .save to each element if the collection is #savable" 
      it "returns true if the saving/updating was successful for all elements"
      it "returns false if any of the saves/updates fails"

      pending "transactions" do
        it "doesn't save anything if any of the saves/updates fail" 
      end
    end

    context "saving a NilExample" do
      it "does nothing"
      it "returns false" do
        Example::Repository.save(nil_example).should be_false
      end
    end
  end

  it { should respond_to :find }
  it { should respond_to :destroy }
end
