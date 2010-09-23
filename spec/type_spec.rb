require 'spec_helper'

describe JIT::Type do
  let(:context) { JIT::Context.new }

  %w[uint8 int8 uint16 int16 uint32 int32 uint64 int64 uintn intn].each do |t|
    describe ".create(:#{t})" do
      subject { JIT::Type.create(t.to_sym) }
      
      it_should_behave_like "an #{t} type"
    end
  end

  describe '.create(:pointer, :pointer, :int8)' do
    let(:type) { JIT::Type.create(:pointer, :pointer, :int8) }
    subject { type }
    
    it_should_behave_like 'a pointer type'
    
    describe('ref_type') do
      subject { type.ref_type }
      
      it_should_behave_like 'a pointer type'
      
      describe('ref_type') do
        subject { type.ref_type.ref_type }
        
        it_should_behave_like 'an int8 type'
      end
    end
  end
  
  describe '.create(:stringz)' do
    let(:type) { JIT::Type.create(:stringz) }
    subject { type }
    
    its(:pointer?) { should be_true }
    its(:to_sym) { should eql :stringz }
  end

  describe "cast" do
    context "from :int32 to :int8" do
      let(:func) do
        context.build_function [:int32], :int8 do |f|
          x = f.arg(0)
          x = x.cast(:int8)
          f.return(x)
        end
      end

      [3, -112, 104, 57, -73].each do |x|
        context "when value is #{x}" do
          subject { func[x] }
          it { should eql(x) }
        end
      end
    end
  end
  
  describe "from_ffi_type" do
    {
      :char => :int8,
      :int8 => :int8,
      :string => :stringz,
      :double => :float64,
      :ulong => :uintn,
      FFI::Type::Builtin::LONG => :intn
    }.each do |k, v|
      context "when passed #{k.inspect}" do
        it "should return JIT type for '#{v}'" do
          JIT::Type.from_ffi_type(k).to_sym.should eql v
        end
      end
    end
  end

  after do
    context.destroy # Die monster, you don't belong in this world!
  end
end

