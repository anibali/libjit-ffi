module JIT
  class Error < RuntimeError ; end
  
  class BuildLockError < Error ; end
  class TypeError < Error ; end
  class UnsupportedTypeError < TypeError ; end
  class InstructionError < Error ; end
end
