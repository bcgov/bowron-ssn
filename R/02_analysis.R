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

library(lubridate)

## reading in stream temperature files containing all sites output from 01_load.R
## and three historical stream temperature sites
h2o_df <- read_csv("../data/Bowron_river/summer_18/csv/h2o.csv")
air_df <- read_csv("../data/Bowron_river/summer_18/csv/air.csv")
his_df <- read_csv("C:/Users/yuwang/Projects/data/Bowron_river/data/John/all.csv")

## reading in table containing site coordinates
df_ref <- read_csv("../data/Bowron_river/summer_18/csv/Site_Details.csv") %>%
  select(site, Latitude, Longitude, "Altitude (m)") %>%
  rename("Elevation" = "Altitude (m)")

df_ref$Latitude <- as.double(df_ref$Latitude)
df_ref$Longitude <- as.double(df_ref$Longitude)

## obtaining August mean water and air temperature for each site, retaining only
## complete days of measurements. Taispai taken out, Grizzly1 only daily summaries
h2o_df <- h2o_df %>%
  filter(month(date) != 7 & month(date) != 9) %>%
  group_by(site, date(date)) %>%
  add_tally() %>%  # adds total count of observations in a day
  filter(site == "Grizzly1" | n >= 96) %>%
  group_by(site) %>%
  dplyr::summarise(WTRTMP = mean(stream_temp, na.rm = TRUE))

## Haggen 2 taken out
air_df <- air_df %>%
  filter(month(date) != 7 & month(date) != 9 & month(date) != 10) %>%
  group_by(site, date(date)) %>%
  add_tally() %>%
  filter(n >= 96) %>%
  group_by(site) %>%
  dplyr::summarise(AirMEANc = mean(air_temp, na.rm = TRUE))

## adding site coordinates to stream temperature file
h2o_df <- right_join(df_ref, h2o_df, by = "site")

## joining air and water temp dataframes
df <- left_join(h2o_df, air_df, by = "site")

df <- full_join(df, his_df)

## outputting df
write_csv(df, "../data/Bowron_river/summer_18/csv/temp_summary.csv")
