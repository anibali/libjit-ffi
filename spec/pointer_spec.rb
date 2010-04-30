require File.dirname(__FILE__) + "/spec_helper"

describe JIT::Pointer do

let(:context) { JIT::Context.new }

context "when type is 'uint8'" do
describe "#dereference" do
  let :func do
    context.build_function [:uint8], :uint8 do |f|
      a = f.arg(0)
      ptr = a.address
      a = ptr.dereference
      f.return a
    end
  end
  subject { func }
  
  [0, 2, 5, 63, 127, 200, 255].each do |x|
    context "when evaluating 'x = #{x}; dereference(address_of(x))'" do
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

