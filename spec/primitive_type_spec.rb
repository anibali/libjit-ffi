($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::PrimitiveType do
  %w[uint8 int8 uint16 int16 uint32 int32 uint64 int64 uintn intn].each do |t|
    context ".new(:#{t})" do
      subject { JIT::PrimitiveType.new(t.to_sym) }
      
      it_should_behave_like "an #{t} type"
    end
  end

  %w[float32 float64].each do |t|
    context ".new(:#{t})" do
      subject { JIT::PrimitiveType.new(t.to_sym) }
      
      it_should_behave_like "a #{t} type"
    end
  end

  context ".new(:foo_bar)" do
    it do
      expect {
        JIT::PrimitiveType.new(:foo_bar)
      }.to raise_exception(JIT::UnsupportedTypeError)
    end
  end
end

