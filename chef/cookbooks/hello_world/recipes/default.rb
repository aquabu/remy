template "/tmp/foo.txt" do
  source "foo.txt.erb"
  owner 'root'
  group 'staff'
  mode "644"
  variables(:color => node['color'], :chef_ip => node['chef_ip'], :rails_env => node['rails_env'])
end

ruby_block "test" do
  block do
    puts `rspec -f progress #{File.expand_path(File.join(File.dirname(__FILE__), '../../../spec/hello_world/default_spec.rb'))}`
  end
end
