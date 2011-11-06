require 'spec_helper'

describe Remy::Chef do
  def node_configuration(chef)
    chef.instance_variable_get(:@node_configuration)
  end

  before do
    Remy.configure do |config|
      config.yml_files = ['../fixtures/foo.yml', '../fixtures/bar.yml', '../fixtures/chef.yml'].map { |f| File.join(File.dirname(__FILE__), f) }
      config.cookbook_path = ["../../chef/cookbooks"].map { |f| File.join(File.dirname(__FILE__), f) }
      config.spec_path = ["../../chef/spec"].map { |f| File.join(File.dirname(__FILE__), f) }
    end
  end

  describe "#configuration" do
    it 'should use the top-level IP address in the yml files, if one is present in the yml files, and an ip address is not passed in as an argument' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/hello_world_chef.yml') }
      chef = Remy::Chef.new
      node_configuration(chef).ip_address.should == IP_ADDRESS
      node_configuration(chef).color.should == 'blue'
      node_configuration(chef).recipes.should == ['recipe[hello_world]']
    end

    it 'should allow the top-level values in the yml files to be overridden' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/hello_world_chef.yml') }
      chef = Remy::Chef.new(:ip_address => '1.2.3.4', :color => 'green')
      node_configuration(chef).ip_address.should == '1.2.3.4'
      node_configuration(chef).color.should == 'green'
      node_configuration(chef).recipes.should == ['recipe[hello_world]']
    end

    it 'should return properties from the :servers section of the yml file if the ip address is found in there' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/chef.yml') }
      chef = Remy::Chef.new(:ip_address => '51.51.51.51')
      node_configuration(chef).ip_address.should == '51.51.51.51'
      node_configuration(chef).rails_env.should == 'production'
      node_configuration(chef).color.should == 'yellow'
      node_configuration(chef).adapter.should == 'mysql2'
      node_configuration(chef).encoding.should == 'utf8'
    end

    it 'should allow properties from the servers section of the yml file to be overridden plus additional options added' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/chef.yml') }
      chef = Remy::Chef.new(:ip_address => '51.51.51.51', :color => 'purple', :temperature => 'warm')
      node_configuration(chef).color.should == 'purple'      # Overrides 'yellow' from the yml files
      node_configuration(chef).temperature.should == 'warm'  # A new attribute not present in the yml files
    end

    it 'should allow the chef args to be specified (and not merge this into the node configuration)' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/chef.yml') }
      chef = Remy::Chef.new(:chef_args => '-l debug')
      node_configuration(chef).chef_args.should be_nil
      chef.instance_variable_get(:@chef_args).should == '-l debug'
    end

    it 'should allow the quiet option to be specified (and not merge this into the node configuration)' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/chef.yml') }
      chef = Remy::Chef.new(:quiet => true)
      node_configuration(chef).quiet.should be_nil
      chef.instance_variable_get(:@quiet).should be_true
    end
  end

  describe '#run' do
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
