require 'libjit'

describe JIT::StructType do

describe '#offset(0)' do
  subject { @type.offset(0) }
  
  context "when struct has fields [:int8, :int32, :int8, :int16]" do
    before { @type = JIT::StructType.new(:int8, :int32, :int8, :int8) }
    
    it { should eql(0) }
  end
end

end

