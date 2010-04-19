require 'libjit'

describe JIT::PointerType do

context "new(:uint8)" do
  let(:type) { JIT::PointerType.new(:uint8) }
  subject { type }
  
  its(:pointer?) { should be_true }
  
  context "ref_type" do
    subject { type.ref_type }
    it { should_not be_nil }
    its(:pointer?) { should be_false }
    its(:unsigned?) { should be_true }
    its(:to_sym) { should eql(:uint8) }
    its(:size) { should eql(1) }
  end
end

describe '#ref_type' do
  subject { @type.ref_type.to_sym }
  
  %w[int8 int16 int32 int64 float32 float64 uint8 uint16 uint32 uint64 pointer
     void].each do |t|
    context "when ref type is '#{t}'" do
      before { @type = JIT::PointerType.new(t) }
      
      it { should eql(t.to_sym) }
    end
  end
end

describe '#pointer?' do
  subject { @type.pointer? }
  
  %w[int8 int16 int32 int64 float32 float64 uint8 uint16 uint32 uint64 pointer
     void].each do |t|
    context "when ref type is '#{t}'" do
      before { @type = JIT::PointerType.new(t) }
      
      it { should be_true }
    end
  end
  
  # Pointer to a pointer to an 8-bit integer
  context "when ref type is a int8 pointer" do
    before { @type = JIT::PointerType.new(:pointer, :int8) }
    
    it { should be_true }
  end
end

end

