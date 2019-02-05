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
# edges <- st_read("../data/Bowron_river/summer_18/ssn/edges.shp")
sites18 <- st_read("../data/Bowron_river/summer_18/ssn/Bowron_Air_Water_join.shp")
preds <- st_read("../data/Bowron_river/summer_18/ssn/preds.shp")
# edge <- ms_simplify(edges[1], 0.05) # simplifying only for the viz

## plotting the study sites in the watershed
ws <- wsc_drainages()

ggplot() +
  geom_sf(data = ws[ws$SUB_SUB_DRAINAGE_AREA_NAME %in% "Willow - Bowron", ],
          aes(fill = "Willow - Bowron")) +
  geom_sf(data = edge, aes(colour = "Stream Network"), show.legend = "line") +
  geom_sf(data = sites[1], aes(colour = "Observations"), show.legend = "point") +
  scale_colour_manual(values = c("Observations" = "gold", "Stream Network" = "black"), name = NULL,
                      guide = guide_legend(override.aes = list(linetype = c("blank", "solid"), shape = c(16, NA)))) +
  scale_fill_manual(values = c("Willow - Bowron" = "darkseagreen3"), name = NULL,
                    guide = guide_legend(override.aes = list(linetype = "blank", shape = NA))) +
  theme_void() +
  theme(panel.grid = element_line(colour = 'transparent'))

## SSN modelling ####
## reading in 2018/future prediction bowron watershed Spatial Stream Network files
## preds contains ClimateBC predictions august mean, mean monthly and annual precip
ssn <- importSSN("../data/Bowron_river/summer_18/ssn/", predpts = "preds")
ssn <- importSSN("../data/Bowron_river/summer_18/ssn/", predpts = "preds25")
ssn <- importSSN("../data/Bowron_river/summer_18/ssn/", predpts = "preds55")

## creating distance matrix for generalised linear model
# createDistMat(ssn, "preds", o.write = TRUE)

## model 1, inflated standard error
glm1 <- glmssn(WTRTMP ~ AirMEANc + ELEV + SLOPE + CANOPY + ASPECT + h2oAreaKm2 + WB_AREA_PE + RS_Cross + RD_Density,
               ssn, CorModels = c("Exponential.tailup"), addfunccol = "afvArea")
summary(glm1)


glm2 <- glmssn(WTRTMP ~ AirMEANc + CANOPY + ASPECT + h2oAreaKm2, ssn,
               CorModels = c("Exponential.tailup"), addfunccol = "afvArea")
summary(glm2)

## adding autocorrelation models
glm3 <- glmssn(WTRTMP ~ AirMEANc + CANOPY + ASPECT + h2oAreaKm2, ssn,
               CorModels = c("Exponential.tailup", "Exponential.taildown", "Exponential.Euclid"), addfunccol = "afvArea")
summary(glm3)


pred1 <- predict(glm1, "preds")
plot(pred1)

pred1df <- getSSNdata.frame(pred1, "preds")
summary(pred1df$WTRTMP)

pred2 <- predict(glm2, "preds")
pred2df <- getSSNdata.frame(pred2, "preds")
summary(pred2df$WTRTMP)

pred3 <- predict(glm3, "preds")
pred3df <- getSSNdata.frame(pred3, "preds")
summary(pred3df$WTRTMP)

## change according to the summaries
pred1df$WTRTMP_cat <- cut(pred1df$WTRTMP, breaks = c(-Inf, 0, 10, 11, 12, 13, 14, 15, Inf),
                          labels = c("< 0", "0 - 10",  "10 - 11", "11 - 12", "12 - 13", "13 - 14", "14 - 15", "15 +"))
## make sure there's no NAs
summary(pred1df$WTRTMP_cat)

pred2df$WTRTMP_cat <- cut(pred2df$WTRTMP, breaks = c(8, 9, 10, 11, 12, 13, 14, 15, Inf),
                          labels = c("8 - 9", "9 - 10", "10 - 11", "11 - 12", "12 - 13", "13 - 14", "14 - 15", "15 +"))

pal <- rev(brewer.pal(8, "RdYlBu"))

pred3df$WTRTMP_cat <- cut(pred2df$WTRTMP, breaks = c(8, 9, 10, 11, 12, 13, 14, 15, Inf),
                          labels = c("8 - 9", "9 - 10", "10 - 11", "11 - 12", "12 - 13", "13 - 14", "14 - 15", "15 +"))




ggplot(pred1df, aes(LONGITUDE, LATITUDE, colour = WTRTMP_cat, size = WTRTMP.predSE)) +
  geom_point() +
  # scale_colour_viridis_d(option = "plasma") +
  scale_colour_manual(values = pal) +
  labs(size = "Std Error", colour = "Temperature\n(degree C)", title = "Predicted Stream Temperature for August, 2018 in Bowron Watershed") +
  # scale_color_manual(values = c("#2166ac","#92c5de", "#f4a582", "#d6604d", "#b2182b")) +
  theme_void() +
  theme(text = element_text(size = 15), title = element_text(size = 25))

ggsave("../bowron-18-model1.jpg", width = 40, height = 35, units = "cm")


ggplot(pred2df, aes(LONGITUDE, LATITUDE, colour = WTRTMP_cat, size = WTRTMP.predSE)) +
  geom_point() +
  scale_colour_manual(values = pal) +
  labs(size = "Std Error", colour = "Temperature\n(degree C)", title = "Predicted Stream Temperature for August, 2018 in Bowron Watershed") +
  theme_void() +
  theme(text = element_text(size = 15), title = element_text(size = 25))

ggsave("../bowron-18-model2.jpg", width = 40, height = 35, units = "cm")

ggplot(pred3df, aes(LONGITUDE, LATITUDE, colour = WTRTMP_cat, size = WTRTMP.predSE)) +
  geom_point() +
  scale_colour_manual(values = pal) +
  labs(size = "Std Error", colour = "Temperature\n(degree C)", title = "Predicted Stream Temperature for August, 2018 in Bowron Watershed") +
  theme_void() +
  theme(text = element_text(size = 15), title = element_text(size = 25))


## outputting prediction results
write.csv(pred1df, "../data/bowron_pred1.csv", row.names = FALSE)
write.csv(pred2df, "../data/bowron_pred2.csv", row.names = FALSE)
write.csv(pred3df, "../data/bowron_pred3.csv", row.names = FALSE)
