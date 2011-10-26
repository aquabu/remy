template "/tmp/foo.txt" do
  source "foo.txt.erb"
  owner 'root'
  group 'staff'
  mode "644"
  variables(:color => node['color'], :remote_chef_ip => node['remote_chef_ip'], :rails_env => node['rails_env'])
end
