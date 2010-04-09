module JIT

class Type
  attr_reader :jit_t
  
  def self.create *args
    if args[0].is_a? Type
      return args[0]
    elsif args[0] == :pointer
      return PointerType.new(*args[1..-1])
    elsif args[0] == :signature
      raise NotImplementedError.new("TODO: enable signature creation via Type.create")
    else
      return SimpleType.new(*args)
    end
  end
  
  [:void?, :pointer?, :floating_point?, :integer?, :signed?,
   :unsigned?, :signature?].each do |method|
    define_method method do
      false
    end
  end
  
  # Returns the number of bytes that values of this type require for storage
  def size
    LibJIT.jit_type_get_size(@jit_t)
  end
end

# SimpleType represents basic types such as ints, floats, void and pointers
# without target types
class SimpleType < Type
  JIT_SYM_MAP = {
    :int8 => :sbyte,
    :uint8 => :ubyte,
    :int16 => :short,
    :uint16 => :ushort,
    :int32 => :int,
    :uint32 => :uint,
    :int64 => :long,
    :uint64 => :ulong,
    :float32 => :float32,
    :float64 => :float64,
    :void => :void
  }.freeze
  
  FFI_SYM_MAP = {
    :int8 => :int8,
    :uint8 => :uint8,
    :int16 => :int16,
    :uint16 => :uint16,
    :int32 => :int32,
    :uint32 => :uint32,
    :int64 => :int64,
    :uint64 => :uint64,
    :float32 => :float,
    :float64 => :double,
    :void => :void
  }.freeze
  
  def initialize sym
    @sym = sym.to_sym
    
    @jit_t = LibJIT.jit_type_from_string(JIT_SYM_MAP[@sym].to_s)
    
    if @jit_t.null?
      raise JIT::TypeError.new("'#{@sym}' is not a supported simple type")
    end
  end
  
  def void?
    @sym == :void
  end
  
  def floating_point?
    [:float32, :float64].include? @sym
  end
  
  def integer?
    [:int8, :int16, :int32, :int64, :uint8, :uint16, :uint32, :uint64].include? @sym
  end
  
  def signed?
    [:int8, :int16, :int32, :int64, :float32, :float64].include? @sym
  end
  
  def unsigned?
    [:uint8, :uint16, :uint32, :uint64].include? @sym
  end
  
  def to_ffi_type
    FFI_SYM_MAP[@sym]
  end
  
  def to_sym
    return @sym
  end
end

class PointerType < Type
  attr_reader :target_type  
  
  # 'PointerType.new' => void pointer
  # 'PointerType.new(:void)' => void pointer
  # 'PointerType.new(:pointer)' => pointer to void pointer
  # 'PointerType.new(:pointer, :void)' => pointer to void pointer
  # 'PointerType.new(PointerType.new)' => pointer to void pointer
  # 'PointerType.new(:pointer, :int8)' => pointer to pointer to int8
  # 'PointerType.new(:int8, :pointer, :int16)' => don't do this! (everything after :int8 is ignored resulting in a pointer to int8)
  def initialize(*args)
    # Defaults to void pointer
    @target_type = Type.create :void
    
    args.reverse.each do |t|
      if t.to_sym == :pointer
        @target_type = self.class.new(@target_type)
      else
        @target_type = Type.create t
      end
    end
    
    @jit_t = LibJIT.jit_type_create_pointer(@target_type.jit_t, 1)
  end
  
  # True
  def pointer?
    true
  end
  
  def to_ffi_type
    :pointer
  end
  
  def to_sym
    :pointer
  end
end

class SignatureType < Type
  attr_reader :param_types, :return_type
  
  def initialize(param_types, return_type, abi=:cdecl)
    @param_types = param_types.map {|t| Type.create t}
    @return_type = Type.create(return_type)
    
    n_params = @param_types.length
    
    return_type = @return_type.jit_t
    
    param_types = @param_types.map {|t| t.jit_t}
    ptr = FFI::MemoryPointer.new(:pointer, n_params)
    ptr.put_array_of_pointer 0, param_types
    param_types = ptr
    
    @jit_t = LibJIT.jit_type_create_signature(abi, return_type, param_types, n_params, 1)
  end
  
  def abi
    LibJIT.jit_type_get_abi(@jit_t)
  end
  
  # True
  def signature?
    true
  end
  
  def to_ffi_type
    raise JIT::TypeError.new("Can't get FFI type from a signature")
  end
end

end

