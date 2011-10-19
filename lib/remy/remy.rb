module Remy
  class Configuration
    attr_accessor :yml_files
  end

  class << self
    def configuration
      @configuration
    end

    def configure(&block)
      @config_instance = Configuration.new
      block.call(@config_instance)
      @configuration = Mash.new(:yml_files => @config_instance.yml_files)

      @config_instance.yml_files.each do |filename|
        configuration.deep_merge!(YAML::load(IO.read(filename)))
      end
    end
  end
end
