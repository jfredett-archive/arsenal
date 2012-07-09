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

    it "delegates calls it doesn't understand to it's elements" do
      subject.each { |e| e.should_receive(:foo) } 
      subject.foo
    end

    it "takes methods of the form #any_<predicate>? and turns them into a .any? call" do
      subject.each { |e| e.should_receive(:predicate?).at_most(:once) } 
      subject.should_receive(:any?)
      subject.any_predicate?
    end

    it "takes methods of the form #all_<predicate>? and turns them into a .all? call" do
      subject.each { |e| e.should_receive(:predicate?).at_most(:once) } 
      subject.should_receive(:all?)
      subject.all_predicate?
    end

    it "aliases #savable? to #all_savable?" do
      subject.each { |e| e.should_receive(:savable?).at_most(:once) } 
      subject.should_receive(:all?)
      subject.savable?
    end

    it "aliases #persisted? to #all_persisted?" do
      subject.each { |e| e.should_receive(:persisted?).at_most(:once) } 
      subject.should_receive(:all?)
      subject.savable?
    end
  end
end

