####################
### 02. EEZ data ###
####################

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
utm <- "19"

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
  
  res <- caribbean_tiles %>%
    dplyr::filter(Resolution == resolution,
                  UTM == utm)
  
  res_list <- as.vector(res$tile)
  
  tile <- list.files(path = dir,
                     pattern = stringr::str_glue("BlueTopo_{code}.*\\.tiff$"))
  
  tiles <- file.path(dir, tile)
  
  rasters <- lapply(tiles, terra::rast)
  
  merge <- do.call(what = terra::merge,
                   args = rasters)
  
  bathymetry <- merge$Elevation
  
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
res4_agg8 <- terra::aggregate(x = res4, fact = 2)
res(res4_agg)

res8_agg <- terra::merge(x = res4_agg,
                             y = res8)

## 16m
res4_agg16 <- terra::aggregate(x = res4, fact = 4)
res(res4_agg16)

res8_agg16 <- terra::aggregate(x = res8, fact = 2)
res(res8_agg16)

res8_agg <- terra::merge(x = res4_agg16,
                             y = res8_agg16)
res(res8_agg)

res16_agg <- terra::merge(x = res8_agg,
                              y = res16_20n)
res(res16_agg)
plot(res16_agg)

#####################################
#####################################

# export data
## raw data
terra::writeRaster(x = res4, file = file.path(raster_dir, stringr::str_glue("{region_name}_4m_utm{utm}n.grd")), overwrite = T)
terra::writeRaster(x = res8, file = file.path(raster_dir, stringr::str_glue("{region_name}_8m_utm{utm}n.grd")), overwrite = T)
terra::writeRaster(x = res16, file = file.path(raster_dir, stringr::str_glue("{region_name}_16m_utm{utm}n.grd")), overwrite = T)

## aggregated data
## 8m
terra::writeRaster(x = res4_agg8, file = file.path(raster_dir, stringr::str_glue("{region_name}_4m_agg8_utm{utm}n.grd")), overwrite = T)
terra::writeRaster(x = res8_agg, file = file.path(raster_dir, stringr::str_glue("{region_name}_8m_utm{utmn.grd")), overwrite = T)

## 16m
terra::writeRaster(x = res16_20n_agg, file = file.path(raster_dir, "caribbean_16m_utm19n.grd"), overwrite = T)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

