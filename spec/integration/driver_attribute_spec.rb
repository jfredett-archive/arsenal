require './spec/integration/integration_spec_helper.rb'

describe 'driver/attribute integration' do
  # this will eventually be replaced with 'strategy'
  let(:attr_driver) { Arsenal::Attribute.new(:attr_driver, :driver => :some_driver) } 
  subject { attr_driver } 

  context 'naming a specific driver' do
    subject { attr_driver.driver }  

    pending "implementation of drivers" do
      #driver api
      subject { should respond_to :write } 
      subject { should respond_to :delete }
      subject { should respond_to :find } 
    end
  end
end
