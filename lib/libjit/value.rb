module JIT
class Value
  attr_reader :jit_t
  
  def initialize(function, type)
    raise ArgumentError.new "Function can't be nil" if function.nil?
    @function = function
    @type = Type.new type
    @jit_t = LibJIT.jit_value_create(@function.jit_t, @type.jit_t)
  end
  
  def self.wrap(function, jit_t)
    raise ArgumentError.new "Function can't be nil" if function.nil?
    value = self.allocate
    value.instance_variable_set(:@function, function)
    value.instance_variable_set(:@jit_t, jit_t)
    return value
  end
  
  def store(other)
    LibJIT.jit_insn_store(@function.jit_t, @jit_t, other.jit_t)
  end
  
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
  
  def to_bool
    wrap_value LibJIT.jit_insn_to_bool(@function.jit_t, @jit_t)
  end
  
  private
  def wrap_value val
    Value.wrap @function, val
  end
end

class Constant < Value
  def initialize(function, type, val)
    raise ArgumentError.new "Function can't be nil" if function.nil?
    @function = function
    @type = Type.new type
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

