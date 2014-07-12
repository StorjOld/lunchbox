lunchbox
========

Deploy and automation scripts.

## Chef

To setup our nodes, we're currently using [http://www.getchef.com/](chef).
All our custom recipes and resources are in the chef/site-cookbooks directory.

You can see an example node.json configuration in [chef/nodes/node.storj.io.json.example](chef/nodes/node.storj.io.json.example).

After cloning this repository and running bundle install, you can setup a node
by creating a json file in the nodes/ directory with the name "hostname.json"
(for example, node1.storj.io.json) and running the following commands:

    knife solo prepare root@node1.storj.io
    knife solo cook root@node1.storj.io


## Components and overall design

### Storj's components

#### Datacoin

metadisk uses the Datacoin blockchain to store information relative to the
uploaded files. Each node currently contains a datacoin daemon that's watching
the blockchain. Datacoin is installed through a deb package, hosted on
packages.storj.io. We're currently running our own [fork of the datacoin
daemon](//github.com/Storj/datacoin-hp), with some small patches to make it
configurable on compile time.

#### Pushycat

During development, it is good to have our code being self-updatable. To do so, we
have some webhooks on github that automatically update some pieces of our stack. This
is achieved by using [pushycat](//github.com/Storj/pushy-cat). Pushycat is also installed
through a deb package, hosted on the same repository as datacoin.


#### metadisk-webcore

[metadisk-webcore](//github.com/Storj/web-core) is a web API that allows users
to upload and download files, as well as retrieve information about the node's
state. It is implemented as a python-flask web application, plus a
synchronization daemon. The web application is ran through gunicorn.


#### metadisk-accounts

[metadisk-account](//github.com/Storj/accounts) is a web API that keeps track
of user accounts, along with their respective credit. Just like
metadisk-webcore, it runs through gunicorn.


#### metadisk-frontend

[metadisk-frontend](//github.com/Storj/metadisk) is a html/js frontend for
metadisk-webcore. It is purely a client-side frontend, requiring no extra
backends other than metadisk-webcore and metadisk-accounts.


#### metadisk-websockets

[metadisk-websockets](//github.com/Storj/metadisk-websockets) is a websocket
wrapper for the metadisk-webcore web api. Is it built using Flask, socket.io
and gevent.


### Generic infrastructure

#### Service monitoring

All our daemons are controlled through upstart.


#### Webserver

All web apis and html frontends are served/proxied through nginx.


#### Databases

Both metadisk-webcore and metadisk-accounts require a data store to keep track
of their state. We decided to go with postgresql. You should configure the
database passwords in the node's json configuration file, as shown by the
example.
