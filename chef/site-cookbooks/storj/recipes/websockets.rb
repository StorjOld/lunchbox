include_recipe 'python::virtualenv'

account = 'websockets'

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

template "/etc/init/metadisk-websockets.conf" do
  mode  0644
  owner 'root'
  group 'root'

  source "metadisk-websockets.upstart.erb"
  variables user: account

  notifies :run, 'execute[enable-metadisk-websockets]'
end

execute 'enable-metadisk-websockets' do
  command 'service metadisk-websockets start'
  action  :nothing

  user  'root'
  group 'root'
end
