####################
### 04. EEZ data ###
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

## resolution
res <- 16

## UTM zone
zone1 <- 19
zone2 <- 20

## coordinate reference system
### 
crs <- "ESRI:102761"
crs2 <- "EPSG:4326"

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
raster_dir <- "data/e_output_data"

#####################################
#####################################

raster1 <- terra::rast(x = file.path(raster_dir, stringr::str_glue("{region_name}_{res}m_utm{zone1}n.grd"))) %>%
  terra::project(x = .,
                 y = crs)

raster2 <- terra::rast(x = file.path(raster_dir, stringr::str_glue("{region_name}_{res}m_utm{zone2}n.grd"))) %>%
  terra::project(x = .,
                 y = crs)

res(raster1)
res(raster2)

plot(raster1)
plot(raster2)

#####################################
#####################################

# vrt <- terra::vrt(x = c(raster1, raster2),
#                   filename = "carib.vrt",
#                   overwrite = TRUE)

full_raster <- terra::mosaic(x = raster1,
                             y = raster2) %>%
  terra::project(x = .,
                 y = crs2)

res(full_raster)
plot(full_raster)

#####################################
#####################################

# export data
terra::writeRaster(x = full_raster, file = file.path(raster_dir, stringr::str_glue("{region_name}_{res}m_full.grd")), overwrite = T)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
