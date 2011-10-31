Remy permits you to easily run chef-solo (one of the tools that is part of [Chef](http://www.opscode.com/chef/) from
[Opscode](http://www.opscode.com/)), whether from within a standard Ruby application, or from within a Rails project.
Remy is "a little Chef"; our contention is that you get 95-98% of the benefits of Chef without 95-98% of the hassles
by not using chef-client & chef-server, but rather just using [chef-solo](http://wiki.opscode.com/display/chef/Chef+Solo);
Remy provides the additional tools which are required to easily use chef-solo. Remy allows you to build a remote cloud
server box easily (whether from Rackspace or from some other cloud service provider), and then bootstrap it so that it
can run chef-solo (the bootstrap will also run on physical, not cloud, boxes; all that's required is a valid IP address
for Remy to use). Remy then provides an easy and convenient way to run chef-solo against these remote boxes, either
programmatically or from the provided rake tasks. The ability to support a cluster of boxes plus multiple config files
& directories (where some of these config files might contain passwords on encrypted drives) is what distinguishes Remy
from [soloist](https://github.com/mkocher/soloist) and other chef-solo utilities; these multiple config files and
directories are then "blended" together to create an overall chef configuration for a particular chef node.

We also do Test-Driven Chef (TDC) in our example recipes; rspec specs are run on the remote boxes to verify that the
packages and configuration are installed properly.

Note that the Chef bootstrap portion of Remy is currently limited to Ubuntu (it contains references 'apt-get'), but the
chef-solo part of Remy can run on any type of Unix if the box has been properly bootstrapped for Chef; it would be relatively simple
to extend Remy to support yum and CentOS/RedHat and other Unix OS's.

## Basic usage:

See http://www.github.com/gregwoodward/remy_simple_rails_example for the absolute simplest Remy installation with a
"Hello world" recipe; you can be up and running with chef-solo in under 5 minutes.
http://www.github.com/gregwoodward/remy_cluster_rails_example shows a full Rails installation with a clustered environment
for staging and production, and a single box which hosts the entire Rails app for the demo environment. These are the
actual recipes we use for our clustered server environment at [SharesPost](http://www.sharespost.com/).

## Concepts

Remy is configured as shown in http://www.github.com/gregwoodward/remy_cluster_rails_example/config/initializers/remy.rb,
along with the yml files in http://www.github.com/gregwoodward/remy_cluster_rails_example/chef/config/chef.yml and
http://www.github.com/gregwoodward/remy_cluster_rails_example/SecureEncryptedDrive/chef/config/chef.yml (this 'SecureEncryptedDrive'
would normally not be a part of the Rails project, but rather an encrypted disk volume which is mounted such as
/Volumes/SecureEncryptedDrive).  To use Remy, create a cookbooks directory which contains all of your recipes (see
http://www.github.com/gregwoodward/remy_cluster_rails_example/chef/cookbooks as an example). The location of the Chef
cookbooks directory is specified in the Remy configuration (see http://www.github.com/gregwoodward/remy_cluster_rails_example/lib/initializers/remy.rb).
Within one of these YAML files, create an array of servers as specified by :servers (see
http://www.github.com/gregwoodward/remy_cluster_rails_example/chef/config/chef.yml). The values in the yml config files
which are loaded last take precedence over those which were loaded earlier, and options passed directly into Remy take
precedence over values in yml config files.

Remy is typically used programmatically in a Capistrano deploy file (see http://www.github.com/gregwoodward/remy_cluster_rails_example/deploy.rb),
or by using the Remy rake tasks (see http://www.github.com/gregwoodward/remy/lib/tasks/remy.rake).

### :ip_address

:ip_address is the IP address of the box which chef-solo will run against. Normally, this is fed in as part of the options
argument (either programmatically, or from a rake task), but it could also come in from a yml config file. The simplest
usage of Remy to run chef-solo is:

`Remy::Chef.new(:ip_address => '123.123.123.123').run`

where '123.123.123.123' is the IP address that chef-solo will run on.

### :servers

If you are configuring a cluster of boxes, look at the http://www.github.com/gregwoodward/remy_cluster_rails_example/chef/config/chef.yml
file as an example. You'll see a :servers section; each server should specify its :ip_address. When Remy runs, Remy will
find the section of the :servers in the yml file which has the same :ip_address as the currently specified value, and
those values will get "promoted" to the top level, and applied against this chef node.  level.

### :cloud_configuration

You can specify the cloud server configuration in a :cloud_configuration section in one of the Remy config yml files;
see http://www.github.com/gregwoodward/remy_cluster_rails_example/SecureEncryptedDrive/chef/config/chef.yml for an example.
These cloud values can also be passed into the various Remy rake commands; see :server_name, :cloud_api_key, :cloud_username,
etc., in the Rake commands in http://www.github.com/gregwoodward/remy/lib/tasks/remy.rake.

## Create a new cloud server

Use the following rake command to create a new cloud server:

`rake remy:server:create[:server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id]`

e.g.,

`rake remy:server:create[foobar.sharespost.com,4,abcdefg1234,sharespost,Rakespace,49]`

Note that if you have the :cloud_api_key, etc., specified in your Remy config, you can omit those arguments to the
rake command:

`rake remy:server:create[foobar.sharespost.com,4]

See the [here](http://obn.me/2011/04/rackspace-cloud-images-and-flavors-id/) for a list of Rackspace flavor IDs and image
IDs (they might differ for other cloud providers).

## Bootstrap your new cloud server to run Remy and chef-solo

`rake remy:chef:bootstrap[:ip_address, :password]`

## Build and bootstrap your cloud server

You can build a box and bootstrap it for chef-solo in one step:

`rake remy:server:create_and_bootstrap[:server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id]`

## Run chef-solo on an individual box

Note: this only works if the Remy.configuration has already been specified, such as in a Rails application.

`rake remy:chef:run[123.123.123.123]`

## Programmatic ussage from within Capistrano or other Ruby code

### Run chef-solo on a single box:

The simplest usage of Remy:

`Remy::Chef.new(:ip_address => '123.123.123.123').run`

Note that the :ip_address could also have been specified in the yml config files, although more commonly it's passed in
as an argument.

Example: update your production database box:

`db_config = Remy.find_server_config(:rails_env => :production, :role => :db)
Remy::Chef.new(db_config).run`

### Run chef-solo on a collection of boxes:

From within your Capistrano file, you do a variety of things, such as the following:

    Remy.servers.find_servers(:rails_env => :staging, :role => :app) do |server|
        Remy::Chef.new(server).run
    end

## Test-Driven Chef (TDC)

Look at the example recipes in http://github.com/gregwoodward/remy_cluster_rails_example/chef/spec to see how we do
Test-Driven Chef (TDC). When writing our recipes, we will first create a failing spec, and then write the Chef recipe to
make the test pass.
