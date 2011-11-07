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

    def configure
      @config_instance = Configuration.new
      yield @config_instance
      @configuration = Mash.new({:yml_files => [@config_instance.yml_files].compact.flatten,
                                 :remote_chef_dir => (@config_instance.remote_chef_dir || '/var/chef'),
                                 :roles_path => [@config_instance.roles_path].compact.flatten,
                                 :spec_path => [@config_instance.spec_path].compact.flatten,
                                 :cookbook_path => [@config_instance.cookbook_path].compact.flatten}.merge!(@config_instance.node_attributes))

      @config_instance.yml_files.each do |filename|
        begin
          configuration.deep_merge!(YAML.load(ERB.new(File.read(filename)).result) || {})
        rescue SystemCallError, IOError
          warn "WARN: #{filename} could not be found!"
        end
      end
    end

    def configuration
      @configuration ? @configuration : Mash.new
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

    def find_server_config_by_name(name)
      return nil unless configuration.servers
      configuration.servers.find {|(server_name, _)| server_name == name}.try(:last)
    end

    def cloud_configuration
      configuration && configuration.cloud_configuration
    end

    def determine_ip_addresses_for_remy_run(rake_args)
      ip_addresses = []
      if options_hash = convert_properties_to_hash(rake_args)
        servers = find_servers(options_hash)
        if !servers.empty?
          ip_addresses = servers.collect {|server_name, chef_option| chef_option.ip_address }
        else
          ip_addresses = [options_hash[:ip_address]]
        end
      else
        names_or_ip_addresses = rake_args.split(' ').collect {|name| name.strip }
        names_or_ip_addresses.each do |name_or_ip_address|
          # From: http://www.regular-expressions.info/examples.html
          ip_address_regex = '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
          if name_or_ip_address.match(ip_address_regex)
            ip_addresses << name_or_ip_address
          elsif server_config = find_server_config_by_name(name_or_ip_address)
            ip_addresses << server_config.ip_address
          end
        end
        ip_addresses << configuration.ip_address
      end
      ip_addresses.compact
    end

    # Converts "foo:bar baz:blech" to {:foo => 'bar', :baz => 'blech'}
    def convert_properties_to_hash(properties)
      if properties =~ /:/
        properties.split(' ').inject({}) do |result, pair|
          key, value = pair.split(':')
          result[key] = value
          result
        end.symbolize_keys
      else
        nil
      end
    end
  end
end
