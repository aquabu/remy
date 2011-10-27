module Remy
  module Shell
    def execute(command)
      if quiet?
        `#{command} 2>&1`
        $?.success?
      else
        puts "Running command: #{command}"
        system command
      end
    end

    def remote_execute(cmd)
      raise ArgumentError.new unless ip_address
      execute "ssh -T #{user}@#{ip_address} '#{cmd.strip}'"
    end

    def user
      'root'
    end

    def quiet?
      false
    end
  end
end
