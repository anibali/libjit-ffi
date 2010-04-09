require 'libjit'

describe JIT::PointerType do

describe '#target_type' do
  subject { @type.target_type.to_sym }
  
  %w[int8 int16 int32 int64 float32 float64 uint8 uint16 uint32 uint64 pointer
     void].each do |t|
    context "when target type is '#{t}'" do
      before { @type = JIT::PointerType.new(t) }
      
      it { should eql(t.to_sym) }
    end
  end
end

describe '#pointer?' do
  subject { @type.pointer? }
  
  %w[int8 int16 int32 int64 float32 float64 uint8 uint16 uint32 uint64 pointer
     void].each do |t|
    context "when target type is '#{t}'" do
      before { @type = JIT::PointerType.new(t) }
      
      it { should be_true }
    end
  end
  
  # Pointer to a pointer to an 8-bit integer
  context "when target type is a int8 pointer" do
    before { @type = JIT::PointerType.new(:pointer, :int8) }
    
    it { should be_true }
  end
end

end

