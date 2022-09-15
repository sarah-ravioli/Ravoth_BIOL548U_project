#### BIOL548U SESSION 3
#### BY: SARAH RAVOTH
#### DATE: 2022-SEP-13

########################### PURPOSE ########################### 
# task 1: Convert all dates and geographic coordinates to ISO standards

########################### LOAD PACKAGES ########################### 
library(lubridate) # for dates
library(rgdal) # for coordinates
library(tidyverse) # for general tidying
library(raster) # for coordinates


########################### LOAD DATA ########################### 
getwd() # check
setwd("/Users/sarahravoth/Desktop/biol548U/Ravoth_BIOL548U_project/data") # reset 

# import all tables as separate data frames
abundance <- read.csv("bwgv1_abundance.csv", header=T)
bromeliads <- read.csv("bwgv1_bromeliads.csv", header=T)
datasets <- read.csv("bwgv1_datasets.csv", header=T)
owners <- read.csv("bwgv1_owners.csv", header=T)
ownership <- read.csv("bwgv1_ownership.csv", header=T)
traits <- read.csv("bwgv1_traits.csv", header=T)
visits <- read.csv("bwgv1_visits.csv", header=T)



########################### OVERVIEW OF DATA ########################### 
# iso standard time: YYYY-MM-DD
# iso standard coordinates: decimal degrees, N & E positive, lat before long
# i'm loading the first 6 rows of all the BWG datasets to see which have date/coordinate data
sapply(list(abundance, bromeliads, datasets, owners, ownership, traits, visits), head, n = 6)

# [1] abundance--NA
# [2] bromeliads--date (collection_date), coordinate (utme, utmn)
# [3] datasets--date (bwg_release, public_release), coordinate (lat, lng)
# [4] owners--NA
# [5] ownership--NA
# [6] traits--NA
# [7] visits--date (date, latitude, longitude)


########################### TIDYING "bromeliads" DATA ########################### 
## FIX DATE
str(bromeliads) # collection date is character--convert to date class to make it easier to work with & make calculations
bromeliads$collection_date # otherwise, the format meets ISO standard (YYYY-MM-DD)
bromeliads$collection_date <- ymd(bromeliads$collection_date) # convert character to date class
class(bromeliads$collection_date) # check--successful

## FIX COORDS
bromeliads$utme # check
bromeliads$utmn # check
bromeliads %>%  # check
  filter(!is.na(utme) & !is.na(utmn)) # everything is NA

# can't convert from UTM to lat/long since it's all NA, which isn't accepted, BUT
# if i was going to, i'd convert to raster, use following functions to convert, and leave as raster 
# or convert back from raster to dataframe (see below)
coordinates(bromeliads) <- ~utme + utmn # sets these cols as the coords
proj4string(bromeliads) <- CRS("+proj=longlat +datum=WGS84 +zone=16") # converts utm to lat/long & sets the correct crs
bromeliads <- rasterFromXYZ(bromeliads)
head(bromeliads) # check
str(bromeliads) # check

# alternatively, could just rename utmn & utme to lat & long, since it's arbitrary 
# if they're filled with NAs anyway
bromeliads <- bromeliads %>% 
  rename(latitude = utmn, longitude = utme)
colnames(bromeliads) # check



########################### TIDYING "datasets" DATA ########################### 
head(datasets)

## FIX DATE
datasets$bwg_release <- dmy(datasets$bwg_release)
datasets$public_release <- dmy(datasets$public_release)
head(datasets) # check

## FIX COORDS 
# technically these are fine, but i'm just going to rename them to latitude & longitude so consistant
# with the other lat/long variable names in the other bwg datasets 
datasets <- datasets %>% 
  rename(latitude = lat, longitude = lng)
colnames(datasets) # check


########################### TIDYING "visits" DATA ########################### 
head(visits)
str(visits)
# [7] visits--date (date, latitude, longitude)

## FIX DATE
# date is in correct format (YYYY-MM-DD), but is character not date class 
visits$date <- ymd(visits$date)
str(visits) # check

## FIX COORDS
visits$latitude
visits$longitude
# coords are fine, don't need to be tidied 



########################### EXPORT CLEANED FILES ########################### 
# i'll only be exporting files for data i cleaned--i.e., bromeliads, datasets, visits
getwd() # check
setwd("/Users/sarahravoth/Desktop/biol548U/Ravoth_BIOL548U_project/data") # reset 
write.csv(bromeliads, file="bromeliads_tidied_week2assignment.csv")
write.csv(datasets, file="datasets_tidied_week2assignment.csv")
write.csv(visits, file="visits_tidied_week2assignment.csv")



################################ THE END :) ################################ 