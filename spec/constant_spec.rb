require 'libjit'

describe JIT::Constant do

before do
  @context = JIT::Context.new
end

context "when type is 'uint32'" do
  [0, 2, 63, 127, 200, 1024, 4294967295].each do |x|
    it "should work for a value of #{x}" do
      @func = @context.build_function [], :uint64 do |f|
        num = f.const :uint32, x
        f.return num
      end
      @func[].should eql(x)
    end
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end
  
end

