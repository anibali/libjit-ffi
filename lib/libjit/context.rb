module JIT
class Context
  attr_reader :jit_t
  
  # Returns the Context currently used for building
  def self.current
    @@current
  end
  
  def initialize
    @jit_t = LibJIT.jit_context_create
    
    # Clean up if Context is garbage collected
    ObjectSpace.define_finalizer(self, proc { self.destroy })
  end
  
  def destroy
    LibJIT.jit_context_destroy @jit_t
    @jit_t = nil
  end
  
  def destroyed?
    @jit_t.nil?
  end
  
  def build
    build_start
    yield self
    build_end
  end
  
  def build_start
    if defined? @@current and not @@current.nil?
      if @@current == self
        raise JIT::Error.new("Context already holds the build lock")
      else
        raise JIT::Error.new("Another context holds the build lock")
      end
    end
  
    if @jit_t.nil?
      raise JIT::Error.new("Context can't be used to build once destroyed")
    end
    
    @@current = self
    LibJIT.jit_context_build_start @jit_t
  end
  
  def build_end
    @@current = nil
    LibJIT.jit_context_build_end @jit_t
  end
  
  def function param_types, return_type
    func = Function.new(param_types, return_type)
    
    if block_given?
      yield func
      func.compile
    end
    
    return func
  end
end
end
