module Remy
  class Configuration
    attr_accessor :yml_files
  end

  class << self
    def configure
      @config_instance = Configuration.new
      yield @config_instance
      @configuration = Mash.new(:yml_files => @config_instance.yml_files)

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
