module JIT

class Function
  attr_reader :jit_t
  
  def initialize(param_types, return_type)
    @signature = SignatureType.new(param_types, return_type)
    @jit_t = LibJIT.jit_function_create(Context.current.jit_t, @signature.jit_t)
  end
  
  def self.wrap jit_t
    function = self.allocate
    function.instance_variable_set(:@jit_t, jit_t)
    function
  end
  
  def signature
    @signature ||= Type.wrap LibJIT.jit_function_get_signature(jit_t)
  end
  
  def compile
    # Add a default return instruction
    x = LibJIT.jit_insn_default_return(jit_t)
    # If function is expected to return a value and default return instruction
    # is reached, raise an exception
    if x == 1 and not signature.return_type.void?
      raise JIT::Error.new("Expected 'return' instruction for non-void function")
    end
    
    LibJIT.jit_function_compile jit_t
  end
  
  def call(*args)
    # Turn each element of 'args' into a pointer to its value
    signature.param_types.each_with_index do |type, i|
      ptr = FFI::MemoryPointer.new(type.to_ffi_type, 1)
      ptr.send("put_#{type.to_ffi_type}", 0, args[i])
      args[i] = ptr
    end
    
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, args.length)
    args_ptr.put_array_of_pointer 0, args
    
    # Create a pointer used to access the function's return value
    return_ptr = nil
    unless signature.return_type.void?
      return_ptr = FFI::MemoryPointer.new(signature.return_type.to_ffi_type, 1)
    end
    
    # Call the function!
    LibJIT.jit_function_apply(jit_t, args_ptr, return_ptr)
    
    # Return with our results
    unless signature.return_type.void?
      return return_ptr.send("get_#{signature.return_type.to_ffi_type}", 0)
    end
    
    return
  end
  
  def [](*args)
    call *args
  end
  
  def arg(i)
    Value.wrap LibJIT.jit_value_get_param(jit_t, i.to_i)
  end
  
  # arguments represent a Type
  def declare(*args)
    Value.create(self, *args)
  end
  
  def return(value=nil)
    LibJIT.jit_insn_return(jit_t, value ? value.jit_t : nil)
  end
  
  def const(val, *type)
    Constant.new self, val, *type
  end
  
  # Create null-terminated string in stack memory.
  def stringz(ruby_string)
    ruby_string += "\0"
    ptr = Value.wrap LibJIT.jit_insn_alloca(jit_t, const(ruby_string.size, :uint32).jit_t)
    ruby_string.unpack('C*').each_with_index do |c, i|
      ptr.mstore(const(c, :uint8), i)
    end
    ptr
  end
  
  def label
    Label.new(self)
  end
  
  def call_other(func, *args)
    # Turn each element of 'args' into a pointer to its value
    args = args.map {|val| val.jit_t}
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, args.length)
    args_ptr.put_array_of_pointer 0, args
    
    Value.wrap LibJIT.jit_insn_call(jit_t, nil, func.jit_t, nil, args_ptr, args.length, 0)
  end
  
  def call_native(func, signature, *args)
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, args.length)
    args = args.map {|val| val.jit_t}
    args_ptr.put_array_of_pointer 0, args
  
    Value.wrap LibJIT.jit_insn_call_native(jit_t, nil, func, signature.jit_t, args_ptr, args.length, 0, 0)
  end

  def c
    @c ||= C.new(self)
  end

  def null
    const(0, :int8)
  end

  def true
    const(1, :int8)
  end

  def false
    const(0, :int8)
  end
  
  def jmp label
    LibJIT.jit_insn_branch(jit_t, label.jit_t)
  end
  
  def jmp_if cond, label
    LibJIT.jit_insn_branch_if(jit_t, cond.jit_t, label.jit_t)
  end
  
  def jmp_if_not cond, label
    LibJIT.jit_insn_branch_if_not(jit_t, cond.jit_t, label.jit_t)
  end
  
  def if &condition
    If.new self, &condition
  end
  
  def unless &condition
    Unless.new self, &condition
  end
  
  def while &condition
    While.new self, &condition
  end
  
  def until &condition
    Until.new self, &condition
  end
  
  def break
    IterationStructure.break self
  end
  
  def acos(a)
    Value.wrap LibJIT.jit_insn_acos(jit_t, a.jit_t)
  end
  
  def asin(a)
    Value.wrap LibJIT.jit_insn_asin(jit_t, a.jit_t)
  end
  
  def atan(a)
    Value.wrap LibJIT.jit_insn_atan(jit_t, a.jit_t)
  end
  
  def atan2(a, b)
    Value.wrap LibJIT.jit_insn_atan2(jit_t, a.jit_t, b.jit_t)
  end
  
  def ceil(a)
    Value.wrap LibJIT.jit_insn_ceil(jit_t, a.jit_t)
  end
  
  def cos(a)
    Value.wrap LibJIT.jit_insn_cos(jit_t, a.jit_t)
  end
  
  def cosh(a)
    Value.wrap LibJIT.jit_insn_cosh(jit_t, a.jit_t)
  end
end

end

