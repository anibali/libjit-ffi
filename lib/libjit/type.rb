module JIT

class Type
  # Get the FFI pointer representing this value's underlying jit_type_t
  # (mainly for internal use).
  attr_reader :jit_t
  
  # Create a type.
  #
  # * `Type.create(:pointer, ...)` is equivalent to `{PointerType}.new(...)`
  # * `Type.create(:struct, ...)` is equivalent to `{StructType}.new(...)`
  # * `Type.create(:signature, ...)` is equivalent to `{SignatureType}.new(...)`
  # * `Type.create(:void)` is equivalent to `{VoidType}.new`
  # * `Type.create(...)` is equivalent to `{PrimitiveType}.new(...)`
  #
  # For more information about creating specific kinds of types see
  # {PrimitiveType#initialize}, {PointerType#initialize},
  # {StructType#initialize} and {SignatureType#initialize}.
  #
  # @param *args the arguments which define the type.
  # @return [Type] the new type object.
  def self.create *args
    return args.first if args.first.is_a? Type
    
    case args.first.to_sym
    when :stringz
      PointerType.new(:uint8)
    when :pointer
      PointerType.new(*args[1..-1])
    when :signature
      SignatureType.new(*args[1..-1])
    when :struct, :structure
      StructType.new(*args[1..-1])
    when :void
      VoidType.new(*args[1..-1])
    when :bool, :boolean
      BoolType.new(*args[1..-1])
    else
      PrimitiveType.new(*args)
    end
  end
  
  def self.from_ffi_type ffi_type
    #TODO: handle struct types
    args = case FFI.find_type(ffi_type)
      when FFI::Type::Builtin::INT8
        :int8
      when FFI::Type::Builtin::UINT8
        :uint8
      when FFI::Type::Builtin::INT16
        :int16
      when FFI::Type::Builtin::UINT16
        :uint16
      when FFI::Type::Builtin::INT32
        :int32
      when FFI::Type::Builtin::UINT32
        :uint32
      when FFI::Type::Builtin::INT64
        :int64
      when FFI::Type::Builtin::UINT64
        :uint64
      when FFI::Type::Builtin::LONG
        :intn
      when FFI::Type::Builtin::ULONG
        :uintn
      when FFI::Type::Builtin::FLOAT32
        :float32
      when FFI::Type::Builtin::FLOAT64
        :float64
      when FFI::Type::Builtin::STRING
        :stringz
      when FFI::Type::Builtin::BOOL
        :bool
      when FFI::Type::Builtin::VOID
        :void
      when FFI::Type::Builtin::POINTER
        :pointer
      else
        raise "unrecognised ffi type '#{ffi_type}'"
    end
    
    Type.create *args
  end
  
  # Create a type by wrapping an FFI pointer representing a jit_type_t
  # (mainly for internal use).
  #
  # @return [Type] the new type object.
  def self.wrap jit_t
    t = Type.allocate
    t.instance_variable_set(:@jit_t, jit_t)
    
    if t.struct?
      StructType.wrap jit_t
    elsif t.pointer?
      PointerType.wrap jit_t
    elsif t.signature?
      SignatureType.wrap jit_t
    elsif t.void?
      VoidType.wrap jit_t
    elsif t.bool?
      BoolType.wrap jit_t
    else
      PrimitiveType.wrap jit_t
    end
  end
  
  [:floating_point?, :integer?, :signed?, :unsigned?].each do |method|
    define_method method do
      false
    end
  end
  
  def boolean?
    bool?
  end
  
  def bool?
    t = jit_t
    until t.null?
      if LibJIT.jit_type_get_tagged_kind(t) == :sys_bool
        return true
      end
      t = LibJIT.jit_type_get_tagged_type(t)
    end
    return false
  end
  
  def void?
    LibJIT.jit_type_get_kind(jit_t) == :void
  end
  
  # Check whether this type is a struct (alias for {#struct?}).
  #
  # @return [Boolean] true if struct, false otherwise.
  def structure?
    struct?
  end
  
  # Check whether this type is a struct.
  #
  # @return [Boolean] true if struct, false otherwise.
  def struct?
    LibJIT.jit_type_is_struct(@jit_t)
  end
  
  # Check whether this type is a pointer.
  #
  # @return [Boolean] true if pointer, false otherwise.
  def pointer?
    LibJIT.jit_type_is_pointer(@jit_t)
  end
  
  # Check whether this type is a signature.
  #
  # @return [Boolean] true if signature, false otherwise.
  def signature?
    LibJIT.jit_type_is_signature(@jit_t)
  end
  
  # Get the number of bytes that values of this type require for storage.
  #
  # @return [Integer] the size
  def size
    LibJIT.jit_type_get_size(@jit_t)
  end
end

# PrimitiveType represents basic numeric types such as ints and floats
class PrimitiveType < Type
  JIT_SYM_MAP = {
    :int8    => :sbyte,
    :uint8   => :ubyte,
    :int16   => :short,
    :uint16  => :ushort,
    :int32   => :int,
    :uint32  => :uint,
    :int64   => :long,
    :uint64  => :ulong,
    :intn    => :nint,
    :uintn   => :nuint,
    :float32 => :float32,
    :float64 => :float64
  }.freeze
  
  FFI_SYM_MAP = {
    :int8    => :int8,
    :uint8   => :uint8,
    :int16   => :int16,
    :uint16  => :uint16,
    :int32   => :int32,
    :uint32  => :uint32,
    :int64   => :int64,
    :uint64  => :uint64,
    :intn    => :long,
    :uintn   => :ulong,
    :float32 => :float,
    :float64 => :double,
  }.freeze
  
  # Create a primitive type. Acceptable arguments are :int8, :uint8, :int16,
  # :uint16, :int32, :uint32, :int64, :uint64, :intn, :uintn, :float32 and
  # :float64.
  #
  # @param [Symbol] sym the Ruby symbol representation of this type.
  def initialize sym
    @sym = sym.to_sym
    
    if LibJIT.respond_to? "jit_type_#{JIT_SYM_MAP[@sym]}"
      @jit_t = LibJIT.send "jit_type_#{JIT_SYM_MAP[@sym]}"
    else
      raise JIT::UnsupportedTypeError.new("'#{@sym}' is not a supported primitive type")
    end
  end
  
  # Create a primitive type by wrapping an FFI pointer representing a jit_type_t
  # (mainly for internal use).
  #
  # @return [PrimitiveType] the new type object.
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  # Check whether this is a floating point type.
  #
  # @return [Boolean] true if floating point type, false otherwise.
  def floating_point?
    [:float32, :float64].include? to_sym
  end
  
  # Check whether this is an integer type.
  #
  # @return [Boolean] true if integer type, false otherwise.
  def integer?
    [:int8, :int16, :int32, :int64, :intn,
     :uint8, :uint16, :uint32, :uint64, :uintn].include? to_sym
  end
  
  # Check whether this is a signed type.
  #
  # @return [Boolean] true if signed type, false otherwise.
  def signed?
    [:int8, :int16, :int32, :int64, :intn, :float32, :float64].include? to_sym
  end
  
  # Check whether this is an unsigned type.
  #
  # @return [Boolean] true if unsigned type, false otherwise.
  def unsigned?
    [:uint8, :uint16, :uint32, :uint64, :uintn].include? to_sym
  end
  
  # Get the FFI representation of this type.
  #
  # @return [FFI::Type] the FFI representation of this type.
  def to_ffi_type
    FFI_SYM_MAP[to_sym]
  end
  
  # Get the Ruby symbol representing this type.
  #
  # @return [Symbol] the Ruby symbol representation of this type.
  def to_sym
    @sym ||= LibJIT.jit_type_get_kind(@jit_t)
  end
  
  def inspect
    to_sym.inspect
  end
end

class BoolType < PrimitiveType
  def initialize
    @jit_t = LibJIT.jit_type_create_tagged LibJIT.jit_type_sbyte, :sys_bool, nil, nil, 1
  end
  
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  def to_sym
    :bool
  end
  
  def to_ffi_type
    :int8
  end
end

class VoidType < Type
  def initialize
    @jit_t = LibJIT.jit_type_void
  end
  
  # Create a void type by wrapping an FFI pointer representing a jit_type_t
  # (mainly for internal use).
  #
  # @return [VoidType] the new type object.
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  # See {Type#void?}.
  #
  # @return [Boolean] true
  def void?
    true
  end
  
  # :void
  def to_ffi_type
    :void
  end
  
  # :void
  def to_sym
    :void
  end
  
  def inspect
    to_sym.inspect
  end
end

class PointerType < Type
  # Create a pointer type.
  #
  # Examples:
  #
  # * `PointerType.new` => void pointer
  # * `PointerType.new(:void)` => void pointer
  # * `PointerType.new(:pointer)` => pointer to void pointer
  # * `PointerType.new(:pointer, :void)` => pointer to void pointer
  # * `PointerType.new(PointerType.new)` => pointer to void pointer
  # * `PointerType.new(:pointer, :int8)` => pointer to pointer to int8
  # * `PointerType.new(:int8, :pointer, :int16)` => don't do this! (everything
  #   after :int8 is ignored resulting in a pointer to int8)
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
  
  # Create a pointer type by wrapping an FFI pointer representing a jit_type_t
  # (mainly for internal use).
  #
  # @return [PointerType] the new type object.
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  def ref_type
    @ref_type ||= Type.wrap(LibJIT.jit_type_get_ref(@jit_t))
  end
  
  # See {Type#pointer?}.
  #
  # @return [Boolean] true
  def pointer?
    true
  end
  
  def to_ffi_type
    :pointer
  end
  
  def to_sym
    :pointer
  end
  
  def inspect
    depth = 1
    t = ref_type
    while t.pointer?
      t = t.ref_type
      depth += 1
    end
    arr = []
    depth.times { arr << :pointer }
    arr << t
    arr.inspect
  end
end

class SignatureType < Type
  def initialize(param_types, return_type, abi=:cdecl)
    @param_types = param_types.map {|t| Type.create(*t)}
    @return_type = Type.create(*return_type)
    
    n_params = @param_types.length
    
    return_type = @return_type.jit_t
    
    param_types = @param_types.map {|t| t.jit_t}
    ptr = FFI::MemoryPointer.new(:pointer, n_params)
    ptr.put_array_of_pointer 0, param_types
    
    @jit_t = LibJIT.jit_type_create_signature(abi, return_type, ptr, n_params, 1)
  end
  
  # Create a signature type by wrapping an FFI pointer representing a jit_type_t
  # (mainly for internal use).
  #
  # @return [SignatureType] the new type object.
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
  
  # See {Type#signature?}.
  #
  # @return [Boolean] true
  def signature?
    true
  end
  
  def to_ffi_type
    raise JIT::TypeError.new("Can't get FFI type from a signature")
  end
  
  def inspect
    [:signature, param_types, return_type].inspect
  end
end

class StructType < Type
  def initialize *args
    field_types = args.map {|t| Type.create(*t).jit_t}
    
    n_fields = field_types.length
    ptr = FFI::MemoryPointer.new(:pointer, n_fields)
    ptr.put_array_of_pointer 0, field_types
    
    @jit_t = LibJIT.jit_type_create_struct(ptr, n_fields, 1)
  end
  
  # Create a struct type by wrapping an FFI pointer representing a jit_type_t
  # (mainly for internal use).
  #
  # @return [StructType] the new type object.
  def self.wrap jit_t
    type = self.allocate
    type.instance_variable_set(:@jit_t, jit_t)
    type
  end
  
  # Get a field's memory offset from its index.
  #
  # @return [Integer] the field's offset.
  def offset field
    field = find_field(field) unless field.is_a? Integer
    LibJIT.jit_type_get_offset(jit_t, field)
  end
  
  # Get a field's type from its index.
  #
  # @return [Type] the field's type.
  def field_type field
    field = find_field(field) unless field.is_a? Integer
    Type.wrap LibJIT.jit_type_get_field(jit_t, field)
  end
  
  # Get a field's index from its name.
  #
  # @return [Integer] the field's index.
  def find_field name
    LibJIT.jit_type_find_name jit_t, name.to_s
  end
  
  # Set names for each of this struct's fields.
  #
  # @param [Array] names the field names.
  def field_names=(names)
    array_ptr = FFI::MemoryPointer.new :pointer, names.size
    names = names.map do |name|
      name += "\0"
      string_ptr = FFI::MemoryPointer.new :char, name.size
      string_ptr.put_array_of_char 0, name.unpack('C*')
      string_ptr.address
    end
    array_ptr.put_array_of_pointer 0, names
    
    LibJIT.jit_type_set_names jit_t, array_ptr, names.size
  end
  
  def field_name(field)
    LibJIT.jit_type_get_name(jit_t, field)
  end
  
  def field_count
    LibJIT.jit_type_num_fields jit_t
  end
  
  # Set this struct's name.
  #
  # @param [String] name the name to set.
  def struct_name=(name)
    LibJIT.jit_type_create_tagged(jit_t, :struct_name, name, nil, 1)
    @name = name
  end
  
  # Get this struct's name.
  #
  # @return [String] the name.
  def struct_name
    if @name.nil?
      t = jit_t
      
      until(LibJIT.jit_type_get_tagged_kind(t) == :struct_name)
        t = LibJIT.jit_type_get_tagged_type(t)
        return nil if t.null?
      end
      
      @name = LibJIT.jit_type_get_tagged_data(t)
    else
      @name
    end
  end
  
  # See {Type#struct?}.
  #
  # @return [Boolean] true
  def struct?
    true
  end
  
  def inspect
    arr = [:struct]
    field_count.times do |i|
      arr << field_type(i)
    end
    arr.inspect
  end
end

end

