require 'rspec'

describe 'hello_world/default' do
  it { File.exist?('/tmp/foo.txt').should be_true }
  it { File.read('/tmp/foo.txt').should include('blue') }
end
