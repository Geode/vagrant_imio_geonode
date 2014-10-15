vagrant_imio_geonode
====================

Current version geonode 2.4alpha

Will install .deb package from dev-repository
And after install in virtualenv imio_genode a geonode-project by git clone and pip install

1. install last virtualbox and vagrant
2. git clone https://github.com/Geode/vagrant_imio_geonode
3. cd vagrant_imio_geonode
4. vagrant up

Note : createsuperuser --noinput is a temporary superuser, new one has to be created manually with password to finish the installation :

vagrant ssh (add ssh to the path if windows)
sudo su
geonode createsuperuser
