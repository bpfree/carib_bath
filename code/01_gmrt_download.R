#########################
### 01. download data ###
#########################

# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# define the boundaries of the study box
minlongitude <- -68.5804 # westernmost longitude
maxlongitude <- -63.1751 # easternmost longitude

minlatitude <- 14.7101 # southernmost latitude
maxlatitude <- 22.0643 # northernmost latitude

# select the format for the data
## netcdf
## coards
## esriascii
## geotiff
format <- "netcdf"

# selection the resolution
## default (low/default)
## med (medium)
## high (high)
## max (maximum)
resolution <- "max"

# layer
## topo -- Gridded data with GEBCO 2014 filled in
## non-topo -- Gridded data with NaN elsewhere
layer <- "topo"

#####################################
#####################################

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(renv,
               dplyr,
               ggplot2,
               janitor,
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

# Create function that will pull data from publicly available websites
## This allows for the analyis to have the most current data; for some
## of the datasets are updated with periodical frequency (e.g., every 
## month) or when needed. Additionally, this keeps consistency with
## naming of files and datasets.
### The function downloads the desired data from the URL provided and
### then unzips the data for use

data_download_function <- function(download_list, data_dir){
  
  # designate the URL that the data are hosted on
  url <- download_list
  
  # file will become last part of the URL, so will be the data for download
  file <- basename(url)
  
  # Download the data
  if (!file.exists(file)) {
    options(timeout=1000000)
    # download the file from the URL
    download.file(url = url,
                  # place the downloaded file in the data directory
                  destfile = file.path(data_dir, file),
                  mode="wb")
  }
  
  # Unzip the file if the data are compressed as .zip
  ## Examine if the filename contains the pattern ".zip"
  ### grepl returns a logic statement when pattern ".zip" is met in the file
  if (grepl(".zip", file)){
    
    # grab text before ".zip" and keep only text before that
    new_dir_name <- sub(".zip", "", file)
    
    # create new directory for data
    new_dir <- file.path(data_dir, new_dir_name)
    
    # unzip the file
    unzip(zipfile = file.path(data_dir, file),
          # export file to the new data directory
          exdir = new_dir)
    # remove original zipped file
    file.remove(file.path(data_dir, file))
  }
}

#####################################
#####################################

# set directories
## define data directory (as this is an R Project, pathnames are simplified)
data_dir <- "data/a_exploratory_data"

#####################################
#####################################

# Download list
download_list <- c(
  
  # GMRT Map tool: https://www.gmrt.org/GMRTMapTool/
  ## Webservices: https://www.gmrt.org/services/index.php
  ### URL builder: https://www.gmrt.org/services/gridserverinfo.php#!/services/getGMRTGrid
  
  stringr::str_glue("https://www.gmrt.org:443/services/GridServer?minlongitude={-68.5804}&maxlongitude={-63.1751}&minlatitude={14.7101}&maxlatitude={22.0643}&format={format}&resolution={resolution}&layer={layer}")
)

#####################################
#####################################

#####################################
#####################################

parallel::detectCores()

cl <- parallel::makeCluster(spec = parallel::detectCores(), # number of clusters wanting to create
                            type = 'PSOCK')

work <- parallel::parLapply(cl = cl, X = download_list, fun = data_download_function, data_dir = data_dir)

parallel::stopCluster(cl = cl)

#####################################
#####################################

# list all files in data directory
list.files(data_dir)

file <- list.files(data_dir, pattern = "GridServer")

file.rename(from = file.path(data_dir, file),
            # and move to the new bathymetry subdirectory
            to = file.path(data_dir, "gmrt_v4.grd"))

#####################################
#####################################

# calculate end time and print time difference
print(Sys.time() - start) # print how long it takes to calculate

