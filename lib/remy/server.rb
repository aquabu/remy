class Remy::Server
  attr_reader :server_name, :cloud_api_key, :cloud_username, :cloud_provider, :flavor_id, :image_id, :server
  
  def initialize(options = {})
    options = {
      :flavor_id => 4, # 2GB
      :image_id => 49, # Ubuntu 10.04 LTS (lucid)
      :quiet => false
    }.merge(options || {})

    @server_name = options[:server_name]
    @cloud_api_key = options[:cloud_api_key]
    @cloud_username = options[:cloud_username]
    @cloud_provider = options[:cloud_provider]
    @flavor_id = options[:flavor_id]
    @image_id = options[:image_id]
    @quiet = options[:quiet]
    @raise_exception = options[:raise_exception]
    @server = nil
  end

  def create
    compute = Fog::Compute.new(
      :provider => cloud_provider,
      :rackspace_api_key => cloud_api_key,
      :rackspace_username => cloud_username
    )
    @server = compute.servers.create(:flavor_id => flavor_id.to_i, :image_id => image_id.to_i, :name => server_name)
    server.wait_for do
      print '.'
      STDOUT.flush
      ready?
    end
    print server_info
    {:ip_address => server.public_ip_address, :password => server.password}
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
