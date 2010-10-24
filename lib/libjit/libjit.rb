# This module contains raw FFI bindings to LibJIT functions. If you are not a
# developer for libjit-ffi, you shouldn't need to use anything in this module!
module LibJIT
  extend FFI::Library
  
  LIB_OPTS = %w[libjit.so libjit.dll].map do |name|
    Pathname.new(__FILE__).expand_path.dirname.join(name).to_s
  end unless defined? LIB_OPTS
  LIB_OPTS << 'jit'
  LIB_OPTS << '/usr/local/lib/libjit.so'
  
  ffi_lib LIB_OPTS
  
  enum :jit_abi_t, [:cdecl, :vararg, :stdcall, :fastcall]
  enum :jit_kind_t, [:invalid, -1, :void, :int8, :uint8, :int16, :uint16,
    :int32, :uint32, :intn, :uintn, :int64, :uint64, :float32, :float64,
    :floatn, :struct, :union, :signature, :pointer]
  enum :jit_typetag_t, [
    :stringz, 1000,
    :name, 10000, :struct_name, :union_name, :enum_name,
    :const, :volatile, :reference, :output, :restrict, :sys_bool, :sys_char,
    :sys_schar, :sys_uchar, :sys_short, :sys_ushort, :sys_int, :sys_uint,
    :sys_long, :sys_ulong, :sys_longlong, :sys_ulonglong, :sys_float,
    :sys_double, :sys_longdouble]
  
  %w[void sbyte ubyte short ushort int uint nint nuint long ulong float32
  float64 nfloat void_ptr].each do |t|
    attach_variable :"jit_type_#{t}", :pointer
  end
  
  attach_function :jit_context_create, [], :pointer
  attach_function :jit_context_destroy, [:pointer], :void
  attach_function :jit_context_build_start, [:pointer], :void
  attach_function :jit_context_build_end, [:pointer], :void
  
  attach_function :jit_type_create_struct, [:pointer, :uint, :int], :pointer
  attach_function :jit_type_get_field, [:pointer, :uint], :pointer
  attach_function :jit_type_set_names, [:pointer, :pointer, :uint], :int
  attach_function :jit_type_get_name, [:pointer, :uint], :string
  attach_function :jit_type_find_name, [:pointer, :string], :uint
  attach_function :jit_type_get_offset, [:pointer, :uint], :ulong
  attach_function :jit_type_num_fields, [:pointer], :ulong
  
  attach_function :jit_type_create_tagged, [:pointer, :jit_typetag_t, :string, :pointer, :int], :pointer
  attach_function :jit_type_get_tagged_data, [:pointer], :string
  attach_function :jit_type_get_tagged_kind, [:pointer], :jit_typetag_t
  attach_function :jit_type_get_tagged_type, [:pointer], :pointer
  
  attach_function :jit_type_create_signature, [:jit_abi_t, :pointer, :pointer, :uint, :int], :pointer
  attach_function :jit_type_get_abi, [:pointer], :jit_abi_t
  attach_function :jit_type_num_params, [:pointer], :ulong
  attach_function :jit_type_get_return, [:pointer], :pointer
  attach_function :jit_type_get_param, [:pointer, :uint], :pointer
  attach_function :jit_type_create_pointer, [:pointer, :int], :pointer
  attach_function :jit_type_get_ref, [:pointer], :pointer
  attach_function :jit_type_get_size, [:pointer], :ulong
  attach_function :jit_type_is_struct, [:pointer], :bool
  attach_function :jit_type_is_pointer, [:pointer], :bool
  attach_function :jit_type_is_signature, [:pointer], :bool
  attach_function :jit_type_get_kind, [:pointer], :jit_kind_t
  
  attach_function :jit_function_create, [:pointer, :pointer], :pointer
  attach_function :jit_function_compile, [:pointer], :void
  attach_function :jit_function_apply, [:pointer, :pointer, :pointer], :void
  attach_function :jit_function_get_signature, [:pointer], :pointer
  
  attach_function :jit_insn_return, [:pointer, :pointer], :int
  attach_function :jit_insn_default_return, [:pointer], :int
  attach_function :jit_insn_call, [:pointer, :string, :pointer, :pointer, :pointer, :uint, :int], :pointer
  attach_function :jit_insn_call_native, [:pointer, :string, :pointer, :pointer, :pointer, :uint, :int, :int], :pointer
  # Bitwise operations
  attach_function :jit_insn_not, [:pointer, :pointer], :pointer
  attach_function :jit_insn_shl, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_shr, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_and, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_xor, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_or, [:pointer, :pointer, :pointer], :pointer
  # Standard arithmetic
  attach_function :jit_insn_neg, [:pointer, :pointer], :pointer
  attach_function :jit_insn_mul, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_div, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_add, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_sub, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_rem, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_pow, [:pointer, :pointer, :pointer], :pointer
  # Comparison
  attach_function :jit_insn_lt, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_le, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_gt, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_ge, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_eq, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_ne, [:pointer, :pointer, :pointer], :pointer
  # Conversion
  attach_function :jit_insn_to_bool, [:pointer, :pointer], :pointer
  attach_function :jit_insn_to_not_bool, [:pointer, :pointer], :pointer
  
  attach_function :jit_insn_store, [:pointer, :pointer, :pointer], :void
  attach_function :jit_insn_load_relative, [:pointer, :pointer, :long, :pointer], :pointer
  attach_function :jit_insn_store_relative, [:pointer, :pointer, :long, :pointer], :int
  attach_function :jit_insn_load_elem, [:pointer, :pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_store_elem, [:pointer, :pointer, :pointer, :pointer], :int
  
  attach_function :jit_insn_alloca, [:pointer, :pointer], :pointer
  
  attach_function :jit_insn_address_of, [:pointer, :pointer], :pointer
  attach_function :jit_value_set_addressable, [:pointer], :void
  attach_function :jit_value_is_addressable, [:pointer], :bool
  
  attach_function :jit_insn_label, [:pointer, :pointer], :void
  attach_function :jit_insn_branch, [:pointer, :pointer], :void
  attach_function :jit_insn_branch_if, [:pointer, :pointer, :pointer], :void
  attach_function :jit_insn_branch_if_not, [:pointer, :pointer, :pointer], :void
  
  attach_function :jit_value_get_param, [:pointer, :int], :pointer
  attach_function :jit_value_create, [:pointer, :pointer], :pointer
  attach_function :jit_value_get_type, [:pointer], :pointer
  attach_function :jit_value_get_function, [:pointer], :pointer
  attach_function :jit_insn_convert, [:pointer, :pointer, :pointer, :int], :pointer
  
  # Constants
  attach_function :jit_value_create_nint_constant, [:pointer, :pointer, :long], :pointer
  attach_function :jit_value_create_long_constant, [:pointer, :pointer, :long_long], :pointer
  attach_function :jit_value_create_float32_constant, [:pointer, :pointer, :float], :pointer
  attach_function :jit_value_create_float64_constant, [:pointer, :pointer, :double], :pointer
  attach_function :jit_value_get_nint_constant, [:pointer], :long
  attach_function :jit_value_get_long_constant, [:pointer], :long_long
  attach_function :jit_value_get_float32_constant, [:pointer], :float
  attach_function :jit_value_get_float64_constant, [:pointer], :double
  
  module Math
    extend FFI::Library
    
    ffi_lib LibJIT::LIB_OPTS
  
    attach_function :acos, :jit_insn_acos, [:pointer, :pointer], :pointer
    attach_function :asin, :jit_insn_asin, [:pointer, :pointer], :pointer
    attach_function :atan, :jit_insn_atan, [:pointer, :pointer], :pointer
    attach_function :atan2, :jit_insn_atan2, [:pointer, :pointer, :pointer], :pointer
    attach_function :ceil, :jit_insn_ceil, [:pointer, :pointer], :pointer
    attach_function :cos, :jit_insn_cos, [:pointer, :pointer], :pointer
    attach_function :cosh, :jit_insn_cosh, [:pointer, :pointer], :pointer
    attach_function :exp, :jit_insn_exp, [:pointer, :pointer], :pointer
    attach_function :floor, :jit_insn_floor, [:pointer, :pointer], :pointer
    attach_function :log, :jit_insn_log, [:pointer, :pointer], :pointer
    attach_function :log10, :jit_insn_log10, [:pointer, :pointer], :pointer
    attach_function :rint, :jit_insn_rint, [:pointer, :pointer], :pointer
    attach_function :round, :jit_insn_round, [:pointer, :pointer], :pointer
    attach_function :sin, :jit_insn_sin, [:pointer, :pointer], :pointer
    attach_function :sinh, :jit_insn_sinh, [:pointer, :pointer], :pointer
    attach_function :sqrt, :jit_insn_sqrt, [:pointer, :pointer], :pointer
    attach_function :tan, :jit_insn_tan, [:pointer, :pointer], :pointer
    attach_function :tanh, :jit_insn_tanh, [:pointer, :pointer], :pointer
    #TODO: more...
  end
end

