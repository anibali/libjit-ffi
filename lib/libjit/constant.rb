module JIT

class Constant
  # Create a new constant.
  #
  # @param [Function] function the function to which the constant will belong.
  # @param [Number] val the number to be represented by the constant.
  # @param [Type] *type the type of the constant.
  def self.create(function, val, *type)
    raise ArgumentError.new "Function can't be nil" if function.nil?
    
    type = Type.create *type
    if type.bool?
      BoolConstant.new(function, val, type)
    elsif type.floating_point?
      FloatConstant.new(function, val, type)
    else
      IntConstant.new(function, val, type)
    end
  end
end

class IntConstant < Primitive
  def initialize(function, val, *type)
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
    else
      raise JIT::TypeError.new("Creation of '#{@sym}' constants not supported")
    end
  end
  
  # Get the integer represented by this constant as a Ruby object.
  #
  # @return [Integer] the integer represented by this constant.
  def to_i
    @i ||= case type.to_sym
    when :uint8, :int8, :uint16, :int16, :uint32, :int32, :uintn, :intn
      val = LibJIT.jit_value_get_nint_constant jit_t
      # Turn unsigned integer into a signed one if appropriate
      [val].pack('i').unpack('I').first if type.unsigned?
    when :uint64, :int64
      val = LibJIT.jit_value_get_long_constant jit_t
      # Turn unsigned integer into a signed one if appropriate
      [val].pack('q').unpack('Q').first if type.unsigned?
    else
      raise JIT::TypeError.new("Constant is not of a supported int type")
    end
  end
end

class FloatConstant
  def initialize(function, val, *type)
    @function = function
    @type = Type.create *type
    
    @jit_t = case @type.to_sym
    when :float32
      LibJIT.jit_value_create_float32_constant(@function.jit_t, @type.jit_t, val)
    when :float64
      LibJIT.jit_value_create_float64_constant(@function.jit_t, @type.jit_t, val)
    else
      raise JIT::TypeError.new("Creation of '#{@sym}' constants not supported")
    end
  end
  
  # @return [Float] the float represented by this constant.
  def to_f
    @f ||= case type.to_sym
    when :float32
      LibJIT.jit_value_get_float32_constant jit_t
    when :float64
      LibJIT.jit_value_get_float64_constant jit_t
    else
      raise JIT::TypeError.new("Constant is not of a supported float type")
    end
  end
end

class BoolConstant < Bool
  def initialize(function, val, *type)
    @function = function
    type ||= Type.create(:bool)
    @type = Type.create *type
    
    val = 1 if val == true
    val = 0 if val == false
    @jit_t = LibJIT.jit_value_create_nint_constant(@function.jit_t, @type.jit_t, val)
  end
  
  # Get the integer represented by this constant as a Ruby object.
  #
  # @return [Integer] the integer represented by this constant.
  def to_i
    @i ||= LibJIT.jit_value_get_nint_constant jit_t
  end
  
  # @return [Boolean] the boolean represented by this constant.
  def to_b
    to_i != 0
  end
end

end
