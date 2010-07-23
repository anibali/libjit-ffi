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

Example
-------

    require 'libjit'
    
    multiply = JIT::Context.default.build_function [:int32, :int32], :int32 do |f|
      lhs = f.arg(0)
      rhs = f.arg(1)
      f.return(lhs * rhs)
    end
    
    puts multiply[6, 7] #=> 42

Features
--------

* 100% Rubyful wrappers - no thin bindings that feel like you're working with
  the C library directly!

Limitations
-----------

* Function building is not thread-safe.

