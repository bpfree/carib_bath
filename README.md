# Caribbean Bathymetry
Bathymetry creation for the US Caribbean Exclusive Economic Zones (Puerto Rico and United States Virgin Islands). These data were built from 
NOAA's BlueTopo and the Global multi-resolution topography datasets.

## Methods
### 1. Software
R 4.4.0 (terra 1.7-78, sf 1.0-19, dplyr 1.1.4)
ArcGIS Pro 3.3.1

### Coordinate reference system
After discussions on which coordinate reference system to procede, it was chosen that WGS84 (EPSG:4326) would minimize any area differences across the US Caribbean EEZ. BlueTopo data come in both the UTM19N and UTM20N zones, while the GMRT data are in WGS84.

### 2. Data sources
#### EEZ
Exclusive economic zone data came from [here](https://marinecadastre.gov/downloads/data/mc/FederalStateWaters.zip) and cover all state and federal waters (for [metadata](https://www.fisheries.noaa.gov/inport/item/54383)). The Coastal Management Act [data](https://hub.marinecadastre.gov/datasets/noaa::coastal-zone-management-act/about) are similar and do fill in small holes that exist for smaller islands.
NOAA's OCS also [provide data](https://nauticalcharts.noaa.gov/data/us-maritime-limits-and-boundaries.html) for [EEZ boundaries](https://maritimeboundaries.noaa.gov/downloads/USMaritimeLimitsAndBoundariesSHP.zip). These exist as polylines, so are less ideal for the current work.

Within R, the EEZ polygon got flattened and any areas that would normally 

#### BlueTopo
[BlueTopo](https://nauticalcharts.noaa.gov/data/bluetopo.html) are products by NOAA's Office of Coast Survey that provide consistent bathymetry coverage for the waters across the United States. For understanding naming conventions and other specifications in regards to the data, please visit [this page](https://nauticalcharts.noaa.gov/data/bluetopo_specs.html).
A helpful way to visually inspect the data is at this [map viewer](https://nowcoast.noaa.gov/). To install the Python package and begin working with the BlueTopo tiles, follow OCS Hydrography [GitHub repository](https://github.com/noaa-ocs-hydrography/BlueTopo) for BlueTopo. For it to work, check the [necessary requirements](https://github.com/noaa-ocs-hydrography/BlueTopo#requirements) and follow these [installation instructions](https://github.com/noaa-ocs-hydrography/BlueTopo#installation).
This analysis adapted the code provided in the [quickstart](https://github.com/noaa-ocs-hydrography/BlueTopo?tab=readme-ov-file#quickstart) to obtain the BlueTopo tiles for only the US Caribbean.

#### GMRT
[Global multi-resolution topography (GMRT)](Global Multi-Resolution Topography (GMRT)) can provided coverage for areas that do not exist by BlueTopo bathymetry. These data can get accessed through a [toolkit](https://www.gmrt.org/GMRTMapTool/) and also through [web services](https://www.gmrt.org/services/index.php). This analysis relied on the web-services to automatically generate the data based on coordinates and other criterias; this is possible by constructing the URL for downloading the data. To learn more about how to construct an URL for data download, one option is [here](https://www.gmrt.org/services/gridserverinfo.php#!/services/getGMRTGrid).

### 3. Bathymetry combination
#### BlueTopo
BlueTopo gets delineated into three different resolutions: 4m, 8m, and 16m. Due to the geographic orientation of the US Caribbean, it straddles two different UTM zones (19N and 20N). When these data
get obtained through the Python bluetopo package, they arrive as tiles for the UTM zones within they exist.
After BlueTopo Tiles get combined for each UTM zone in R, they get combined in ArcGIS Pro to reduce artifacts and errors that R produces.

1.) Mosaic to New Raster (UTM19N + UTM20N, output coordinate reference system = WGS84)

#### GMRT
ArcGIS tool new mosaic to raster that combines the GMRT data and the 16m resolution data to form a complete raster. The resolution output was the same as the x-cell size (5.49372231074078E-04). When values overlap, the first raster got elected for filling in the value (the 16m-resolution combined raster formed by BlueTopo tiles). Given that the These data got masked to only the EEZ

1. [Mosaic to New Raster](https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/mosaic-to-new-raster.htm) (BlueTopo combined + GMRT, GMRT for cell size, BlueTopo for overlapping values)
2. [Set Null](https://pro.arcgis.com/en/pro-app/latest/tool-reference/spatial-analyst/set-null.htm) (values greater than or equal to 0 get NULL value)
3. [Extract by Mask](https://pro.arcgis.com/en/pro-app/latest/tool-reference/spatial-analyst/extract-by-mask.htm) (full EEZ acts as mask)

#### Notes
There remain some artefacts due to how the BlueTopo data got created and combined. There exist slits of no data between a few tiles.

#### Contacts
For questions concerning the creation of these data, contact [Brian Free](mailto:brian.free@gmail.com).
[Tashi Geleg](mailto:phuntsok.geleg@noaa.gov) can assist with any questions about how to access, download, and generally interact with BlueTopo data.
