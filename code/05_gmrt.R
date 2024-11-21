#####################
### 05. GMRT data ###
#####################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# set parameters
## designate region name
region_name <- "carib"

## CRS
crs <- "EPSG:4326"

## res
res = 16

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
data_dir <- "data/a_exploratory_data"

eez_dir <- "data/a_exploratory_data/eez.gpkg"

raster_dir <- "data/e_output_data"

#####################################
#####################################

# inspect layers within geodatabase
sf::st_layers(dsn = eez_dir)

#####################################
#####################################

data <- terra::rast(x = "data/a_exploratory_data/gmrt_v4.tif") %>%
  terra::ifel(test = . > 0, yes = NA, no = .)

bluetopo <- terra::rast(x = file.path(raster_dir, stringr::str_glue("{region_name}_{res}m_ful/w001001.adf"))) + 100000

plot(bluetopo)

boundary <- sf::st_read(dsn = eez_dir,
                        layer = sf::st_layers(dsn = eez_dir)[1][[grep(pattern = "eez",
                                                                      x = sf::st_layers(dsn = eez_dir)[[1]])]]) %>%
  sf::st_transform(x = .,
                   crs = crs)

#####################################
#####################################

carib_gmrt <- data %>%
  terra::crop(x = .,
              y = boundary,
              mask = T)

plot(carib_gmrt)

carib_gmrt_mask <- terra::mask(x = carib_gmrt,
                               mask = bluetopo,
                               inverse = T)

#####################################
#####################################



# export data

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
