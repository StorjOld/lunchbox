include_recipe 'python::virtualenv'

account = 'pushycat'

user_account account do
  create_group true
  ssh_keygen   false
end

git "/home/#{account}/pushy-cat" do
  repository 'https://github.com/storj/pushy-cat.git'
  action :sync

  user  account
  group account

  notifies :run, 'execute[pushycat-requirements]'
end

python_virtualenv "/home/#{account}/pushy-cat/.env" do
  owner account
  group account
end

execute 'pushycat-requirements' do
  command '.env/bin/pip install -r requirements.txt'
  action  :nothing

  cwd   "/home/#{account}/pushy-cat"
  user  account
  group account
end

