module JIT
  class Error < RuntimeError ; end
  
  class TypeError < Error ; end
  class UnsupportedTypeError < TypeError ; end
end
