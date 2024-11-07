##############################
### 00. create directories ###
##############################

# renv::init()
# renv::update()
# renv::snapshot()

# create data directory
data_dir <- dir.create("data")

# designate subdirectories
data_subdirectories <- c("a_exploratory_data",
                         "b_source_data",
                         "c_input_data",
                         "d_model_data",
                         "e_output_data",
                         "zz_miscellaneous_data")

#####################################

# create sub-directories within data directory
for (i in 1:length(data_subdirectories)){
  subdirectories <- dir.create(paste0("data/", data_subdirectories[i]))
}

#####################################

# create code directory
code_dir <- dir.create("code")

#####################################

# create figure directory
figure_dir <- dir.create("figure")

#####################################
#####################################

# delete directory (if necessary)
### ***Note: change directory path for desired directory
#unlink("data/a_raw_data", recursive = T)