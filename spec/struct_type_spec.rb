($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::StructType do
  context "when fields are two 32-bit integers named 'x' and 'y'" do
    subject do
      @type = JIT::StructType.new(:int32, :int32)
      @type.field_names = ['x', 'y']
      @type
    end
    
    it_should_behave_like 'a struct type'
    
    its(:struct_name) { should be_nil }
    
    its(:find_field, 'x') { should eql 0 }
    its(:find_field, 'y') { should eql 1 }
    
    its(:field_name, 0) { should eql 'x' }
    its(:field_name, 1) { should eql 'y' }
    
    its(:field_count) { should eql 2 }
    
    its(:offset, 0) { should eql 0 }
    its(:offset, 1) { should eql 4 }
    
    context "when struct is named 'point'" do
      subject do
        @type = JIT::StructType.new(:int32, :int32)
        @type.field_names = ['x', 'y']
        @type.struct_name = 'point'
        @type
      end
      
      it_should_behave_like 'a struct type'
      
      its(:struct_name) { should eql 'point' }
      
      its(:find_field, 'x') { should eql 0 }
      its(:find_field, 'y') { should eql 1 }
      
      its(:field_name, 0) { should eql 'x' }
      its(:field_name, 1) { should eql 'y' }
      
      its(:field_count) { should eql 2 }
      
      its(:offset, 0) { should eql 0 }
      its(:offset, 1) { should eql 4 }
    end
  end
end

