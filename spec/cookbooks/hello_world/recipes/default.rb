remote_file "/tmp/foo.txt" do
  source "foo.txt"
  mode 0440
  owner "root"
  group "root"
end
