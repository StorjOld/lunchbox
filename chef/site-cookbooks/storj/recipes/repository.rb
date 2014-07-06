include_recipe 'apt'

apt_repository 'storj' do
  uri "http://packages.storj.io/"
  distribution node['lsb']['codename']
  components ['main']

  key 'hello@storj.io.gpg.key'
end
