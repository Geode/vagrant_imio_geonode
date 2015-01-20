#!/usr/bin/env python

#Note : @todo parameter and all refactoring

from geoserver.catalog import Catalog

#connect to geoserver
cat = Catalog("http://localhost:8080/geoserver/rest", "admin", "PUTADMINPW")

#create datrastore for URB schema

ds = cat.create_datastore(name)
ds.connection_parameters.update(
    host="remotegeoserver1URL",
    port="5432",
    database="urb_dison",
    user="ro_user",
    password="PUTROUSERPW",
    dbtype="postgis")

cat.save(ds)
ds = cat.get_store(name)

#connect to tables and create layers and correct urban styles
