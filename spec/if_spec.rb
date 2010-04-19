require 'libjit'

describe JIT::Function do
  let(:context) { JIT::Context.new }  
  
  it "should handle 'if' statements" do
    pos_test = context.build_function [:int32], :int8 do |f|
      zero = f.const(:int8, 0)
      one = f.const(:int8, 1)
      
      res = f.declare :int8
      res.store zero
      
      f.if(proc {f.arg(0) > zero}) do
        res.store one
      end
      
      f.return res
    end
  
    pos_test.call(5).should_not eql(0)
    pos_test.call(-65).should eql(0)
    pos_test.call(0).should eql(0)
  end
  
  it "should handle 'if-else' statements" do
    pos_test = context.build_function  [:int32], :int8 do |f|
      zero = f.const(:int8, 0)
      one = f.const(:int8, 1)
      
      res = f.declare :int8
      
      test = proc {f.arg(0) > zero}     # If arg(0) > 0
      main_proc = proc {res.store one}  #   res = 1
                                        # Else
      else_proc = proc {res.store zero} #   res = 0
      
      f.if(test, else_proc, &main_proc)
      
      f.return res
    end
  
    pos_test.call(5).should_not eql(0)
    pos_test.call(-65).should eql(0)
    pos_test.call(0).should eql(0)
  end
  
  it "should handle 'unless' statements" do
    pos_test = context.build_function [:int32], :int8 do |f|
      zero = f.const(:int8, 0)
      one = f.const(:int8, 1)
      
      res = f.declare :int8
      res.store zero
      
      f.unless(proc {f.arg(0) <= zero}) do
        res.store one
      end
      
      f.return res
    end
  
    pos_test.call(5).should_not eql(0)
    pos_test.call(-65).should eql(0)
    pos_test.call(0).should eql(0)
  end
  
  it "should handle 'unless-else' statements" do
    pos_test = context.build_function [:int32], :int8 do |f|
      zero = f.const(:int8, 0)
      one = f.const(:int8, 1)
      
      res = f.declare :int8
      
      test = proc {f.arg(0) <= zero}    # If arg(0) > 0
      main_proc = proc {res.store one}  #   res = 1
                                        # Else
      else_proc = proc {res.store zero} #   res = 0
      
      f.unless(test, else_proc, &main_proc)
      
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

