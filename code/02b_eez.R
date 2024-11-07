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

## coordinate reference system
### set the coordinate reference system that data should become (NAD83 UTM 19N: https://epsg.io/26919)
crs <- "EPSG:26919"

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
data_dir <- "data/a_exploratory_data/FederalStateWaters/FederalAndStateWaters.gdb"

output_gpkg <- "data/a_exploratory_data/eez.gpkg"

#####################################
#####################################

# inspect layers within geodatabase
sf::st_layers(dsn = data_dir)

#####################################
#####################################

# parameters
## country iso3 code
iso3 <- c("PRI", "VIR")

#####################################
#####################################

data <- sf::st_read(dsn = data_dir)

#####################################
#####################################

pri_vir <- data %>%
  # get the waters around Puerto Rico and U.S. Virgin Islands
  dplyr::filter(grepl(pattern = 'Puerto | Virgin Islands',
                      x = Jurisdicti))

## EEZ waters
eez <- pri_vir %>%
  # get the federal waters
  dplyr::filter(grepl(pattern = 'Federal',
                      x = Jurisdicti)) %>%
  # change to polygon so all EEZs are available
  sf::st_cast(to = "POLYGON") %>%
  # get the areas where federal waters (EEZ) touch the waters around Puerto Rico and U.S. Virgin Islands
  dplyr::filter(lengths(sf::st_touches(x = .,
                                       # lengths > 0 will return polygons touching the coastal waters
                                       y = pri_vir)) > 0)

plot(eez$Shape)

carib_waters <- rbind(pri_vir,
                      eez) %>%
  # dissolve to have single boundary
  rmapshaper::ms_dissolve()

plot(carib_waters$Shape)

#####################################
#####################################

# export data
sf::st_write(obj = carib_waters, dsn = output_gpkg, layer = "eez_pri_vir", append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
