module Remy
  class Configuration
    attr_accessor :yml_files, :cookbook_path, :spec_path, :remote_chef_dir, :node_attributes, :roles_path

    def initialize
      @yml_files = []
      @node_attributes = {}
    end
  end

  class << self
    include ::Remy::Shell
    include FileUtils

    attr_reader :configuration

    def configure
      @config_instance = Configuration.new
      yield @config_instance
      @configuration = Mash.new({:yml_files => [@config_instance.yml_files].compact.flatten,
                                 :remote_chef_dir => (@config_instance.remote_chef_dir || '/var/chef'),
                                 :roles_path => [@config_instance.roles_path].compact.flatten,
                                 :spec_path => [@config_instance.spec_path].compact.flatten,
                                 :cookbook_path => [@config_instance.cookbook_path].compact.flatten}.merge!(@config_instance.node_attributes))

      @config_instance.yml_files.each do |filename|
        configuration.deep_merge!(YAML.load(ERB.new(File.read(filename)).result) || {})
      end
    end

    def to_json
      configuration.to_json
    end

    def servers
      configuration.servers
    end

    def find_servers(options = {})
      return nil unless configuration.servers
      Mash.new(configuration.servers.inject({}) do |hash, (server_name, server_config)|
        found = options.all? { |(key, value)| server_config[key] == value }
        hash[server_name] = server_config if found
        hash
      end)
    end

    def find_server(options = {})
      return nil unless configuration.servers
      server_name, server_config = configuration.servers.detect do |(server_name, server_config)|
        options.all? { |(key, value)| server_config[key] == value }
      end
      {server_name => server_config.nil? ? nil : server_config.dup}
    end

    def find_server_config(options = {})
      find_server(options).try(:values).try(:first)
    end

    def cloud_configuration
      try(:configuration).try(:cloud_configuration)
    end
  end
end
