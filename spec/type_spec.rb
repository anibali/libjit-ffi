require 'libjit'

describe JIT::Type do

context "when initializing" do
  it "should fail if type isn't recognized" do
    lambda do
      JIT::Type.new(:foo_bar)
    end.should raise_exception(JIT::TypeError)
  end
end

describe '#void?' do
  subject { @type.void? }
  
  context "when type is 'void'" do
    before { @type = JIT::Type.new('void') }
    
    it { should be_true }
  end
  
  %w[int8 int16 int32 int64 float32 float64 uint8 uint16 uint32 uint64 pointer].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::Type.new(t) }
      
      it { should be_false }
    end
  end
end

describe '#signed?' do
  subject { @type.signed? }
  
  %w[int8 int16 int32 int64 float32 float64].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::Type.new(t) }
      
      it { should be_true }
    end
  end
  
  %w[uint8 uint16 uint32 uint64 pointer void].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::Type.new(t) }
      
      it { should be_false }
    end
  end
end

describe '#unsigned?' do
  subject { @type.unsigned? }
  
  %w[uint8 uint16 uint32 uint64].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::Type.new(t) }
      
      it { should be_true }
    end
  end
  
  %w[int8 int16 int32 int64 float32 float64 pointer void].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::Type.new(t) }
      
      it { should be_false }
    end
  end
end

describe '#pointer?' do
  subject { @type.pointer? }
  
  context "when type is 'pointer'" do
    before { @type = JIT::Type.new('pointer') }
    
    it { should be_true }
  end
  
  %w[int8 int16 int32 int64 float32 float64 uint8 uint16 uint32 uint64 void].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::Type.new(t) }
      
      it { should be_false }
    end
  end
end

end

