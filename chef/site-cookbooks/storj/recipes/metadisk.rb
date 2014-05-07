include_recipe 'python::virtualenv'

account = 'metadisk'

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
  action  :nothing

  cwd   "/home/#{account}/web-core"
  user  account
  group account
end
