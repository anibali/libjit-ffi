require File.dirname(__FILE__) + "/../lib/libjit"
Dir["#{File.dirname(__FILE__)}/shared/**/*.rb"].each {|f| require f}

module LibJITMatchers
end

Spec::Runner.configure do |config|
  config.include(LibJITMatchers)
end

