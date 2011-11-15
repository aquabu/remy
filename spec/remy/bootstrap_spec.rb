require 'spec_helper'

describe Remy::Bootstrap do
  def ruby_version(bootstrap)
    bootstrap.instance_variable_get(:@ruby_version)
  end

  def gem(bootstrap)
    bootstrap.instance_variable_get(:@gems)
  end

  def ip_address(bootstrap)
    bootstrap.instance_variable_get(:@ip_address)
  end

  describe "ruby_version" do
    it 'should default to 1.8.7 if there is no Ruby version specified in the yml files' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/hello_world_chef.yml') }
      bootstrap = Remy::Bootstrap.new
      ruby_version(bootstrap).should == '1.8.7'
    end

    it 'should get the Ruby version if specified in the yml files' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/chef.yml') }
      bootstrap = Remy::Bootstrap.new
      ruby_version(bootstrap).should == '1.9.2'
    end

    it 'should use the version passed in as an option, even if it exists in the yml files' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/chef.yml') }
      bootstrap = Remy::Bootstrap.new(:ruby_version => '1.9.1')
      ruby_version(bootstrap).should == '1.9.1'
    end
  end

  describe "gems" do
    it 'should default to nil if not specified in the yml files' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/hello_world_chef.yml') }
      bootstrap = Remy::Bootstrap.new
      gem(bootstrap)[:chef].should be_nil
      gem(bootstrap)[:bundler].should be_nil
      gem(bootstrap)[:rspec].should be_nil
    end

    it 'should get gem version if it has been specified in the yml files' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/chef.yml') }
      bootstrap = Remy::Bootstrap.new
      gem(bootstrap)[:chef].should == '0.10.4'
      gem(bootstrap)[:bundler].should == '1.0.21'
      gem(bootstrap)[:rspec].should == '2.7.0'
    end
  end

  describe "ip_address" do
    it 'should use the value from the options' do
      Remy.configure { |config| config.yml_files = File.join(File.dirname(__FILE__), '../fixtures/hello_world_chef.yml') }
      bootstrap = Remy::Bootstrap.new(:ip_address => '1.2.3.4', :password => 'abcdef')
      ip_address(bootstrap).should == '1.2.3.4'
    end
  end
end
