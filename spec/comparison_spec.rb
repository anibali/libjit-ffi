require 'spec_helper'

describe JIT::Value do

before do
  @context = JIT::Context.new
end

pairs = [[0, 0], [1, 0], [-1, 1], [-1, -1], [127, -128], [42, 43]]
pairs.dup.each { |a, b| pairs << [b, a] unless a == b }

# Less than
describe '#<' do
  let :func do
    @context.build_function [:int8, :int8], :int8 do |f|
      f.return f.arg(0) < f.arg(1)
    end
  end
  
  pairs.each do |a, b|
    context "when evaluating '#{a} < #{b}'" do
      subject { func[a, b] != 0 }
      it { should be(a < b) }
    end
  end
end

# Less than or equal to
describe '#<=' do
  let :func do
    @context.build_function [:int8, :int8], :int8 do |f|
      f.return f.arg(0) <= f.arg(1)
    end
  end
  
  pairs.each do |a, b|
    context "when evaluating '#{a} <= #{b}'" do
      subject { func[a, b] != 0 }
      it { should be(a <= b) }
    end
  end
end

# Greater than
describe '#>' do
  let :func do
    @context.build_function [:int8, :int8], :int8 do |f|
      f.return f.arg(0) > f.arg(1)
    end
  end
  
  pairs.each do |a, b|
    context "when evaluating '#{a} > #{b}'" do
      subject { func[a, b] != 0 }
      it { should be(a > b) }
    end
  end
end

# Greater than or equal to
describe '#>=' do
  let :func do
    @context.build_function [:int8, :int8], :int8 do |f|
      f.return f.arg(0) >= f.arg(1)
    end
  end
  
  pairs.each do |a, b|
    context "when evaluating '#{a} >= #{b}'" do
      subject { func[a, b] != 0 }
      it { should be(a >= b) }
    end
  end
end

# Equal to
describe '#eq' do
  let :func do
    @context.build_function [:int8, :int8], :int8 do |f|
      f.return f.arg(0).eq(f.arg(1))
    end
  end
  
  pairs.each do |a, b|
    context "when evaluating '#{a} == #{b}'" do
      subject { func[a, b] != 0 }
      it { should be(a == b) }
    end
  end
end

# Not equal to
describe '#ne' do
  let :func do
    @context.build_function [:int8, :int8], :int8 do |f|
      f.return f.arg(0).ne(f.arg(1))
    end
  end
  
  pairs.each do |a, b|
    context "when evaluating '#{a} != #{b}'" do
      subject { func[a, b] != 0 }
      it { should be(a != b) }
    end
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end

end

