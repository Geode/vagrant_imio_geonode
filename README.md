vagrant_imio_geonode
====================

Current version geonode 2.4alpha

Install pat-get geonode
Install in virtualenv imio_genode a geonode-project by git clone and pip install

1. install last virtualbox and vagrant
2. git clone https://github.com/Geode/vagrant_imio_geonode
3. vagrant up

Note : createsuperuser --noinput is not complete, must create manually a superuser with password, to finis the install :

vagrant ssh (add ssh to the path if windows)
sudo su
geonode createsuperuser
