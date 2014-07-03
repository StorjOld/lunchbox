include_recipe 'python::virtualenv'

package 'supervisor'

account = 'websockets'
hostname = 'node2.storj.io'

user_account account do
  create_group true
  ssh_keygen   false
end

git "/home/#{account}/metadisk-websockets" do
  repository 'https://github.com/storj/metadisk-websockets.git'
  action :sync

  user  account
  group account

  notifies :run, 'execute[metadisk-websockets-requirements]'
end

python_virtualenv "/home/#{account}/metadisk-websockets/.env" do
  owner account
  group account
end

execute 'metadisk-websockets-requirements' do
  command '.env/bin/pip install -r requirements.txt'

  cwd   "/home/#{account}/metadisk-websockets"
  user  account
  group account
end

template "/etc/supervisor/conf.d/websockets.conf" do
  mode 0600
  owner "root"
  group "root"
  source "supervisord-websockets.conf.erb"

  variables user: account

  notifies :run, 'execute[enable-supervisord-websockets]'
end

execute 'enable-supervisord-websockets' do
  command 'supervisorctl start websockets'
  action  :nothing

  user  'root'
  group 'root'
end