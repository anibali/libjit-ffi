module JIT

class Function
  attr_reader :jit_t
  
  def initialize(param_types, return_type)
    @signature = SignatureType.new(param_types, return_type)
    @jit_t = LibJIT.jit_function_create(context.jit_t, @signature.jit_t)
  end
  
  def self.wrap jit_t
    function = self.allocate
    function.instance_variable_set(:@jit_t, jit_t)
    function
  end
  
  def signature
    @signature ||= Type.wrap LibJIT.jit_function_get_signature(jit_t)
  end
  
  def context
    @context ||= Context.current
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
    if context.destroyed?
      raise JIT::Error.new("can't call function, context has been destroyed")
    end
    
    n_args = args.length
    expected_n_args = signature.param_types.length
    if n_args != expected_n_args
      raise ArgumentError.new expected_n_args, n_args
    end
  
    # Turn each element of 'args' into a pointer to its value
    signature.param_types.each_with_index do |type, i|
      ptr = FFI::MemoryPointer.new(type.to_ffi_type, 1)
      if type.bool?
        args[i] = 1 if args[i] == true
        args[i] = 0 if args[i] == false
      end
      
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
      res = return_ptr.send("get_#{signature.return_type.to_ffi_type}", 0)
      if signature.return_type.bool?
        return res != 0
      else
        return res
      end
    end
    
    return
  end
  
  def [](*args)
    call *args
  end
  
  def arg(i)
    unless i >= 0 and i < signature.param_types.length
      raise InstructionError.new("argument index #{i} is out of bounds")
    end
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
    Constant.create self, val, *type
  end
  
  # Create null-terminated string in stack memory.
  def stringz(ruby_string)
    ruby_string += "\0"
    ptr = Value.wrap LibJIT.jit_insn_alloca(jit_t, const(ruby_string.size, :uintn).jit_t)
    ruby_string.unpack('C*').each_with_index do |c, i|
      ptr.mstore(const(c, :uint8), i)
    end
    ptr
  end
  
  def label
    Label.new(self)
  end
  
  def call_other(func, *args)
    n_args = args.length
    expected_n_args = func.signature.param_types.length
    if n_args != expected_n_args
      raise ArgumentError.new expected_n_args, n_args
    end
    
    # Turn each element of 'args' into a pointer to its value
    args = args.map {|val| val.jit_t}
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, n_args)
    args_ptr.put_array_of_pointer 0, args
    
    Value.wrap LibJIT.jit_insn_call(jit_t, nil, func.jit_t, nil, args_ptr, n_args, 0)
  end
  
  def call_native(func, signature, *args)
    n_args = args.length
    expected_n_args = signature.param_types.length
    if n_args != expected_n_args
      raise ArgumentError.new expected_n_args, n_args
    end
    
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, args.length)
    args = args.map {|val| val.jit_t}
    args_ptr.put_array_of_pointer 0, args
  
    Value.wrap LibJIT.jit_insn_call_native(jit_t, nil, func, signature.jit_t, args_ptr, n_args, 0, 0)
  end
  
  def call_native_variadic(func, signature, *args)
    param_types = signature.param_types
    param_types += args[param_types.size..-1].map {|arg| arg.type}
    signature = SignatureType.new param_types, signature.return_type
    
    call_native(func, signature, *args)
  end

  def c
    @c ||= LibC.new(self)
  end

  def null
    const(0, :int8)
  end

  def true
    const(1, :bool)
  end

  def false
    const(0, :bool)
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
  
  def math
    MathProxy.new(self)
  end
  
  class MathProxy
    def initialize function
      @function = function
    end
    
    def method_missing(name, *args)
      Value.wrap LibJIT::Math.send(*[name, @function.jit_t] + args.map {|a| a.jit_t})
    end
  end
end

end

