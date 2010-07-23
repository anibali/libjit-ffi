module JIT

class Value
  # Get the FFI pointer representing this value's underlying jit_value_t
  # (mainly for internal use).
  attr_reader :jit_t
  
  # Create a value which may be have data stored in it later.
  #
  # @param function the function to which the value will belong.
  # @param [Type] *type the value's intended type.
  # @return [Value] the new value object.
  def self.create(function, *type)
    raise ArgumentError.new "Function is required" unless function.is_a? Function
    raise ArgumentError.new "Type is required" if type.empty?
    type = Type.create *type
    wrap LibJIT.jit_value_create(function.jit_t, type.jit_t)
  end
  
  # Create a value by wrapping an FFI pointer representing a jit_value_t
  # (mainly for internal use).
  #
  # @return [Value] the new value object.
  def self.wrap(jit_t)
    v = Value.allocate
    v.instance_variable_set(:@jit_t, jit_t)
    
    type = v.type
    value = if type.struct?
      Struct.allocate
    elsif type.pointer?
      Pointer.allocate
    elsif type.void?
      Void.allocate
    elsif type.bool?
      Bool.allocate
    else
      Primitive.allocate
    end
    
    value.instance_variable_set(:@jit_t, jit_t)
    # It's not strictly necessary to set @type, but we might as well
    # (caching FTW!)
    value.instance_variable_set(:@type, type)
    
    return value
  end
  
  # Get the function which this value belongs to.
  #
  # @return [Function] the function which this value belongs to.
  def function
    @function ||= Function.wrap(LibJIT.jit_value_get_function(jit_t))
  end
  
  # Get the type associated with this value.
  #
  # @return [Type] the type associated with this value.
  def type
    @type ||= Type.wrap LibJIT.jit_value_get_type(jit_t)
  end
  
  # Generate an instruction to store another value in this value (assignment).
  #
  # @param [Value] other the value to be stored.
  def store(other)
    LibJIT.jit_insn_store(function.jit_t, jit_t, other.jit_t)
    self
  end
  
  # Generate an instruction to get this value's address in memory. It will 
  # become addressable if it isn't already.
  #
  # @return [Pointer] a temporary value containing the address.
  def address
    Value.wrap LibJIT.jit_insn_address_of(function.jit_t, jit_t)
  end
  
  # Check whether this value is currently addressable.
  #
  # @return [Boolean] true if addressable, false otherwise.
  def addressable?
    LibJIT.jit_value_is_addressable(jit_t)
  end
  
  # Make this value addressable.
  def set_addressable
    LibJIT.jit_value_set_addressable(jit_t)
  end
  
  # Generate an instruction to convert this value into a boolean.
  #
  # @return [Bool] a temporary value representing the boolean.
  def to_bool
    v = Value.create function, :bool
    v.store Value.wrap(LibJIT.jit_insn_to_bool(function.jit_t, jit_t))
    v
  end
  
  def to_not_bool
    v = Value.create function, :bool
    v.store Value.wrap(LibJIT.jit_insn_to_not_bool(function.jit_t, jit_t))
    v
  end
  
  # Generate an instruction to cast this value into a new type.
  #
  # @param [Type] *type the type to cast to.
  # @return [Value] a temporary value representing the cast result.
  def cast *type
    type = Type.create *type
    Value.wrap LibJIT.jit_insn_convert(function.jit_t, jit_t, type.jit_t, 0)
  end
end

class Void < Value
end

class Primitive < Value
  # Generate an instruction to check whether this value is less than another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def <(other)
    Value.wrap(LibJIT.jit_insn_lt(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generate an instruction to check whether this value is less than or equal to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def <=(other)
    Value.wrap(LibJIT.jit_insn_le(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generate an instruction to check whether this value is greater than another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def >(other)
    Value.wrap(LibJIT.jit_insn_gt(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generate an instruction to check whether this value is greater than or equal to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def >=(other)
    Value.wrap(LibJIT.jit_insn_ge(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generate an instruction to check whether this value is equal to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def eq(other)
    Value.wrap(LibJIT.jit_insn_eq(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generate an instruction to check whether this value is not equal to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def ne(other)
    Value.wrap(LibJIT.jit_insn_ne(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generate an instruction to calculate the bitwise negation of this value.
  #
  # @return [Primitive] a temporary value representing the result of negation.
  def ~()
    Value.wrap LibJIT.jit_insn_not(function.jit_t, jit_t)
  end
  
  # Generate an instruction to perform an arithmetic left shift on this value.
  #
  # @param [Primitive] other the number of positions to shift.
  # @return [Primitive] a temporary value representing the result of shifting.
  def <<(other)
    Value.wrap LibJIT.jit_insn_shl(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to perform an arithmetic right shift on this value.
  #
  # @param [Primitive] other the number of positions to shift.
  # @return [Primitive] a temporary value representing the result of shifting.
  def >>(other)
    Value.wrap LibJIT.jit_insn_shr(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to perform a
  # [bitwise AND](http://en.wikipedia.org/wiki/Bitwise_operation#AND) with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def &(other)
    Value.wrap LibJIT.jit_insn_and(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to perform a
  # [bitwise XOR](http://en.wikipedia.org/wiki/Bitwise_operation#XOR) with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def ^(other)
    Value.wrap LibJIT.jit_insn_xor(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to perform a
  # [bitwise OR](http://en.wikipedia.org/wiki/Bitwise_operation#OR) with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def |(other)
    Value.wrap LibJIT.jit_insn_or(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to reverse the sign of this value.
  #
  # @return [Primitive] a temporary value representing the calculated result.
  def -@
    Value.wrap LibJIT.jit_insn_neg(function.jit_t, jit_t)
  end
  
  # Generate an instruction to perform an addition with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def +(other)
    Value.wrap LibJIT.jit_insn_add(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to perform a subtraction with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def -(other)
    Value.wrap LibJIT.jit_insn_sub(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to perform a multiplication with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def *(other)
    Value.wrap LibJIT.jit_insn_mul(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generate an instruction to perform a division with this value.
  #
  # @param [Primitive] divisor the divisor.
  # @return [Primitive] a temporary value representing the calculated result.
  def /(divisor)
    Value.wrap LibJIT.jit_insn_div(function.jit_t, jit_t, divisor.jit_t)
  end
  
  # Generate an instruction to apply the modulo function on this value.
  #
  # @param [Primitive] divisor the divisor.
  # @return [Primitive] a temporary value representing the remainder.
  def %(divisor)
    Value.wrap LibJIT.jit_insn_rem(function.jit_t, jit_t, divisor.jit_t)
  end
  
  # Generate an instruction to find a power of this value.
  #
  # @param [Primitive] exponent the exponent.
  # @return [Primitive] a temporary value representing the calculated result.
  def **(exponent)
    Value.wrap LibJIT.jit_insn_pow(function.jit_t, jit_t, exponent.jit_t)
  end
end

class Bool < Primitive
  def not
    self.to_not_bool
  end
  
  def and(other)
    (self & other).to_bool
  end
  
  def or(other)
    (self | other).to_bool
  end
  
  def xor(other)
    (self ^ other).to_bool
  end
end

class Pointer < Primitive
  # Generate an instruction to retrieve the value being pointed to. If an
  # explicit type is not specified it will be inferred.
  #
  # @param [Type] *type the type to dereference as.
  # @return [Value] the retrieved value.
  def dereference(*type)
    ref_type_jit_t = nil
    if type.empty?
      ref_type_jit_t = LibJIT.jit_type_get_ref(self.type.jit_t)
    else
      ref_type_jit_t = Type.create(*type).jit_t
    end
    
    Value.wrap LibJIT.jit_insn_load_relative(function.jit_t, jit_t, 0, ref_type_jit_t)
  end

  # Generate an instruction to store a value at the address referenced by this
  # pointer. An address offset may optionally be set with a Ruby integer.
  #
  # @param [Value] value the value to store.
  # @param [Integer] offset an offset to the address.
  def mstore(value, offset=0)
    LibJIT.jit_insn_store_relative(function.jit_t, self.jit_t, offset, value.jit_t)
  end
end

class Struct < Value
  # Generate an instruction to load the value of a field.
  #
  # @param [Integer] index the field's index.
  # @return [Value] the field's value.
  def [](index)
    Value.wrap LibJIT.jit_insn_load_relative(function.jit_t, self.address.jit_t, type.offset(index), type.field_type(index).jit_t)
  end
  
  # Generate an instruction to store a value in a field.
  #
  # @param [Integer] index the field's index.
  # @param [Value] value the value to store.
  def []=(index, value)
    LibJIT.jit_insn_store_relative(function.jit_t, self.address.jit_t, type.offset(index), value.jit_t)
  end
end

class Constant < Primitive
  # Create a new constant.
  #
  # @param [Function] function the function to which the constant will belong.
  # @param [Number] val the number to be represented by the constant.
  # @param [Type] *type the type of the constant.
  def initialize(function, val, *type)
    raise ArgumentError.new "Function can't be nil" if function.nil?
    @function = function
    @type = Type.create *type
    
    @jit_t = case @type.to_sym
    when :uint8, :int8, :uint16, :int16, :uint32, :int32, :uintn, :intn
      # Pass big unsigned integers as signed ones so FFI doesn't spit the dummy
      val = [val].pack('I').unpack('i').first if @type.unsigned?
      LibJIT.jit_value_create_nint_constant(@function.jit_t, @type.jit_t, val)
    when :uint64, :int64
      # Pass big unsigned integers as signed ones so FFI doesn't spit the dummy
      val = [val].pack('Q').unpack('q').first if @type.unsigned?
      LibJIT.jit_value_create_long_constant(@function.jit_t, @type.jit_t, val)
    when :float32
      LibJIT.jit_value_create_float32_constant(@function.jit_t, @type.jit_t, val)
    when :float64
      LibJIT.jit_value_create_float64_constant(@function.jit_t, @type.jit_t, val)
    when :bool
      val = 1 if val == true
      val = 0 if val == false
      LibJIT.jit_value_create_nint_constant(@function.jit_t, @type.jit_t, val)
    else
      raise JIT::TypeError.new("'#{@sym}' is not a supported type for constant creation")
    end
  end
  
  # Get the number represented by this constant as a Ruby object.
  #
  # @return [Number] the number represented by this constant.
  def to_numeric
    @numeric ||= case type.to_sym
    when :uint8, :int8, :uint16, :int16, :uint32, :int32, :uintn, :intn
      val = LibJIT.jit_value_get_nint_constant jit_t
      # Turn unsigned integer into a signed one if appropriate
      [val].pack('i').unpack('I').first if type.unsigned?
    when :uint64, :int64
      val = LibJIT.jit_value_get_long_constant jit_t
      # Turn unsigned integer into a signed one if appropriate
      [val].pack('q').unpack('Q').first if type.unsigned?
    when :float32
      LibJIT.jit_value_get_float32_constant jit_t
    when :float64
      LibJIT.jit_value_get_float64_constant jit_t
    else
      raise JIT::TypeError.new("Constant is not of a supported numeric type")
    end
  end
end

end

