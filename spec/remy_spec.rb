require 'spec_helper'

describe Remy do
  before do
    Remy.configure do |config|
      config.yml_files = ['fixtures/foo.yml', 'fixtures/bar.yml']
      config.cookbook_path = ["cookbooks"]
    end
  end

  describe '.configuration' do
    it 'should combine multiple yaml files into a mash' do
      subject.configuration.yml_files.should == ['fixtures/foo.yml', 'fixtures/bar.yml']
      subject.configuration.blah.should == 'bar'
      subject.configuration.baz.should == 'baz'
    end
  end

  describe '.to_json' do
    it 'should create the expected JSON' do
      JSON.parse(subject.to_json).should == {"yml_files"=>["fixtures/foo.yml", "fixtures/bar.yml"], "baz"=>"baz", "blah"=>"bar"}
    end
  end

  describe '.run_chef_remote' do
    it 'should work' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      Remy.run_chef_remote('111.111.111.111')
    end
  end
end
