shared_examples_for 'an unsigned type' do
  its(:signed?)         { should be_false }
  its(:unsigned?)       { should be_true }
end

shared_examples_for 'a signed type' do
  its(:signed?)         { should be_true }
  its(:unsigned?)       { should be_false }
end

shared_examples_for 'an integer type' do
  its(:integer?)        { should be_true }
  its(:floating_point?) { should be_false }
  its(:struct?)         { should be_false }
  its(:signature?)      { should be_false }
  its(:pointer?)        { should be_false }
  its(:void?)           { should be_false }
end

shared_examples_for 'a floating point type' do
  its(:integer?)        { should be_false }
  its(:floating_point?) { should be_true }
  its(:struct?)         { should be_false }
  its(:signature?)      { should be_false }
  its(:pointer?)        { should be_false }
  its(:void?)           { should be_false }
end

shared_examples_for 'a pointer type' do
  its(:floating_point?) { should be_false }
  its(:struct?)         { should be_false }
  its(:signature?)      { should be_false }
  its(:pointer?)        { should be_true }
  its(:void?)           { should be_false }
  its(:to_sym)          { should eql :pointer }
end

shared_examples_for 'a void type' do
  its(:floating_point?) { should be_false }
  its(:struct?)         { should be_false }
  its(:signature?)      { should be_false }
  its(:pointer?)        { should be_false }
  its(:void?)           { should be_true }
  its(:to_sym)          { should eql :void }
end

shared_examples_for 'a struct type' do
  its(:floating_point?) { should be_false }
  its(:struct?)         { should be_true }
  its(:signature?)      { should be_false }
  its(:pointer?)        { should be_false }
  its(:void?)           { should be_false }
end

shared_examples_for 'a signed integer type' do
  it_should_behave_like 'a signed type'
  it_should_behave_like 'an integer type'
end

shared_examples_for 'an unsigned integer type' do
  it_should_behave_like 'an unsigned type'
  it_should_behave_like 'an integer type'
end

shared_examples_for 'an int8 type' do
  it_should_behave_like 'a signed integer type'
  its(:size) { should eql(1) }
  its(:to_sym) { should eql(:int8) }
end

shared_examples_for 'an uint8 type' do
  it_should_behave_like 'an unsigned integer type'
  its(:size) { should eql(1) }
  its(:to_sym) { should eql(:uint8) }
end

shared_examples_for 'an int16 type' do
  it_should_behave_like 'a signed integer type'
  its(:size) { should eql(2) }
  its(:to_sym) { should eql(:int16) }
end

shared_examples_for 'an uint16 type' do
  it_should_behave_like 'an unsigned integer type'
  its(:size) { should eql(2) }
  its(:to_sym) { should eql(:uint16) }
end

shared_examples_for 'an int32 type' do
  it_should_behave_like 'a signed integer type'
  its(:size) { should eql(4) }
  its(:to_sym) { should eql(:int32) }
end

shared_examples_for 'an uint32 type' do
  it_should_behave_like 'an unsigned integer type'
  its(:size) { should eql(4) }
  its(:to_sym) { should eql(:uint32) }
end

shared_examples_for 'an int64 type' do
  it_should_behave_like 'a signed integer type'
  its(:size) { should eql(8) }
  its(:to_sym) { should eql(:int64) }
end

shared_examples_for 'an uint64 type' do
  it_should_behave_like 'an unsigned integer type'
  its(:size) { should eql(8) }
  its(:to_sym) { should eql(:uint64) }
end

shared_examples_for 'an intn type' do
  it_should_behave_like 'a signed integer type'
  its(:size) { should eql([0].pack('l_').size) }
  its(:to_sym) { should eql(:intn) }
end

shared_examples_for 'an uintn type' do
  it_should_behave_like 'an unsigned integer type'
  its(:size) { should eql([0].pack('L_').size) }
  its(:to_sym) { should eql(:uintn) }
end

shared_examples_for 'a float32 type' do
  it_should_behave_like 'a signed type'
  it_should_behave_like 'a floating point type'
  its(:size) { should eql(4) }
  its(:to_sym) { should eql(:float32) }
end

shared_examples_for 'a float64 type' do
  it_should_behave_like 'a signed type'
  it_should_behave_like 'a floating point type'
  its(:size) { should eql(8) }
  its(:to_sym) { should eql(:float64) }
end

