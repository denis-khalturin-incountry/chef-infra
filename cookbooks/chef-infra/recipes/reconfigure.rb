bash 'reconfigure' do
  code 'chef-server-ctl status | grep run || (chef-server-ctl reconfigure --chef-license=accept; sleep 5)'
end

if node[:server][:users]
  node[:server][:users].each do |name, params|
    bash "user-show-#{name}" do
      code "chef-server-ctl user-show #{name} > /dev/null"

      ignore_failure :quiet
      returns 100

      action :nothing
      subscribes :run, [ "bash[reconfigure]" ]
    end

    bash "user-create-#{name}" do
      code <<-EOF
        chef-server-ctl user-create \
          #{name} \
          #{params[:first_name]} \
          #{params[:last_name]} \
          #{params[:email]} \
          #{params[:password]} \
          -f /opt/user-#{name}.pem
      EOF

      action :nothing
      subscribes :run, [ "bash[user-show-#{name}]" ]
    end
  end
end

if node[:server][:orgs]
  node[:server][:orgs].each do |name, params|
    bash "org-show-#{name}" do
      code "chef-server-ctl org-show #{name}"

      ignore_failure :quiet
      returns 100

      action :nothing
      subscribes :run, [ "bash[reconfigure]" ]
    end

    bash "org-create-#{name}" do
      code <<-EOF
        chef-server-ctl org-create \
          '#{name}' \
          '#{name}' \
          -a #{params[:association_user]} \
          -f /opt/org-#{name}.pem
      EOF

      action :nothing
      subscribes :run, [ "bash[org-show-#{name}]" ]
    end
  end
end
