require 'spec_helper'



shared_examples_for "Arsenal::Driver" do
  
  it { should respond_to :save    }
  it { should respond_to :find    }
  it { should respond_to :destroy }
  it { should respond_to :execute }

  #TODO: How to test these?
  #
  #it should be threadsafe
  #
  #creating a new instance of a driver should create a new copy with it's own
  # connections and the like. (part of being threadsafe)

  describe '#save' do
    # in the case of an kvs- the location might be a key prefix, in the case of a
    # sql db, it might be a table name. in the case of documents, it might be
    # null, or an index in which to index the document (as in elastic search)
    it "expects to be given a ruby hash and a location in which to store that item"
  end

  describe '#find' do
    it 'expects a hash of properties to look for, and a location to look in'
    it 'returns a collection of hashes'
  end

  describe '#destroy' do
    
  end

  describe '#execute' do

  end
end


describe MemoryDriver do
  it_should_behave_like "Arsenal::Driver"
end

describe SqliteDriver do
  it_should_behave_like "Arsenal::Driver"
end
