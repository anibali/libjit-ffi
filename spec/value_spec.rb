($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Value do

before do
  @context = JIT::Context.new
  @context.build_start
end

context "when type is :int8" do
  before do
    @function = JIT::Function.new [:int8], :void
    @value = @function.arg(0)
  end
  
  context "after #address is called" do
    before do
      @value.address
    end
    subject { @value }
    
    its(:addressable?) { should be_true }
  end
  
  describe "#type" do
    subject { @value.type }
    
    its(:to_sym) { should eql(:int8) }
    it { should be_kind_of(JIT::PrimitiveType) }
  end
end

context "when type is :intn" do
  before do
    @function = JIT::Function.new [:intn], :void
    @value = @function.arg(0)
  end
  
  context "after #address is called" do
    before do
      @value.address
    end
    subject { @value }
    
    its(:addressable?) { should be_true }
  end
  
  describe "#type" do
    subject { @value.type }
    
    its(:to_sym) { should eql(:intn) }
    it { should be_kind_of(JIT::PrimitiveType) }
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end

end

