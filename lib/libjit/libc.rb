module JIT
  class LibC
    LIB = FFI::DynamicLibrary.open(FFI::Platform::LIBC,
      FFI::DynamicLibrary::RTLD_LAZY | FFI::DynamicLibrary::RTLD_GLOBAL)
    
    FUNCTIONS = {}
    
    [
     
      #########
      # stdio #
      #########
      
      # Operations on files
      [:remove, [:stringz], :int32],
      [:rename, [:stringz, :stringz], :int32],
      [:tmpfile, [], :pointer],
      [:tmpnam, [:stringz], :stringz],
      
      # File access functions
      [:fclose, [:pointer], :int32],
      [:fflush, [:pointer], :int32],
      [:fopen, [:stringz, :stringz], :pointer],
      [:freopen, [:stringz, :stringz, :pointer], :pointer],
      [:setbuf, [:pointer, :stringz], :void],
      #[:setvbuf, [:pointer, :stringz, :int32, :size_t], :void],
      
      # Formatted input/output functions
      [:fprintf, [:pointer, :stringz, :varargs], :int32],
      [:fscanf, [:pointer, :stringz, :varargs], :int32],
      [:printf, [:stringz, :varargs], :int32],
      [:scanf, [:stringz, :varargs], :int32],
      #[:snprintf, [:stringz, :size_t, :stringz, :varargs], :int32],
      [:sprintf, [:stringz, :stringz, :varargs], :int32],
      [:sscanf, [:stringz, :stringz, :varargs], :int32],
      #vprintf
      #vscanf
      #vsnprintf
      #vsprintf
      #vsscanf
      
      #Character input/output functions
      [:fgetc, [:pointer], :int32],
      [:fgets, [:stringz, :int32, :pointer], :stringz],
      [:fputc, [:int32, :pointer], :int32],
      [:fputs, [:stringz, :pointer], :int32],
      [:getc, [:pointer], :int32],
      [:getchar, [], :int32],
      [:gets, [:stringz], :stringz],
      [:putc, [:int32, :pointer], :int32],
      [:putchar, [:int32], :int32],
      [:puts, [:stringz], :int32],
      [:ungetc, [:int32, :pointer], :int32],
      
      # Direct input/output functions
      #[:fread, [:pointer, :size_t, :size_t, :pointer], :size_t],
      #[:fwrite, [:pointer, :size_t, :size_t, :pointer], :size_t],
      
      # File positioning functions
      [:fgetpos, [:pointer, :pointer], :int32],
      [:fseek, [:pointer, :intn, :int32], :int32],
      [:fsetpos, [:pointer, :pointer], :int32],
      [:ftell, [:pointer], :intn],
      [:rewind, [:pointer], :void],
      
      # Error-handling functions
      [:clearerr, [:pointer], :void],
      [:feof, [:pointer], :int32],
      [:ferror, [:pointer], :int32],
      [:perror, [:stringz], :void],
      
      ##########
      # stdlib #
      ##########
      
      [:rand, [], :int32],
      [:srand, [:uint32], :void],
      [:malloc, [:uint32], :pointer],
      [:realloc, [:pointer, :uintn], :pointer],
      [:free, [:pointer], :void],
      [:abs, [:int32], :int32],
      
      ########
      # time #
      ########
      [:time, [:pointer], :int64],
      
    ].each do |name, param_types, return_type|
      variadic = param_types.last == :varargs
      param_types.slice! -1 if variadic
          
      param_types = param_types.map {|t| Type.create t}
      return_type = Type.create return_type
      
      ffi_param_types = param_types.map {|t| t.to_ffi_type}
      ffi_param_types << :varargs if variadic
      
      addr = LIB.find_function String(name)
      raise "couldn't find function '#{name}'" if addr.nil?
      func = FFI::Function.new(return_type.to_ffi_type, ffi_param_types, addr)
      sig = SignatureType.new(param_types, return_type)
      
      FUNCTIONS[name] = [func, sig, variadic]
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
      func, signature, variadic = *FUNCTIONS[name.to_sym]
      
      if variadic
        @function.call_native_variadic func, signature, *args
      else
        @function.call_native func, signature, *args
      end
    end
  end
end

