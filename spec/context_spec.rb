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
  subject { @context }
  
  context "when holding build lock" do
    before do
      @context.build_start
    end
  
    it "should not be able to acquire build lock again" do
      expect {
        @context.build {}
      }.to raise_exception JIT::Error
    end
    
    it "should be able to create functions" do
      expect {
        func = @context.function [], :void do |f|
          f.return
        end
        func.call
      }.to_not raise_exception
    end
    
    its("destroyed?") { should be_false }
    
    after do
      @context.build_end
    end
  end
  
  context "when destroyed" do
    before do
      @context.destroy
    end
    
    it "should not be able to acquire build lock" do
      expect {
        @context.build {|c|}
      }.to raise_exception(JIT::Error)
    end
    
    its("destroyed?") { should be_true }
  end
  
  after do
    @context.destroy
  end
end

