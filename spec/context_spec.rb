require 'libjit'

def new_context_build &block
  context = JIT::Context.new
  context.build &block
  context.destroy
end

describe JIT::Context do
  before do
    @context = JIT::Context.new
  end
  
  context "when holding build lock" do
    before do
      @context.build_start
    end
  
    it "should not be able to acquire build lock" do
      lambda do
        @context.build {}
      end.should raise_exception JIT::Error
    end
    
    it "should be able to create functions" do
      lambda do
        func = @context.function [], :void do |f|
          f.return
        end
        func.call
      end.should_not raise_exception
    end
    
    after do
      @context.build_end
    end
  end
  
  context "when destroyed" do
    before do
      @context.destroy
    end
    
    it "should not be able to acquire build lock" do
      lambda do
        @context.build {|c|}
      end.should raise_exception(JIT::Error)
    end
  end
  
  after do
    @context.destroy unless @context.destroyed?
  end
end

