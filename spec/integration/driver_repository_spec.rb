require './spec/integration/integration_spec_helper'

describe 'integration test with drivers' do
  context "save successful" do
    it "FIXME: the persisted object reflects the saved attributes appropriately"
  end

  context "save failed" do
    it "throws an error if there is an exact duplicate of the #id of the object it's trying to save" do
      pending "impl"
      expect {
        subject.save(example)
        subject.save(example)
      }.to raise_error Arsenal::DuplicateRecord
    end
  end

  context "updating an already persisted Example" do
    it "returns an object containing the new updates"
  end
end
