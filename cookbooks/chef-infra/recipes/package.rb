deb = File.basename(node[:package][:deb])

remote_file "/opt/#{deb}" do
  source node[:package][:deb]
  checksum node[:package][:sum]
  show_progress true
  action :create
end

dpkg_package "/opt/#{deb}"
