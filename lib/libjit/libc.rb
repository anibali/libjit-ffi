module JIT
  module LibC
    extend FFI::Library
    
    ffi_lib FFI::Platform::LIBC
    
    @bound = {}
    
    def self.bind name, param_types, return_type
      varargs = false
      if param_types.last == :varargs
        varargs = true
        param_types.slice! -1
      end
          
      param_types = param_types.map {|t| Type.create t}
      return_type = Type.create return_type
      
      ffi_param_types = param_types.map {|t| t.to_ffi_type}
      ffi_param_types << :varargs if varargs
      ptr = attach_function(name, ffi_param_types, return_type.to_ffi_type)
      sig = SignatureType.new(param_types, return_type)
      
      @bound[name] = [ptr, sig]
    end
    
    def self.[] name
      @bound[name.to_sym]
    end
    
    # stdlib
    bind :rand, [], :int32
    bind :srand, [:uint32], :void
    bind :malloc, [:uint32], :pointer
    bind :free, [:pointer], :void
    bind :abs, [:int32], :int32
    
    # stdio
    bind :printf, [:pointer, :varargs], :int32
    bind :fprintf, [:pointer, :pointer, :varargs], :int32
    bind :sprintf, [:pointer, :pointer, :varargs], :int32
    bind :scanf, [:pointer, :varargs], :int32
    bind :fscanf, [:pointer, :pointer, :varargs], :int32
    bind :puts, [:pointer], :int32
    bind :putchar, [:int32], :int32
    bind :getchar, [], :int32
    
    # time
    bind :time, [:pointer], :int64
  end

  class C
    def initialize(function)
      @function = function
    end

    def time(ptr=@function.null)
      call_native(:time, ptr)
    end

    def method_missing(*args)
      call_native(*args)
    end

    def call_native(name, *args)
      func, signature = *LibC[name]
      
      # Handle methods with varargs
      if func.is_a? FFI::VariadicInvoker
        param_types = signature.param_types
        param_types += args[param_types.size..-1].map {|arg| arg.type}
        signature = SignatureType.new param_types, signature.return_type
        
        ffi_param_types = signature.param_types.map do |t|
          FFI.find_type(t.to_ffi_type)
        end
        ffi_return_type = FFI.find_type(signature.return_type.to_ffi_type)
        
        func = nil
        LibC.ffi_libraries.each do |lib|
          begin
            func ||= FFI.create_invoker(lib, name.to_s, ffi_param_types, ffi_return_type)
          rescue LoadError
          end
        end
      end
      
      @function.call_native func, signature, *args
    end
  end
end

