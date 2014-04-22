apt-get -y install postgresql libpq-dev

sudo -iu postgres bash <<EOF
  createdb storj
  psql storj -c "create user storj with password 'storj';"
  psql storj -c "grant all privileges on database storj to storj;"
EOF
