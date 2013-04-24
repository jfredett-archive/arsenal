require './spec/unit/unit_spec_helper'

describe Arsenal::Registry do

  it { should respond_to :register }
  it { should respond_to :[] }
  it { should respond_to :clear! }
  it { should respond_to :has_key? }
  it { should respond_to :empty? }

  it { should be_an Enumerable }
  it { should respond_to :each }


  let (:mapper) { lambda { |r| "|#{r}|" } }
  let (:registry) { Arsenal::Registry.new &mapper }
  let (:registrant) { "A lovely bunch of coconuts." }
  subject { registry }

  describe "#register" do
    subject { registry.register(registrant) }

    it { should be registry }
    it { should have_key registrant }

    context "the value associated with the registered key" do
      before { registry.register(registrant) }
      subject { registry[registrant] }

      it { should == mapper.call(registrant) }
    end
  end

  describe "#clear!" do
    before do
      registry.register(registrant)
      registry.should have_key(registrant)
      registry.clear!
    end

    it { should_not have_key(registrant) }
    it { should be_empty }

    it { should be_a Arsenal::Registry }
  end

  context "delegated methods" do
    let (:internal_registry) { double('registry') }
    let (:registry) { Arsenal::Registry.new internal_registry, &mapper }

    it "delegates #[] to the internal registry" do
      internal_registry.should_receive(:[]).with(registrant)
      subject[registrant]
    end

    it "delegates #each to the internal registry" do
      internal_registry.should_receive(:each)
      subject.each
    end

    it "delegates #has_key? to the internal registry" do
      internal_registry.should_receive(:has_key?).with(registrant)
      subject.has_key?(registrant)
    end
  end
end
