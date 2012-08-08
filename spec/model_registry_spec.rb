require 'spec_helper'

describe Arsenal::ModelRegistry do
  let! (:fake_model) do
    class FakeModel
      include Arsenal
    end
  end
  let! (:registry) { Arsenal::ModelRegistry.new } 

  subject { registry } 

  after  { Object.send(:remove_const, :FakeModel) }
  before { registry.register!(FakeModel) }

  it { should respond_to :have_model? } 
  it "delegates #have_model? to #has_key?"

  it { should respond_to :collection_for }
  it { should respond_to :nil_for        }
  it { should respond_to :persisted_for  }
  it { should respond_to :repository_for }

  describe "#collection_for" do
    subject { registry.collection_for(FakeModel) } 
    it { should be FakeModel::Collection } 
  end
  
  describe "#nil_for" do
    subject { registry.nil_for(FakeModel) } 
    it { should be FakeModel::Nil } 
  end
  
  describe "#persisted_for" do
    subject { registry.persisted_for(FakeModel) } 
    it { should be FakeModel::Persisted } 
  end
  
  describe "#persisted_for" do
    subject { registry.persisted_for(FakeModel) } 
    it { should be FakeModel::Persisted } 
  end
end
