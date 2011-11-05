require 'spec_helper'

describe Remy do
  describe '.configuration' do
    describe 'with no yml files' do
      it 'should return an empty mash' do
        Remy.configuration.should == Mash.new
      end
    end

    describe "yml files" do
      it 'should combine multiple yaml files into a mash' do
        Remy.configure { |config| config.yml_files = ['fixtures/foo.yml', 'fixtures/bar.yml'].map { |f| File.join(File.dirname(__FILE__), f) } }
        subject.configuration.yml_files.should == ['fixtures/foo.yml', 'fixtures/bar.yml'].map { |f| File.join(File.dirname(__FILE__), f) }
        subject.configuration.blah.should == 'bar'
        subject.configuration.baz.should == 'baz'
      end

      it 'should return an empty array if there are no yml files' do
        Remy.configure {}
        subject.configuration.yml_files.should == []
      end

      it 'should not raise an error if there is a file does does not exist' do
        expect do
          Remy.configure { |config| config.yml_files = ['does_not_exist.yml'] }
        end.should_not raise_error
      end
    end

    describe "cookbooks path" do
      it "should work if a single cookbook path is specified" do
        Remy.configure { |config| config.cookbook_path = 'cookbooks' }
        subject.configuration.cookbook_path.should == ['cookbooks']
      end

      it "should work if multiple cookbook paths are specified" do
        Remy.configure { |config| config.cookbook_path = ['cookbooks1', 'cookbooks2'] }
        subject.configuration.cookbook_path.should == ['cookbooks1', 'cookbooks2']
      end

      it "should return an empty array if no cookbook paths are specified" do
        Remy.configure {}
        subject.configuration.cookbook_path.should == []
      end
    end

    describe "specs path" do
      it "should work if a single spec path is specified" do
        Remy.configure { |config| config.spec_path = 'specs' }
        subject.configuration.spec_path.should == ['specs']
      end

      it "should work if multiple spec paths are specified" do
        Remy.configure { |config| config.spec_path = ['specs1', 'specs2'] }
        subject.configuration.spec_path.should == ['specs1', 'specs2']
      end

      it "should return an empty array if no spec paths are specified" do
        Remy.configure {}
        subject.configuration.spec_path.should == []
      end
    end

    describe "roles path" do
      it "should work if a single file is specified" do
        Remy.configure { |config| config.roles_path = 'roles' }
        subject.configuration.roles_path.should == ['roles']
      end

      it "should work if multiple files are specified" do
        Remy.configure { |config| config.roles_path = ['roles1', 'roles2'] }
        subject.configuration.roles_path.should == ['roles1', 'roles2']
      end

      it "should return an empty array if no roles paths are specified" do
        Remy.configure {}
        subject.configuration.roles_path.should == []
      end
    end

    describe "node attributes" do
      it "should merge in the other node attributes from the hash" do
        Remy.configure { |config| config.node_attributes = {:another_node_attribute => 'red'} }
        subject.configuration.another_node_attribute.should == 'red'
      end

      it "should not blow up if there no node attributes are specified" do
        lambda { Remy.configure {} }.should_not raise_error
      end
    end

    describe "#remote_chef_dir" do
      it "should default to /var/chef if no option is given" do
        subject.configuration.remote_chef_dir.should == '/var/chef'
      end

      it "should be able to be overriden" do
        Remy.configure { |config| config.remote_chef_dir = '/foo/shef' }
        subject.configuration.remote_chef_dir.should == '/foo/shef'
      end
    end
  end

  describe '.to_json' do
    it 'should create the expected JSON' do
      Remy.configure {}
      lambda do
        JSON.parse(subject.to_json)
      end.should_not raise_error
    end
  end

  context 'with a configuration' do
    before do
      Remy.configure do |config|
        config.yml_files = ['fixtures/chef.yml'].map { |f| File.join(File.dirname(__FILE__), f) }
      end
    end

    describe '.servers' do
      it 'returns all servers' do
        Remy.servers.size.should == 3
        Remy.servers['db.sharespost.com'].color.should == 'yellow'
      end
      it 'should return servers that match the criteria (using standard Enumerable methods)' do
        Remy.servers.select { |(k, v)| v.rails_env == 'demo' }.map(&:first).should == ['web.sharespost.com', 'demo.sharespost.com']
      end
    end

    describe '.find_servers' do
      it 'should return servers that match the criteria' do
        Remy.find_servers(:rails_env => 'demo').keys.should == ['web.sharespost.com', 'demo.sharespost.com']
      end

      it 'should return all servers if there are no criteria' do
        Remy.find_servers.keys.should == ['db.sharespost.com', 'web.sharespost.com', 'demo.sharespost.com']
      end

      it 'should return servers that match the criteria (with multiple criteria)' do
        Remy.find_servers(:rails_env => 'demo', :color => 'blue').keys.should == ['web.sharespost.com']
      end

      it "should return nil if there are no servers specified in the yaml file" do
        Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), 'fixtures/hello_world_chef.yml') }
        Remy.find_servers(:rails_env => 'demo').should be_nil
      end
    end

    describe '.find_server' do
      it 'should return the first server that matchs the criteria' do
        Remy.find_server(:rails_env => 'demo').keys.should == ['web.sharespost.com']
      end

      it 'should return nil if there are no servers specifie in the yml files' do
        Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), 'fixtures/hello_world_chef.yml') }
        Remy.find_server(:rails_env => 'demo').should be_nil
      end
    end

    describe '.find_server_config' do
      it 'should return the first server that matchs the criteria' do
        Remy.find_server_config(:rails_env => 'demo').to_hash.should == {"color"=>"blue", "recipes"=>["recipe[hello_world]"], "rails_env"=>"demo", "ip_address"=> IP_ADDRESS}
      end

      it 'should return nil if no server info is found' do
        Remy.find_server_config(:rails_env => 'foo').should be_nil
      end

      it 'should return nil if there are no servers in the yml files' do
        Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), 'fixtures/hello_world_chef.yml') }
        Remy.find_server_config(:rails_env => 'foo').should be_nil
      end
    end

    describe '.find_server_config_by_name' do
      it 'should return the server that matches the name' do
        Remy.find_server_config_by_name('db.sharespost.com').to_hash.should == {"encoding"=>"utf8", "adapter"=>"mysql2", "color"=>"yellow", "rails_env"=>"production", "ip_address"=>"51.51.51.51"}
      end

      it 'should return nil if theres no server that matches the name' do
        Remy.find_server_config_by_name('db.asdfjkll.com').should be_nil
      end

      it 'should return nil (and not blow up) if there are no servers in the yml files' do
        Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), 'fixtures/hello_world_chef.yml') }
        Remy.find_server_config_by_name('db.asdfjkll.com').should be_nil
      end

      it 'should return nil (and not blow up) if there is no Remy configuration' do
        Remy.instance_variable_set('@configuration', nil)
        Remy.find_server_config_by_name('db.asdfjkll.com').should be_nil
      end
    end

    describe '.cloud_configuration' do
      it 'should return nil if it has not been specified in the yml files' do
        Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), 'fixtures/hello_world_chef.yml') }
        Remy.cloud_configuration.should be_nil
      end

      it 'should return the cloud configuration options if present in the yml files' do
        Remy.cloud_configuration.should == Mash.new({:cloud_api_key => 'abcdefg12345',
                                                     :cloud_provider => 'Rackspace',
                                                     :cloud_username => 'sharespost',
                                                     :flavor_id => 4,
                                                     :image_id => 49,
                                                     :server_name => 'new-server.somedomain.com'})

      end

      it 'should return nil if there is currently no Remy configuration' do
        Remy.instance_variable_set('@configuration', nil)
        Remy.cloud_configuration.should be_nil
      end
    end
  end

  describe 'support for the rake tasks' do
    before do
      Remy.configure do |config|
        config.yml_files = ['fixtures/foo.yml', 'fixtures/bar.yml', 'fixtures/chef.yml'].map { |f| File.join(File.dirname(__FILE__), f) }
      end
    end

    describe '.convert_properties_to_hash' do
      it 'should convert properties to a hash' do
        Remy.send(:convert_properties_to_hash, ' foo:bar blah:blech').should == {:foo => 'bar', :blah => 'blech'}
      end

      it 'should convert a blank string to nil' do
        Remy.send(:convert_properties_to_hash, '  ').should be_nil
      end

      it 'should return nil if the string is not in property format' do
        Remy.send(:convert_properties_to_hash, 'demo.sharespost.com').should be_nil
      end
    end

    describe '.convert_rake_args_to_chef_options' do
      it 'should return an empty hash if no options are given' do
        Remy.send(:convert_rake_args_to_chef_options, '').should == [{}]
      end

      it 'should return an ip address if an ip address is given as property value (this IP address is not in the yml file)' do
        Remy.send(:convert_rake_args_to_chef_options, 'ip_address:1.2.3.4').should == [{:ip_address => '1.2.3.4'}]
      end

      it 'should return pass through additional properties' do
        Remy.send(:convert_rake_args_to_chef_options, 'ip_address:1.2.3.4 color:green').should == [{:ip_address => '1.2.3.4', :color => 'green'}]
      end

      it 'should return additional properties from the yaml if the server is found in the :servers section of the yml files' do
        Remy.send(:convert_rake_args_to_chef_options, 'ip_address:52.52.52.52').should == [
            Mash.new({:ip_address => '52.52.52.52',
                      :color => 'green',
                      :recipes => ['recipe[hello_world]'],
                      :adapter => 'mysql2',
                      :rails_env => 'demo',
                      :encoding => 'utf8'})]
      end

      it 'should return additional properties from the yaml if the server is found in the :servers section of the yml files - IP address is specified' do
        Remy.send(:convert_rake_args_to_chef_options, '52.52.52.52').should == [
            Mash.new({:ip_address => '52.52.52.52',
                      :color => 'green',
                      :recipes => ['recipe[hello_world]'],
                      :adapter => 'mysql2',
                      :rails_env => 'demo',
                      :encoding => 'utf8'})]
      end

      it 'should return the IP address - the IP address is specified, but is not found in the servers section in the yml files' do
        Remy.send(:convert_rake_args_to_chef_options, '1.2.3.4').should == [Mash.new({:ip_address => '1.2.3.4'})]
      end

      it 'should be able to find servers by name' do
        Remy.send(:convert_rake_args_to_chef_options, 'demo.sharespost.com').should == [
            Mash.new({:ip_address => '52.52.52.52',
                      :recipes => ['recipe[hello_world]'],
                      :adapter => 'mysql2',
                      :encoding => 'utf8',
                      :rails_env => 'demo',
                      :color => 'green'})
        ]
      end

      it 'should be able to find servers from the yml files by searching by attributes' do
        Remy.send(:convert_rake_args_to_chef_options, 'rails_env:demo').should == [
            Mash.new({:ip_address => '50.57.162.242',
                      :recipes => ['recipe[hello_world]'],
                      :rails_env => 'demo',
                      :color => 'blue'}),
            Mash.new({:ip_address => '52.52.52.52',
                      :recipes => ['recipe[hello_world]'],
                      :adapter => 'mysql2',
                      :rails_env => 'demo',
                      :color => 'green',
                      :encoding => 'utf8',
                      :adapter => 'mysql2'})
        ]
      end
    end
  end
end

