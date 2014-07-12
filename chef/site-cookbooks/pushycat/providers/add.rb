use_inline_resources if defined?(use_inline_resources)

def whyrun_supported
  true
end

action :install do
  url  = new_resource.url
  path = new_resource.path
  user = new_resource.user

  execute 'pushycat-add' do
    command "pushycat-add #{url} #{path} #{user} && service pushycatd restart"

    user  'root'
    group 'root'
  end
end
