module Remy
  module Shell
    def execute(command)
      puts "command: #{command}"
      if quiet?
        `#{command} 2>&1`
        $?.success?
      else
        system command
      end
    end

    def remote_execute(cmd)
      raise ArgumentError.new unless public_ip
      execute "ssh #{user}@#{public_ip} '#{cmd.strip}'"
    end

    def user
      'root'
    end

    def quiet?
      false
    end
  end
end
