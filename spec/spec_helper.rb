$LOAD_PATH << File.join(File.dirname(File.expand_path(__FILE__)), 'lib')
require 'libjit'
require 'rspec/core'
Dir["#{File.dirname(__FILE__)}/shared/**/*.rb"].each {|f| require f}

def evaluate_to(return_type)
  context = JIT::Context.new
  context.build_start
  func = nil
  begin
    func = context.function [], return_type
    func.return(yield func)
    func.compile
    context.build_end
  rescue Exception => ex
    context.destroy
    raise ex
  end
  res = func.call
  context.destroy
  return res
end

def in_function
  context = JIT::Context.new
  context.build_start
  begin
    func = context.function [], :void
    yield func
    context.build_end
  rescue Exception => ex
    context.destroy
    raise ex
  end
  context.destroy
end

module RSpec::Core::Subject::ClassMethods
  alias_method :old_its, :its
  
  def its attribute, *args, &block
    if args.empty?
      old_its attribute, &block
    else
      describe("#{attribute}(#{args.map{|a| a.inspect}.join ', '})") do
        define_method(:subject) { super().send(attribute, *args) }
        it(&block)
      end
    end
  end
end

