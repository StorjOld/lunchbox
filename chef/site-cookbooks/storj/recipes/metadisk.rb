include_recipe 'python::virtualenv'
include_recipe 'nginx'
include_recipe 'postgresql::server'

package 'supervisor'

account = 'metadisk'
hostname = 'node2.storj.io'

user_account account do
  create_group true
  ssh_keygen   false
end

git "/home/#{account}/web-core" do
  repository 'https://github.com/storj/web-core.git'
  action :sync

  user  account
  group account

  notifies :run, 'execute[webcore-requirements]'
end

git "/home/#{account}/frontend" do
  repository 'https://github.com/storj/metadisk.git'
  action :sync

  user  account
  group account
end

python_virtualenv "/home/#{account}/web-core/.env" do
  owner account
  group account
end

execute 'webcore-requirements' do
  command '.env/bin/pip install -r requirements.txt'

  not_if "[ `comm -13 <(.env/bin/pip freeze|sort|sed -e 's/@.*//') <(cat requirements.txt|sort|sed -e 's/#.*//')` = '' ]"

  cwd   "/home/#{account}/web-core"
  user  account
  group account
end

template "/etc/nginx/sites-available/metadisk.conf" do
  mode   0600
  owner  "root"
  group  "root"
  source "nginx-metadisk.conf.erb"

  variables hostname: hostname, user: account
end

template "/etc/supervisor/conf.d/metadisk-cloudsync.conf" do
  mode 0600
  owner "root"
  group "root"
  source "supervisord-metadisk-cloudsync.conf.erb"

  variables user: account

  notifies :run, 'execute[enable-supervisord-metadisk-cloudsync]'
end

template "/etc/supervisor/conf.d/metadisk-webcore.conf" do
  mode 0600
  owner "root"
  group "root"
  source "supervisord-metadisk-webcore.conf.erb"

  variables user: account

  notifies :run, 'execute[enable-supervisord-metadisk-webcore]'
end

execute 'enable-supervisord-metadisk-cloudsync' do
  command 'supervisorctl start metadisk-cloudsync'
  action  :nothing

  user  'root'
  group 'root'
end

execute 'enable-supervisord-metadisk-webcore' do
  command 'supervisorctl start metadisk-webcore'
  action  :nothing

  user  'root'
  group 'root'
end

nginx_site 'metadisk.conf'
