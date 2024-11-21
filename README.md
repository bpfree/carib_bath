# Caribbean Bathymetry
Bathymetry creation for the US Caribbean Exclusive Economic Zones (Puerto Rico and United States Virgin Islands). These data were built from 
NOAA's BlueTopo and the Global multi-resolution topography datasets.

## Methods
### Software
R 4.4.0 (terra 1.7-78, sf 1.0-19, dplyr 1.1.4)
ArcGIS Pro 3.3.1

### Coordinate reference system
After discussions on which coordinate reference system to procede, it was chosen that WGS84 (EPSG:4326) would minimize any area differences across the US Caribbean EEZ. BlueTopo data come in both the UTM19N and UTM20N zones, while the GMRT data are in WGS84.

### Data sources
#### BlueTopo
[BlueTopo](https://nauticalcharts.noaa.gov/data/bluetopo.html) are products by NOAA's Office of Coast Survey that provide consistent bathymetry coverage for the waters across the United States. For understanding naming conventions and other specifications in regards to the data, please visit [this page](https://nauticalcharts.noaa.gov/data/bluetopo_specs.html).
A helpful way to visually inspect the data is at this [map viewer](https://nowcoast.noaa.gov/).  

#### GMRT
[Global multi-resolution topography (GMRT)](Global Multi-Resolution Topography (GMRT)) can provided coverage for areas that do not exist by BlueTopo bathymetry. These data can get accessed through a [toolkit](https://www.gmrt.org/GMRTMapTool/) and also through [web services](https://www.gmrt.org/services/index.php). This analysis relied on the web-services to automatically generate the data based on coordinates and other criterias; this is possible by constructing the URL for downloading the data. To learn more about how to construct an URL for data download, one option is [here](https://www.gmrt.org/services/gridserverinfo.php#!/services/getGMRTGrid).

### Bathymetry combination
BlueTopo gets delineated into three different resolutions: 4m, 8m, and 16m. Due to the geographic orientation of the US Caribbean, it straddles two different UTM zones (19N and 20N). When these data
get obtained through the Python bluetopo package, they arrive as tiles for the UTM zones they exist.
After BlueTopo Tiles get combined for each UTM zone in R, they get combined in ArcGIS Pro to reduce artifacts and errors that R produces.

1.) Mosaic to New Raster (UTM19N + UTM20N, coordinate reference system = WGS84)

### GMRT

ArcGIS tool new mosaic to raster that combines the GMRT data and the 16m resolution data to form a complete raster. The resolution output was the same as the x-cell size (5.49372231074078E-04). When values overlap, the first raster got elected for filling in the value (the 16m-resolution combined raster formed by BlueTopo tiles). Given that the These data got masked to only the EEZ

1. Mosaic to New Raster (BlueTopo combined + GMRT, GMRT for cell size, BlueTopo for overlapping values)
2. Set Null (values greater than or equal to 0 get NULL value)
3. Extract by Mask (full EEZ acts as mask)

#### Notes
There remain some artefacts due to how the BlueTopo data got created and combined. There exist slits of no data between a few tiles.

#### Contacts
For questions concerning the creation of these data, contact [Brian Free](mailto:brian.free@gmail.com).
[Tashi Geleg](mailto:phuntsok.geleg@noaa.gov) can assist with any questions about how to access, download, and generally interact with BlueTopo data.
