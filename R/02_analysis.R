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

h2o_df <- read_csv("../data/Bowron_river/summer_18/csv/h2o.csv")

h2o_df$date <- date(h2o_df$date)

## obtaining August mean water temperature for each site
h2o_df <- h2o_df %>%
  filter(month(date) == 8) %>%
  group_by(site) %>%
  summarise(stream_temp = mean(stream_temp, na.rm = TRUE))
