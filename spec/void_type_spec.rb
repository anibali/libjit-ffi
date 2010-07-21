require 'spec_helper'

describe JIT::VoidType do
  context ".new" do
    subject { JIT::VoidType.new }
    
    it_should_behave_like "a void type"
  end
end

