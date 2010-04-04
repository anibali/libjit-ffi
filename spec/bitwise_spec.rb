require 'libjit'

describe JIT::Value do

before do
  @context = JIT::Context.new
end

describe "bitwise not" do
  context "when type is 'uint8'" do
    before do
      @func = @context.build_function [:uint8], :uint8 do |f|
        f.return ~f.arg(0)
      end
    end
    
    [0, 2, 5, 63, 127, 200, 255].each do |x|
      context "and value is #{x}" do
        subject { @func[x] }
        it { should eql((2**8 - 1) - x) }
      end
    end
  end
  
  context "when type is 'uint16'" do
    before do
      @func = @context.build_function [:uint16], :uint16 do |f|
        f.return ~f.arg(0)
      end
    end
    
    [0, 68, 127, 2000, 255, 9999, 65535].each do |x|
      context "and value is #{x}" do
        subject { @func[x] }
        it { should eql((2**16 - 1) - x) }
      end
    end
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end
  
end

