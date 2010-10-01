module JIT
class Context
  attr_reader :jit_t

  @@default = nil
  @@current = nil
  
  # Gets the context currently used for building.
  #
  # @return [Context] the current context.
  def self.current
    @@current
  end
  
  # Gets the default context.
  #
  # @return [Context] the default context.
  def self.default
    @@default ||= new
  end
  
  def initialize
    @jit_t = LibJIT.jit_context_create
  end
  
  # Destroys the context. This method should be called when the context is no
  # longer required.
  def destroy
    return if destroyed?
    build_end if building?
    LibJIT.jit_context_destroy @jit_t
    @jit_t = nil
  end
  
  # Checks whether the context has been destroyed.
  #
  # @return [Boolean] true if destroyed, false otherwise.
  def destroyed?
    @jit_t.nil?
  end
  
  def build
    build_start
    begin
      yield self
    rescue Exception => ex
      build_end
      raise ex
    end
    build_end
  end
  
  def build_start
    if defined? @@current and not @@current.nil?
      if @@current == self
        raise JIT::BuildLockError.new("context already holds the build lock")
      else
        raise JIT::BuildLockError.new("another context holds the build lock")
      end
    end
  
    if @jit_t.nil?
      raise JIT::BuildLockError.new("context can't acquire the build lock once destroyed")
    end
    
    @@current = self
    LibJIT.jit_context_build_start @jit_t
  end
  
  def build_end
    @@current = nil
    LibJIT.jit_context_build_end @jit_t
  end
  
  def building?
    @@current == self
  end
  
  # Equivalent to context.build { context.function(*args, &block) }
  def build_function *args, &block
    func = nil
    build do
      func = function *args, &block
    end
    func
  end
  
  def function param_types, return_type
    unless building?
      raise JIT::BuildLockError.new("context doesn't hold the build lock")
    end
    
    func = Function.new(param_types, return_type)
    
    if block_given?
      yield func
      func.compile
    end
    
    return func
  end
end
end
