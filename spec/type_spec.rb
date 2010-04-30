require 'libjit'

describe JIT::Type do

let(:context) { JIT::Context.new }

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
      @type.ref_type.pointer?.should be_true
      @type.ref_type.ref_type.to_sym.should eql(:int8)
    end
  end
end

describe "cast" do
  context "from :int32 to :int8" do
    let(:func) do
      context.build_function [:int32], :int8 do |f|
        x = f.arg(0)
        x = x.cast(:int8)
        f.return(x)
      end
    end

    [3, -112, 104, 57, -73].each do |x|
      context "when value is #{x}" do
        subject { func[x] }
        it { should eql(x) }
      end
    end
  end
end

after do
  context.destroy # Die monster, you don't belong in this world!
end

end

