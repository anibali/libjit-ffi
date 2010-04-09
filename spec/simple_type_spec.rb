require 'libjit'

describe JIT::SimpleType do

context "when initializing" do
  it "should fail if type isn't recognized" do
    lambda do
      JIT::SimpleType.new(:foo_bar)
    end.should raise_exception(JIT::TypeError)
  end
end

describe '#void?' do
  subject { @type.void? }
  
  context "when type is 'void'" do
    before { @type = JIT::SimpleType.new('void') }
    
    it { should be_true }
  end
  
  %w[int8 int16 int32 int64 float32 float64 uint8 uint16 uint32 uint64].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::SimpleType.new(t) }
      
      it { should be_false }
    end
  end
end

describe '#signed?' do
  subject { @type.signed? }
  
  %w[int8 int16 int32 int64 float32 float64].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::SimpleType.new(t) }
      
      it { should be_true }
    end
  end
  
  %w[uint8 uint16 uint32 uint64 void].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::SimpleType.new(t) }
      
      it { should be_false }
    end
  end
end

describe '#unsigned?' do
  subject { @type.unsigned? }
  
  %w[uint8 uint16 uint32 uint64].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::SimpleType.new(t) }
      
      it { should be_true }
    end
  end
  
  %w[int8 int16 int32 int64 float32 float64 void].each do |t|
    context "when type is '#{t}'" do
      before { @type = JIT::SimpleType.new(t) }
      
      it { should be_false }
    end
  end
end

describe '#size' do
  subject { @type.size }
  
  { :uint8 => 1,
    :int8 => 1,
    :uint16 => 2,
    :int16 => 2,
    :uint32 => 4,
    :int32 => 4,
    :uint64 => 8,
    :int64 => 8,
    :float32 => 4,
    :float64 => 8
  }.each do |k, v|
    context "when type is #{k.inspect}" do
      before { @type = JIT::SimpleType.new(k) }
      
      it { should eql(v) }
    end
  end
end

end

