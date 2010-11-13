($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Value do

before do
  @context = JIT::Context.new
end

context "when type is 'int32'" do
  %w[+ - * **].each do |op|
    describe op do
      before do
        @func = @context.build_function [:int32, :int32], :float32 do |f|
          f.return f.arg(0).send(op, f.arg(1))
        end
      end
      
      [2, 8, 9, 3, 20, 0, -5, 3].each_slice(2) do |a, b|
        context "when evaluating #{a} #{op} #{b}" do
          it { @func[a, b].should be_within(1e-4).of(a.send(op, b)) }
        end
      end
    end
  end
  
  %w[/ %].each do |op|
    describe op do
      before do
        @func = @context.build_function [:int32, :int32], :float32 do |f|
          f.return f.arg(0).send(op, f.arg(1))
        end
      end
      
      [2, 8, 9, 3, 20, 1].each_slice(2) do |a, b|
        context "when evaluating #{a} #{op} #{b}" do
          it { @func[a, b].should be_within(1e-4).of(a.send(op, b)) }
        end
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
      it { @func[a, b].should be_within(1e-4).of(a + b) }
    end
  end
end

describe "#acos" do
  before do
    @func = @context.build_function [:float32], :float32 do |f|
      f.return f.math.acos(f.arg(0))
    end
  end
  
  [0.4, 0.3, -0.1, 0.43, 0, 1].each do |x|
    context "when evaluating acos(#{x})" do
      subject { @func[x] }
      it { should be_within(1e-4).of(Math.acos(x)) }
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
      it { @func[a, b].should be_within(1e-6).of(a + b) }
    end
  end
end

end

after do
  @context.destroy # Die monster, you don't belong in this world!
end
  
end

