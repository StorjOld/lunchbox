actions :install
default_action :install

attribute :port, kind_of: Fixnum, default: 8080
attribute :path, kind_of: String, default: '/webhook/'
