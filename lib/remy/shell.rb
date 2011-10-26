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
      raise ArgumentError.new unless public_ip
      execute "ssh -T #{user}@#{public_ip} '#{cmd.strip}'"
    end

    def user
      'root'
    end

    def quiet?
      false
    end
  end
end
