libjit-ffi
==========

Warning
-------

These bindings are still being developed, so the API is by no means stable.
Suggestions for improvements are always welcome!

Synopsis
--------

libjit-ffi provides bindings to the wonderful
[LibJIT](http://dotgnu.org/libjit-doc/libjit_toc.html) via
[FFI](http://github.com/ffi/ffi), thus bringing just-in-time compilation
to Ruby. A similar project called [ruby-libjit](http://ruby-libjit.rubyforge.org/)
exists, but I felt that using FFI rather than C extensions would increase
the portability of the bindings.

libjit-ffi currently wraps LibJIT 0.1.2, of which the source tarball may be found 
[here](ftp://ftp.gnu.org/gnu/dotgnu/libjit/libjit-0.1.2.tar.gz)

Example
-------

    require 'libjit'
    
    # Build a function which accepts 2 signed 32-bit integer arguments and
    # returns a signed 32-bit integer.
    multiply = JIT::Context.default.build_function [:int32, :int32], :int32 do |f|
      # Return the product of the first and second arguments
      f.return f.arg(0) * f.arg(1)
    end
    
    # Call the built function
    puts multiply[6, 7] #=> 42
    
    # This function squares numbers below 100 using the previously defined
    # 'multiply' function
    funky = JIT::Context.default.build_function [:uint32], :uint32 do |f|
      # If the first argument is under 100...
      f.if { f.arg(0) < f.const(100, :uint32) }.do {
        # ...return the product of the first argument and itself.
        f.return f.call_other(multiply, f.arg(0), f.arg(0))
      }.end
      # Otherwise, return the first argument unchanged
      f.return f.arg(0)
    end
    
    puts funky[5] #=> 25
    puts funky[105] #=> 105

Installing
----------

### From source

1. Install the 'burke' gem with `sudo gem install burke`.
2. Download the source for libjit-ffi.
3. Run `sudo rake install` from inside the libjit-ffi directory to build the
   gem and install it.

Features
--------

* 100% Rubyful wrappers - no thin bindings that feel like you're working with
  the C library directly!

Limitations
-----------

* Function building is not thread-safe.

