package 'build-essential'
package 'm4'
package 'libssl-dev'
package 'libdb++-dev'
package 'libboost-all-dev'
package 'libminiupnpc-dev'
package 'zip'
package 'libgmp-dev'
package 'git'

account  = 'datacoin'
password = node['datacoin']['rpc']['password']
host     = node['datacoin']['rpc']['host']
user     = node['datacoin']['rpc']['user']

user_account account do
  create_group true
  ssh_keygen   false
end

directory "/home/#{account}/.datacoin" do
  action :create
  owner account
  group account
  mode  0700
end

template "/home/#{account}/.datacoin/datacoin.conf" do
  mode   0400
  owner  account
  group  account
  source 'datacoin.conf.erb'

  variables(
    host:     host,
    user:     user,
    password: password)
end

git "/home/#{account}/datacoin-hp" do
  repository 'https://github.com/foo1inge/datacoin-hp'
  action :sync

  user  account
  group account

  notifies :run, 'execute[build-datacoind]'
end

execute 'build-datacoind' do
  command 'make -f makefile.unix'
  action  :nothing

  cwd   "/home/#{account}/datacoin-hp/src"
  user  account
  group account
end
