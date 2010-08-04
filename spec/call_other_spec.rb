require 'spec_helper'

describe JIT::Function do

before do
  @context = JIT::Context.new
end

describe "#call_other" do
  before do
    @int_pow = @context.build_function [:int32, :int32], :int32 do |f|
      f.return(f.math.rint(f.arg(0) ** f.arg(1)))
    end
    
    @square = @context.build_function [:int32], :int32 do |f|
      f.return(f.call_other(@int_pow, f.arg(0), f.const(2, :int32)))
    end
  end
  
  [2, 8, 9, 3, 20, 0, -5, 3].each do |a|
    context "when curry squaring #{a}" do
      it { @square[a].should eql(a ** 2) }
    end
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end
  
end

