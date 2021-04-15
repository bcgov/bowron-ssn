![img](https://img.shields.io/badge/Lifecycle-Experimental-339999)

Bowron Watershed Stream Temperature Modelling
=============================================

R code to model summer stream temperature under different climate scenarios in the Bowron watershed in Northern British Columbia. Stream and air temperature records have been collected, along with site-specific variables such as tree cover, drainage area, and slope as model input. The code reads in the *spatial stream network* shapefile created from the [STARS](https://www.fs.fed.us/rm/boise/AWAE/projects/SSN_STARS/software_data.html) package. This repository contains the modelling component using the [ssn](https://cran.r-project.org/web/packages/SSN/index.html) package and [NorWeST](https://www.fs.fed.us/rm/boise/AWAE/projects/NorWeST.html) method.

### Study Site

Bowron watershed is in the Willow - Bowron sub-sub-drainage area in British Columbia shown below using the [bcmaps](https://github.com/bcgov/bcmaps) package:

``` r
drainage <- get_layer("wsc_drainages", class ="sf")
drainage_df <- subset(drainage, SUB_SUB_DRAINAGE_AREA_NAME == "Willow - Bowron")
plot(st_geometry(bc_bound()))
plot(drainage_df[1], col = "darkseagreen3", add = TRUE)
```

![](tools/readme/README-stream%20prep-1.png)

Sample map of the Bowron spatial stream network:

``` r
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
```

![](tools/readme/README-site%20viz-1.png)

### Project Status

This project is an active multi-year project. Each summer, new stream and air temperature records will be collected on the field and added to the model.

### Goals/Roadmap

The goal of this project is to use the modelled temperature records along with environmental and topographic variables to predict bull trout density in the Bowron watershed under various conditions and climate scenarios. We also experiment with R's geospatial capacities by conducting a series of geoprocessing and outputting resultant maps.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/bowron-ssn/issues/).

### How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

    Copyright 2018 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

------------------------------------------------------------------------

*This project was created using the [bcgovr](https://github.com/bcgov/bcgovr) package.*
