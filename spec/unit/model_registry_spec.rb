require './spec/unit/unit_spec_helper'

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

  # #have_model? aliases to #have_key? at the ruby level, so there's no
  # delegation, they're literally the same method
  it { should respond_to :have_model? } 

  it { should respond_to :collection_for }
  it { should respond_to :nil_for        }
  it { should respond_to :persisted_for  }
  it { should respond_to :repository_for }

  context "looking up via the root model" do
    describe "#collection_for" do
      subject { registry.collection_for(FakeModel) } 
      it { should be FakeModel::Collection } 
    end

    describe "#nil_for" do
      subject { registry.nil_for(FakeModel) } 
      it { should be FakeModel::Nil.instance } 
    end

    describe "#persisted_for" do
      subject { registry.persisted_for(FakeModel) } 
      it { should be FakeModel::Persisted } 
    end

    describe "#repository_for" do
      subject { registry.repository_for(FakeModel) } 
      it { should be FakeModel::Repository } 
    end

    describe "#model_for" do
      subject { registry.model_for(FakeModel) } 
      it { should be FakeModel } 
    end
  end

  %w{Persisted Repository Nil Collection}.each do |generated|
    context "looking via the #{generated} generated model" do
      let (:klass) { "FakeModel::#{generated}".constantize } 

      describe "#collection_for" do
        subject { registry.collection_for(klass) } 
        it { should be FakeModel::Collection } 
      end

      describe "#nil_for" do
        subject { registry.nil_for(klass) } 
        it { should be FakeModel::Nil.instance } 
      end

      describe "#persisted_for" do
        subject { registry.persisted_for(klass) } 
        it { should be FakeModel::Persisted } 
      end

      describe "#persisted_for" do
        subject { registry.repository_for(klass) } 
        it { should be FakeModel::Repository } 
      end

      describe "#model_for" do
        subject { registry.model_for(FakeModel) } 
        it { should be FakeModel } 
      end
    end
  end
end
