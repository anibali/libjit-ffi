require 'nice-ffi'
require 'pathname'

require 'libjit/errors'
require 'libjit/type'
require 'libjit/value'
require 'libjit/context'
require 'libjit/function'
require 'libjit/label'

module LibJIT
  extend NiceFFI::Library
  
  cur_path = Pathname.new(__FILE__).expand_path.dirname
  ffi_lib cur_path.join("libjitplus.so").to_s
  
  enum :jit_abi_t, [:cdecl, :vararg, :stdcall, :fastcall]
  
  attach_function :jit_context_create, [], :pointer
  attach_function :jit_context_destroy, [:pointer], :void
  attach_function :jit_context_build_start, [:pointer], :void
  attach_function :jit_context_build_end, [:pointer], :void
  
  attach_function :jit_type_create_signature, [:jit_abi_t, :pointer, :pointer, :int, :int], :pointer
  attach_function :jit_type_get_abi, [:pointer], :int
  
  attach_function :jit_type_from_string, [:string], :pointer
  
  attach_function :jit_function_create, [:pointer, :pointer], :pointer
  attach_function :jit_function_compile, [:pointer], :void
  attach_function :jit_function_apply, [:pointer, :pointer, :pointer], :void
  
  attach_function :jit_insn_return, [:pointer, :pointer], :int
  attach_function :jit_insn_default_return, [:pointer], :int
  attach_function :jit_insn_call, [:pointer, :string, :pointer, :pointer, :pointer, :uint, :int], :pointer
  attach_function :jit_insn_call_native, [:pointer, :string, :pointer, :pointer, :pointer, :uint, :int, :int], :pointer
  attach_function :jit_insn_mul, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_div, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_add, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_sub, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_rem, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_store, [:pointer, :pointer, :pointer], :void
  attach_function :jit_insn_label, [:pointer, :pointer], :void
  attach_function :jit_insn_lt, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_le, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_gt, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_ge, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_eq, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_ne, [:pointer, :pointer, :pointer], :pointer
  attach_function :jit_insn_branch, [:pointer, :pointer], :void
  attach_function :jit_insn_branch_if, [:pointer, :pointer, :pointer], :void
  attach_function :jit_insn_branch_if_not, [:pointer, :pointer, :pointer], :void
  
  attach_function :jit_undef_label, [], :int
  
  attach_function :jit_value_get_param, [:pointer, :int], :pointer
  attach_function :jit_value_create, [:pointer, :pointer], :pointer
  attach_function :jit_value_create_nint_constant, [:pointer, :pointer, :int], :pointer
end

module JIT
  module LibC
    extend NiceFFI::Library
    
    ffi_lib FFI::Platform::LIBC
    
    @bound = {}
    
    def self.bind name, param_types, return_type
      param_types = param_types.map {|t| Type.new t}
      return_type = Type.new return_type
      
      ptr = attach_function(name, param_types.map {|t| t.to_ffi_type}, return_type.to_ffi_type)
      sig = Signature.new(param_types, return_type)
      
      @bound[name] = [ptr, sig]
    end
    
    def self.[] name
      @bound[name]
    end
    
    bind :abs, [:int32], :int32
    bind :rand, [], :int32
    bind :srand, [:uint32], :void
    bind :time, [:pointer], :int64
  end
end

