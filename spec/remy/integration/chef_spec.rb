require 'spec_helper'

describe Remy::Chef do
  before do
    Remy.configure do |config|
      config.yml_files = ['../../fixtures/foo.yml', '../../fixtures/bar.yml', '../../fixtures/chef.yml'].map { |f| File.join(File.dirname(__FILE__), f) }
      config.cookbook_path = ["../../../chef/cookbooks"].map { |f| File.join(File.dirname(__FILE__), f) }
      config.spec_path = ["../../../chef/spec"].map { |f| File.join(File.dirname(__FILE__), f) }
    end
  end

  describe '#run' do
    def clean_up_remote_chef_test_files(chef)
      chef.remote_execute "rm -rf /tmp/hello_world.txt #{Remy.configuration.remote_chef_dir}" if Remy.configuration.remote_chef_dir && Remy.configuration.remote_chef_dir.size > 2
    end

    def verify_contents_of_hello_world(chef)
      chef.remote_execute(%Q{cat /tmp/hello_world.txt | grep "I am feeling blue"}).should be_true
    end

    def run_chef(options = {})
      chef = Remy::Chef.new(options)
      clean_up_remote_chef_test_files(chef)
      chef.run
      yield chef
      clean_up_remote_chef_test_files(chef)
    end

    it 'should work with a hash as its argument' do
      run_chef(:ip_address => IP_ADDRESS) do |chef|
        verify_contents_of_hello_world(chef)
      end
    end

    it 'should work with JSON as its argument' do
      run_chef("{\"ip_address\":\"#{IP_ADDRESS}\"}") do |chef|
        verify_contents_of_hello_world(chef)
      end
    end
  end
end
