require 'spec_helper'

describe Remy do
  describe '.configuration' do
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
end

