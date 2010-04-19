module JIT

class Value
  attr_reader :jit_t
  
  def self.create(function, *args)
    raise ArgumentError.new "Function is required" unless function.is_a? Function
    raise ArgumentError.new "Type is required" if args.empty?
    type = Type.create *args
    wrap function, LibJIT.jit_value_create(function.jit_t, type.jit_t)
  end
  
  def self.wrap(function, jit_t)
    #TODO: infer function from jit_t, and remove function argument
    raise ArgumentError.new "Function can't be nil" if function.nil?
    
    v = Value.allocate
    v.instance_variable_set(:@function, function)
    v.instance_variable_set(:@jit_t, jit_t)
    
    type = v.type
    value = if type.struct?
      Struct.allocate
    elsif type.pointer?
      Pointer.allocate
    elsif type.void?
      Void.allocate
    else
      Primitive.allocate
    end
    
    value.instance_variable_set(:@function, function)
    value.instance_variable_set(:@jit_t, jit_t)
    # Not strictly necessary to set @type, but we might as well so that it
    # doesn't need to be inferred later on
    value.instance_variable_set(:@type, type)
    
    value
  end
  
  def type
    @type ||= Type.wrap LibJIT.jit_value_get_type(jit_t)
  end
  
  def store(other)
    LibJIT.jit_insn_store(@function.jit_t, @jit_t, other.jit_t)
    self
  end
  
  # Gets address of variable (will be made addressable if not already).
  def address
    wrap_value LibJIT.jit_insn_address_of(@function.jit_t, @jit_t)
  end
  
  def addressable?
    LibJIT.jit_value_is_addressable(@jit_t) != 0
  end
  
  def set_addressable
    LibJIT.jit_value_set_addressable(@jit_t)
  end
  
  def to_bool
    wrap_value LibJIT.jit_insn_to_bool(@function.jit_t, @jit_t)
  end
  
  private
  def wrap_value val
    Value.wrap @function, val
  end
end

class Primitive < Value
  def <(other)
    wrap_value LibJIT.jit_insn_lt(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def <=(other)
    wrap_value LibJIT.jit_insn_le(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def >(other)
    wrap_value LibJIT.jit_insn_gt(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def >=(other)
    wrap_value LibJIT.jit_insn_ge(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def eq(other)
    wrap_value LibJIT.jit_insn_eq(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def ne(other)
    wrap_value LibJIT.jit_insn_ne(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def ~
    wrap_value LibJIT.jit_insn_not(@function.jit_t, @jit_t)
  end
  
  def <<(other)
    wrap_value LibJIT.jit_insn_shl(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def >>(other)
    wrap_value LibJIT.jit_insn_shr(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def &(other)
    wrap_value LibJIT.jit_insn_and(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def ^(other)
    wrap_value LibJIT.jit_insn_xor(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def |(other)
    wrap_value LibJIT.jit_insn_or(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def -@
    wrap_value LibJIT.jit_insn_neg(@function.jit_t, @jit_t)
  end
  
  def +(other)
    wrap_value LibJIT.jit_insn_add(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def -(other)
    wrap_value LibJIT.jit_insn_sub(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def *(other)
    wrap_value LibJIT.jit_insn_mul(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def /(other)
    wrap_value LibJIT.jit_insn_div(@function.jit_t, @jit_t, other.jit_t)
  end
  
  def %(other)
    wrap_value LibJIT.jit_insn_rem(@function.jit_t, @jit_t, other.jit_t)
  end
end

class Void < Value
end

class Pointer < Primitive
  #TODO: add dereference function
end

class Struct < Value
  def [](index)
    Value.wrap @function, LibJIT.jit_insn_load_relative(@function.jit_t, self.address.jit_t, @type.offset(index), @type.field_jit_t(index))
  end
  
  def []=(index, value)
    LibJIT.jit_insn_store_relative(@function.jit_t, self.address.jit_t, @type.offset(index), value.jit_t)
  end
end

class Constant < Primitive
  def initialize(function, type, val)
    raise ArgumentError.new "Function can't be nil" if function.nil?
    @function = function
    @type = Type.create type
    @val = val
    
    @jit_t = case @type.to_sym
    when :uint8, :int8, :uint16, :int16, :uint32, :int32
      LibJIT.jit_value_create_nint_constant(@function.jit_t, @type.jit_t, val)
    when :uint64, :int64
      raise NotImplementedError.new("TODO: Implement long constants")
    else
      raise JIT::TypeError.new("'#{@sym}' is not a supported type for constant creation")
    end
  end
  
  def to_i
    #TODO: use jit_value_get_X_constant
    @val.to_i
  end
end

end

