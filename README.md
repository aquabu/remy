# [Remy](http://www.github.com/gregwoodward/remy)

Remy permits you to easily run chef-solo (one of the tools that is part of [Chef](http://www.opscode.com/chef/) from
[Opscode](http://www.opscode.com/)), whether from within a stand-alone Ruby application, or from within a Rails project.
Remy is "a little chef"; our contention is that you get 95-98% of the benefits of Chef without 95-98% of the hassles
by **NOT** using [chef-client](http://wiki.opscode.com/display/chef/Chef+Client) &
[chef-server](http://wiki.opscode.com/display/chef/Chef+Server), but rather just using
[chef-solo](http://wiki.opscode.com/display/chef/Chef+Solo); Remy provides the missing tools which are required to
easily use chef-solo. Remy allows you to build a remote cloud
server box easily (whether from Rackspace or from some other cloud service provider), and then bootstrap it so that it
can run chef-solo (the bootstrap will also run on physical, not cloud, boxes; all that's required is remote host at a valid IP address
for Remy to use). Remy then provides an easy and convenient way to run chef-solo against these remote boxes, either
programmatically or from some rake tasks that are provided. The ability to support a cluster of boxes plus multiple config files
& directories (where some of these config files might contain passwords on encrypted drives) is what distinguishes Remy
from [soloist](https://github.com/mkocher/soloist) and other chef-solo utilities; these multiple config files and
directories are then "blended" together to create an overall chef configuration (as JSON) for a particular chef node.

We also do Test-Driven Chef (TDC) in our example recipes; rspec specs are run on the remote boxes to verify that the
packages and configuration are installed properly; we use these specs to drive the creation of the Chef recipes.

Note that the Chef bootstrap portion of Remy is currently limited to Ubuntu (it contains references to 'apt-get'), but the
chef-solo part of Remy can run on any type of Unix if the box has been properly bootstrapped for Chef. Also note that it
would be relatively simple to extend Remy to support yum and CentOS/RedHat and other Unix OS's.


## Basic usage:

See [the Remy simple Rails example](http://www.github.com/gregwoodward/remy_simple_rails_example) for the absolute simplest
Remy installation with a "Hello world" recipe; you can be up and running with chef-solo in under 5 minutes.
[The Remy cluster rails example](http://www.github.com/gregwoodward/remy_cluster_rails_example) shows a full Rails
installation with a clustered environment for staging and production, and a single box which hosts the entire Rails app
for the demo environment; multiple config files are used because passwords are stored separately on an encrypted drive.
These are the actual recipes we use for our clustered server environment at [SharesPost](http://www.sharespost.com/).


## Concepts

Remy is configured as shown in an example Remy configuration file [config/initializers/remy.rb](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/config/initializers/remy.rb),
along with the example yml files in [chef/config/chef.yml](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/config/chef.yml) and
[SecureEncryptedDrive/chef/config/chef.yml](https://github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/SecureEncryptedDrive/chef/config/chef.yml)
(this 'SecureEncryptedDrive' would normally not be a part of the Rails project, but rather an encrypted disk volume which is mounted such as
/Volumes/SecureEncryptedDrive).  To use Remy, create a cookbooks directory which contains all of your recipes (see
[chef/cookbooks](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/cookbooks) as an example;
these cookbook directories should be in the [standard Opscode Chef cookbooks format](http://wiki.opscode.com/display/chef/Cookbooks) ).
The location of the chef cookbooks directory is specified in the Remy configuration (see
[remy.rb](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/config/initializers/remy.rb)); the default
location is /var/chef on the remote boxes, and is typically put in RAILS_ROOT/chef/cookbooks in your local Rails app.
Within one of these YAML files, create an array of servers as specified by :servers (see
[chef/config/chef.yml](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/config/chef.yml) ). The values in the yml config files
which are loaded last take precedence over those which were loaded earlier, and options passed directly into Remy take
precedence over values in the yml config files.

Remy is typically used programmatically in a Capistrano deploy file or other Rails code
(see [deploy.rb](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/deploy.rb)), or by using the supplied Remy rake tasks
(see [remy.rake](http://www.github.com/gregwoodward/remy/blob/master/lib/tasks/remy.rake)).

### Remy yml config files

The Remy yml files can be pretty much in whatever format you desire with a few constraints; see
[this example for simple usage](https://github.com/gregwoodward/remy_simple_rails_example/blob/master/chef/config/chef.yml), and this one for
[an advanced example to support a cluster](https://github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/config/chef.yml).

These are keys which have special significance in the Remy config files; see :ip_address, :servers, and :cloud_configuration
[here](https://github.com/gregwoodward/remy_simple_rails_example/blob/master/chef/config/chef.yml),
[here](https://github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/config/chef.yml), and
[here](https://github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/SecureEncryptedDrive/chef/config/chef.yml) for examples.

#### :ip_address

:ip_address is the IP address of the box which chef-solo will run against. Normally, this is given to Remy as part of the options
arguments (either programmatically, or from a rake task) and is not in the yml config files, but it could also come in from one of the Remy yml config file(s).
The simplest usage of Remy to run chef-solo is:

`Remy::Chef.new(:ip_address => '123.123.123.123').run`

where '123.123.123.123' is the IP address that chef-solo will run on. Note that:

`Remy::Chef.new.run`

would also work if :ip_address was specified somewhere in the Remy configuration (i.e., it was specified in one of the Remy yml files); this is
the case in the [chef.yml in the "hello world" Remy example](http://www.github.com/gregwoodward/remy_simple_rails_example/blob/master/chef/config/chef.yml)


#### :servers

If you are configuring a cluster of boxes, look at the [chef/config/chef.yml](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/config/chef.yml)
file as an example. You'll see a :servers section; each server should specify its :ip_address. When Remy runs, Remy will
find the section of the :servers in the yml file which has the same :ip_address as the currently specified value, and
those values will get "promoted" to the top level, and applied against this chef node (i.e., JSON will be generated which
contains these values).

#### :cloud_configuration

You can specify the cloud server configuration in a :cloud_configuration section in one of the Remy config yml files;
see [SecureEncryptedDrive/chef/config/chef.yml](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/SecureEncryptedDrive/chef/config/chef.yml) for an example.
Alternatively, these cloud values can also be passed into the various Remy rake commands; see :server_name, :cloud_api_key, :cloud_username,
etc., in the Rake commands in [remy.rake](http://www.github.com/gregwoodward/remy/blob/master/lib/tasks/remy.rake).

#### :bootstrap

You can specify the Ruby version that gets installed on a new remote box, along with the versions of the various bootstrap
Ruby gems (chef, bundler, and rspec) in the yml config files; see
[chef.yml](http://www.github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/config/chef.yml) for an example
of these parameters.


## Remy usage from Rake

### Create a new cloud server

Use the following rake command to create a new cloud server:

`rake remy:server:create[:server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id]`

e.g.,

`rake remy:server:create[foobar.sharespost.com,4,abcdefg1234,sharespost,Rakespace,49]`

Note that if you have the :cloud_api_key, etc., specified in your Remy configuration yml files, you can omit those arguments to the
rake command:

`rake remy:server:create[foobar.sharespost.com,4]`

[See here](http://obn.me/2011/04/rackspace-cloud-images-and-flavors-id/) for a list of Rackspace flavor IDs and image
IDs (they might differ for other cloud providers).

### Bootstrap your new cloud server to run Remy and chef-solo

This bootstrap task installs the prerequisites necessary to run chef on this new remote box, such as updating the Linux
distribution, installing RVM, installing the Chef gem and its prerequisites, and installing rspec (which is required
because we do test-driven Chef):

`rake remy:chef:bootstrap[:ip_address, :password]`


### Build and bootstrap your cloud server

You can both build a box and bootstrap it for chef-solo all in one step:

`rake remy:server:create_and_bootstrap[:server_name, :flavor_id, :cloud_api_key, :cloud_username, :cloud_provider, :image_id]`

### Run chef-solo

`rake remy:chef:run['123.123.123.123']`

will run chef-solo on the remote host at 123.123.123.123. You can also specify the rake arguments as properties:

`rake remy:chef:run['ip_address:123.123.123.123']`

Run Remy against a collection of remote nodes:

`rake remy:chef:run['rails_env:staging role:app']`

This will run Remy against all app servers for the staging environment; i.e., all servers in the :servers section of the Remy config files
that match :rails_env = :staging and :role = :app will have Remy (i.e., chef-solo) run on them.  Run Remy against a
specific named node:

`rake remy:chef:run['demo.sharespost.com']`

This assumes that 'demo.sharespost.com' is specified in the :servers section of a Remy yml config file.


## Remy usage from Ruby code (i.e., from within Capistrano or elsewhere)

### Run chef-solo on a single box:

The simplest usage of Remy (Note: this only works if the Remy.configuration has already been specified, such as within
a Rails application):

`Remy::Chef.new(:ip_address => '123.123.123.123').run`

Note that the :ip_address could also have been specified in the yml config files, although more commonly it's passed in
as an argument.

Example: update your production database box:

    server_config = Remy.find_server_config(:rails_env => :production, :role => :db)
    Remy::Chef.new(server_config).run

Other arguments can be passed into chef and will get applied against this node:

`Remy::Chef.new(:ip_address => '123.123.123.123', :color => :blue, :height => :short).run`

means that you can access node['color'] and node['height'] from within your Chef recipes, which will be :blue and :short,
respectively. You can also give arguments which will be passed to chef-solo:

`Remy::Chef.new(:ip_address => '123.123.123.123', :chef_arguments => '-l debug').run`

which will make chef-solo run in debug mode.


### Run chef-solo on a collection of boxes:

From within your Capistrano file, you do a variety of things, such as the following:

    Remy.servers.find_servers(:rails_env => :staging, :role => :app) do |server|
        Remy::Chef.new(server).run
    end

## Chef location on the remote box

The chef files are installed in /var/chef by default (this can be overridden to be another location in the
[Remy configuration](https://github.com/gregwoodward/remy_cluster_rails_example/blob/master/config/initializers/remy.rb)).

### Running chef-solo manually on the remote box

You can always ssh into the remote box, cd into the chef directory (/var/chef by default; it could have been overridden in the
Remy configuration), and run chef-solo by typing

`/var/chef/run_chef_solo`

as root. You can pass in debug arguments for chef-solo, e.g.:

`/var/chef/run_chef_solo -l debug`

If you ssh to the remote box, you can see the glob of JSON that was created by blending together all of the various
Remy yml config files at /var/chef/node.json.



## Test-Driven Chef (TDC)

Look at the example specs in [chef/spec](http://github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/spec) to see how we do
Test-Driven Chef (TDC). When writing our recipes, we first write a failing spec, and then write the Chef recipe to
make this test pass; we then refactor the recipe as needed. Each time Remy (i.e., chef-solo) is run on a remote box, the
specs for this recipe are also run. As an example of this, see the
[bottom of this recipe](https://github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/cookbooks/server_bootstrap/recipes/create_user.rb)
for where spot where the specs are invoked for the Chef recipe 'create_user'.  The
[specs for this recipe are here](https://github.com/gregwoodward/remy_cluster_rails_example/blob/master/chef/spec/server_bootstrap/create_user_spec.rb)
and consist of the various things that one would want to check for when this recipe executes. Note that these specs run on the remote box,
not the local box.
