use_inline_resources if defined?(use_inline_resources)

def whyrun_supported
  true
end

action :install do
  package 'pushycatd' do
    action :upgrade
  end

  python 'pushycat config' do
    code <<-EOH
import json

with open("/etc/pushycat/config.json") as f:
  data = f.read()

data = json.loads(data)
data['port'] = #{new_resource.port}
data['path'] = "#{new_resource.path}"

with open("/etc/pushycat/config.json", "w") as f:
  f.write(json.dumps(data))
EOH
  end
end
