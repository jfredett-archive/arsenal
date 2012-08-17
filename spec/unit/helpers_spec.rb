require './spec/unit/unit_spec_helper'

describe "be_defined, be_undefined" do
  after do
    Object.send(:remove_const, "Foo") rescue nil #igore failures
  end

  it "properly detects and undefined class" do
    "Foo".should_not be_defined
    "Foo".should be_undefined
  end

  it "properly detects a defined class" do
    class Foo
    end

    "Foo".should be_defined
    "Foo".should_not be_undefined
  end
end

describe 'be_a_subset_of, be_a_superset_of' do
  before do
    class IncluderExample
      def initialize(str)
        @str = str
      end

      def each
        @str.chars
      end

      def include?(other)
        return false unless other.is_a? String and other.length == 1
        each { |c| return true if c == other }
      end
    end
  end

  after do
    Object.send(:remove_const, :IncluderExample)
  end

  let (:subset) { [1,3,4] }
  let (:superset) { [1,2,3,4,5,6] } 

  let (:include_sub) { IncluderExample.new("abc") } 
  let (:include_super) { IncluderExample.new("abcde") } 


  describe 'be_a_subset_of' do
    it "properly detects a subset" do
      subset.should be_a_subset_of superset
    end

    it "properly detects a not-subset" do
      superset.should_not be_a_subset_of subset
    end

    it 'works when the LHS implements #each, and the RHS implements #include?' do
      include_sub.should be_a_subset_of include_super
    end
  end

  describe 'be_a_superset_of' do
    it "properly detects a superset" do
      superset.should be_a_superset_of subset
    end

    it "properly detects a not-superset" do
      subset.should_not be_a_superset_of superset
    end

    it 'works when the LHS implements #each, and the RHS implements #include?' do
      include_super.should be_a_superset_of include_sub
    end
  end


end
