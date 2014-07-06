include_recipe 'storj::repository'

package 'datacoind'

template "/etc/datacoind/datacoin.conf" do
  mode   0400
  owner  'datacoind'
  group  'datacoind'
  source 'datacoin.conf.erb'

  variables(
    host:     node['datacoin']['rpc']['host'],
    user:     node['datacoin']['rpc']['user'],
    password: node['datacoin']['rpc']['password'])

  notifies :run, 'execute[enable-datacoind]'
end

execute 'enable-datacoind' do
  command 'service datacoind restart'

  action  :nothing
  user    'root'
  group   'root'
end
