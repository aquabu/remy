require 'rspec'

describe 'hello_world/default' do
  it { File.exist?('/tmp/hello_world.txt').should be_true }
  it { File.read('/tmp/hello_world.txt').should include('blue') }
end
