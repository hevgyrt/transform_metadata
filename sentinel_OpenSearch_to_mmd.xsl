<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.met.no/schema/mmd"
    xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:mmd="http://www.met.no/schema/mmd"
    xmlns:mapping_instruments="http://www.met.no/schema/mmd/instruments"
    >

    <!-- Following the MMD specification sheet v. 3.1 -->
    <xsl:output method="xml" indent="yes" />
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

    <xsl:template match="/entry">
        <xsl:element name="mmd:mmd">

            <!-- 2.1 - metadata_identifier-->
            <xsl:element name="mmd:metadata_identifier">
               <xsl:value-of select="str[@name = 'uuid']"/>
            </xsl:element>

            <!-- 2.3 - last_metadata_update -->
            <xsl:apply-templates select="date[@name = 'ingestiondate']" />
            <!-- 2.4 - metadata_status -->
            <xsl:element name="mmd:metadata_status" >Active</xsl:element>
            <!-- 2.5 - collection -->
            <xsl:element name="mmd:collection" >NBS</xsl:element>
            <!-- 2.6 - metadata_title -->
            <xsl:element name="mmd:title">
              <xsl:attribute name="xml:lang">en</xsl:attribute>
              <xsl:value-of select="title" />
            </xsl:element>
            <!-- 2.7 - abstract-->
            <xsl:apply-templates select="str[@name = 'platformname']"/>
            <!-- 2.8 - temporal_extent -->
            <xsl:element name="mmd:temporal_extent">
              <xsl:apply-templates select="date[@name = 'beginposition']" />
              <xsl:apply-templates select="date[@name = 'endposition']" />
            </xsl:element>
            
            <!--  2.9 and 2.10 - geographic_extent - SOLVE Rectangle in PYTHON-->
            <xsl:element name="mmd:geographic_extent">
              <!-- <xsl:apply-templates select="str[@name = 'gmlfootprint']" /> -->
            </xsl:element>

            <!-- 2.12 - dataset_production_status -->
            <xsl:element name="mmd:dataset_production_status">In Work</xsl:element>

            <!-- 2.13 - dataset_language -->
            <xsl:element name="mmd:dataset_language" >en</xsl:element>

            <!-- 2.14 - operational_status -->
            <xsl:element name="mmd:operational_status">Operational</xsl:element>
            
            <!-- 2.15 - access_constraint-->
            <xsl:element name="mmd:access_constraint">Open</xsl:element>
            
            <!-- 2.16 - use_constraint-->
            <xsl:element name="mmd:use_constraint">
              <xsl:element name="mmd:license_text">The use of these data are covered by the Legal notice on the use of Copernicus Sentinel Data and Service Information at https://sentinels.copernicus.eu/documents/247904/690755/Sentinel_Data_Legal_Notice</xsl:element>
            </xsl:element>

            <!-- 2.17 - personnel  -->
            <xsl:element name="mmd:personnel" >
              <xsl:element name="mmd:role">Data center contact</xsl:element>
              <xsl:element name="mmd:name">NBS Helpdesk</xsl:element>
              <xsl:element name="mmd:email">nbs-helpdesk@met.no</xsl:element>
              <xsl:element name="mmd:organisation">Norwegian Meteorological Institute</xsl:element>
            </xsl:element>
            <xsl:element name="mmd:personnel" >
              <xsl:element name="mmd:role">Metadata author</xsl:element>
              <xsl:element name="mmd:name">NBS team</xsl:element>
              <xsl:element name="mmd:email">nbs-helpdesk@met.no</xsl:element>
              <xsl:element name="mmd:organisation">Norwegian Meteorological Institute</xsl:element>
            </xsl:element>

            <!-- 2.18 - data_center -->
            <xsl:element name="mmd:data_center" >
              <xsl:element name="mmd:data_center_name">
                <xsl:element name="mmd:short_name">METNO</xsl:element>
                <xsl:element name="mmd:long_name">Norwegian Meteorological Institute</xsl:element>
              </xsl:element>
              <xsl:element name="mmd:data_center_url">https://met.no</xsl:element>
            </xsl:element>

            <!-- 2.19 - data_access (Implemented in another Python script)-->           

            <!-- 2.21 - storage_information-->
            <xsl:element name="mmd:storage_information">
              <xsl:element name="mmd:file_format">NetCDF-CF</xsl:element>
            </xsl:element>
            
            
            <!-- 2.22 - related_information  (Implemented in another Python script) -->

            <!-- 2.23 - iso_topic_category (see 2.24 - keywords) -->

            <!-- 2.24 - keywords  -->
            <xsl:variable name="i_id" select="str[@name = 'instrumentshortname']"/>
            <xsl:choose>
              <xsl:when test="$i_id = 'SAR-C SAR'" >
                <xsl:element name="mmd:iso_topic_category">climatologyMeteorologyAtmosphere</xsl:element>
                <xsl:element name="mmd:iso_topic_category">oceans</xsl:element>
                <xsl:element name="mmd:iso_topic_category">imageryBaseMapsEarthCover</xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GCMDSK</xsl:attribute>
                  <xsl:element name="mmd:keyword">Earth Science &gt; Spectral/Engineering &gt; RADAR &gt; RADAR backscatter</xsl:element>
                  <xsl:element name="mmd:keyword">Earth Science &gt; Spectral/Engineering &gt; RADAR &gt; RADAR imagery</xsl:element>
                  <xsl:element name="mmd:keyword">Earth Science &gt; Spectral/Engineering &gt; Microwave &gt; Microwave imagery</xsl:element>
                  <xsl:element name="mmd:resource">https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords</xsl:element>
                  <xsl:element name="mmd:separator">&gt;</xsl:element>
                </xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GEMET</xsl:attribute>
                  <xsl:element name="mmd:keyword">Orthoimagery</xsl:element>
                  <xsl:element name="mmd:keyword">Land cover</xsl:element>
                  <xsl:element name="mmd:keyword">Oceanographic geographical features</xsl:element>
                  <xsl:element name="mmd:resource">http://inspire.ec.europa.eu/theme</xsl:element>
                </xsl:element>
              </xsl:when>
              <xsl:when test="$i_id = 'MSI'" >
                <xsl:element name="mmd:iso_topic_category">climatologyMeteorologyAtmosphere</xsl:element>
                <xsl:element name="mmd:iso_topic_category">oceans</xsl:element>
                <xsl:element name="mmd:iso_topic_category">imageryBaseMapsEarthCover</xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GCMDSK</xsl:attribute>
                  <xsl:element name="mmd:keyword">Earth Science &gt; Atmosphere &gt; Atmospheric radiation &gt; Reflectance</xsl:element>
                  <xsl:element name="mmd:resource">https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords</xsl:element>
                  <xsl:element name="mmd:separator">&gt;</xsl:element>
                </xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GEMET</xsl:attribute>
                  <xsl:element name="mmd:keyword">Orthoimagery</xsl:element>
                  <xsl:element name="mmd:keyword">Land cover</xsl:element>
                  <xsl:element name="mmd:resource">http://inspire.ec.europa.eu/theme</xsl:element>
                </xsl:element>
              </xsl:when>
              <xsl:when test="$i_id = 'OLCI'" >
                <xsl:element name="mmd:iso_topic_category">climatologyMeteorologyAtmosphere</xsl:element>
                <xsl:element name="mmd:iso_topic_category">oceans</xsl:element>
                <xsl:element name="mmd:iso_topic_category">inlandWaters</xsl:element>
                <xsl:element name="mmd:iso_topic_category">imageryBaseMapsEarthCover</xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GCMDSK</xsl:attribute>
                  <xsl:element name="mmd:keyword">Earth Science &gt; Atmosphere &gt; Atmospheric radiation &gt; Reflectance</xsl:element>
                  <xsl:element name="mmd:resource">https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords</xsl:element>
                  <xsl:element name="mmd:separator">&gt;</xsl:element>
                </xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GEMET</xsl:attribute>
                  <xsl:element name="mmd:keyword">Orthoimagery</xsl:element>
                  <xsl:element name="mmd:keyword">Land cover</xsl:element>
                  <xsl:element name="mmd:keyword">Oceanographic geographical features</xsl:element>
                  <xsl:element name="mmd:resource">http://inspire.ec.europa.eu/theme</xsl:element>
                </xsl:element>

              </xsl:when>
              <xsl:when test="$i_id = 'SLSTR'" >
                <xsl:element name="mmd:iso_topic_category">climatologyMeteorologyAtmosphere</xsl:element>
                <xsl:element name="mmd:iso_topic_category">oceans</xsl:element>
                <xsl:element name="mmd:iso_topic_category">imageryBaseMapsEarthCover</xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GCMDSK</xsl:attribute>
                  <xsl:element name="mmd:keyword">Earth Science &gt; Atmosphere &gt; Atmospheric radiation &gt; Reflectance</xsl:element>
                  <xsl:element name="mmd:resource">https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords</xsl:element>
                  <xsl:element name="mmd:separator">&gt;</xsl:element>
                </xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GEMET</xsl:attribute>
                  <xsl:element name="mmd:keyword">Orthoimagery</xsl:element>
                  <xsl:element name="mmd:keyword">Land cover</xsl:element>
                  <xsl:element name="mmd:keyword">Oceanographic geographical features</xsl:element>
                  <xsl:element name="mmd:resource">http://inspire.ec.europa.eu/theme</xsl:element>
                </xsl:element>

              </xsl:when>
              <xsl:when test="$i_id = 'SRAL'" >
                <xsl:element name="mmd:iso_topic_category">climatologyMeteorologyAtmosphere</xsl:element>
                <xsl:element name="mmd:iso_topic_category">oceans</xsl:element>
                <xsl:element name="mmd:iso_topic_category">elevation</xsl:element>
                <xsl:element name="mmd:iso_topic_category">imageryBaseMapsEarthCover</xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GCMDSK</xsl:attribute>
                  <xsl:element name="mmd:keyword">Earth Science &gt; Atmosphere &gt; Atmospheric radiation &gt; Reflectance</xsl:element>
                  <xsl:element name="mmd:resource">https://gcmd.earthdata.nasa.gov/kms/concepts/concept_scheme/sciencekeywords</xsl:element>
                  <xsl:element name="mmd:separator">&gt;</xsl:element>
                </xsl:element>
                <xsl:element name="mmd:keywords">
                  <xsl:attribute name="vocabulary">GEMET</xsl:attribute>
                  <xsl:element name="mmd:keyword">Orthoimagery</xsl:element>
                  <xsl:element name="mmd:resource">http://inspire.ec.europa.eu/theme</xsl:element>
                </xsl:element>
              </xsl:when>
              </xsl:choose>
              <!-- 2.25 - project -->
              <xsl:element name="mmd:project">
                <xsl:element name="mmd:short_name">NBS</xsl:element>
                <xsl:element name="mmd:long_name">Nasjonalt BakkeSegment</xsl:element>
              </xsl:element>
            
              <!-- 2.26 - platform -->
              <xsl:apply-templates select="str[@name = 'identifier']"/>

              <!-- 2.27 - spatial_representation -->
              <xsl:element name="mmd:spatial_representation">grid</xsl:element>

              <!-- 2.28 - activity_type -->
              <xsl:element name="mmd:activity_type">Space Borne Instrument</xsl:element>

              <!-- 2.28 - dataset_citation -->
              <xsl:element name="mmd:dataset_citation">
      		<xsl:variable name="date_acq" select="date[@name = 'beginposition']"/>
                <xsl:element name="mmd:title">
                  <xsl:value-of select="title" />
                </xsl:element>
                <xsl:element name="mmd:other">
                  <xsl:text>Contains modified Copernicus Sentinel data </xsl:text>
                  <xsl:value-of select="substring($date_acq,1,4)" />
                </xsl:element>
              </xsl:element>

        </xsl:element>
    </xsl:template>

     <!-- TEMPLATES: -->

    <!--  title and platform -->
    <xsl:template match="str[@name = 'identifier']">
      <xsl:variable name="id" select="."/>
      <xsl:element name="mmd:platform" >
        <xsl:choose>
          <xsl:when test="substring($id,1,3) = 'S1A'">
            <xsl:element name="mmd:short_name">Sentinel-1A</xsl:element>
            <xsl:element name="mmd:long_name">Sentinel-1A</xsl:element>
            <xsl:element name="mmd:resource">https://www.wmo-sat.info/oscar/satellites/view/sentinel_1a</xsl:element>
          </xsl:when>
          <xsl:when test="substring($id,1,3) = 'S1B'">
            <xsl:element name="mmd:short_name">Sentinel-1B</xsl:element>
            <xsl:element name="mmd:long_name">Sentinel-1B</xsl:element>
            <xsl:element name="mmd:resource">https://www.wmo-sat.info/oscar/satellites/view/sentinel_1b</xsl:element>
          </xsl:when>
          <xsl:when test="substring($id,1,3) = 'S2A'">
            <xsl:element name="mmd:short_name">Sentinel-2A</xsl:element>
            <xsl:element name="mmd:long_name">Sentinel-2A</xsl:element>
            <xsl:element name="mmd:resource">https://www.wmo-sat.info/oscar/satellites/view/sentinel_2a</xsl:element>
          </xsl:when>
          <xsl:when test="substring($id,1,3) = 'S2B'">
            <xsl:element name="mmd:short_name">Sentinel-2B</xsl:element>
            <xsl:element name="mmd:long_name">Sentinel-2B</xsl:element>
            <xsl:element name="mmd:resource">https://www.wmo-sat.info/oscar/satellites/view/sentinel_2b</xsl:element>
          </xsl:when>
          <xsl:when test="substring($id,1,3) = 'S3A'">
            <xsl:element name="mmd:short_name">Sentinel-3A</xsl:element>
            <xsl:element name="mmd:long_name">Sentinel-3A</xsl:element>
            <xsl:element name="mmd:resource">https://www.wmo-sat.info/oscar/satellites/view/sentinel_3a</xsl:element>
          </xsl:when>
          <xsl:when test="substring($id,1,3) = 'S3B'">
            <xsl:element name="mmd:short_name">Sentinel-3B</xsl:element>
            <xsl:element name="mmd:long_name">Sentinel-3B</xsl:element>
            <xsl:element name="mmd:resource">https://www.wmo-sat.info/oscar/satellites/view/sentinel_3b</xsl:element>
          </xsl:when>
          <xsl:when test="substring($id,1,3) = 'S5P'">
            <xsl:element name="mmd:short_name">Sentinel-5P</xsl:element>
            <xsl:element name="mmd:long_name">Sentinel-5P</xsl:element>
            <xsl:element name="mmd:resource">https://www.wmo-sat.info/oscar/satellites/view/sentinel_5p</xsl:element>
          </xsl:when>
        </xsl:choose>
        <xsl:element name="mmd:orbit_relative">
             <xsl:value-of select="../int[@name = 'relativeorbitnumber']"/>
        </xsl:element>
        <xsl:element name="mmd:orbit_absolute">
             <xsl:value-of select="../int[@name = 'orbitnumber']"/>
        </xsl:element>
        <xsl:element name="mmd:orbit_direction">
             <!--<xsl:value-of select="../str[@name = 'orbitdirection']"/>-->
             <xsl:value-of select="translate(../str[@name = 'orbitdirection'],$uppercase, $lowercase)"/>
        </xsl:element>
        <xsl:element name="mmd:instrument">
	   <xsl:call-template name="instrument"/>
        </xsl:element>
        <xsl:element name="mmd:ancillary">
	   <xsl:call-template name="ancillary"/>
        </xsl:element>
      </xsl:element>
    </xsl:template>

    <xsl:template name="instrument">
	
       <xsl:if test="../str[@name = 'instrumentshortname'] ='SAR-C SAR'">
               <xsl:element name="mmd:short_name">
             <xsl:text>SAR-C</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:long_name">
             <xsl:text>Synthetic Aperture Radar (C-band)</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:resource">
             <xsl:text>https://www.wmo-sat.info/oscar/instruments/view/sar_c_sentinel_1</xsl:text>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../str[@name = 'instrumentshortname'] ='MSI'">
          <xsl:element name="mmd:short_name">
             <xsl:text>MSI</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:long_name">
             <xsl:text>Multi-Spectral Imager for Sentinel-2</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:resource">
             <xsl:text>https://www.wmo-sat.info/oscar/instruments/view/msi_sentinel_2a</xsl:text>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../str[@name = 'instrumentshortname'] ='OLCI'">
          <xsl:element name="mmd:short_name">
             <xsl:text>OLCI</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:long_name">
             <xsl:text>Ocean and Land Colour Imager</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:resource">
             <xsl:text>https://www.wmo-sat.info/oscar/instruments/view/olci</xsl:text>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../str[@name = 'instrumentshortname'] ='SLSTR'">
          <xsl:element name="mmd:short_name">
             <xsl:text>SLSTR</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:long_name">
             <xsl:text>Sea and Land Surface Temperature Radiometer</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:resource">
             <xsl:text>https://www.wmo-sat.info/oscar/instruments/view/slstr</xsl:text>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../str[@name = 'instrumentshortname'] ='MWR'">
          <xsl:element name="mmd:short_name">
             <xsl:text>MWR</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:long_name">
             <xsl:text>Micro-Wave Radiometer</xsl:text>
          </xsl:element>
          <xsl:element name="mmd:resource">
             <xsl:text>https://www.wmo-sat.info/oscar/instruments/view/mwr_sentinel_3</xsl:text>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../str[@name = 'sensoroperationalmode'] = 'SM' or ../str[@name = 'sensoroperationalmode']= 'IW' or ../str[@name = 'sensoroperationalmode'] = 'EW' or ../str[@name = 'sensoroperationalmode'] = 'VW'">
          <xsl:element name="mmd:mode">
             <xsl:value-of select="../str[@name = 'sensoroperationalmode']"/>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../str[@name = 'polarisationmode'] !=''">
          <xsl:element name="mmd:polarisation">
             <xsl:value-of select="translate(../str[@name = 'polarisationmode'], ' ', '+')"/>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../str[@name = 'producttype'] !=''">
          <xsl:element name="mmd:product_type">
             <xsl:value-of select="../str[@name = 'producttype']"/>
          </xsl:element>
       </xsl:if>
    </xsl:template>

    <xsl:template name="ancillary">
       <xsl:if test="../double[@name='cloudcoverpercentage']  !=''">
          <xsl:element name="mmd:cloud_coverage">
             <xsl:value-of select="../double[@name='cloudcoverpercentage']"/>
          </xsl:element>
       </xsl:if>
       <xsl:if test="../mmd:scene_cover !=''">
          <xsl:element name="mmd:scene_coverage">
             <xsl:value-of select="../mmd:scene_cover/mmd:value"/>
          </xsl:element>
       </xsl:if>
    </xsl:template>

    <!-- geographic_extent POLYGON -->
    <xsl:template match="str[@name = 'gmlfootprint']">
        <xsl:element name="mmd:polygon">
          <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- abstract -->
    <xsl:template match="str[@name = 'platformname']">
      <xsl:variable name="p_id" select="."/>
        <xsl:choose>
        <xsl:when test="$p_id = 'Sentinel-1'">
          <xsl:element name="mmd:abstract" >
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            The SENTINEL-1 mission comprises a constellation of two polar-orbiting satellites, operating day and night performing C-band synthetic aperture radar imaging, enabling them to acquire imagery regardless of the weather.
          </xsl:element>
          <xsl:element name="mmd:related_information" >
            <xsl:element name="mmd:type">Users guide</xsl:element>
            <xsl:element name="mmd:description">URI to a users guide or product manual for the dataset.</xsl:element>
            <xsl:element name="mmd:resource">https://sentinel.esa.int/web/sentinel/missions/sentinel-1</xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$p_id = 'Sentinel-2'">
          <xsl:element name="mmd:abstract" >
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            Each of the satellites in the SENTINEL-2 mission carries a single payload: the Multi-Spectral Instrument (MSI).
          </xsl:element>
          <xsl:element name="mmd:related_information" >
            <xsl:element name="mmd:type">Users guide</xsl:element>
            <xsl:element name="mmd:description">URI to a users guide or product manual for the dataset.</xsl:element>
            <xsl:element name="mmd:resource">https://sentinel.esa.int/web/sentinel/missions/sentinel-2</xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$p_id = 'Sentinel-3'">
          <xsl:element name="mmd:abstract" >
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            The main objective of the SENTINEL-3 mission is to measure sea surface topography, sea and land surface temperature, and ocean and land surface colour with high accuracy and reliability to support ocean forecasting systems, environmental monitoring and climate monitoring.
          </xsl:element>
          <xsl:element name="mmd:related_information" >
            <xsl:element name="mmd:type">Users guide</xsl:element>
            <xsl:element name="mmd:description">URI to a users guide or product manual for the dataset.</xsl:element>
            <xsl:element name="mmd:resource">https://sentinel.esa.int/web/sentinel/missions/sentinel-3</xsl:element>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="mmd:abstract" >
            <xsl:attribute name="xml:lang">en</xsl:attribute>
          </xsl:element>
          <xsl:element name="mmd:related_information" >
            <xsl:element name="mmd:type">Users guide</xsl:element>
            <xsl:element name="mmd:resource"></xsl:element>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>






    <!-- temporal_extent -->
    <xsl:template match="date[@name = 'beginposition']">
      <xsl:variable name="name" select="@name"/>
      <xsl:variable name="date" select="."/>
        <xsl:element name="mmd:start_date">
          <xsl:value-of select="$date"/>
          </xsl:element>
    </xsl:template>

    <xsl:template match="date[@name = 'endposition']">
      <xsl:variable name="name" select="@name"/>
      <xsl:variable name="date" select="."/>
          <xsl:element name="mmd:end_date">
            <xsl:value-of select="$date"/>
          </xsl:element>
    </xsl:template>

    <!-- last_metadata_update -->
    <xsl:template match="date[@name = 'ingestiondate']">
      <xsl:variable name="date" select="."/>
      <xsl:element name="mmd:last_metadata_update">
        <xsl:element name="mmd:update">
          <xsl:element name="mmd:datetime">
            <xsl:value-of select="$date"/>
          </xsl:element>
          <xsl:element name="mmd:type">Created</xsl:element>
          <xsl:element name="mmd:note"></xsl:element>
        </xsl:element>
      </xsl:element>
    </xsl:template>


    <!-- Look up tables -->
    <mapping_instruments:instrument orig="SAR-C SAR" mmd_convention="C-SAR" />
    <mapping_instruments:instrument orig="MSI" mmd_convention="MSI" />
    <mapping_instruments:instrument orig="OLCI" mmd_convention="OLCI" />


  </xsl:stylesheet>
