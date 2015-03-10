#!/usr/bin/env python
import os
import geonode
os.environ['DJANGO_SETTINGS_MODULE'] = 'geonode.settings'

from optparse import OptionParser
from geoserver.catalog import Catalog
from uuid import uuid4
from decimal import *
from pprint import pprint
from django.core.management import call_command

from geonode.layers.models import Layer

#DOc: https://groups.google.com/forum/#!msg/geonode-users/R-u57r8aECw/A9zk-LXBgjUJ

def main(options):
  #connect to geoserver
  cat = Catalog("http://localhost:8080/geoserver/rest", "raphael", options.gpw)
  
  #create datrastore for URB schema
  ws = cat.create_workspace(options.alias,options.uri)
  
  ds = cat.create_datastore(options.alias, ws)
  ds.connection_parameters.update(
      host=options.urbanUrl,
      port="5432",
      database=options.database,
      user=options.postuser,
      passwd=options.ropw,
      dbtype="postgis")
  
  cat.save(ds)
  ds = cat.get_store(options.alias)

  lL = Layer.objects.all()
  print(lL)
  c = lL.count()
  print(c)
  while c > 0:
    c = c-1
    l = lL[c]
    if l.name=='bxl':
      print('on le garde')
    else:
       l.delete()
  
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
  print(len(urb))   	

  try:
    #connect to tables and create layers and correct urban styles
    for table in urb:
      print(' ')
      print('--------------------------------------')
      print('--------------------------------------')
      lL = Layer.objects.all()
      print(lL)
      print(' ')
      print('   !!! table : ')
      print(table)
      style = urb[table]
      ft = cat.publish_featuretype(table, ds, 'EPSG:31370', srs='EPSG:31370')
      ft.default_style = style
      cat.save(ft)
      res_name = ft.dirty['name']
      res_title = options.alias+"_"+table

      print(' ')
      print('   !!! ft :')
      pprint (vars(ft))

      #resource = ft.resource
      #resource.title = options.alias+"_"+table
      #resource.save()

      print(' ')
      print('   !!! uuid :')
      t_uuid = str(uuid4())
      print(t_uuid)
      
      #layer, created = Layer.objects.get_or_create(name=res_name, defaults={
      #	            "workspace": ws.name,
      #              "store": ds.name,
      #              "storeType": ds.resource_type,
      #              "typename": "%s:%s" % (ws.name.encode('utf-8'), res_name.encode('utf-8')),
      #              "title": res_title or 'No title provided',
      #              "abstract": 'No abstract provided',
      #              #"owner": owner,
      #              "uuid": t_uuid
      #              #"bbox_x0": Decimal(ft.latLonBoundingBox.miny),
      #              #"bbox_x1": Decimal(ft.latLonBoundingBox.maxy),
      #              #"bbox_y0": Decimal(ft.latLonBoundingBox.minx),
      #              #"bbox_y1": Decimal(ft.latLonBoundingBox.maxx)
      # 	         })
    
      #if created:
      #  print(' ')
      #  print('   !!! layer cree :')
      #  pprint (vars(layer))
      #  layer.save()
      #  #set_attributes(layer, overwrite=True)
      #  if created:
      #    print('   layer cree')
      #    layer.set_default_permissions()
      #    layer.save()
      #  print('   layer_name :')
      #  print(layer.title)
      #else:
      #  print(' ')
      #  print("   !!! le layer n'as pas ete cree ... Verifier si il etait deja cree avant ?")
      #  print('   layer_name :')
      #  print(layer.title)
  except Exception as e:
    print(str(e))

  call_command('updatelayers') # est appeler mais n'uploade pas dans geonode... par contre via l'interface admin et la nouvelle option d'appele on a des layers dans geonode.
  
if __name__ == "__main__":
	parser = OptionParser()
	parser.add_option("-p", "--gpw", action="store", type="string", dest="gpw", default="", help="Geoserver admin password [default: %default]")
	parser.add_option("-u", "--urbanUrl", action="store", type="string", dest="urbanUrl", default="", help="Urban URL [default: %default]")
	parser.add_option("-r", "--ropw", action="store", type="string", dest="ropw", default="", help="Remote postGIS ro_user password [default: %default]")
	parser.add_option("-d", "--database", action="store", type="string", dest="database", default="urb_xxx", help="remote urban database name [default: %default]")
	parser.add_option("-a", "--alias", action="store", type="string", dest="alias", default="", help="prefix alias [default: %default]")
        parser.add_option("-z", "--uri", action="store", type="string", dest="uri", default="", help="uri= [default: %default]")
        parser.add_option("-g", "--postuser", action="store", type="string", dest="postuser", default="", help="db_user= [default: %default]")
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
