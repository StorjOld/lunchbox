include_recipe 'python::virtualenv'
include_recipe 'nginx'
include_recipe 'postgresql::server'
include_recipe 'database::postgresql'
include_recipe 'storj::pushycat'

package 'git'
package 'build-essential'
package 'python-dev'

account = 'metadisk'

user_account account do
  create_group true
  ssh_keygen   false
end

pgconn = {
  host: 'localhost',
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

postgresql_database_user 'storj' do
  connection pgconn

  password node['postgresql']['password']['storj']
  action :create
end

postgresql_database 'storj' do
  connection pgconn

  owner 'storj'
  action :create
end

git "/home/#{account}/web-core" do
  repository 'https://github.com/storj/web-core.git'
  action :sync

  user  account
  group account

  notifies :run, 'execute[webcore-requirements]'
end

git "/home/#{account}/accounts" do
  repository 'https://github.com/storj/accounts.git'
  action :sync

  user  account
  group account

  notifies :run, 'execute[accounts-requirements]'
end

git "/home/#{account}/frontend" do
  repository 'https://github.com/storj/metadisk.git'
  action :sync

  user  account
  group account
end

python_virtualenv "/home/#{account}/accounts/.env" do
  owner account
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

  notifies :run, 'execute[webcore-migrations]'
end

execute 'accounts-requirements' do
  command '.env/bin/pip install -r requirements.txt'

  not_if "[ `comm -13 <(.env/bin/pip freeze|sort|sed -e 's/@.*//') <(cat requirements.txt|sort|sed -e 's/#.*//')` = '' ]"

  cwd   "/home/#{account}/accounts"
  user  account
  group account

  notifies :run, 'execute[accounts-migrations]'
end

template "/home/#{account}/frontend/static/js/local_settings.js" do
  mode   0644
  owner  account
  group  account
  source "metadisk-local-settings.js.erb"

  variables hostname: node['metadisk']['hostname']
end

template "/home/#{account}/frontend/static/css/local_settings.css" do
  mode   0644
  owner  account
  group  account
  source "metadisk-local-settings.css.erb"
end

template "/home/#{account}/web-core/local_settings.py" do
  mode   0644
  owner account
  group account
  source "metadisk-local-settings.py.erb"

  variables(
    datacoin_password: node['datacoin']['rpc']['password'],
    database_password: node['postgresql']['password']['storj'],

    limits_storage_size:      node['metadisk']['limits']['storage_size'],
    limits_file_size:         node['metadisk']['limits']['file_size'],
    limits_incoming_transfer: node['metadisk']['limits']['incoming_transfer'],
    limits_outgoing_transfer: node['metadisk']['limits']['outgoing_transfer'],

    accounts_enabled: node['metadisk']['accounts']['enabled'],
    accounts_api_key: node['metadisk']['accounts']['api_key'],
    hostname:         node['metadisk']['accounts']['hostname']
  )

  notifies :run, 'execute[enable-metadisk-webcore]'
  notifies :run, 'execute[enable-metadisk-cloudsync]'
end

template "/home/#{account}/accounts/local_settings.py" do
  mode   0644
  owner account
  group account
  source "metadisk-accounts-local-settings.py.erb"

  variables database_password: node['postgresql']['password']['storj']
end

execute 'webcore-migrations' do
  command '.env/bin/python migrate.py'

  cwd   "/home/#{account}/web-core"
  user  account
  group account
end

execute 'accounts-migrations' do
  command '.env/bin/python migrate.py'

  cwd   "/home/#{account}/accounts"
  user  account
  group account
end

execute 'accounts-api-key' do
  command ".env/bin/python add-key.py #{node['metadisk']['accounts']['api_key']}"

  cwd   "/home/#{account}/accounts"
  user  account
  group account
end

template "/etc/nginx/sites-available/metadisk.conf" do
  mode   0600
  owner  "root"
  group  "root"
  source "nginx-metadisk.conf.erb"

  variables hostname: node['metadisk']['hostname'], user: account
end

template "/etc/init/metadisk-cloudsync.conf" do
  mode  0644
  owner 'root'
  group 'root'

  source 'metadisk-cloudsync.upstart.erb'
  variables user: account

  notifies :run, 'execute[enable-metadisk-cloudsync]'
end

template "/etc/init/metadisk-webcore.conf" do
  mode  0644
  owner 'root'
  group 'root'

  source 'metadisk-webcore.upstart.erb'
  variables user: account

  notifies :run, 'execute[enable-metadisk-webcore]'
end

template "/etc/init/metadisk-accounts.conf" do
  mode  0644
  owner 'root'
  group 'root'

  source 'metadisk-accounts.upstart.erb'
  variables user: account

  notifies :run, 'execute[enable-metadisk-accounts]'
end

execute 'enable-metadisk-cloudsync' do
  command 'service metadisk-cloudsync restart'
  action  :nothing

  user  'root'
  group 'root'
end

execute 'enable-metadisk-webcore' do
  command 'service metadisk-webcore restart'
  action  :nothing

  user  'root'
  group 'root'
end

execute 'enable-metadisk-accounts' do
  command 'service metadisk-accounts restart'
  action  :nothing

  user  'root'
  group 'root'
end

nginx_site 'metadisk.conf'
nginx_site 'default' do
  enable false
end

pushycat_add 'metadisk' do
  url "https://github.com/Storj/metadisk.git"
  path "/home/#{account}/frontend/"
  user account
end
