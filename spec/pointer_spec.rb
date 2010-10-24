($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Pointer do

let(:context) { JIT::Context.new }

context "when type is 'uint8'" do
describe "#dereference" do
  let :deref_implicit do
    context.build_function [:int8], :int32 do |f|
      a = f.arg(0)
      ptr = a.address
      a = ptr.dereference
      f.return a
    end
  end
  
  let :deref_uint8 do
    context.build_function [:int8], :int32 do |f|
      a = f.arg(0)
      ptr = a.address
      a = ptr.dereference :uint8
      f.return a
    end
  end
  
  [0, 2, 5, 63, 127, -45, -128].each do |x|
    context "when evaluating 'x = #{x}; dereference(address_of(x))'" do
      subject { deref_implicit[x] }
      it { should eql(x) }
    end
  end
  
  [0, 2, 5, 63, 127, -45, -128].each do |x|
    context "when evaluating 'x = #{x}; dereference(address_of(x), int8)'" do
      subject { deref_uint8[x] }
      it { should eql [x].pack('c').unpack('C').first }
    end
  end
end
end

after do
  context.destroy # Die monster, you don't belong in this world!
end
  
end

