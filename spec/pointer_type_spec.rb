($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::PointerType do
  %w[uint8 int8 uint16 int16 uint32 int32 uint64 int64 uintn intn].each do |t|
    context ".new(:#{t})" do
      let(:type) { JIT::PointerType.new(t) }
      subject { type }
      
      it_should_behave_like 'a pointer type'
      
      describe('ref_type') do
        subject { type.ref_type }
        
        it_should_behave_like "an #{t} type"
      end
    end
  end

  %w[float32 float64 pointer void].each do |t|
    context ".new(:#{t})" do
      let(:type) { JIT::PointerType.new(t) }
      subject { type }
      
      it_should_behave_like 'a pointer type'
      
      describe('ref_type') do
        subject { type.ref_type }
        
        it_should_behave_like "a #{t} type"
      end
    end
  end

  # Pointer to a pointer to an 8-bit integer
  context ".new(:pointer, :int8)" do
    let(:type) { JIT::PointerType.new(:pointer, :int8) }
    subject { type }
    
    it_should_behave_like 'a pointer type'
    
    describe('ref_type') do
      subject { type.ref_type }
      
      it_should_behave_like 'a pointer type'
      
      describe('ref_type') do
        subject { type.ref_type.ref_type }
        
        it_should_behave_like 'an int8 type'
      end
    end
  end
end

