#!/usr/bin/env bash
echo 'start installing geonode geode'

echo 'apt cleaning and update'
rm -v /etc/apt/sources.list.d/puppetlabs*
apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:geonode/testing 
apt-get update

echo 'apt installing geonode dependencies'

packagelist=(
    build-essential
    apache2
    gcc
    gdal-bin
    gettext
    git-core
    libapache2-mod-wsgi
    libgeos-dev
    libjpeg-dev
    libpng-dev
    libpq-dev
    libproj-dev
    libxml2-dev
    libxslt1-dev
    openjdk-6-jre
    patch
    postgresql-9.3
    postgresql-9.3-postgis-2.1
    postgresql-contrib
    postgresql-contrib-9.3
    python-dev
    python-gdal
    python-imaging
    python-pip
    python-software-properties
    python-support
    python-virtualenv
    tomcat7
    tmux
    unzip
    zip
    zlib1g-dev
    curl
)

apt-get install -y ${packagelist[@]}
apt-get build-dep -y python-lxml
#pip install virtualenvwrapper ya déjà une install sur imiobox
apt-get install -y --force-yes openjdk-6-jdk ant maven2 --no-install-recommends
apt-get install -y git

echo ' > Fix bug, install gdal for development'
add-apt-repository ppa:ubuntugis/ubuntugis-unstable
apt-get update
apt-get -y install libgdal1h libgdal-dev python-gdal

echo 'creating virtyualenv with IMIO 2.7 python'
virtualenv imio_geonode --system-site-package 
#@todo use 2.7 and import / reinstall system-site-packages from  system python
#virtualenv imio_geonode --system-site-package
source imio_geonode/bin/activate

echo 'installing python dependencies in virtualenv'
pip install --no-install GDAL
cd /home/vagrant/imio_geonode/build/GDAL
python setup.py build_ext --include-dirs=/usr/include/gdal/
pip install --no-download GDAL
cd /home/vagrant

pip install -r /setup/requirements.txt

echo 'downloading geonode zip'
curl -LOk https://github.com/Geode/geonode/archive/IMIO.zip
unzip IMIO.zip  
rm IMIO.zip
mv geonode-IMIO geonode

echo 'configuring postgresql users and passwords :'
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password 'password';"
sudo -u postgres psql -U postgres -d postgres -c "create user geonode with password 'geonode';"
echo 'allowing remote access to db server and enable password auth for all :'
cp /etc/postgresql/9.3/main/postgresql.conf /etc/postgresql/9.3/main/postgresql.conf.bck
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.3/main/postgresql.conf
cp /etc/postgresql/9.3/main/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf.bck
sed -i "s/local all all peer/local all all md5/g" /etc/postgresql/9.3/main/pg_hba.conf
sed -i "s/local   all             all                                     peer/local   all             all                                     md5/g" /etc/postgresql/9.3/main/pg_hba.conf
sed -i "s/host all all ::1\/128 md5/host all all ::1\/32 md5/g" /etc/postgresql/9.3/main/pg_hba.conf
service postgresql restart
echo 'setup geonode database, postgis extension'
sudo -u postgres psql -U postgres -d postgres -c 'CREATE DATABASE geonode;'
sudo -u postgres psql -U postgres -d postgres -c 'GRANT ALL PRIVILEGES ON DATABASE geonode TO geonode;'
sudo -u postgres psql -U postgres -d postgres -c 'CREATE DATABASE "geonode-imports";'
sudo -u postgres psql -U postgres -d postgres -c 'GRANT ALL PRIVILEGES ON DATABASE "geonode-imports" TO geonode;'
sudo -u postgres psql -U postgres -d geonode-imports -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql
sudo -u postgres psql -U postgres -d geonode-imports -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql
sudo -u postgres psql -U postgres -d geonode-imports -c 'GRANT ALL ON geometry_columns TO PUBLIC;'
sudo -u postgres psql -U postgres -d geonode-imports -c 'GRANT ALL ON spatial_ref_sys TO PUBLIC;'
sudo -u postgres psql -U postgres -d geonode -c 'create extension postgis;'

pip install -e geonode --use-mirrors --allow-external pyproj --allow-unverified pyproj

cd geonode
paver setup

cp -f /setup/local_settings.py  /home/vagrant/geonode/geonode/local_settings.py
python manage.py syncdb --noinput

echo 'start installing IMIO geonode version alpha'

cd /var/www/
#django-admin startproject imio_geonode --template=https://github.com/Geode/imio_geonode/archive/master.zip -epy,rst
git clone https://github.com/Geode/imio_geonode
pip install -e imio_geonode

cp /var/www/imio_geonode/imio_geonode/local_settings.py.sample /var/www/imio_geonode/imio_geonode/local_settings.py
cp /setup/wsgi.py /var/www/imio_geonode/imio_geonode/wsgi.py
cp -f /setup/geonode.conf /etc/apache2/sites-available/geonode.conf

cd /var/www/imio_geonode/

sed -i 's/SITENAME = '\''GeoNode'\''/SITENAME = '\''Imio-GeoNode'\''/g' imio_geonode/local_settings.py
sed -i 's/SITEURL = '\''http:\/\/localhost\/'\''/SITEURL = '\''http:\/\/localhost:2780\/'\''/g' imio_geonode/local_settings.py

#ln -s /etc/geonode/local_settings.py  /var/www/imio_geonode/imio_geonode/local_settings.py
# edit the Apache conf to prevent the error:
# Could not reliably determine the server s fully qualified domain name, using 127.0.1.1 for ServerName"
sed -i "$ a\ServerName localhost" /etc/apache2/apache2.conf
sed -i 's/WSGIScriptAlias \/ \/var\/www\/geonode\/wsgi\/geonode.wsgi/WSGIScriptAlias \/ \/var\/www\/imio_geonode\/imio_geonode\/wsgi.py/g' /etc/apache2/sites-available/geonode.conf
#sed -i 's/WSGIScriptAlias \/ \/var\/www\/imio_geonode\/imio_geonode\/wsgi.py/WSGIScriptAlias \/ \/var\/www\/geonode\/wsgi\/geonode.wsgi/g' /etc/apache2/sites-available/geonode.conf

a2ensite geonode
a2dissite 000-default
chown www-data:www-data /var/www/imio_geonode/imio_geonode/static/
mkdir /var/www/imio_geonode/imio_geonode/static_root/
chown www-data:www-data /var/www/imio_geonode/imio_geonode/static_root/
mkdir /home/vagrant/geonode/geonode/uploaded
chown www-data:www-data /home/vagrant/geonode/geonode/uploaded/
chown www-data:www-data /var/www/imio_geonode/imio_geonode/uploaded/
a2enmod wsgi
a2enmod proxy_http

service apache2 restart

cd /var/www/imio_geonode/
python manage.py createsuperuser --username=geode --email=info@opengeode.be --noinput
python manage.py collectstatic --noinput

echo 'Moving to tomcat7'
service tomcat7 stop
cp /home/vagrant/geonode/downloaded/geoserver.war /var/lib/tomcat7/webapps/
service tomcat7 start

echo 'Import des données Fléron et Dison de test en postgis'
cp /setup/gis_dison.dump.gz /tmp/gis_dison.dump.gz
cp /setup/gis_fleron.dump.gz /tmp/gis_fleron.dump.gz
gunzip /tmp/gis_dison.dump.gz 
gunzip /tmp/gis_fleron.dump.gz 
echo "localhost:*:*:geonode:geonode" > $HOME/.pgpass
echo "localhost:*:*:geonode-imports:geonode" > $HOME/.pgpass
chmod 0600 $HOME/.pgpass
psql -U geonode -d geonode-imports -f gis_dison.dump
psql -U geonode -d geonode-imports -f gis_fleron.dump
rm $HOME/.pgpass
#geoserver manual
python manage.py updatelayers
echo 'finished installing IMIO geonode, test http://localhost:2780/'
echo 'dont forget to finish creating superuser, doing the following steps : '
echo 'vagrant ssh'
echo '#note for windows user: set PATH=%PATH%;c:\Program Files (x86)\Git\bin'
echo 'sudo su'
echo '#activate virtualenv imio_geonode, one way, with wrapper :'
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python'
echo 'export WORKON_HOME=/home/.venvs'
echo 'source /usr/local/bin/virtualenvwrapper.sh'
echo 'export PIP_DOWNLOAD_CACHE=$HOME/.pip-downloads'
echo 'workon imio_geonode'
echo 'geonode createsuperuser'
