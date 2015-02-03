#!/usr/bin/env python

from optparse import OptionParser
from geoserver.catalog import Catalog

#from https://groups.google.com/forum/#!msg/geonode-users/R-u57r8aECw/A9zk-LXBgjUJ
def publishTable(layerName, epsg, style=None):
    
    if not epsg.startswith('EPSG:'): epsg = 'EPSG:'+epsg
    
    gsUrl = settings.OGC_SERVER['default']['LOCATION'] + "rest"
    gsUser = settings.OGC_SERVER['default']['USER']
    gsPassword = settings.OGC_SERVER['default']['PASSWORD']
    
    cat = Catalog(gsUrl, gsUser, gsPassword)    
    if cat is None: raise GeonodeManagementError('unable to instantiate geoserver catalog')

    ws = cat.get_workspace(settings.DEFAULT_WORKSPACE)
    if ws is None: raise GeonodeManagementError('workspace %s not found in geoserver'%settings.DEFAULT_WORKSPACE)
    
    storeName = settings.OGC_SERVER['default']['DATASTORE']
    store = cat.get_store(storeName, ws)
    if store is None: raise GeonodeManagementError('workspace %s not found in geoserver'%storeName)
    
    ft = cat.publish_featuretype(layerName, store, epsg, srs=epsg)
    if ft is None: raise GeonodeManagementError('unable to publish layer %s'%layerName)
    
    cat.save(ft)
    
    if style is not None:
        publishing = cat.get_layer(layerName)
        if publishing is None: raise GeonodeManagementError('layer not found ($s)'%layerName)
        publishing.default_style = cat.get_style(style)
        cat.save(publishing)
    
    resource = cat.get_resource(layerName, store, ws)
    if resource is None: raise GeonodeManagementError('resource not found ($s)'%layerName)
    
    layer, created = Layer.objects.get_or_create(name=layerName, defaults={
                    "workspace": ws.name,
                    "store": store.name,
                    "storeType": store.resource_type,
                    "typename": "%s:%s" % (ws.name.encode('utf-8'), resource.name.encode('utf-8')),
                    "title": resource.title or 'No title provided',
                    "abstract": resource.abstract or 'No abstract provided',
                    #"owner": owner,
                    "uuid": str(uuid.uuid4()),
                    "bbox_x0": Decimal(resource.latlon_bbox[0]),
                    "bbox_x1": Decimal(resource.latlon_bbox[1]),
                    "bbox_y0": Decimal(resource.latlon_bbox[2]),
                    "bbox_y1": Decimal(resource.latlon_bbox[3])
                })
    
    set_attributes(layer, overwrite=True)
    
    if created: layer.set_default_permissions()


def main(options):
  #connect to geoserver
  cat = Catalog("http://localhost:8080/geoserver/rest", "admin", options.gpw)
  
  #create datrastore for URB schema
  ws = cat.create_workspace(options.alias,'imio.be')
  
  ds = cat.create_datastore(options.alias, ws)
  ds.connection_parameters.update(
      host=options.urbanUrl,
      port="5432",
      database=options.database,
      user="ro_user",
      password=options.ropw,
      dbtype="postgis")
  
  cat.save(ds)
  ds = cat.get_store(options.alias)
  
  #config object
  urb = {
  	"capa":"Parcelles",
  	"toli":"cadastre_ln_toponymiques",
  	"canu":"cadastre_pt_num",
  	"cabu":"Batiments",
  	"gept":"cadastre_points_generaux",
  	"gepn":"cadastre_pol_gen",
  	"inpt":"point",
  	"geli":"cadastre_ln_generales",
  	"inli":"cadastre_ln_informations",
  	"topt":"point",
  	}   	
  	
  #connect to tables and create layers and correct urban styles
  for table in urb:
    style = urb[table]
    ft = cat.publish_featuretype(table, ds, 'EPSG:31370', srs='EPSG:31370')
    ft.default_style = style
    cat.save(ft)
    resource = ft.resource
    resource.title = options.alias+"_"+table
    resource.save()
  
if __name__ == "__main__":
	parser = OptionParser()
	parser.add_option("-p", "--gpw", action="store", type="string", dest="gpw", default="", help="Geoserver admin password [default: %default]")
	parser.add_option("-u", "--urbanUrl", action="store", type="string", dest="urbanUrl", default="", help="Urban URL [default: %default]")
	parser.add_option("-r", "--ropw", action="store", type="string", dest="ropw", default="", help="Remote postGIS ro_user password [default: %default]")
	parser.add_option("-d", "--database", action="store", type="string", dest="database", default="urb_xxx", help="remote urban database name [default: %default]")
	parser.add_option("-a", "--alias", action="store", type="string", dest="alias", default="", help="prefix alias [default: %default]")
	(options, args) = parser.parse_args()
	if options.gpw is None:
    		parser.error('Admin geoserver password not given')
	if options.urbanUrl is None:
    		parser.error('Urban postGIS URL not given')
	if options.ropw is None:
    		parser.error('ro_user password not given')
	if options.alias is None:
    		parser.error('alias not given')
	main(options)
