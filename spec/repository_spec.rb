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
  it { should respond_to :find }
  it { should respond_to :destroy }
end
