require 'spec_helper'

describe 'Example::Persisted' do
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
  after { Object.send(:remove_const, :Example) }

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

    it { should respond_to :nil? }
    it { should_not be_nil }
  end
end
