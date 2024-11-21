# carib_bath
Bathymetry creation for the US Caribbean



# Methods
## Software
R 4.4.0 (terra 1.7-78, sf 1.0-19, dplyr 1.1.4)
ArcGIS Pro 3.3.1

## Coordinate reference system
After discussions on which coordinate reference system to procede, it was chosen that WGS84 (EPSG:4326) would minimize any area differences across the US Caribbean EEZ.

## BlueTopo Tiles
BlueTopo tiles got

After BlueTopo Tiles get combined for each UTM zone in R, they get combined in ArcGIS Pro to reduce artifacts and errors that R produces.

1.) Mosaic to New Raster (UTM19N + UTM20N, coordinate reference system = WGS84)

## GMRT
[Global multi-resolution topography (GMRT)](Global Multi-Resolution Topography (GMRT)) can provided coverage for areas that do not exist by BlueTopo bathymetry. These data can get accessed through a [toolkit](https://www.gmrt.org/GMRTMapTool/) and also through [web services](https://www.gmrt.org/services/index.php). This analysis relied on the web-services to automatically generate the data based on coordinates and other criterias; this is possible by constructing the URL for downloading the data. To learn more about how to construct an URL for data download, one option is [here](https://www.gmrt.org/services/gridserverinfo.php#!/services/getGMRTGrid).

ArcGIS tool new mosaic to raster that combines the GMRT data and the 16m resolution data to form a complete raster. The resolution output was the same as the x-cell size (5.49372231074078E-04). When values overlap, the first raster got elected for filling in the value (the 16m-resolution combined raster formed by BlueTopo tiles). Given that the These data got masked to only the EEZ

1. Mosaic to New Raster (BlueTopo combined + GMRT, GMRT for cell size, BlueTopo for overlapping values)
2. Set Null (values greater than or equal to 0 get NULL value)
3. Extract by Mask (full EEZ acts as mask)

### Contacts
For questions concerning the creation of these data, contact [Brian Free](mailto:brian.free@gmail.com).
[Tashi Geleg](mailto:phuntsok.geleg@noaa.gov) can assist with any questions about how to access, download, and generally interact with BlueTopo data.
