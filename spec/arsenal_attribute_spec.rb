require 'spec_helper'

describe 'Attributes and Attribute Collections' do
  describe Arsenal::Attribute do
    let(:attribute) { Arsenal::Attribute.new(:foo, default: :baz) } 

    subject { attribute } 

    it { should respond_to :name }
    it { should respond_to :default }
    it { should respond_to :value } 

    describe '#foo' do

      context '#value when the instance does not implement #foo' do
        subject { attribute.value(Class.new { }.new) } 
        it { should == :baz } 
      end

      context '#value when the instance implements #foo' do
        subject { attribute.value(Class.new { def foo ; 'the_value' ; end }.new) } 
        it { should == 'the_value' } 
      end
    end

    its(:default) { should == :baz } 

    pending 'drivers' do
      it { should respond_to :drivers }
    end
  end

  describe Arsenal::AttributeCollection do
    let(:attr1) { Arsenal::Attribute.new(:fee, default: :tweedle) }
    let(:attr2) { Arsenal::Attribute.new(:fye, default: :deedle)  }
    let(:attr3) { Arsenal::Attribute.new(:foe, default: :dum)     }

    let(:collection) { Arsenal::AttributeCollection.new([attr1, attr2, attr3]) }

    subject { collection }

    it { should respond_to :[]   }
    it { should respond_to :<<   } 
    it { should respond_to :keys } 

    describe '#keys' do
      its(:keys) { should =~ [:fye, :foe, :fee] }
    end

    describe '#<<' do
      let(:attr_test1) { Arsenal::Attribute.new(:test1) } 
      let(:attr_test2) { Arsenal::Attribute.new(:test2) } 

      subject { collection << attr_test1 } 

      it 'is chainable' do
        expect { collection << attr_test1 << attr_test2 }.to_not raise_error 
        collection[:test1].should_not be_nil
        collection[:test2].should_not be_nil
      end

      it 'adds an attribute to the collection' do
        subject[:test1].should == attr_test1
      end

      it "throws an error if the class given doesn't adhere to the Attribute API" do
        expect { 
          collection << Class.new 
        }.to raise_error ArgumentError
      end
    end

    describe '#[]' do
      it 'returns the attribute by name' do
        subject[:fee].should == attr1
        subject[:foe].should == attr3
      end

      it "returns nil if the attribute isn't in the collection" do
        subject[:slartibartfast].should be_nil  
      end
    end
  end
end
