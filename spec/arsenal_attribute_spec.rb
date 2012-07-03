require 'spec_helper'

describe 'Attributes and Attribute Collections' do
  describe Arsenal::Attribute do
    let(:attribute) { Arsenal::Attribute.new(:foo, default: :baz) } 
    let(:attribute_no_default) { Arsenal::Attribute.new(:quux) } 
    let(:attribute_required) { Arsenal::Attribute.new(:chex, required: true) } 

    subject { attribute } 

    it { should respond_to :name }
    it { should respond_to :value } 
    it { should respond_to :required? } 
    it { should respond_to :default }
    it { should respond_to :has_default? } 

    context 'aliases' do
      let(:attr_with_alias) { Arsenal::Attribute.new(:foo, method: :bar) } 
      let(:attr_with_default) { Arsenal::Attribute.new(:foo, method: :bar, default: "fail") } 
      let(:receiver) { receiver = double('instance') } 

      before do
        receiver.should_receive(:bar)
        receiver.should_not_receive(:foo)
      end

      it 'allows me to override the method called with the `method` parameter' do
        attr_with_alias.value(receiver)
      end

      it 'works even when the object has a default' do
        attr_with_default.value(receiver)
      end

      it 'still returns the default if the receiver does not implement the method' do
        receiver.stub(:respond_to?).with(:bar).and_return(:false)
        attr_with_default.value(receiver)
      end
    end

    describe '#required?' do
      context 'a required attribute' do
        subject { attribute_required }
        it { should be_required }
      end

      context 'an unrequired attribute' do
        subject { attribute } 
        it { should_not be_required }
      end
    end

    describe '#default' do
      its(:default) { should == :baz } 

      describe '#has_default?' do 
        context 'when the attribute sets a default value' do
          subject { attribute }
          it { should have_default } 
        end

        context 'when the attribute does not set a default value' do
          subject { attribute_no_default }
          it { should_not have_default } 
        end
      end
    end

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

    pending 'drivers' do
      it { should respond_to :drivers }
    end
  end

  describe Arsenal::AttributeCollection do
    let(:attr1) { Arsenal::Attribute.new(:fee, default: :tweedle) }
    let(:attr2) { Arsenal::Attribute.new(:fye, default: :deedle)  }
    let(:attr3) { Arsenal::Attribute.new(:foe, default: :dum)     }
    let(:attr4) { Arsenal::Attribute.new(:bla, default: :ralb)   }

    let(:collection) { Arsenal::AttributeCollection.new([attr1, attr2, attr3]) }

    subject { collection }

    it { should respond_to :[]      }
    it { should respond_to :<<      }
    it { should respond_to :keys    }
    it { should respond_to :to_hash }
    it { should respond_to :each    }
    it { should respond_to :+       }

    describe '#==' do
      let(:collection_dup) { Arsenal::AttributeCollection.new([attr1, attr2, attr3]) }
      let(:collection_unordered) { Arsenal::AttributeCollection.new([attr2, attr3, attr1]) }
      let(:collection_diff) { Arsenal::AttributeCollection.new([attr1, attr2]) }
      let(:collection_superset) { Arsenal::AttributeCollection.new([attr1, attr2, attr3, attr4]) }

      it { should == collection_dup } 
      it { should == collection_unordered } 

      it { should_not == collection_diff } 
      it { should_not == collection_superset } 
    end

    describe '#each' do
      let (:mock_attr) { double('test_attribute') } 
      subject { Arsenal::AttributeCollection.new([mock_attr]) } 

      its(:each) { should be_an Enumerator } 

      it 'touches every attribute in the collection' do
        mock_attr.should_receive(:test_message) 
        subject.each do |attr|
          attr.test_message      
        end
      end
    end

    describe '#+' do
      let (:collection1) { Arsenal::AttributeCollection.new([attr1, attr2]) }
      let (:collection2) { Arsenal::AttributeCollection.new([attr3])        }

      context 'adding nil' do
        subject { collection1 + nil } 

        it { should == collection1 } 
      end

      context 'adding a collection' do

        subject { collection1 + collection2 } 

        it { should == collection } 
      end
      context 'adding a malformed collection' do
        subject { collection1 + [double('malformed collection')] }
       
        it 'throws an argument error' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end

    describe '#keys' do
      its(:keys) { should =~ [:fye, :foe, :fee] }
    end

    describe '#to_hash' do
      let(:klass) { double('mock').stub(:fee => 1, :fye => 2, :foe => 3)  }
      subject { collection.to_hash(klass) } 

      it { should be_a Hash } 
      its(:length) { should be 3 }
      its(:keys) { should =~ [:fee, :fye, :foe] }
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
