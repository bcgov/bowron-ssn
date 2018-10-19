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

library(tidyverse)
library(readxl)

## listing stream temperature files
h2o_dir <- dir("../data/Bowron_river/summer_18/", pattern = "H2O|H20|h2o|h20")

## listing air temperature files stored in files named with either air or rh (relative humidity)
air_dir <- as.list(dir("../data/Bowron_river/summer_18/", pattern = "air"))
rh_dir <- as.list(dir("../data/Bowron_river/summer_18/", pattern = "RH|rh|rH"))

## prefer air temperature recorded from rh sensors over air sensors
for (i in 1:length(air_dir)) {
  if (sub("_.*", "", air_dir[i]) %in% sub("_.*", "", rh_dir)) {
    print(air_dir[i])
    air_dir[i] <- NULL
  }
}

air_dir <- append(air_dir, rh_dir)

## creating empty tibbles to later row bind with newly added files
h2o_df <- tibble(site = character(),
                 date = as.POSIXct(character()),
                 stream_temp = numeric())
air_df <- tibble(site = character(),
                 date = as.POSIXct(character()),
                 air_temp = numeric())

## adding in all stream temperature files using readxl package
for (i in 1:length(h2o_dir)) {
  h2o <- read_xlsx(paste0("../data/Bowron_river/summer_18/", h2o_dir[i]), sheet = 1, skip = 1)
  ## extracting site name (everything before the "_" in file name)
  site_name <- sub("_.*", "", h2o_dir[i])
  h2o <- select(h2o, grep("Date|date", colnames(h2o)), grep("Temp,", colnames(h2o))) %>%
    mutate(site = site_name)
  colnames(h2o)[1:2] <- c("date", "stream_temp")
  h2o_df <- bind_rows(h2o_df, h2o)
}

## adding in air temperature files
for (i in 1:length(air_dir)) {
  air <- read_xlsx(paste0("../data/Bowron_river/summer_18/", air_dir[i]), sheet = 1, skip = 1)
  site_name <- sub("_.*", "", air_dir[i])
  air <- select(air, grep("Date|date", colnames(air)), grep("Temp,", colnames(air))) %>%
    mutate(site = site_name)
  colnames(air)[1:2] <- c("date", "air_temp")
  print(head(air))
  air_df <- bind_rows(air_df, air)
}

write_csv(h2o_df, "../data/Bowron_river/summer_18/csv/h2o.csv")
write_csv(air_df, "../data/Bowron_river/summer_18/csv/air.csv")
