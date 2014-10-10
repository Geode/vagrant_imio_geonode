#!/usr/bin/env bash
echo 'start installing IMIO geonode version 0.1 alpha'
apt-get install -y git
pip install virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export WORKON_HOME=/home/.venvs
source /usr/local/bin/virtualenvwrapper.sh
export PIP_DOWNLOAD_CACHE=$HOME/.pip-downloads
mkvirtualenv imio_geonode --system-site-package

echo ' install in the new active local virtualenv'
workon imio_geonode
pip install psycopg2
cd /var/www/
#django-admin startproject imio_geonode --template=https://github.com/Geode/imio_geonode/archive/master.zip -epy,rst
git clone https://github.com/Geode/imio_geonode
pip install -e imio_geonode
cd /var/www/imio_geonode/
cp imio_geonode/local_settings.py.sample imio_geonode/local_settings.py
sed -i 's/SITENAME = '\''GeoNode'\''/SITENAME = '\''Imio-GeoNode'\''/g' imio_geonode/local_settings.py
sed -i 's/SITEURL = '\''http:\/\/localhost\/'\''/SITEURL = '\''http:\/\/localhost:2780\/'\''/g' imio_geonode/local_settings.py

#ln -s /etc/geonode/local_settings.py  /var/www/imio_geonode/imio_geonode/local_settings.py
# edit the Apache conf to prevent the error:
# Could not reliably determine the server s fully qualified domain name, using 127.0.1.1 for ServerName"
sed -i "$ a\ServerName localhost" /etc/apache2/apache2.conf
sed -i 's/WSGIScriptAlias \/ \/var\/www\/geonode\/wsgi\/geonode.wsgi/WSGIScriptAlias \/ \/var\/www\/imio_geonode\/imio_geonode\/wsgi.py/g' /etc/apache2/sites-available/geonode.conf
#sed -i 's/WSGIScriptAlias \/ \/var\/www\/imio_geonode\/imio_geonode\/wsgi.py/WSGIScriptAlias \/ \/var\/www\/geonode\/wsgi\/geonode.wsgi/g' /etc/apache2/sites-available/geonode.conf
cp /setup/wsgi.py /var/www/imio_geonode/imio_geonode/wsgi.py
service apache2 restart
cd /var/www/imio_geonode/
python manage.py collectstatic --noinput
echo 'finished installing IMIO geonode, test http://localhost:2780/'
