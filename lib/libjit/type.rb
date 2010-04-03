module JIT
class Type
  attr_reader :jit_t
  
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
    :pointer => :void_ptr,
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
    :pointer => :pointer,
    :void => :void
  }.freeze
  
  def initialize sym
    @sym = sym.to_sym
    
    @jit_t = LibJIT.jit_type_from_string(JIT_SYM_MAP[@sym].to_s)
    
    if @jit_t.null?
      raise JIT::TypeError.new("'#{@sym}' is not a supported type")
    end
  end
  
  def void?
    @sym == :void
  end
  
  def pointer?
    @sym == :pointer
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
end

