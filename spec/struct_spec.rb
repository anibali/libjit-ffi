require 'libjit'

describe JIT::Struct do

before do
  @context = JIT::Context.new
end

context "when the fields are [int8, int8]" do
  before do
    @func = @context.build_function [:int8, :int8], :int32 do |f|
      v = JIT::Value.create(f, :struct, :int8, :int8)
      2.times { |i| v[i] = f.arg(i) }
      f.return(v[0] + v[1])
    end
  end
  
  [1, 2, -32, 47].each_slice(2) do |x, y|
    context "and values are [#{x}, #{y}]" do
      subject { @func[x, y] }
      it "should return #{x + y} as sum of fields" do
        should eql(x + y)
      end
    end
  end
end

context "when the fields are [int8, uint16]" do
  before do
    @func = @context.build_function [:int8, :uint16], :int32 do |f|
      v = JIT::Value.create(f, :struct, :int8, :uint16)
      2.times { |i| v[i] = f.arg(i) }
      f.return(v[0] + v[1])
    end
  end
  
  [1, 2, -32, 47].each_slice(2) do |x, y|
    context "and values are [#{x}, #{y}]" do
      subject { @func[x, y] }
      it "should return #{x + y} as sum of fields" do
        should eql(x + y)
      end
    end
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end
  
end

