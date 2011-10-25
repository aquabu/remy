require 'spec_helper'

describe Remy do
  before do
    Remy.configure do |config|
      config.yml_files = ['fixtures/foo.yml', 'fixtures/bar.yml']
      config.cookbook_path = ["cookbooks"]
      config.node_attributes = {:another_node_attribute => 'red'}
    end
  end

  describe '.configuration' do
    it 'should combine multiple yaml files into a mash' do
      subject.configuration.yml_files.should == ['fixtures/foo.yml', 'fixtures/bar.yml']
      subject.configuration.blah.should == 'bar'
      subject.configuration.baz.should == 'baz'
    end

    it "should merge in the other node attributes from the hash" do
      subject.configuration.another_node_attribute.should == 'red'
    end

    describe "#remote_chef_dir" do
      it "should default to /var/chef if no option is given" do
        subject.configuration.remote_chef_dir.should == '/var/chef'
      end

      it "should be able to be overriden" do
        Remy.configure do |config|
          config.remote_chef_dir = '/foo/shef'
        end
        subject.configuration.remote_chef_dir.should == '/foo/shef'
      end
    end
  end

  describe '.to_json' do
    it 'should create the expected JSON' do
      JSON.parse(subject.to_json).should == {"cookbook_path"=>["cookbooks"], "remote_chef_dir"=>"/var/chef", "baz"=>"baz", "yml_files"=>["fixtures/foo.yml", "fixtures/bar.yml"], "blah"=>"bar"}
    end
  end

  describe '.run_chef_remote' do
    it 'should work with a hash' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      Remy::LittleChef.new(:public_ip => '50.57.159.107', :run_list => ['recipe[hello_world::default]']).run
      Remy.configuration.public_ip.should == '50.57.159.107'
      Remy.configuration.run_list.should == ['recipe[hello_world::default]']
    end

    it 'should work with JSON' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      Remy::LittleChef.new("{\"public_ip\":\"50.57.159.107\",\"run_list\":[\"recipe[hello_world::default]\"]}").run
      Remy.configuration.public_ip.should == '50.57.159.107'
      Remy.configuration.run_list.should == ['recipe[hello_world::default]']
    end

    it 'should not modify the global Remy config, but rather only the config for this Chef run which is used to generate the JSON' do
      Remy.configuration.another_node_attribute.should == 'red'
      little_chef = Remy::LittleChef.new(:another_node_attribute.should == 'blue')
      little_chef.configuration.another_node_attribute.should == 'blue'
      little_chef.configuration.yml_files.should == ['fixtures/foo.yml', 'fixtures/bar.yml']
      Remy.configuration.another_node_attribute.should == 'red'
    end
  end
end

