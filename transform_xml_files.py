""" Script for transformation of metadata files to MMD (MetMetaData file)
    - works for entire directory, i.e. loops through all xml files
    - works for single file

AUTHOR: Trygve Halsne 02.03.2017

REVISION: N/A

STATUS:
    - Works only for results from OpenSearch from colhub.met.no
"""

import os
from xml.dom.minidom import parseString
import glob
import lxml.etree as ET
from StringIO import StringIO
import codecs
import numpy as np
import sys
from s2_extract_filename import extract_value, extract_filename

class Transformer(object):
    """ Object with methods for transforming xml files """
    def __init__(self, filepath, stylesheet, output_path, single_file=False,filename='foo'):
        """ Set required local variables """
        self.filepath = filepath
        self.stylesheet = stylesheet
        self.output_path = output_path
        self.single_file = single_file
        self.filename = filename
        self.counter = 0 # counting all files generated

    def transform(self):
        """ Function for transforming xml files
        """
        print "\n------------START TRANSFORMING METADATA FILE(S)---------------\n"
        filepath, stylesheet, output_path = self.filepath, self.stylesheet, self.output_path
        single_file, filename = self.single_file, self.filename
        counter = self.counter

        # Only made for OpenSearch ENTRY files
        if not single_file:
            xml_files = glob.glob(str(filepath + '*.xml'))
        else:
            xml_files = [str(filepath + filename + '.xml')]

        for name in xml_files:
            try:
                doc = ET.parse(name)
                tree = doc.getroot()
                title = tree.findall('title')
                
		if len(title) == 1:
                    output_fname = title[0].text
                output_complete = os.path.join(output_path,output_fname)

                # extract rectangle from POLYGON:
                lat = []
                lon = []
                polygon_element = tree.xpath("//str[@name='footprint']")[0].text
                coordinates = polygon_element.split('(')[-1].split(')')[0].split(',')
                for pair in coordinates:
                    lat_lon = pair.lstrip().split(' ')
                    lat.append(float(lat_lon[1]))
                    lon.append(float(lat_lon[0]))

                north = np.array(lat).max()
                south = np.array(lat).min()
                east = np.array(lon).max()
                west = np.array(lon).min()
                #print "N: %.2f, S: %.2f, e: %.2f, w: %.2f" %(north, south, east, west)

                # Perform transformation
                xslt = ET.parse(stylesheet)
                transform = ET.XSLT(xslt)
                result = transform(doc)

                # Add rectangle
                final = result.getroot()
                ns = final.nsmap
                rectangle_element = ET.Element(ET.QName(ns.values()[0],'rectangle'),srsName='EPSG:4326',nsmap=ns)
                rectangle_north = ET.SubElement(rectangle_element,ET.QName(ns.values()[0],'north'))
                rectangle_south= ET.SubElement(rectangle_element,ET.QName(ns.values()[0],'south'))
                rectangle_west= ET.SubElement(rectangle_element,ET.QName(ns.values()[0],'west'))
                rectangle_east= ET.SubElement(rectangle_element,ET.QName(ns.values()[0],'east'))

                rectangle_north.text = str(north)
                rectangle_south.text = str(south)
                rectangle_west.text = str(west)
                rectangle_east.text = str(east)

                final.xpath('//mmd:geographic_extent',namespaces=ns)[0].append(rectangle_element)

		        # Add data_access elements
                if not single_file:
                    filename = name.split('/')[-1].split('.')[0]

                # Get platform name
                satellite_platform = final.find('./mmd:platform',namespaces=ns)
                satellite_platform_name = satellite_platform.find('./mmd:short_name', namespaces=ns)

                # Decide data_access_path from date (and mode if Sentinel-1)
                date =  tree.xpath('.//date[@name="beginposition"]')[0].text
                output_path_splitted = date.split('-')
		if satellite_platform_name.text == 'S2A' or satellite_platform_name.text == 'S2B':
		    polarisation = None
                    data_access_output_path_prefix = str(satellite_platform_name.text + '/' + output_path_splitted[0] +
		                                         '/' + output_path_splitted[1] + '/' + output_path_splitted[2].split('T')[0] + '/')
		elif satellite_platform_name.text == 'S1A' or satellite_platform_name.text == 'S1B':
		    mode_name = tree.xpath('.//str[@name="sensoroperationalmode"]')[0].text 
		    polarisation = tree.xpath('.//str[@name="polarisationmode"]')[0].text 
                    data_access_output_path_prefix = str(satellite_platform_name.text + '/' + output_path_splitted[0] + 
		                                         '/' + output_path_splitted[1] + '/' + output_path_splitted[2].split('T')[0] + 
							 '/' + mode_name + '/')
		elif satellite_platform_name.text == 'S3A' or satellite_platform_name.text == 'S3B':
		    polarisation = None
                    instrument = (tree.xpath('.//str[@name="instrumentshortname"]')[0].text)
                    data_access_output_path_prefix = str(satellite_platform_name.text + '/' + output_path_splitted[0] +
		                                         '/' + output_path_splitted[1] + '/' + output_path_splitted[2].split('T')[0] + 
                                                         '/' + instrument + '/')
                else:
                    data_access_output_path_prefix = "test"
		    polarisation = None
                    

                da_opendap = self.create_data_access_element(final,"OPeNDAP", data_access_output_path_prefix, filename)
                da_ogcwms = self.create_data_access_element(final,"OGC WMS",data_access_output_path_prefix, filename, platform=satellite_platform_name.text, polarisation=polarisation)
                da_HTTP = self.create_data_access_element(final,"HTTP",data_access_output_path_prefix, filename)
                ri_landing_page = self.create_related_information_element(final,"TMP",data_access_output_path_prefix, filename)

                uuid = tree.xpath("//str[@name='uuid']")[0].text

                da_SAFE = self.create_data_access_element(final,"ODATA",'', uuid)

                final.append(da_opendap)
                final.append(da_ogcwms)
                final.append(da_HTTP)
                final.append(ri_landing_page)
                final.append(da_SAFE)


                output = codecs.open(output_complete + '.xml' ,'w','utf-8')
                result.write(output,encoding='utf-8',method='xml',pretty_print=True)
                output.close()
                counter += 1
            except:
	        e = sys.exc_info()
                print "Could not transform file %s" % name
		print e

            #print result
            # append data_access elements for OPeNDAP, OGC WMS, HTTP and HTTPserver
            #break;

        print "Transformed %i files to \n\t%s" % (counter,output_path)

    def create_related_information_element(self, root, element_type, path_prefix, id):
        """ Function for manually constructing related_information elements """

        ns = root.nsmap.values()[0]
        related_information = ET.Element(ET.QName(ns,'related_information'),nsmap=root.nsmap)
        related_information_type = ET.SubElement(related_information,ET.QName(ns,'type'))
        related_information_description = ET.SubElement(related_information,ET.QName(ns,'description'))
        related_information_resource = ET.SubElement(related_information,ET.QName(ns,'resource'))
        related_information_type.text = "Dataset landing page"
        related_information_resource.text = ("http://nbstds.met.no/thredds/catalog/NBS/" + path_prefix  + "catalog.html?dataset=nbs/"
                                      + path_prefix  + id + ".nc")
        related_information_description.text = "A dataset landing page."
        return related_information

    def create_data_access_element(self, root, element_type, path_prefix, id, platform=None, polarisation=None):
        """ Function for manually constructing data_access elements """

        valid_types = ['OPeNDAP', 'OGC WMS', "HTTP", "ODATA"]
        ns = root.nsmap.values()[0]
        data_access_element = ET.Element(ET.QName(ns,'data_access'),nsmap=root.nsmap)
        type_sub_element = ET.SubElement(data_access_element,ET.QName(ns,'type'))
        description_sub_element = ET.SubElement(data_access_element,ET.QName(ns,'description'))
        resource_sub_element = ET.SubElement(data_access_element,ET.QName(ns,'resource'))
        wms_layers_sub_element = ET.SubElement(data_access_element,ET.QName(ns,'wms_layers'))

        if element_type == "OPeNDAP":
            type_sub_element.text = "OPeNDAP"
            description_sub_element.text = "Open-source Project for a Network Data Access Protocol."
            resource_sub_element.text = ("http://nbstds.met.no/thredds/dodsC/NBS/" + path_prefix  + id + ".nc")
            wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
            return data_access_element
        elif element_type == "OGC WMS":
            if platform=='S2A' or platform=='S2B':
                type_sub_element.text = "OGC WMS"
                description_sub_element.text = "OGC Web Mapping Service, URI to GetCapabilities Document."
                resource_sub_element.text = ("http://nbswms.met.no/thredds/wms_ql/NBS/" + path_prefix  + id + ".nc")
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "True Color Vegetation Composite"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "False Color Vegetation Composite"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "False Color Glacier Composite"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B1"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B2"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B3"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B4"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B5"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B6"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B7"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B8"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B8A"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B9"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B10"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B11"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Reflectance in band B12"
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "Cloud mask 10m resolution"
                #wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                #wms_layer.text = "Opaque cloud mask 10m resolution"
                return data_access_element
            elif platform=='S1A' or platform=='S1B':
                type_sub_element.text = "OGC WMS"
                description_sub_element.text = "OGC Web Mapping Service, URI to GetCapabilities Document."
                resource_sub_element.text = ("http://nbswms.met.no/thredds/wms_ql/NBS/" + path_prefix  + id + ".nc")
		for p in polarisation.split(): 
                    wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                    wms_layer.text = str("Amplitude " + p + " polarisation")
                    #wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                    #wms_layer.text = "Amplitude_VH"
                return data_access_element
            elif platform=='S3A' or platform=='S3B':
                type_sub_element.text = "OGC WMS"
                description_sub_element.text = "OGC Web Mapping Service, URI to GetCapabilities Document."
                resource_sub_element.text = ("http://nbswms.met.no/thredds/wms_ql/NBS/" + path_prefix  + id + ".nc")
                wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
                wms_layer.text = "True Color Vegetation Composite"
                return data_access_element
            else:
                return data_access_element
                
        elif element_type == "HTTP":
            type_sub_element.text = "HTTP"
            description_sub_element.text = str("Direct access to the full data file." +
                            " May require authentication, but should point directly to" +
                            " the data file or a catalogue containing the data.")
            resource_sub_element.text = ("http://nbstds.met.no/thredds/fileServer/NBS/"
                                    + path_prefix + id + ".nc")
            wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
            return data_access_element
        elif element_type == "ODATA":
            type_sub_element.text = "ODATA"
            description_sub_element.text = "Open Data Protocol."
            resource_sub_element.text = ("https://colhub.met.no/odata/v1/Products('" + id + "')/$value")
            wms_layer = ET.SubElement(wms_layers_sub_element, ET.QName(ns,'wms_layer'))
            return data_access_element
        else:
            print "Invalid data access element"
            return None

def main():
    # Read config data
    import yaml
    with open('transform_config.yaml') as config_file:
        try:
            config=yaml.safe_load(config_file)
        except yaml.YAMLError as exc:
            print(exc)
    
    fpath =config['parameters']['fpath']
    output_path =config['parameters']['output_path']
    stylesheet = config['parameters']['stylesheet']
    
    single_file = True    
    filename = 'S3A_OL_1_EFR____20190927T095206_20190927T095506_20190927T114949_0180_049_350_1800_LN1_O_NR_002'
    #filename = 'S2B_MSIL1C_20180802T150759_N0206_R025_T31XEL_20180802T201204'
    test = Transformer(fpath,stylesheet,output_path,single_file,filename)
    #test = Transformer(fpath,stylesheet,output_path)
    test.transform()

if __name__=='__main__':
    main()
