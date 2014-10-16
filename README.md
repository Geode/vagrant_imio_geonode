vagrant_imio_geonode
====================

@Todo: remove this branch and create an independent repository


Purpose
=======

Test last geonode release from geode/geonode fork


Setup
=====


1. install last virtualbox and vagrant
2. git clone -b dev-trunk https://github.com/Geode/vagrant_imio_geonode
3. cd vagrant_imio_geonode
4. vagrant up
5. do stuff!


If needed create a superuser
============================

1. vagrant ssh
2. sudo su
3. export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
4. export WORKON_HOME=/home/.venvs
5. source /usr/local/bin/virtualenvwrapper.sh
6. export PIP_DOWNLOAD_CACHE=$HOME/.pip-downloads
7. workon geonode
8. cd /home/geonode/
8. python manage.py createsuperuser

This procedure is not finished yet, some bug fixing required!

