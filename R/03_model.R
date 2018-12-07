# Copyright 2018 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

## script for using spatial stream network to model stream temperature
## according to the NorWest template (https://www.fs.fed.us/rm/boise/AWAE/projects/NorWeST.html)

library(SSN) # stream network modelling
library(sf) # shapefile processing
library(ggplot2)
library(bcmaps)
library(RColorBrewer)
library(rmapshaper)

## modelling prep ####
## reading in each component for the Spatial Stream Network file
edges <- st_read("../data/Bowron_river/summer_18/ssn/edges.shp")
sites <- st_read("../data/Bowron_river/summer_18/ssn/sites.shp") # original sites
sites18 <- st_read("../data/Bowron_river/summer_18/ssn/Bowron_Air_Water_join.shp") #18 sites
preds <- st_read("../data/Bowron_river/summer_18/ssn/Preds1.shp")
edge <- ms_simplify(edges[1], 0.05) # simplifying only for the viz


## SSN modelling ####
## reading in 2018 bowron watershed Spatial Stream Network files
## preds contains ClimateBC predictions august mean, mean monthly and annual precip
importSSN("../data/Bowron_river/summer_18/ssn/")
