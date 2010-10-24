($LOAD_PATH << File.dirname(File.expand_path(__FILE__))).uniq!
require 'spec_helper'

describe JIT::Bool do

before do
  @context = JIT::Context.new
end

describe '#and' do
  let :func do
    @context.build_function [:bool, :bool], :bool do |f|
      f.return f.arg(0).and(f.arg(1))
    end
  end
  
  context "when evaluating 'true && false'" do
    subject { func[true, false] }
    it { should eql(true && false) }
  end
  
  context "when evaluating 'true && true'" do
    subject { func[true, true] }
    it { should eql(true && true) }
  end
  
  context "when evaluating 'false && true'" do
    subject { func[false, true] }
    it { should eql(false && true) }
  end
  
  context "when evaluating 'false && false'" do
    subject { func[false, false] }
    it { should eql(false && false) }
  end
end

describe '#or' do
  let :func do
    @context.build_function [:bool, :bool], :bool do |f|
      f.return f.arg(0).or(f.arg(1))
    end
  end
  
  context "when evaluating 'true || false'" do
    subject { func[true, false] }
    it { should eql(true || false) }
  end
  
  context "when evaluating 'true || true'" do
    subject { func[true, true] }
    it { should eql(true || true) }
  end
  
  context "when evaluating 'false || true'" do
    subject { func[false, true] }
    it { should eql(false || true) }
  end
  
  context "when evaluating 'false || false'" do
    subject { func[false, false] }
    it { should eql(false || false) }
  end
end

describe '#xor' do
  let :func do
    @context.build_function [:bool, :bool], :bool do |f|
      f.return f.arg(0).xor(f.arg(1))
    end
  end
  
  context "when evaluating 'true ^^ false'" do
    subject { func[true, false] }
    it { should eql(true ^ false) }
  end
  
  context "when evaluating 'true ^^ true'" do
    subject { func[true, true] }
    it { should eql(true ^ true) }
  end
  
  context "when evaluating 'false ^^ true'" do
    subject { func[false, true] }
    it { should eql(false ^ true) }
  end
  
  context "when evaluating 'false ^^ false'" do
    subject { func[false, false] }
    it { should eql(false ^ false) }
  end
end

describe '#not' do
  let :func do
    @context.build_function [:bool], :bool do |f|
      f.return f.arg(0).not
    end
  end
  
  context "when evaluating '!false'" do
    subject { func[false] }
    it { should eql(!false) }
  end
  
  context "when evaluating '!true'" do
    subject { func[true] }
    it { should eql(!true) }
  end
end

after do
  @context.destroy # Die monster, you don't belong in this world!
end

end

