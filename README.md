vagrant_imio_geonode
====================

Current version geonode 2.4 alpha

Will install .deb package from dev-repository
And after install in virtualenv imio_genode a geonode-project by git clone and pip install

Purpose
=======

Test in the last geonode release (dev alpha and later stable) the IMIO custom website.

HowTo
=====

1. install last virtualbox and vagrant
2. vagrant box add imiobox /path/to/vm-imio/geoserver.box
3. git clone https://github.com/Geode/vagrant_imio_geonode
4. cd vagrant_imio_geonode
5. vagrant up

Note : createsuperuser --noinput is a temporary superuser, new one has to be created manually with password to finish the installation :

vagrant ssh (add ssh to the path if windows)
sudo su
geonode createsuperuser
