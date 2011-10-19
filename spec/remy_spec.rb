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
    Remy.configure do |config|
      config.yml_files = ['foo.yml', 'bar.yml']
    end
  end

  describe '.configuration' do
    it 'should combine multiple yaml files into a mash' do
      subject.configuration.yml_files.should == ['foo.yml', 'bar.yml']
      subject.configuration.blah.should == 'bar'
      subject.configuration.baz.should == 'baz'
    end
  end

  describe '.to_json' do
    it 'should create the expected JSON' do
      JSON.parse(subject.to_json).should == {"yml_files"=>["foo.yml", "bar.yml"], "baz"=>"baz", "blah"=>"bar"}
    end
  end
end
