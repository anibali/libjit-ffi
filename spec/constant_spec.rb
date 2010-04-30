require 'libjit'

describe JIT::Constant do

let(:context) { JIT::Context.new }

context "when type is 'uint64'" do
  [0, 2, 63, 127, 200, 1024, 2**32 - 1].each do |x|
    context "and value is #{x}" do
      it "should evaluate to #{x}" do
        context.build_function [], :uint32 do |f|
          num = f.const(x, :uint32)
          f.return num
        end.call.should eql(x)
      end

      describe "#to_i" do
        it do
           context.build_function [], :void do |f|
            num = f.const(x, :uint32)
            num.to_i.should eql(x)
          end
        end
      end
    end
  end
end

context "when type is 'uint64'" do
  [0, 63, 2**32 - 1, 2**64 - 1].each do |x|
    context "and value is #{x}" do
      it "should evaluate to #{x}" do
        context.build_function [], :uint64 do |f|
          num = f.const(x, :uint64)
          f.return num
        end.call.should eql(x)
      end

      describe "#to_i" do
        it do
          context.build_function [], :void do |f|
            num = f.const(x, :uint64)
            num.to_i.should eql(x)
          end
        end
      end
    end
  end
end

after do
  context.destroy # Die monster, you don't belong in this world!
end
  
end

