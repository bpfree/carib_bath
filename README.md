# Caribbean Bathymetry
Bathymetry creation for the US Caribbean Exclusive Economic Zones (Puerto Rico and United States Virgin Islands). These data were built from 
NOAA's BlueTopo and the Global multi-resolution topography datasets.

## Methods
### 1. Software
This analysis relied on the combination of R and ArcGIS Pro for the data acquisition and transformation. ArcGIS Pro 3.3.1 provided the best methods to combine the bathymetry data to reduce artefacts and errors.
Below details the system and packages relied upon for the R portions of the analysis.

```
R version 4.4.0 (2024-04-24)
Platform: aarch64-apple-darwin20
Running under: macOS 15.1.1

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: America/New_York
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] tidyr_1.3.1      terra_1.7-78     targets_1.8.0    stringr_1.5.1    sp_2.1-4         rmapshaper_0.5.0 purrr_1.0.2      plyr_1.8.9      
 [9] nngeo_0.4.8      sf_1.0-19        mregions2_1.1.1  janitor_2.2.0    ggplot2_3.5.1    dplyr_1.1.4      devtools_2.4.5   usethis_3.0.0   
[17] renv_1.0.11      pacman_0.5.1    

loaded via a namespace (and not attached):
 [1] tidyselect_1.2.1   fastmap_1.2.0      promises_1.3.0     digest_0.6.37      base64url_1.4      timechange_0.3.0   mime_0.12         
 [8] lifecycle_1.0.4    secretbase_1.0.3   ellipsis_0.3.2     processx_3.8.4     magrittr_2.0.3     compiler_4.4.0     rlang_1.1.4       
[15] tools_4.4.0        yaml_2.3.10        igraph_2.1.1       utf8_1.2.4         data.table_1.16.2  knitr_1.49         htmlwidgets_1.6.4 
[22] pkgbuild_1.4.5     classInt_0.4-10    curl_6.0.0         pkgload_1.4.0      KernSmooth_2.23-24 miniUI_0.1.1.1     withr_3.0.2       
[29] grid_4.4.0         fansi_1.0.6        urlchecker_1.0.1   profvis_0.4.0      xtable_1.8-4       e1071_1.7-16       colorspace_2.1-1  
[36] scales_1.3.0       cli_3.6.3          generics_0.1.3     remotes_2.5.0      rstudioapi_0.17.1  sessioninfo_1.2.2  DBI_1.2.3         
[43] cachem_1.1.0       proxy_0.4-27       vctrs_0.6.5        V8_6.0.0           jsonlite_1.8.9     callr_3.7.6        units_0.8-5       
[50] glue_1.8.0         codetools_0.2-20   ps_1.8.1           lubridate_1.9.3    stringi_1.8.4      gtable_0.3.6       later_1.3.2       
[57] munsell_0.5.1      tibble_3.2.1       pillar_1.9.0       htmltools_0.5.8.1  R6_2.5.1           shiny_1.9.1        evaluate_1.0.1    
[64] lattice_0.22-6     backports_1.5.0    memoise_2.0.1      snakecase_0.11.1   httpuv_1.6.15      class_7.3-22       Rcpp_1.0.13-1     
[71] xfun_0.49          fs_1.6.5           pkgconfig_2.0.3   
```

### 2. Coordinate reference system
After discussions on which coordinate reference system to procede, it was chosen that WGS84 (EPSG:4326) would minimize any area differences across the US Caribbean EEZ. BlueTopo data come in both the UTM19N and UTM20N zones, while the GMRT data are in WGS84.

### 3. Data sources
#### EEZ
Exclusive economic zone data came from [here](https://marinecadastre.gov/downloads/data/mc/FederalStateWaters.zip) and cover all state and federal waters (for [metadata](https://www.fisheries.noaa.gov/inport/item/54383)). The Coastal Management Act [data](https://hub.marinecadastre.gov/datasets/noaa::coastal-zone-management-act/about) are similar and do fill in small holes that exist for smaller islands.
NOAA's OCS also [provide data](https://nauticalcharts.noaa.gov/data/us-maritime-limits-and-boundaries.html) for [EEZ boundaries](https://maritimeboundaries.noaa.gov/downloads/USMaritimeLimitsAndBoundariesSHP.zip). These exist as polylines, so are less ideal for the current work.

The United States Caribbean EEZ are comprised of those for Puerto Rico and US Virgin Islands. Within R, these two EEZ polygons got combined, flattened, and all holes (areas islands reside) removed to ensure the EEZ covered all required areas.

#### BlueTopo
[BlueTopo](https://nauticalcharts.noaa.gov/data/bluetopo.html) are products by NOAA's Office of Coast Survey that provide consistent bathymetry coverage for the waters across the United States. For understanding naming conventions and other specifications in regards to the data, please visit [this page](https://nauticalcharts.noaa.gov/data/bluetopo_specs.html).
A helpful way to visually inspect the data is at this [map viewer](https://nowcoast.noaa.gov/). To install the Python package and begin working with the BlueTopo tiles, follow OCS Hydrography [GitHub repository](https://github.com/noaa-ocs-hydrography/BlueTopo) for BlueTopo. For it to work, check the [necessary requirements](https://github.com/noaa-ocs-hydrography/BlueTopo#requirements) and follow these [installation instructions](https://github.com/noaa-ocs-hydrography/BlueTopo#installation).
This analysis adapted the code provided in the [quickstart](https://github.com/noaa-ocs-hydrography/BlueTopo?tab=readme-ov-file#quickstart) to obtain the BlueTopo tiles for only the US Caribbean.

#### GMRT
[Global multi-resolution topography (GMRT)](https://www.gmrt.org/) can provided coverage for areas that do not exist by BlueTopo bathymetry. These data can get accessed through a [toolkit](https://www.gmrt.org/GMRTMapTool/) and also through [web services](https://www.gmrt.org/services/index.php). This analysis relied on the web-services to automatically generate the data based on coordinates and other criteria; this is possible by constructing the URL for downloading the data. To learn more about how to construct an URL for data download, one option is [here](https://www.gmrt.org/services/gridserverinfo.php#!/services/getGMRTGrid).

### 4. Bathymetry combination
#### BlueTopo
BlueTopo data existed at three different resolutions: 4m, 8m, and 16m. When the BlueTopo data got obtained through the Python bluetopo 
package, they arrived as tiles for the UTM zones within they exist. A tessellation grid provided guidance on which tiles corresponded 
to a particular resolution. Due to the geographic orientation of the US Caribbean, it straddles two different UTM zones (19N and 20N).

When combining the 4m with the 8m resolutions, the 4m had to get aggregated to match the same resolution. By aggregating by a factor of 2
(4 x 2), the 4m resolution dataset got rearranged to have a new resolution of 8m. A similar process got undertaken to have the 4m and 8m 
resolutions to match the 16m to form the complete BlueTopo coverage.

After BlueTopo Tiles got combined for each UTM zone in R, they get combined in ArcGIS Pro to reduce artifacts and errors that R produces.

1.) [Mosaic to New Raster](https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/mosaic-to-new-raster.htm) (UTM19N + UTM20N, output coordinate reference system = WGS84)

#### GMRT
After downloading the GMRT data with a particular area of interest, it had to get combined with the 16m-resolution BlueTopo data. These two rasters got 
transformed into a complete coverage of the eez by relying on BlueTopo data when both datasets provide data and GMRT data for all other locations. To 
accomplish this, the first raster got elected for filling in the value (the 16m-resolution combined raster formed by BlueTopo tiles). The resolution 
output was the same as the x-cell size (5.49372231074078E-04) of GMRT data since it has the less fine resolution. While BlueTopo focuses on bathymetry,
GMRT coverages topography as well. Any positive values (elevation above water line) got set to NULL. The EEZ then acted as a mask to limit only bathymetry
data to the US Caribbean EEZ.

1. [Mosaic to New Raster](https://pro.arcgis.com/en/pro-app/latest/tool-reference/data-management/mosaic-to-new-raster.htm) (BlueTopo combined + GMRT, GMRT for cell size, BlueTopo for overlapping values)
2. [Set Null](https://pro.arcgis.com/en/pro-app/latest/tool-reference/spatial-analyst/set-null.htm) (values greater than or equal to 0 get NULL value)
3. [Extract by Mask](https://pro.arcgis.com/en/pro-app/latest/tool-reference/spatial-analyst/extract-by-mask.htm) (full EEZ acts as mask)

### 5. Notes
There remain some artefacts due to how the BlueTopo data originally got created and combined. There exist slits of no data between a few tiles. With more time and computing, it is possible to fill in those gaps with extrapolation methods.

### 6. Contacts
- NOAA Caribbean leader: [Laughlin Siceloff](mailto:laughlin.siceloff@noaa.gov)
- Offshore Wind (Caribbean) liaison: [Jennifer Au](mailto:jennifer.au@noaa.gov)
- Data analysts: [Matthew Poti](mailto:matthew.poti@noaa.gov) and [Steven Lombardo](mailto:steven.lombardo@noaa.gov)

For questions concerning the creation of these data and code, contact [Brian Free](mailto:brian.free@gmail.com).

[Tashi Geleg](mailto:phuntsok.geleg@noaa.gov) can assist with any questions about how to access, download, and generally interact with BlueTopo data.
