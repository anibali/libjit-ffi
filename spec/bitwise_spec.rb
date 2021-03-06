($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Value do

before do
  @context = JIT::Context.new
end

context "when type is 'uint8'" do
describe "#~" do
  let :func do
    @context.build_function [:uint8], :uint8 do |f|
      f.return ~f.arg(0)
    end
  end
  
  [0, 2, 5, 63, 127, 200, 255].each do |x|
    context "when evaluating '~#{x}'" do
      subject { func[x] }
      it { should eql((2**8 - 1) - x) }
    end
  end
end
end

describe "bitwise NOT" do
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

describe "bitwise AND" do
  context "when type is 'uint8'" do
    before do
      @func = @context.build_function [:uint8, :uint8], :uint8 do |f|
        f.return(f.arg(0) & f.arg(1))
      end
    end
    
    [%w[101010 011], %w[10100 111], %w[110 11010]].each do |xs|
      xs = xs.map {|x| x.to_i(2)}
      
      context "and values are #{xs.inspect}" do
        subject { @func[*xs] }
        it { should eql(xs[0] & xs[1]) }
      end
    end
  end
end

describe "bitwise XOR" do
  context "when type is 'uint8'" do
    before do
      @func = @context.build_function [:uint8, :uint8], :uint8 do |f|
        f.return(f.arg(0) ^ f.arg(1))
      end
    end
    
    [%w[101010 011], %w[10100 111], %w[110 11010]].each do |xs|
      xs = xs.map {|x| x.to_i(2)}
      
      context "and values are #{xs.inspect}" do
        subject { @func[*xs] }
        it { should eql(xs[0] ^ xs[1]) }
      end
    end
  end
end

describe "bitwise OR" do
  context "when type is 'uint8'" do
    before do
      @func = @context.build_function [:uint8, :uint8], :uint8 do |f|
        f.return(f.arg(0) | f.arg(1))
      end
    end
    
    [%w[101010 011], %w[10100 111], %w[110 11010]].each do |xs|
      xs = xs.map {|x| x.to_i(2)}
      
      context "and values are #{xs.inspect}" do
        subject { @func[*xs] }
        it { should eql(xs[0] | xs[1]) }
      end
    end
  end
end

describe "bitwise left shift" do
  context "when type is 'uint8'" do
    before do
      @func = @context.build_function [:uint8, :uint8], :uint8 do |f|
        f.return(f.arg(0) << f.arg(1))
      end
    end
    
    [%w[001010 1], %w[101 11]].each do |xs|
      xs = xs.map {|x| x.to_i(2)}
      
      context "and values are #{xs.inspect}" do
        subject { @func[*xs] }
        it { should eql(xs[0] << xs[1]) }
      end
    end
  end
end

describe "bitwise right shift" do
  context "when type is 'uint8'" do
    before do
      @func = @context.build_function [:uint8, :uint8], :uint8 do |f|
        f.return(f.arg(0) >> f.arg(1))
      end
    end
    
    [%w[001010 1], %w[10111 11]].each do |xs|
      xs = xs.map {|x| x.to_i(2)}
      
      context "and values are #{xs.inspect}" do
        subject { @func[*xs] }
        it { should eql(xs[0] >> xs[1]) }
      end
    end
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end
  
end

