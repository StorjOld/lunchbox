maintainer       "Hugo Peixoto"
maintainer_email "hugo.peixoto@gmail.com"
license          "MIT License"
description      "Recipes for pushycat"
long_description "Configuration helpers for pushycat"
version          "1.0.0"

depends "apt"
depends "user"
depends 'python'

%w{ ubuntu }.each do |os|
  supports os
end

