($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Label do
  describe ".wrap" do
    it "should correctly wrap label pointers" do
      in_function do |f|
        lbl_jit_t = f.label.jit_t
        JIT::Label.wrap(f, lbl_jit_t).jit_t.address.should eql(lbl_jit_t.address)
      end
    end
  end
end

