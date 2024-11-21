#########################
### 03. BlueTopo data ###
#########################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# set parameters
## designate region name
region_name <- "carib"

## UTM
utm <- "20"

## designate date
date <- format(Sys.Date(), "%Y%m%d")

#####################################
#####################################

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(renv,
               devtools,
               dplyr,
               ggplot2,
               janitor,
               mregions2,
               nngeo,
               plyr,
               purrr,
               rmapshaper,
               sf,
               sp,
               stringr,
               targets,
               terra, # is replacing the raster package
               tidyr)

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
utm_dir <- stringr::str_glue("data/a_exploratory_data/BlueTopo/UTM{utm}")

eez_dir <- "data/a_exploratory_data/eez.gpkg"

tiles_dir <- "data/a_exploratory_data/BlueTopo/Tessellation/BlueTopo_Tile_Scheme_20241106_085436.gpkg"

output_dir <- "data/b_source_data"
raster_dir <- "data/e_output_data"

#####################################
#####################################

# inspect layers within geodatabase
sf::st_layers(dsn = eez_dir)

#####################################
#####################################

data <- sf::st_read(dsn = tiles_dir,
                    layer = sf::st_layers(dsn = tiles_dir)[1][[grep(pattern = "BlueTopo",
                                                                    x = sf::st_layers(dsn = tiles_dir)[[1]])]])

boundary <- sf::st_read(dsn = eez_dir,
                        layer = sf::st_layers(dsn = eez_dir)[1][[grep(pattern = "eez",
                                                                      x = sf::st_layers(dsn = eez_dir)[[1]])]]) %>%
  sf::st_transform(x = .,
                   crs = crs(data))

caribbean_tiles <- data[boundary,]

#####################################
#####################################

merge_function <- function(resolution, dir, utm_zone, tile_code){
  
  code <- tile_code
  
  #####################################
  
  res <- caribbean_tiles %>%
    dplyr::filter(Resolution == resolution,
                  UTM == utm)
  
  res_list <- as.vector(res$tile)
  
  #####################################
  
  tile <- list.files(path = dir,
                     pattern = stringr::str_glue("BlueTopo_{code}.*\\.tiff$"))
  
  tiles <- file.path(dir, tile)
  
  #####################################
  
  rasters <- lapply(tiles, terra::rast)
  
  #####################################
  
  merge <- do.call(what = terra::merge,
                   args = rasters)
  
  bathymetry <- merge$Elevation
  
  #####################################
  
  # export data
  terra::writeRaster(x = bathymetry, file = file.path(raster_dir, stringr::str_glue("{region_name}_{resolution}_utm{utm}n.grd")), overwrite = T)
  
  return(bathymetry)
}

res4 <- merge_function(resolution = "4m", dir = utm_dir, utm_zone = utm, tile_code = "BH")
res8 <- merge_function(resolution = "8m", dir = utm_dir, utm_zone = utm, tile_code = "BF")
res16 <- merge_function(resolution = "16m", dir = utm_dir, utm_zone = utm, tile_code = "BC")

plot(res4)
plot(res8)
plot(res16)

#####################################
#####################################

# aggregate data
## 8m
### aggregate the 4m resolution to match 8m resolution
res4_agg8 <- terra::aggregate(x = res4,
                              # factor
                              fact = 2)
res(res4_agg8)
plot(res4_agg8)

### mosaic aggregated 4m and regular 8m resolution data
res8_agg <- terra::mosaic(x = res4_agg8,
                          # 8m resolution data
                          y = res8)

plot(res8_agg)

#####################################

## 16m
### aggregate the 4m resolution data
res4_agg16 <- terra::aggregate(x = res4,
                               # factor
                               fact = 4)
res(res4_agg16)
plot(res4_agg16)

### aggregate the 8m resolution data
res8_agg16 <- terra::aggregate(x = res8,
                               # factor
                               fact = 2)
res(res8_agg16)
plot(res8_agg16)

# mosaic the aggregated 4m and aggregated 8m data
res48_agg16 <- terra::mosaic(x = res4_agg16,
                             # aggregated 8m tiles
                             y = res8_agg16)
res(res48_agg16)
plot(res48_agg16)

# mosaic the aggregated 4m and aggregated 8m data with the 16m data
res16_agg <- terra::mosaic(x = res48_agg16,
                           # normal 16m data
                           y = res16)
res(res16_agg)
plot(res16_agg)

#####################################
#####################################

# export data
## aggregated data
## 8m
terra::writeRaster(x = res4_agg8, file = file.path(raster_dir, stringr::str_glue("{region_name}_4m_agg8_utm{utm}n.grd")), overwrite = T)
terra::writeRaster(x = res8_agg, file = file.path(raster_dir, stringr::str_glue("{region_name}_8m_utm{utm}n.grd")), overwrite = T)

## 16m
terra::writeRaster(x = res4_agg16, file = file.path(raster_dir, stringr::str_glue("{region_name}_4m_agg16_utm{utm}n.grd")), overwrite = T)
terra::writeRaster(x = res8_agg16, file = file.path(raster_dir, stringr::str_glue("{region_name}_8m_agg16_utm{utm}n.grd")), overwrite = T)
terra::writeRaster(x = res48_agg16, file = file.path(raster_dir, stringr::str_glue("{region_name}_48m_agg16_utm{utm}n.grd")), overwrite = T)

terra::writeRaster(x = res16_agg, file = file.path(raster_dir, stringr::str_glue("{region_name}_16m_utm{utm}n.grd")), overwrite = T)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
