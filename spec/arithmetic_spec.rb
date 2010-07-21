require 'spec_helper'

describe JIT::Value do

before do
  @context = JIT::Context.new
end

context "when type is 'int32'" do
  describe "#**" do
    before do
      @func = @context.build_function [:int32, :int32], :int32 do |f|
        f.return f.arg(0) ** f.arg(1)
      end
    end
    
    [2, 8, 9, 3, 20, 0, -5, 3].each_slice(2) do |a, b|
      context "when evaluating #{a} ** #{b}" do
        it { @func[a, b].should eql(a ** b) }
      end
    end
  end
end

context "when type is 'float32'" do

describe "#+" do
  before do
    @func = @context.build_function [:float32, :float32], :float32 do |f|
      f.return f.arg(0) + f.arg(1)
    end
  end
  
  [0.4, 0.3, -0.1, 0.43, 432.65, 89.12354, 0, 7.6, 2, 3].each_slice(2) do |a, b|
    context "when evaluating #{a} + #{b}" do
      it { @func[a, b].should be_close(a + b, 0.0001) }
    end
  end
end

describe "#acos" do
  before do
    @func = @context.build_function [:float32], :float32 do |f|
      f.return f.acos(f.arg(0))
    end
  end
  
  [0.4, 0.3, -0.1, 0.43, 0, 1].each do |x|
    context "when evaluating acos(#{x})" do
      subject { @func[x] }
      it { should be_close(Math.acos(x), 0.0001) }
    end
  end
end

end

context "when type is 'float64'" do

describe "#+" do
  before do
    @func = @context.build_function [:float64, :float64], :float64 do |f|
      f.return f.arg(0) + f.arg(1)
    end
  end
  
  [0.4, 0.3, -0.1, 0.43, 432.65, 89.12354, 0, 7.6, 2, 3].each_slice(2) do |a, b|
    context "when evaluating #{a} + #{b}" do
      it { @func[a, b].should be_close(a + b, 0.000001) }
    end
  end
end

end

after do
  @context.destroy # Die monster, you don't belong in this world!
end
  
end

