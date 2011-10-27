require 'spec_helper'

describe Remy::LittleChef do
  before do
    Remy.configure do |config|
      config.yml_files = ['../fixtures/foo.yml', '../fixtures/bar.yml', '../fixtures/little_chef.yml'].map {|f| File.join(File.dirname(__FILE__), f) }
      config.cookbook_path = ["../../chef/cookbooks"].map {|f| File.join(File.dirname(__FILE__), f) }
      config.spec_path = ["../../chef/spec"].map {|f| File.join(File.dirname(__FILE__), f) }
    end
  end

  describe "#configuration" do
    let(:little_chef) { Remy::LittleChef.new(:ip_address => '50.57.162.227') }
    subject { little_chef.instance_variable_get(:@node_configuration) }
    it "should extract the info which pertains to this " do
      subject.ip_address.should == '50.57.162.227'
      subject.rails_env.should == 'demo'
      subject.color.should == 'blue'
      subject.recipes.should == ['recipe[hello_world]']
    end
  end

  describe '#run' do
    def node_configuration(little_chef)
      little_chef.instance_variable_get(:@node_configuration)
    end

    it 'should work with a hash as its argument' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      little_chef = Remy::LittleChef.new(:ip_address => '50.57.162.227')
      little_chef.run
      node_configuration(little_chef).ip_address.should == '50.57.162.227'
      node_configuration(little_chef).recipes.should == ['recipe[hello_world]']
    end

    it 'should work with JSON as its argument' do
      #Remy.expects(:execute).with("ssh root@111.111.111.111 'chef_solo'")
      little_chef = Remy::LittleChef.new("{\"ip_address\":\"50.57.162.227\"}")
      little_chef.run
      node_configuration(little_chef).ip_address.should == '50.57.162.227'
      node_configuration(little_chef).recipes.should == ['recipe[hello_world]']
    end

    it 'should not modify the global Remy config, but rather only the config which is for this particular Chef node' do
      original_global_remy_node_attribute_value = Remy.configuration.another_node_attribute
      original_global_remy_node_attribute_value.should == 'red'
      new_attribute_value_for_this_node_only = 'blue'
      little_chef = Remy::LittleChef.new(:ip_address => '50.57.162.227', :another_node_attribute => new_attribute_value_for_this_node_only)
      node_configuration(little_chef).another_node_attribute.should == new_attribute_value_for_this_node_only
      node_configuration(little_chef).yml_files.should == ['../fixtures/foo.yml', '../fixtures/bar.yml', '../fixtures/little_chef.yml'].map {|f| File.join(File.dirname(__FILE__), f) }
      Remy.configuration.another_node_attribute.should == original_global_remy_node_attribute_value  # Unchanged
    end
  end
end
