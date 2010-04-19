require 'libjit'

describe JIT::PrimitiveType do

context ".new(:int8)" do
  subject { JIT::PrimitiveType.new(:int8) }

  its(:signed?) { should be_true }
  its(:unsigned?) { should be_false }
  its(:integer?) { should be_true }
  its(:floating_point?) { should be_false }
  its(:struct?) { should be_false }
  its(:signature?) { should be_false }
  its(:pointer?) { should be_false }
  its(:void?) { should be_false }
  its(:size) { should eql(1) }
end

context ".new(:uint64)" do
  subject { JIT::PrimitiveType.new(:uint64) }

  its(:signed?) { should be_false }
  its(:unsigned?) { should be_true }
  its(:integer?) { should be_true }
  its(:floating_point?) { should be_false }
  its(:struct?) { should be_false }
  its(:signature?) { should be_false }
  its(:pointer?) { should be_false }
  its(:void?) { should be_false }
  its(:size) { should eql(8) }
end

context ".new(:float32)" do
  subject { JIT::PrimitiveType.new(:float32) }

  its(:signed?) { should be_true }
  its(:unsigned?) { should be_false }
  its(:integer?) { should be_false }
  its(:floating_point?) { should be_true }
  its(:struct?) { should be_false }
  its(:signature?) { should be_false }
  its(:pointer?) { should be_false }
  its(:void?) { should be_false }
  its(:size) { should eql(4) }
end

context ".new(:foobar)" do
  it do
    expect {
      JIT::PrimitiveType.new(:foo_bar)
    }.to raise_exception(JIT::UnsupportedTypeError)
  end
end

end

