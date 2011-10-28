require 'spec_helper'

describe Remy::Chef do
  before do
    Remy.configure do |config|
      config.yml_files = ['../fixtures/foo.yml', '../fixtures/bar.yml', '../fixtures/chef.yml'].map { |f| File.join(File.dirname(__FILE__), f) }
      config.cookbook_path = ["../../chef/cookbooks"].map { |f| File.join(File.dirname(__FILE__), f) }
      config.spec_path = ["../../chef/spec"].map { |f| File.join(File.dirname(__FILE__), f) }
    end
  end

  describe "#configuration" do
    let(:chef) { Remy::Chef.new(:ip_address => IP_ADDRESS) }
    subject { chef.instance_variable_get(:@node_configuration) }
    it "should extract the info which pertains to this node" do
      subject.ip_address.should == IP_ADDRESS
      subject.rails_env.should == 'demo'
      subject.color.should == 'blue'
      subject.recipes.should == ['recipe[hello_world]']
    end
  end

  describe '#run' do
    def node_configuration(chef)
      chef.instance_variable_get(:@node_configuration)
    end

    it 'should work with a hash as its argument' do
      chef = Remy::Chef.new(:ip_address => IP_ADDRESS)
      node_configuration(chef).ip_address.should == IP_ADDRESS
      node_configuration(chef).recipes.should == ['recipe[hello_world]']
    end

    it 'should work with JSON as its argument' do
      chef = Remy::Chef.new("{\"ip_address\":\"#{IP_ADDRESS}\"}")
      node_configuration(chef).ip_address.should == IP_ADDRESS
      node_configuration(chef).recipes.should == ['recipe[hello_world]']
    end

    it 'should not modify the global Remy config, but rather only the config which is for this particular Chef node' do
      original_global_remy_node_attribute_value = Remy.configuration.another_node_attribute
      original_global_remy_node_attribute_value.should == 'hot'
      new_attribute_value_for_this_node_only = 'cold'
      chef = Remy::Chef.new(:ip_address => IP_ADDRESS, :another_node_attribute => new_attribute_value_for_this_node_only, :color => 'purple')
      node_configuration(chef).color.should == 'purple'
      node_configuration(chef).another_node_attribute.should == new_attribute_value_for_this_node_only
      node_configuration(chef).yml_files.should == ['../fixtures/foo.yml', '../fixtures/bar.yml', '../fixtures/chef.yml'].map { |f| File.join(File.dirname(__FILE__), f) }
      Remy.configuration.another_node_attribute.should == original_global_remy_node_attribute_value # Unchanged                                                                                                    # do some checks
    end
  end

end
