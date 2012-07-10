require 'spec_helper'

describe 'Example::Collection' do
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

  context 'instance' do 
    subject { Example::Collection.new([Example.new, Example.new, Example::Persisted.new, nil_example]) }

    it { should respond_to :each } 

    it { should delegate(:a_method).to_each.when_sent(:a_method) } 

    it { should delegate(:predicate?).to_each.and_aggregate_with(:all?).when_sent(:all_predicate?) }
    it { should delegate(:predicate?).to_each.and_aggregate_with(:any?).when_sent(:any_predicate?) }

    it { should delegate(:savable?)  .to_each.and_aggregate_with(:all?).when_sent(:savable?)   }
    it { should delegate(:persisted?).to_each.and_aggregate_with(:all?).when_sent(:persisted?) }
  end
end

