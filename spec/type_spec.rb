require 'libjit'

describe JIT::Type do

describe '.create' do
  context "when args are [:int8]" do
    before { @type = JIT::Type.create :int8 }
    
    it { @type.should be_a(JIT::Type) }
    
    it "should produce expected Type" do
      @type.to_sym.should eql(:int8)
    end
  end
  
  context "when args are [:pointer, :pointer, :int8]" do
    before { @type = JIT::Type.create :pointer, :pointer, :int8 }
    
    it { @type.should be_a(JIT::Type) }
    
    it "should produce expected Type" do
      @type.pointer?.should be_true
      @type.target_type.pointer?.should be_true
      @type.target_type.target_type.to_sym.should eql(:int8)
    end
  end
end

end

