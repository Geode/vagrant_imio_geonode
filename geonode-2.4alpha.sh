#!/usr/bin/env bash
echo 'start installing geonode version 2.4 alpha'
add-apt-repository ppa:geonode/testing 
apt-get update 
apt-get install -y geonode
geonode createsuperuser --username=geode --email=info@opengeode.be --noinput
geonode-updateip localhost:2780
echo 'finished, to use on windows vagrant ssh :use '
echo 'set PATH=%PATH%;c:\Program Files (x86)\Git\bin'