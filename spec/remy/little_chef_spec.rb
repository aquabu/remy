require 'spec_helper'

describe Remy::LittleChef do
  before do
    Remy.configure do |config|
      config.yml_files = ['../fixtures/foo.yml', '../fixtures/bar.yml', '../fixtures/little_chef.yml']
      config.cookbook_path = ["../cookbooks"]
    end
  end

  describe "#configuration" do
    let(:little_chef) { Remy::LittleChef.new(:remote_chef_ip => '50.57.162.227') }
    subject { little_chef.configuration }
    it "should extract the info which pertains to this " do
      subject.remote_chef_ip.should == '50.57.162.227'
      subject.rails_env.should == 'demo'
      subject.color.should == 'blue'
      subject.recipes.should == ['recipe[hello_world]']
    end
  end

  describe '#run' do
    it 'should work with a hash' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      little_chef = Remy::LittleChef.new(:remote_chef_ip => '50.57.162.227') #, :run_list => ['recipe[hello_world::default]'])
      little_chef.run
      little_chef.configuration.remote_chef_ip.should == '50.57.162.227'
      little_chef.configuration.recipes.should == ['recipe[hello_world]']
    end

    it 'should work with JSON' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      little_chef = Remy::LittleChef.new("{\"remote_chef_ip\":\"50.57.162.227\",\"run_list\":[\"recipe[hello_world::default]\"]}")
      little_chef.run
      little_chef.configuration.remote_chef_ip.should == '50.57.162.227'
      little_chef.configuration.recipes.should == ['recipe[hello_world]']
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
