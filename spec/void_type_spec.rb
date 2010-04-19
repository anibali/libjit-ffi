require 'libjit'

describe JIT::VoidType do

context ".new" do
  subject { JIT::VoidType.new }
  
  its(:signed?) { should be_false }
  its(:unsigned?) { should be_false }
  its(:integer?) { should be_false }
  its(:floating_point?) { should be_false }
  its(:struct?) { should be_false }
  its(:signature?) { should be_false }
  its(:pointer?) { should be_false }
  its(:void?) { should be_true }
end

end

