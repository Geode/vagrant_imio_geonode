#!/usr/bin/env bash
echo 'start installing geonode geode'
rm -v /etc/apt/sources.list.d/puppetlabs*
apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:geonode/testing 
apt-get update

# rm -rv /var/cache/apt
# rm -rv /var/lib/apt/lists
# sed -i 's/ftp.belnet.be\/ubuntu.com/archive.ubuntu.com\/ubuntu/g' /etc/apt/sources.list

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
pip install virtualenvwrapper
apt-get install -y --force-yes openjdk-6-jdk ant maven2 --no-install-recommends

gdebi -n /setup/geonode_2.4.0-Geode.deb

geonode createsuperuser --username=geode --email=info@opengeode.be --noinput
geonode-updateip localhost:2780
echo 'finished, to use on windows vagrant ssh :use '
echo 'set PATH=%PATH%;c:\Program Files (x86)\Git\bin'