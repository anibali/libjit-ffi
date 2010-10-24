($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Function do
  let(:context) { JIT::Context.new }  
  
  it "should handle 'while' statements" do
    func = context.build_function [:uint32], :uint32 do |f|
      zero = f.const(0, :int8)
      one = f.const(1, :int8)
      
      res = f.declare :int8
      res.store zero
      
      f.while { res < f.arg(0) }.do {
        res.store(res + one)
      }.end
      
      f.return res
    end
    
    func.call(0).should eql(0)
    func.call(5).should eql(5)
  end
  
  it "should handle 'break' in 'while' statements" do
    func = context.build_function [:uint32], :uint32 do |f|
      zero = f.const(0, :int8)
      one = f.const(1, :int8)
      
      res = f.declare :int8
      res.store zero
      
      f.while { res < f.arg(0) }.do {
        res.store(res + one)
        f.break
      }.end
      
      f.return res
    end
    
    func.call(0).should eql(0)
    func.call(5).should eql(1)
    func.call(1000).should eql(1)
  end
  
  it "should handle 'until' statements" do
    func = context.build_function [:uint32], :uint32 do |f|
      zero = f.const(0, :int8)
      one = f.const(1, :int8)
      
      res = f.declare :int8
      res.store zero
      
      f.until { res >= f.arg(0) }.do {
        res.store(res + one)
      }.end
      
      f.return res
    end
    
    func.call(0).should eql(0)
    func.call(5).should eql(5)
  end
  
  after do
    context.destroy
  end
end

