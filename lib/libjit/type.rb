module JIT

class Type
  attr_reader :jit_t
  
  class << self
    def create *args
      return args.first if args.first.is_a? Type
      
      case args.first.to_sym
      when :pointer
        PointerType.new(*args[1..-1])
      when :signature
        SignatureType.new(*args[1..-1])
      when :struct, :structure
        StructType.new(*args[1..-1])
      when :void
        VoidType.new(*args[1..-1])
      else
        PrimitiveType.new(*args)
      end
    end
    
    def wrap jit_t
      t = Type.allocate
      t.instance_variable_set(:@jit_t, jit_t)
      
      if t.struct?
        StructType.wrap jit_t
      elsif t.pointer?
        PointerType.wrap jit_t
      elsif t.signature?
        SignatureType.wrap jit_t
      elsif LibJIT.jit_type_get_kind(jit_t) == :void
        VoidType.wrap jit_t
      else
        PrimitiveType.wrap jit_t
      end
    end
  end
  
  [:void?, :floating_point?, :integer?, :signed?, :unsigned?, :primitive?].each do |method|
    define_method method do
      false
    end
  end
  
  def structure?
    struct?
  end
  
  def struct?
    LibJIT.jit_type_is_struct(@jit_t)
  end
  
  def pointer?
    LibJIT.jit_type_is_pointer(@jit_t)
  end
  
  def signature?
    LibJIT.jit_type_is_signature(@jit_t)
  end
  
  # Returns the number of bytes that values of this type require for storage
  def size
    LibJIT.jit_type_get_size(@jit_t)
  end
end

# PrimitiveType represents basic types such as ints, floats, void and pointers
# without target types
class PrimitiveType < Type
  JIT_SYM_MAP = {
    :int8 => :sbyte,
    :uint8 => :ubyte,
    :int16 => :short,
    :uint16 => :ushort,
    :int32 => :int,
    :uint32 => :uint,
    :int64 => :long,
    :uint64 => :ulong,
    :intn => :nint,
    :uintn => :nuint,
    :float32 => :float32,
    :float64 => :float64
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
    :intn => :long,
    :uintn => :ulong,
    :float32 => :float,
    :float64 => :double
  }.freeze
  
  def initialize sym
    @sym = sym.to_sym
    
    @jit_t = LibJIT.jit_type_from_string(JIT_SYM_MAP[@sym].to_s)
    
    if @jit_t.null?
      raise JIT::UnsupportedTypeError.new("'#{@sym}' is not a supported primitive type")
    end
  end
  
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  def primitive?
    true
  end
  
  def floating_point?
    [:float32, :float64].include? to_sym
  end
  
  def integer?
    [:int8, :int16, :int32, :int64, :intn,
     :uint8, :uint16, :uint32, :uint64, :uintn].include? to_sym
  end
  
  def signed?
    [:int8, :int16, :int32, :int64, :intn, :float32, :float64].include? to_sym
  end
  
  def unsigned?
    [:uint8, :uint16, :uint32, :uint64, :uintn].include? to_sym
  end
  
  def to_ffi_type
    FFI_SYM_MAP[to_sym]
  end
  
  def to_sym
    @sym ||= LibJIT.jit_type_get_kind(@jit_t)
  end
end

class VoidType < Type
  def initialize
    @jit_t = LibJIT.jit_type_from_string('void')
  end
  
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  # True
  def void?
    true
  end
  
  def to_ffi_type
    :void
  end
  
  def to_sym
    :void
  end
end

class PointerType < Type
  # 'PointerType.new' => void pointer
  # 'PointerType.new(:void)' => void pointer
  # 'PointerType.new(:pointer)' => pointer to void pointer
  # 'PointerType.new(:pointer, :void)' => pointer to void pointer
  # 'PointerType.new(PointerType.new)' => pointer to void pointer
  # 'PointerType.new(:pointer, :int8)' => pointer to pointer to int8
  # 'PointerType.new(:int8, :pointer, :int16)' => don't do this! (everything after :int8 is ignored resulting in a pointer to int8)
  def initialize(*args)
    # Defaults to void pointer
    @ref_type = Type.create :void
    
    args.reverse.each do |t|
      if [:pointer, 'pointer'].include? t
        @ref_type = self.class.new(@ref_type)
      else
        @ref_type = Type.create t
      end
    end
    
    @jit_t = LibJIT.jit_type_create_pointer(@ref_type.jit_t, 1)
  end
  
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  def ref_type
    @ref_type ||= Type.wrap(LibJIT.jit_type_get_ref(@jit_t))
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
  def initialize(param_types, return_type, abi=:cdecl)
    @param_types = param_types.map {|t| Type.create t}
    @return_type = Type.create(return_type)
    
    n_params = @param_types.length
    
    return_type = @return_type.jit_t
    
    param_types = @param_types.map {|t| t.jit_t}
    ptr = FFI::MemoryPointer.new(:pointer, n_params)
    ptr.put_array_of_pointer 0, param_types
    
    @jit_t = LibJIT.jit_type_create_signature(abi, return_type, ptr, n_params, 1)
  end
  
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  def abi
    @abi ||= LibJIT.jit_type_get_abi(@jit_t)
  end
  
  def param_types
    if @param_types.nil?
      @param_types = []
      LibJIT.jit_type_num_params(@jit_t).times do |i|
        @param_types << Type.wrap(LibJIT.jit_type_get_param(@jit_t, i))
      end
    end
    @param_types
  end
  
  def return_type
    @return_type ||= Type.wrap(LibJIT.jit_type_get_return(@jit_t))
  end
  
  # True
  def signature?
    true
  end
  
  def to_ffi_type
    raise JIT::TypeError.new("Can't get FFI type from a signature")
  end
end

class StructType < Type
  def initialize *args
    field_types = args.map {|t| Type.create(t).jit_t}
    
    n_fields = field_types.length
    ptr = FFI::MemoryPointer.new(:pointer, n_fields)
    ptr.put_array_of_pointer 0, field_types
    
    @jit_t = LibJIT.jit_type_create_struct(ptr, n_fields, 1)
  end
  
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  def offset index
    LibJIT.jit_type_get_offset(@jit_t, index)
  end
  
  def field_type index
    Type.wrap LibJIT.jit_type_get_field(@jit_t, index)
  end
  
  def struct?
    true
  end
end

end

