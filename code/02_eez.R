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

# Run once devtools is successfully installed
devtools::install_github("cfree14/marineregions", force=T)
library(marineregions)

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
data_dir <- "data/a_exploratory_data/eez.gpkg"

#####################################
#####################################

# parameters
## country iso3 code
iso3 <- c("PRI", "VIR")

#####################################
#####################################

eez_function <- function(territory){
  # search for the location of interest and get the geometry
  eez <- mregions2::gaz_search(x = territory) %>%
    # filter for only EEZ and ones that are not deleted (***note: the status of interest is standard)
    dplyr::filter(placeType == "EEZ" & status != "deleted") %>%
    # get the geometry for the EEZ
    mregions2::gaz_geometry()
}

#####################################
#####################################

eez <- mregions2::gaz_search_by_type("EEZ")

pri_eez <- mregions2::gaz_search(x = "(Puerto Rico)") %>%
  dplyr::filter(placeType %in% c("EEZ", "Overlapping claim") & status == "standard") %>%
  mregions2::gaz_geometry()

plot(pri_eez$the_geom)

vir_eez <- mregions2::gaz_search(x = "United States Virgin") %>%
  dplyr::filter(placeType == "EEZ" & status != "deleted") %>%
  mregions2::gaz_geometry() %>%
  dplyr::select(-precision)

plot(vir_eez$the_geom)

eez <- rbind(pri_eez,
               vir_eez)

plot(eez$the_geom)

#####################################
#####################################

data <- marineregions::eezs_lr

eez2 <- data %>%
  dplyr::filter(iso_ter1 %in% iso3)

plot(eez2$geometry)

#####################################
#####################################

# export data
sf::st_write(obj = eez, dsn = data_dir, layer = "eez_boundary", append = F)
sf::st_write(obj = eez2, dsn = data_dir, layer = "eez_pri_vir", append = F)

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate
