require 'spec_helper'

describe Remy do
  describe '.configuration' do
    describe "yml files" do
      it 'should combine multiple yaml files into a mash' do
        Remy.configure { |config| config.yml_files = ['fixtures/foo.yml', 'fixtures/bar.yml'] }
        subject.configuration.yml_files.should == ['fixtures/foo.yml', 'fixtures/bar.yml']
        subject.configuration.blah.should == 'bar'
        subject.configuration.baz.should == 'baz'
      end

      it 'should return an empty array if there are no yml files' do
        Remy.configure {  }
        subject.configuration.yml_files.should == []
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
        Remy.configure { }
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
        Remy.configure { }
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
        lambda { Remy.configure {  } }.should_not raise_error
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
      Remy.configure do |config|
        config.remote_chef_dir = 'foo'
        config.cookbook_path = 'bar'
        config.roles_path = 'blech'
        config.yml_files = ['fixtures/foo.yml', 'fixtures/bar.yml']
      end
      JSON.parse(subject.to_json).should == {"cookbook_path"=>["bar"], "roles_path"=>["blech"], "spec_path"=>[], "remote_chef_dir"=>"foo", "baz"=>"baz", "yml_files"=>["fixtures/foo.yml", "fixtures/bar.yml"], "blah"=>"bar"}
    end
  end

  describe '.servers' do
    before do
      Remy.configure do |config|
        config.yml_files = ['fixtures/little_chef.yml']
      end
    end

    it 'returns all servers' do
      Remy.servers.size.should == 3
      Remy.servers['db.sharespost.com'].color.should == 'yellow'
    end

    describe 'find' do
      it 'should return servers that match the criteria (using standard Enumerable methods)' do
        Remy.servers.select {|(k,v)| v.rails_env == 'demo' }.map(&:first).should == ['web.sharespost.com', 'demo.sharespost.com']
      end

      it 'should return servers that match the criteria' do
        Remy.find_servers(:rails_env => 'demo').keys.should == ['web.sharespost.com', 'demo.sharespost.com']
      end

      it 'should return servers that match the criteria (with multiple criteria)' do
        Remy.find_servers(:rails_env => 'demo', :color => 'blue').keys.should == ['web.sharespost.com']
      end
    end
  end
end

