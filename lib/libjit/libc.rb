module JIT
  class LibC
    LIB = FFI::DynamicLibrary.open(FFI::Platform::LIBC,
      FFI::DynamicLibrary::RTLD_LAZY | FFI::DynamicLibrary::RTLD_GLOBAL)
    
    FUNCTIONS = {}
    
    [
      # stdlib
      [:rand, [], :int32],
      [:srand, [:uint32], :void],
      [:malloc, [:uint32], :pointer],
      [:realloc, [:pointer, :uintn], :pointer],
      [:free, [:pointer], :void],
      [:abs, [:int32], :int32],
      
      # stdio
      [:fopen, [:pointer, :pointer], :pointer],
      [:fread, [:pointer, :uint64, :uint64, :pointer], :uint64],
      [:fclose, [:pointer], :int32],
      [:printf, [:pointer, :varargs], :int32],
      [:fprintf, [:pointer, :pointer, :varargs], :int32],
      [:sprintf, [:pointer, :pointer, :varargs], :int32],
      [:scanf, [:pointer, :varargs], :int32],
      [:fscanf, [:pointer, :pointer, :varargs], :int32],
      [:puts, [:pointer], :int32],
      [:putchar, [:int32], :int32],
      [:getchar, [], :int32],
      
      # time
      [:time, [:pointer], :int64],
      
    ].each do |name, param_types, return_type|
      varargs = param_types.last == :varargs
      param_types.slice! -1 if varargs
          
      param_types = param_types.map {|t| Type.create t}
      return_type = Type.create return_type
      
      ffi_param_types = param_types.map {|t| t.to_ffi_type}
      ffi_param_types << :varargs if varargs
      
      addr = LIB.find_function String(name)
      raise "couldn't find function '#{name}'" if addr.nil?
      func = FFI::Function.new(return_type.to_ffi_type, ffi_param_types, addr)
      sig = SignatureType.new(param_types, return_type)
      
      FUNCTIONS[name] = [func, sig, varargs]
    end
    
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
      func, signature, varargs = *FUNCTIONS[name.to_sym]
      
      # Create new signature for variadic functions
      if varargs
        param_types = signature.param_types
        param_types += args[param_types.size..-1].map {|arg| arg.type}
        signature = SignatureType.new param_types, signature.return_type
      end
      
      # Generate instruction to call native function
      @function.call_native func, signature, *args
    end
  end
end

