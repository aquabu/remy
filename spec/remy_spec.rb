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

    describe "#remote_location_of_chef_dir" do
      it "should default to /var if no option is given" do
        subject.configuration.remote_location_of_chef_dir.should == '/var'
      end

      it "should be able to be overriden" do
        Remy.configure do |config|
          config.remote_location_of_chef_dir = '/foo'
        end
        subject.configuration.remote_location_of_chef_dir.should == '/foo'
      end
    end
  end

  describe '.to_json' do
    it 'should create the expected JSON' do
      JSON.parse(subject.to_json).should == {"yml_files"=>["fixtures/foo.yml", "fixtures/bar.yml"], "baz"=>"baz", "blah"=>"bar"}
    end
  end

  describe '.run_chef_remote' do
    it 'should work with a hash' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      Remy::LittleChef.new(:public_ip => '50.57.159.107', :run_list => ['recipe[hello_world::default]'], :remote_location_of_chef_dir => '/foobar').run
      Remy.configuration.public_ip.should == '50.57.159.107'
      Remy.configuration.run_list.should == ['recipe[hello_world::default]']
    end

    it 'should work with JSON' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      Remy::LittleChef.new("{\"public_ip\":\"50.57.159.107\",\"run_list\":[\"recipe[hello_world::default]\"]}").run
      Remy.configuration.public_ip.should == '50.57.159.107'
      Remy.configuration.run_list.should == ['recipe[hello_world::default]']
    end
  end
end

