#!/usr/bin/env python

from optparse import OptionParser

#Note : @todo parameter and all refactoring

from geoserver.catalog import Catalog

def main(options):
  #connect to geoserver
  cat = Catalog("http://localhost:8080/geoserver/rest", "admin", options.gpw)
  
  #create datrastore for URB schema
  
  ds = cat.create_datastore(name)
  ds.connection_parameters.update(
      host=options.urbanUrl,
      port="5432",
      database=options.database,
      user="ro_user",
      password=options.ropw,
      dbtype="postgis")
  
  cat.save(ds)
  ds = cat.get_store(name)
  
  #connect to tables and create layers and correct urban styles
  
  
if __name__ == "__main__":
	parser = OptionParser()
	parser.add_option("-p", "--gpw", action="store", type="string", dest="gpw", default="", help="Geoserver admin password [default: %default]")
	parser.add_option("-u", "--urbanUrl", action="store", type="string", dest="urbanUrl", default="", help="Urban URL [default: %default]")
	parser.add_option("-r", "--ropw", action="store", type="string", dest="ropw", default="", help="Remote postGIS ro_user password [default: %default]")
	parser.add_option("-d", "--database", action="store", type="string", dest="database", default="urb_xxx", help="remote urban database name [default: %default]")
	parser.add_option("-p", "--prefix", action="store", type="string", dest="prefix", default="xxx", help="prefix alias [default: %default]")
	(options, args) = parser.parse_args()
	if options.gpw is None:
    parser.error('Admin geoserver password not given')
	if options.urbanUrl is None:
    parser.error('Urban postGIS URL not given')
	if options.ropw is None:
    parser.error('ro_user password not given')
	main(options)
