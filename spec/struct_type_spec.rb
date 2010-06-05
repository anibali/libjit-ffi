require 'libjit'

describe JIT::StructType do

describe '#offset(0)' do
  subject { @type.offset(0) }
  
  context "when struct has fields [:int8, :int32, :int8, :int16]" do
    before { @type = JIT::StructType.new(:int8, :int32, :int8, :int8) }
    
    it { should eql(0) }
  end
end

describe '#name' do
  subject { @type.name }
  
  context "when name is set to 'point'" do
    before do
      @type = JIT::StructType.new
      @type.name = "point"
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
end

end

