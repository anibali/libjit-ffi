($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Function do

let(:context) { JIT::Context.new }

before do
  @one_arg_func = context.build_function [:int32], :void do |f|
  end
end

describe "#call" do
  context "when passed too many arguments" do
    it { expect { @one_arg_func.call 42, 42 }.to raise_exception ArgumentError }
  end
  
  context "when passed too few arguments" do
    it { expect { @one_arg_func.call }.to raise_exception ArgumentError }
  end
  
  context "when passed correct number of arguments" do
    it { expect { @one_arg_func.call 42 }.to_not raise_exception ArgumentError }
  end
end

describe "#arg(index)" do
  context "when index is within bounds" do
    it { expect { @one_arg_func.arg(0) }.to_not raise_exception JIT::InstructionError }
  end
  
  context "when index is negative" do
    it { expect { @one_arg_func.arg(-5) }.to raise_exception JIT::InstructionError }
  end
  
  context "when index is too high" do
    it { expect { @one_arg_func.arg(1) }.to raise_exception JIT::InstructionError }
  end
end

after do
  context.destroy # Die monster, you don't belong in this world!
end
  
end

