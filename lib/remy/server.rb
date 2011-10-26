require 'fog'

class Remy::Server
  attr_reader :name, :key, :username, :flavor_id, :image_id, :server
  def initialize(options = {})
    options = {
      :flavor_id => 4, # 2GB
      :image_id => 49 # Ubuntu 10.04 LTS (lucid)
    }.merge(options || {})

    @name = options[:name]
    @key = options[:key]
    @username = options[:username]
    @flavor_id = options[:flavor_id]
    @image_id = options[:image_id]
    @quiet = options[:quiet] || false
    @raise_exception = options[:raise_exception]
    @server = nil
  end

  def create
    compute = Fog::Compute.new(
      :provider => 'Rackspace',
      :rackspace_api_key => key,
      :rackspace_username => username
    )
    @server = compute.servers.create(:flavor_id => flavor_id.to_i, :image_id => image_id.to_i, :name => name)
    server.wait_for do
      print '.'
      STDOUT.flush
      ready?
    end
    print server_info
    {:public_ip => server.public_ip_address, :password => server.password}
  rescue Exception => e
    puts 'Failed!'
    p e
    raise e if raise_exception?
    {}
  end

  private
  def server_info
    <<-SERVER_INFO

Server name:    #{server.name}
Admin password: #{server.password}
Public IP:      #{server.public_ip_address}
Private IP:     #{server.private_ip_address}
RAM:            #{server.flavor.ram} MB
Image:          #{server.image.name}
SERVER_INFO

  end

  def print *args
    Kernel.print(*args) unless quiet?
  end

  def quiet?
    @quiet
  end

  def raise_exception?
    @raise_exception
  end
end
