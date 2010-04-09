module JIT

class Function
  attr_reader :jit_t
  attr_reader :signature
  
  def initialize(param_types, return_type)
    @signature = SignatureType.new(param_types, return_type)
    @jit_t = LibJIT.jit_function_create(Context.current.jit_t, @signature.jit_t)
    @break_labels = []
  end
  
  def compile
    # Add a default return instruction
    x = LibJIT.jit_insn_default_return(@jit_t)
    # If function is expected to return a value and default return instruction
    # is reached, raise an exception
    if x == 1 and not @signature.return_type.void?
      raise JIT::Error.new("Expected 'return' instruction for non-void function")
    end
    
    LibJIT.jit_function_compile(@jit_t)
  end
  
  def call(*args)
    # Turn each element of 'args' into a pointer to its value
    @signature.param_types.each_with_index do |type, i|
      ptr = FFI::MemoryPointer.new(type.to_ffi_type, 1)
      ptr.send("put_#{type.to_ffi_type}", 0, args[i])
      args[i] = ptr
    end
    
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, args.length)
    args_ptr.put_array_of_pointer 0, args
    
    # Create a pointer used to access the function's return value
    return_ptr = nil
    unless @signature.return_type.void?
      return_ptr = FFI::MemoryPointer.new(@signature.return_type.to_ffi_type, 1)
    end
    
    # Call the function!
    LibJIT.jit_function_apply(@jit_t, args_ptr, return_ptr)
    
    # Return with our results
    unless @signature.return_type.void?
      return return_ptr.send("get_#{@signature.return_type.to_ffi_type}", 0)
    end
    
    return
  end
  
  def [](*args)
    call *args
  end
  
  def arg(i)
    wrap_value LibJIT.jit_value_get_param(@jit_t, i.to_i)
  end
  
  def declare(type)
    wrap_value LibJIT.jit_value_create(@jit_t, Type.create(type).jit_t)
  end
  
  def return(value=nil)
    LibJIT.jit_insn_return(@jit_t, value ? value.jit_t : nil)
  end
  
  def const(type, val)
    Constant.new self, type, val
  end
  
  def value type
    Value.new(self, type)
  end
  
  def label
    Label.new(self)
  end
  
  def call_other(func, *args)
    # Turn each element of 'args' into a pointer to its value
    args = args.map {|val| val.jit_t}
    func.signature.param_types.each_with_index do |type, i|
      ptr = FFI::MemoryPointer.new(type.to_ffi_type, 1)
      ptr.send("put_#{type.to_ffi_type}", 0, args[i])
      args[i] = ptr
    end
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, args.length)
    args_ptr.put_array_of_pointer 0, args
    
    wrap_value LibJIT.jit_insn_call(@jit_t, nil, func.jit_t, nil, args_ptr, args.length, 0)
  end
  
  def call_native(func, signature, *args)
    # Make a C array representation of 'args'
    args_ptr = FFI::MemoryPointer.new(:pointer, args.length)
    args = args.map {|val| val.jit_t}
    args_ptr.put_array_of_pointer 0, args
  
    wrap_value LibJIT.jit_insn_call_native(@jit_t, nil, func, signature.jit_t, args_ptr, args.length, 0, 0)
  end
  
  def jmp label
    LibJIT.jit_insn_branch(@jit_t, label.jit_t)
  end
  
  def jmp_if cond, label
    LibJIT.jit_insn_branch_if(@jit_t, cond.jit_t, label.jit_t)
  end
  
  def jmp_if_not cond, label
    LibJIT.jit_insn_branch_if_not(@jit_t, cond.jit_t, label.jit_t)
  end
  
  def if(test, else_proc=nil)
    bottom = self.label
    
    if else_proc.nil?
      jmp_if_not test.call, bottom
      yield
    else
      else_lbl = self.label
      jmp_if_not test.call, else_lbl
      yield
      jmp bottom
      else_lbl.set
      else_proc.call
    end
    
    bottom.set
  end
  
  def unless(test, else_proc=nil)
    bottom = self.label
    
    if else_proc.nil?
      jmp_if test.call, bottom
      yield
    else
      else_lbl = self.label
      jmp_if test.call, else_lbl
      yield
      jmp bottom
      else_lbl.set
      else_proc.call
    end
    
    bottom.set
  end
  
  def while(test)
    top = self.label
    bottom = self.label
    @break_labels.push bottom
    jmp_if_not test.call, bottom
    cond = declare :int8
    
    top.set
    yield
    cond.store test.call.to_bool
    jmp_if cond, top
    
    bottom.set
    @break_labels.pop
  end
  
  def until(test)
    top = self.label
    bottom = self.label
    @break_labels.push bottom
    jmp_if test.call, bottom
    cond = declare :int8
    
    top.set
    yield
    cond.store test.call.to_bool
    jmp_if_not cond, top
    
    bottom.set
    @break_labels.pop
  end
  
  def break
    raise "no loop to break out of" if @break_labels.empty?
    jmp @break_labels.last
  end
  
  def wrap_value jit_t
    Value.wrap(self, jit_t)
  end
end

end

