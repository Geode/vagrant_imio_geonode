#!/usr/bin/env bash
echo 'start installing geonode geode'

echo 'apt cleaning and update'
rm -v /etc/apt/sources.list.d/puppetlabs*
apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:geonode/testing 
apt-get update

echo 'apt installing geonode dependances'

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
    python                 
    python-dev             
    python-gdal            
    python-imaging         
    python-lxml            
    python-pip             
    python-pyproj          
    python-pastescript     
    python-software-properties 
    python-shapely         
    python-support         
    python-httplib2        
    python-urlgrabber      
    python-virtualenv 
    python-nose
    python-httplib2
    python-psycopg2 
    python-django
    python-django-downloadview
    python-django-activity-stream
    python-django-extensions
    python-django-forms-bootstrap
    python-django-friendly-tag-loader
    python-django-geoexplorer
    python-django-jsonfield
    python-django-pagination
    python-django-taggit
    python-django-taggit-templatetags
    python-dialogos
    python-bs4    
    tomcat7                
    tmux                   
    unzip                  
    zip
    zlib1g-dev
    gdebi-core
    gdebi
)

apt-get install -y ${packagelist[@]}
apt-get build-dep -y python-lxml
#pip install virtualenvwrapper ya déjà une install sur imiobox
apt-get install -y --force-yes openjdk-6-jdk ant maven2 --no-install-recommends
apt-get install -y git

echo 'creating virtyualenv @todo : customize good IMIO python'
pip install virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export WORKON_HOME=/home/.venvs
source /usr/local/bin/virtualenvwrapper.sh
export PIP_DOWNLOAD_CACHE=$HOME/.pip-downloads
mkvirtualenv imio_geonode --system-site-package

echo 'downloading geonode zip'
curl -sS https://github.com/Geode/geonode/archive/IMIO.zip > geonode.zip
unzip geonode.zip  
rm geonode.zip
mv geonode-IMIO geonode
cd geonode

echo 'installing geonode'
workon imio_geonode
pip install -e geonode

geonode createsuperuser --username=geode --email=info@opengeode.be --noinput
geonode-updateip localhost:2780

echo 'start installing IMIO geonode version 0.1 alpha'

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
