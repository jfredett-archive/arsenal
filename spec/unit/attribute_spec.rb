require './spec/unit/unit_spec_helper'
describe Arsenal::Attribute do
  let(:attribute) { Arsenal::Attribute.new(:foo, default: :baz) } 

  subject { attribute } 

  it { should respond_to :name }
  it { should respond_to :value } 
  it { should respond_to :required? } 
  it { should respond_to :default }
  it { should respond_to :has_default? } 
  it { should respond_to :driver }

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
      subject { Arsenal::Attribute.new(:chex, required: true) } 
      it { should be_required }
    end

    context 'an unrequired attribute' do
      it { should_not be_required }
    end
  end

  describe '#default' do
    its(:default) { should == :baz } 

    describe '#has_default?' do 
      context 'when the attribute sets a default value' do
        it { should have_default } 
      end

      context 'when the attribute does not set a default value' do
        subject { Arsenal::Attribute.new(:quux) } 
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

  # this will eventually be replaced with 'strategy'
  context 'driver' do
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
end
