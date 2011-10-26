require 'spec_helper'

describe Remy::LittleChef do
  before do
    Remy.configure do |config|
      config.yml_files = ['../fixtures/foo.yml', '../fixtures/bar.yml']
      config.cookbook_path = ["../cookbooks"]
      config.roles_path = ["../roles"]
      config.node_attributes = {:another_node_attribute => 'red'}
    end
  end

  describe '.run_chef_remote' do
    it 'should work with a hash' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      little_chef = Remy::LittleChef.new(:public_ip => '50.57.150.171', :run_list => ['recipe[hello_world::default]'])
      little_chef.run
      little_chef.configuration.public_ip.should == '50.57.150.171'
      little_chef.configuration.run_list.should == ['recipe[hello_world::default]']
    end

    it 'should be able to feed command-line arguments to Chef' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      little_chef = Remy::LittleChef.new(:public_ip => '50.57.150.171', :run_list => ['recipe[hello_world::default]'], :chef_args => "-l debug")
      little_chef.run
    end

    it 'should work with JSON' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      little_chef = Remy::LittleChef.new("{\"public_ip\":\"50.57.150.171\",\"run_list\":[\"recipe[hello_world::default]\"]}")
      little_chef.run
      little_chef.configuration.public_ip.should == '50.57.150.171'
      little_chef.configuration.run_list.should == ['recipe[hello_world::default]']
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

