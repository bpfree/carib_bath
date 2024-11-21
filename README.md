# carib_bath
Bathymetry creation for the US Caribbean

# Coordinate reference system
https://epsg.io/32161 (NAD83 / Puerto Rico & Virgin Is.)
https://spatialreference.org/ref/esri/102761/
https://pro.arcgis.com/en/pro-app/3.1/help/mapping/properties/pdf/projected_coordinate_systems.pdf

https://www.gmrt.org/GMRTMapTool/

# Methods
## Software
R 4.4.0 (terra 1.7-78, sf 1.0-19, dplyr 1.1.4)
ArcGIS Pro 3.3.1

## BlueTopo Tiles
After BlueTopo Tiles get combined for each UTM zone in R, they get combined in ArcGIS Pro to reduce artifacts and errors that R produces.

1.) Mosaic to New Raster (UTM19N + UTM20N, coordinate reference system = WGS84)

## GMRT

ArcGIS tool new mosaic to raster that combines the GMRT data and the 16m resolution data to form a complete raster. The resolution output was the same as the x-cell size (5.49372231074078E-04). When values overlap, the first raster got elected for filling in the value (the 16m-resolution combined raster formed by BlueTopo tiles). Given that the These data got masked to only the EEZ

1. Mosaic to New Raster (BlueTopo combined + GMRT, GMRT for cell size, BlueTopo for overlapping values)
2. Set Null (values greater than or equal to 0 get NULL value)
3. Extract by Mask (full EEZ acts as mask)
