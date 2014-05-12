maintainer       "Hugo Peixoto"
maintainer_email "hugo.peixoto@gmail.com"
license          "MIT License"
description      "Recipes for storj.io"
long_description "Installs datacoin and metadisk"
version          "1.0.0"

depends "apt"
depends "user"
depends 'python'
depends "nginx"
depends "postgresql"
#depends "database"

%w{ ubuntu debian }.each do |os|
  supports os
end

