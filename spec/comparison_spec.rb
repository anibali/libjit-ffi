require 'libjit'

describe JIT::Value do

before do
  @context = JIT::Context.new
end

describe '"less than" comparison' do
  before do
    @func = @context.build_function [:int64, :int64], :uint8 do |f|
      f.return f.arg(0) < f.arg(1)
    end
  end
  
  # Test data: first < second
  [[0, 1], [-23, 23], [256, 257]].each do |a, b|
    context "when the expression is #{a} < #{b}" do
      subject { @func[a, b] == 0 }
      it { should be_false }
    end
  end
  
  # Test data: first >= second
  [[0, 0], [23, -23], [257, 256]].each do |a, b|
    context "when the expression is #{a} < #{b}" do
      subject { @func[a, b] == 0 }
      it { should be_true }
    end
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end

end

