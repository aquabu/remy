remote_file "/tmp/foo.txt" do
  source "foo"
  mode 0440
  owner "root"
  group "root"
end
