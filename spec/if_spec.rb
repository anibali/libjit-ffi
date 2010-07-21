require 'spec_helper'

describe JIT::Function do
  let(:context) { JIT::Context.new }  
  
  it "should handle 'if' statements" do
    pos_test = context.build_function [:int32], :int8 do |f|
      zero = f.const(0, :int8)
      one = f.const(1, :int8)
      
      res = f.declare :int8
      res.store zero
      
      f.if { f.arg(0) > zero }.do {
        res.store one
      }.end
      
      f.return res
    end
  
    pos_test.call(5).should_not eql(0)
    pos_test.call(-65).should eql(0)
    pos_test.call(0).should eql(0)
  end
  
  it "should handle 'if-else' statements" do
    pos_test = context.build_function  [:int32], :int8 do |f|
      zero = f.const(0, :int8)
      one = f.const(1, :int8)
      
      res = f.declare :int8
      
      f.if { f.arg(0) > zero }.do {
        res.store one
      }.else {
        res.store zero
      }.end
      
      f.return res
    end
  
    pos_test.call(5).should_not eql(0)
    pos_test.call(-65).should eql(0)
    pos_test.call(0).should eql(0)
  end
  
  it "should handle 'unless' statements" do
    pos_test = context.build_function [:int32], :int8 do |f|
      zero = f.const(0, :int8)
      one = f.const(1, :int8)
      
      res = f.declare :int8
      res.store zero
      
      f.unless { f.arg(0) <= zero }.do {
        res.store one
      }.end
      
      f.return res
    end
  
    pos_test.call(5).should_not eql(0)
    pos_test.call(-65).should eql(0)
    pos_test.call(0).should eql(0)
  end
  
  it "should handle 'unless-else' statements" do
    pos_test = context.build_function [:int32], :int8 do |f|
      zero = f.const(0, :int8)
      one = f.const(1, :int8)
      
      res = f.declare :int8
      
      f.unless { f.arg(0) <= zero }.do {
        res.store one
      }.else {
        res.store zero
      }.end
      
      f.return res
    end
  
    pos_test.call(5).should_not eql(0)
    pos_test.call(-65).should eql(0)
    pos_test.call(0).should eql(0)
  end
  
  after do
    context.destroy
  end
end

