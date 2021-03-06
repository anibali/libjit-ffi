module JIT

class Value
  # Gets the FFI pointer representing this value's underlying jit_value_t
  # (mainly for internal use).
  # @return [FFI::Pointer] the jit_value_t.
  attr_reader :jit_t
  
  # Creates a value which may be have data stored in it later.
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
  
  # Creates a value by wrapping an FFI pointer representing a jit_value_t
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
  
  # Gets the function which this value belongs to.
  #
  # @return [Function] the function which this value belongs to.
  def function
    @function ||= Function.wrap(LibJIT.jit_value_get_function(jit_t))
  end
  
  # Gets the type associated with this value.
  #
  # @return [Type] the type associated with this value.
  def type
    @type ||= Type.wrap LibJIT.jit_value_get_type(jit_t)
  end
  
  # Generates an instruction to store another value in this value (assignment).
  #
  # @param [Value] other the value to be stored.
  def store(other)
    LibJIT.jit_insn_store(function.jit_t, jit_t, other.jit_t)
    self
  end
  
  # Generates an instruction to get this value's address in memory. It will 
  # become addressable if it isn't already.
  #
  # @return [Pointer] a temporary value containing the address.
  def address
    Value.wrap LibJIT.jit_insn_address_of(function.jit_t, jit_t)
  end
  
  # Checks whether this value is currently addressable.
  #
  # @return [Boolean] true if addressable, false otherwise.
  def addressable?
    LibJIT.jit_value_is_addressable(jit_t)
  end
  
  # Makes this value addressable.
  def set_addressable
    LibJIT.jit_value_set_addressable(jit_t)
  end
  
  # Generates an instruction to convert this value into a boolean.
  #
  # @return [Bool] a temporary value representing the boolean.
  def to_bool
    return self if type.bool?
    v = Value.create function, :bool
    v.store Value.wrap(LibJIT.jit_insn_to_bool(function.jit_t, jit_t))
    return v
  end
  
  def to_not_bool
    v = Value.create function, :bool
    v.store Value.wrap(LibJIT.jit_insn_to_not_bool(function.jit_t, jit_t))
    return v
  end
  
  # Generates an instruction to cast this value into a new type.
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
  # Generates an instruction to check whether this value is less than another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def <(other)
    Value.wrap(LibJIT.jit_insn_lt(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generates an instruction to check whether this value is less than or equal 
  # to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def <=(other)
    Value.wrap(LibJIT.jit_insn_le(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generates an instruction to check whether this value is greater than another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def >(other)
    Value.wrap(LibJIT.jit_insn_gt(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generates an instruction to check whether this value is greater than or
  # equal to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def >=(other)
    Value.wrap(LibJIT.jit_insn_ge(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generates an instruction to check whether this value is equal to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def eq(other)
    Value.wrap(LibJIT.jit_insn_eq(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generates an instruction to check whether this value is not equal to another value.
  #
  # @param [Primitive] other the other value to compare with.
  # @return [Bool] a temporary value representing the boolean result of the comparison.
  def ne(other)
    Value.wrap(LibJIT.jit_insn_ne(function.jit_t, jit_t, other.jit_t)).to_bool
  end
  
  # Generates an instruction to calculate the bitwise negation of this value.
  #
  # @return [Primitive] a temporary value representing the result of negation.
  def ~()
    Value.wrap LibJIT.jit_insn_not(function.jit_t, jit_t)
  end
  
  # Generates an instruction to perform an arithmetic left shift on this value.
  #
  # @param [Primitive] other the number of positions to shift.
  # @return [Primitive] a temporary value representing the result of shifting.
  def <<(other)
    Value.wrap LibJIT.jit_insn_shl(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to perform an arithmetic right shift on this value.
  #
  # @param [Primitive] other the number of positions to shift.
  # @return [Primitive] a temporary value representing the result of shifting.
  def >>(other)
    Value.wrap LibJIT.jit_insn_shr(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to perform a
  # [bitwise AND](http://en.wikipedia.org/wiki/Bitwise_operation#AND) with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def &(other)
    Value.wrap LibJIT.jit_insn_and(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to perform a
  # [bitwise XOR](http://en.wikipedia.org/wiki/Bitwise_operation#XOR) with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def ^(other)
    Value.wrap LibJIT.jit_insn_xor(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to perform a
  # [bitwise OR](http://en.wikipedia.org/wiki/Bitwise_operation#OR) with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def |(other)
    Value.wrap LibJIT.jit_insn_or(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to reverse the sign of this value.
  #
  # @return [Primitive] a temporary value representing the calculated result.
  def -@
    Value.wrap LibJIT.jit_insn_neg(function.jit_t, jit_t)
  end
  
  # Generates an instruction to perform an addition with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def +(other)
    Value.wrap LibJIT.jit_insn_add(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to perform a subtraction with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def -(other)
    Value.wrap LibJIT.jit_insn_sub(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to perform a multiplication with this value.
  #
  # @param [Primitive] other the other operand.
  # @return [Primitive] a temporary value representing the calculated result.
  def *(other)
    Value.wrap LibJIT.jit_insn_mul(function.jit_t, jit_t, other.jit_t)
  end
  
  # Generates an instruction to perform a division with this value.
  #
  # @param [Primitive] divisor the divisor.
  # @return [Primitive] a temporary value representing the calculated result.
  def /(divisor)
    Value.wrap LibJIT.jit_insn_div(function.jit_t, jit_t, divisor.jit_t)
  end
  
  # Generates an instruction to apply the modulo function on this value.
  #
  # @param [Primitive] divisor the divisor.
  # @return [Primitive] a temporary value representing the remainder.
  def %(divisor)
    Value.wrap LibJIT.jit_insn_rem(function.jit_t, jit_t, divisor.jit_t)
  end
  
  # Generates an instruction to find a power of this value.
  #
  # @param [Primitive] exponent the exponent.
  # @return [Primitive] a temporary value representing the calculated result.
  def **(exponent)
    Value.wrap LibJIT.jit_insn_pow(function.jit_t, jit_t, exponent.jit_t)
  end
end

class Bool < Primitive
  # Generates an instruction to apply logical NOT on this value.
  #
  # @return [Bool] a temporary value representing the boolean result.
  def not
    self.to_not_bool
  end
  
  # Generates an instruction to apply logical AND on this value.
  #
  # @return [Bool] a temporary value representing the boolean result.
  def and(other)
    (self & other).to_bool
  end
  
  # Generates an instruction to apply logical OR on this value.
  #
  # @return [Bool] a temporary value representing the boolean result.
  def or(other)
    (self | other).to_bool
  end
  
  # Generates an instruction to apply logical XOR on this value.
  #
  # @return [Bool] a temporary value representing the boolean result.
  def xor(other)
    (self ^ other).to_bool
  end
end

class Pointer < Primitive
  # Generates an instruction to retrieve the value being pointed to. If an
  # explicit type is not specified it will be inferred.
  #
  # @param [Type] *type the type to dereference as.
  # @return [Value] the retrieved value.
  def dereference(*type)
    ref_type = nil
    if type.empty?
      ref_type = self.type.ref_type
    else
      ref_type = Type.create(*type)
    end
    
    Value.wrap LibJIT.jit_insn_load_relative(function.jit_t, jit_t, 0, ref_type.jit_t)
  end

  # Generates an instruction to store a value at the address referenced by this
  # pointer. An address offset may optionally be set with a Ruby integer.
  #
  # @param [Value] value the value to store.
  # @param [Optional Integer] offset an offset to the address.
  def mstore(value, offset=0)
    LibJIT.jit_insn_store_relative(function.jit_t, jit_t, offset, value.jit_t)
  end
  
  # Generates an instruction to load a value from the address referenced by this
  # pointer. An address offset may optionally be set with a Ruby integer.
  #
  # @param [Optional Integer] offset an offset to the address.
  # @param [Type] *type type of value to load (see Type#create).
  # @return [Value] the retrieved value.
  def mload *args
    offset = args.first.is_a?(Fixnum) ? args.slice!(0) : 0
    type = Type.create(*args)
    Value.wrap LibJIT.jit_insn_load_relative(function.jit_t, jit_t, offset, type.jit_t)
  end
  
  # Generates an instruction to load the array element at the specified index.
  #
  # @param [Value, Integer] index the array index.
  # @return [Value] the retrieved value.
  def [](index)
    index = Constant.create(function, index, :uint8) if index.is_a? Fixnum
    Value.wrap LibJIT.jit_insn_load_elem(function.jit_t, jit_t, index.jit_t, type.ref_type.jit_t)
  end
  
  # Generates an instruction to store an array element at the specified index.
  #
  # @param [Value, Integer] index the array index.
  # @param [Value] value the value to store.
  def []=(index, value)
    index = Constant.create(function, index, :uint8) if index.is_a? Fixnum
    LibJIT.jit_insn_store_elem(function.jit_t, jit_t, index.jit_t, value.jit_t)
  end
end

class Struct < Value
  # Generates an instruction to load the value of a field.
  #
  # @param field the field's name or index.
  # @return [Value] the field's value.
  def [](field)
    Value.wrap LibJIT.jit_insn_load_relative(function.jit_t, self.address.jit_t, type.offset(field), type.field_type(field).jit_t)
  end
  
  # Generates an instruction to store a value in a field.
  #
  # @param field the field's name or index.
  # @param [Value] value the value to store.
  def []=(field, value)
    LibJIT.jit_insn_store_relative(function.jit_t, self.address.jit_t, type.offset(field), value.jit_t)
  end
end

end

