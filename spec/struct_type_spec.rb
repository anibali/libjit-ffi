require 'spec_helper'

describe JIT::StructType do
  describe '.new(:int8, :int32, :int8, :int8)' do
    let(:type) { JIT::StructType.new(:int8, :int32, :int8, :int8) }
    subject { type }
    
    it_should_behave_like 'a struct type'
    
    describe 'offset(0)' do
      it { type.offset(0).should eql(0) }
    end
    
    its(:field_count) { should eql 4 }
  end

  describe '#name' do
    subject { @type.struct_name }
    
    context "when name is set to 'point'" do
      before do
        @type = JIT::StructType.new
        @type.struct_name = "point"
      end
      
      it { should eql("point") }
    end
    
    context "when name is not set" do
      before do
        @type = JIT::StructType.new
      end
      
      it { should be_nil }
    end
  end

  describe '#find_field' do
    subject { @type.find_field(@field) }
    
    context "when field names are 'x' and 'y' and required field is 'x'" do
      before do
        @type = JIT::StructType.new(:int32, :int32)
        @type.field_names = ['x', 'y']
        @field = 'x'
      end
      
      it { should eql(0) }
    end
    
    context "when struct name is 'point' and field names are 'x' and 'y' and required field is 'x'" do
      before do
        @type = JIT::StructType.new(:int32, :int32)
        @type.struct_name = 'point'
        @type.field_names = ['x', 'y']
        @field = 'x'
      end
      
      it { pending ; should eql(0) }
    end
  end
end

