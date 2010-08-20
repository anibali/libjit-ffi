module JIT
class Label
  attr_reader :jit_t
  
  def initialize(function)
    @function = function
    @jit_t = FFI::MemoryPointer.new(:ulong, 1)
    # 0xffffffff represents an undefined label
    @jit_t.put_ulong 0, 0xffffffff
  end
  
  def self.wrap(function, jit_t)
    @function = function
    label = self.allocate
    label.instance_variable_set(:@jit_t, jit_t)
    return label
  end
  
  def set
    LibJIT.jit_insn_label(@function.jit_t, jit_t)
  end
end
end
