require './spec/unit/unit_spec_helper'

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
  it { should respond_to :for     }

  it { should be_an Enumerable }

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

  describe '#select' do
    subject { collection.select { true } }
    it { should be_a Arsenal::AttributeCollection }
  end

  describe '#for' do
    let (:driver1) { double('driver1') }
    let (:driver2) { double('driver2') }
    let (:attr_d1) { double('test1_attribute') }
    let (:attr_d2) { double('test2_attribute') }
    let (:attr_id) { double('id_attribute') }

    before do
      attr_d1.stub(:name => :foo, :driver => driver1)
      attr_d2.stub(:name => :bar, :driver => driver2)
      attr_id.stub(:name => :id, :driver => nil)
    end

    subject { Arsenal::AttributeCollection.new([attr_d1, attr_d2]).for(driver1) }

    it { should be_a Arsenal::AttributeCollection }
    it 'returns all the attributes with the given driver and the :id attribute' do
      subject.should be_all { |a| a.driver == driver1 || a.name == :id }
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
      expect { collection << Class.new }.to raise_error ArgumentError
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
