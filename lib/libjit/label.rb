module JIT
class Label
  attr_reader :jit_t
  
  def initialize(function)
    @function = function
    @jit_t = FFI::MemoryPointer.new(:long, 1)
    @jit_t.put_long 0, LibJIT.jit_label_undefined
  end
  
  def self.wrap(function, jit_t)
    @function = function
    label = self.allocate
    label.instance_variable_set(:@jit_t, jit_t)
    return label
  end
  
  def set
    LibJIT.jit_insn_label(@function.jit_t, @jit_t)
  end
end
end
