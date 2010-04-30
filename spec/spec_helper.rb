require File.dirname(__FILE__) + "/../lib/libjit"

module LibJITMatchers
end

Spec::Runner.configure do |config|
  config.include(LibJITMatchers)
end

