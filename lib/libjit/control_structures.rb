module JIT

class ControlStructure
  def initialize(function, &condition)
    @function = function
    @condition = condition
  end
end

class ConditionalStructure < ControlStructure
  def do(&block)
    @do_block = block
    self
  end
  
  def else(&block)
    @else_block = block
    self
  end
end

class If < ConditionalStructure
  def end
    bottom_lbl = @function.label

    if @else_block.nil?
      @function.jmp_if_not @condition.call, bottom_lbl
      @do_block.call
    else
      else_lbl = @function.label
      @function.jmp_if_not @condition.call, else_lbl
      @do_block.call
      @function.jmp bottom_lbl
      else_lbl.set
      @else_block.call
    end
    
    bottom_lbl.set
    self
  end
end

class Unless < ConditionalStructure
  def end
    bottom_lbl = @function.label

    if @else_block.nil?
      @function.jmp_if @condition.call, bottom_lbl
      @do_block.call
    else
      else_lbl = @function.label
      @function.jmp_if @condition.call, else_lbl
      @do_block.call
      @function.jmp bottom_lbl
      else_lbl.set
      @else_block.call
    end
    
    bottom_lbl.set
    self
  end
end

class IterationStructure < ControlStructure
  @@break_labels = {}  
  
  def do(&block)
    @do_block = block
    self
  end
  
  def self.break function
    if @@break_labels[function.jit_t.address].empty?
      raise "no loop to break out of"
    else
      function.jmp @@break_labels[function.jit_t.address].last
    end
  end
  
  private
  def push_break_label label
    @@break_labels[@function.jit_t.address] ||= []
    @@break_labels[@function.jit_t.address].push label
  end
  
  def pop_break_label
    @@break_labels[@function.jit_t.address].pop
  end
end

class While < IterationStructure
  def end
    top_lbl = @function.label
    bottom_lbl = @function.label
    
    push_break_label bottom_lbl
    
    @function.jmp_if_not @condition.call, bottom_lbl
    cond = @function.declare :int8
    
    top_lbl.set
    @do_block.call
    cond.store @condition.call.to_bool
    @function.jmp_if cond, top_lbl
    
    bottom_lbl.set
    
    pop_break_label
  end
end

class Until < IterationStructure
  def end
    top_lbl = @function.label
    bottom_lbl = @function.label
    
    push_break_label bottom_lbl
    
    @function.jmp_if @condition.call, bottom_lbl
    cond = @function.declare :int8
    
    top_lbl.set
    @do_block.call
    cond.store @condition.call.to_bool
    @function.jmp_if_not cond, top_lbl
    
    bottom_lbl.set
    
    pop_break_label
  end
end

end

