require 'spec_helper'

describe Remy do
  let(:foo_yml) do
    <<-YAML
    blah:
      bar
    YAML
  end

  let(:bar_yml) do
    <<-YAML
    baz:
      baz
    YAML
  end

  before do
    IO.expects(:read).with('foo.yml').returns(foo_yml)
    IO.expects(:read).with('bar.yml').returns(bar_yml)
  end

  it 'should combine multiple yaml files into a mash' do
    Remy.configure do |config|
      config.yml_files = ['foo.yml', 'bar.yml']
    end
    Remy.configuration.yml_files.should == ['foo.yml', 'bar.yml']
    Remy.configuration.blah.should == 'bar'
    Remy.configuration.baz.should == 'baz'
  end
end
