module Remy
  class Configuration
    attr_accessor :yml_files, :cookbook_path, :remote_location_of_chef_dir

    def initialize
      @yml_files = []
    end
  end

  class << self
    include ::Remy::Shell
    include FileUtils

    def configure
      @config_instance = Configuration.new
      yield @config_instance
      @configuration = Mash.new(:yml_files => [@config_instance.yml_files].flatten,
                                :remote_location_of_chef_dir => (@config_instance.remote_location_of_chef_dir || '/var'),
                                :cookbook_path => [@config_instance.cookbook_path].flatten)

      @config_instance.yml_files.each do |filename|
        configuration.deep_merge!(YAML::load(IO.read(filename)))
      end
    end

    def configuration
      @configuration
    end

    def to_json
      configuration.to_json
    end
  end
end
