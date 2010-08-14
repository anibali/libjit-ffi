require 'spec_helper'

describe JIT::Constant do

context "when type is 'uint32'" do
  [0, 2, 63, 127, 200, 1024, 2**32 - 1].each do |x|
    context "and value is #{x}" do
      it "should evaluate to #{x}" do
        evaluate_to(:uint32) { |f| f.const(x, :uint32) }.should eql(x)
      end
      
      its(:to_i) do
        in_function { |f| f.const(x, :uint32).to_i.should eql(x) }
      end
    end
  end
end

context "when type is 'uint64'" do
  [0, 63, 2**32 - 1, 2**64 - 1].each do |x|
    context "and value is #{x}" do
      it "should evaluate to #{x}" do
        evaluate_to(:uint64) { |f| f.const(x, :uint64) }.should eql(x)
      end
      
      its(:to_i) do
        in_function { |f| f.const(x, :uint64).to_i.should eql(x) }
      end
    end
  end
end

context "when type is 'uintn'" do
  [0, 2, 63, 127, 200, 1024, [-1].pack('i').unpack('I').first].each do |x|
    context "and value is #{x}" do
      it "should evaluate to #{x}" do
        evaluate_to(:uintn) { |f| f.const(x, :uintn) }.should eql(x)
      end
      
      its(:to_i) do
        in_function { |f| f.const(x, :uintn).to_i.should eql(x) }
      end
    end
  end
end

context "when type is 'bool'" do
  [true, false].each do |x|
    context "and value is #{x}" do
      it "should evaluate to #{x}" do
        evaluate_to(:bool) { |f| f.const(x, :bool) }.should eql(x)
      end
      
      its(:to_b) do
        in_function { |f| f.const(x, :bool).to_b.should eql(x) }
      end
    end
  end
end

context "when type is 'float32'" do
  [0.2, -3.56, 3421.1235].each do |x|
    context "and value is #{x}" do
      it "should evaluate to #{x}" do
        evaluate_to(:float32) { |f| f.const(x, :float32) }.should be_close(x, 0.0001)
      end
      
      its(:to_f) do
        in_function { |f| f.const(x, :float32).to_f.should be_close(x, 0.0001) }
      end
    end
  end
end

context "when type is 'foo'" do
  it do
    expect do
      in_function do |f|
        f.const(0, :foo)
      end
    end.to raise_exception JIT::TypeError
  end
end
  
end

