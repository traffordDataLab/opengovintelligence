
### Work<ness app

This web application has been developed by the [Trafford Data Lab](https://www.trafforddatalab.io/) as part of the European Union funded [OpenGovIntelligence](http://www.opengovintelligence.eu) project. It is the result of a co-creation exercise involving Trafford Council, the Greater Manchester Combined Authority and the Department for Work and Pensions to help reduce worklessness across the Greater Manchester region.

>The OpenGovIntelligence project aims to modernize Public Administration by connecting it to Civil Society through the innovative application of Linked Open Statistical Data (LOSD). We believe the publication of high quality public statistics can transform society, services and enterprises throughout Europe.

The application visualises data relating to worklessness in a variety of ways to help improve understanding of the scale and the extent of need.

### Structure of the app

#### Clusters

The cluster map visualises the spatial distribution of key indicators relating to worklessness using a technique called Local Indicators of Spatial Association [(Anselin, 1995)](http://onlinelibrary.wiley.com/doi/10.1111/j.1538-4632.1995.tb00338.x/abstract). The map shows Lower-layer Super Output Areas (LSOAs) which have 400 households or around 1,500 residents as statistically significant **spatial clusters** (High-High and Low-Low) or **spatial outliers** (Low-High and High-Low). An LSOA marked 'High-High' exhibits positive spatial autocorrelation because it has high values of x and is surrounded by areas with similarly high values. Conversely, an LSOA marked 'High-Low' indicates negative spatial autocorrelation because it records a high value of x and is surrounded by areas with low values.

By hovering over the LSOAs on the map, information such as the indicator value, electoral ward and deprivation data are displayed in the panel.

There are a number of other map options available. Hovering over the layer icon situated under the zoom control (+ - buttons) displays choices for the map backgrounds, such as road atlas and satellite views, as well as the locations of Jobcentre Plus sites, gambling premises, GP practices, food banks and probation offices which can be overlayed on the map.

#### Trends

This section allows users to compare time series data on the proportion of residents claiming JSA or Universal Credit at different geographic levels: electoral wards, local authorities and combined authority. The data can be displayed for single or multiple areas (check the multiple box), on single or separate charts (check the facet box). Simply begin typing into the box provided to add areas and choose them from the options provided.

The data selected are also displayed in a table below the charts. This table can be sorted by the various headings and also downloaded as a Comma Separated Values (CSV) file via the button provided.

#### Reachability

The reachability map allows users to determine the reachable area from a given location. Network distance or travel time by bike, car or foot are provided. The equal distance / travel time polygons are provided by [OpenRouteService](https://openrouteservice.org/). Users can download the generated polygons countours as a GeoJSON file which can be used in many Geographical Information Systems (GIS).

### Sources

The following datasets were used in the application:

- [Claimant count by sex and age](https://www.nomisweb.co.uk/datasets/ucjsa) (Latest available month, ONS)
- [LC5601EW - Highest level of qualification by economic activity](https://www.nomisweb.co.uk/census/2011/lc5601ew) (March 2011, Census 2011)
- [KS107EW - Lone parent households with dependent children](https://www.nomisweb.co.uk/census/2011/KS107EW) (March 2011, Census 2011)
- [Tenure - Social rented households](https://www.nomisweb.co.uk/census/2011/ks402ew) (March 2011, Census 2011)
- [Indices of Multiple Deprivation](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2015) (2015, MHCLG)

Spatial vector boundary layers were provided by the ONS' [Open Geography Portal](http://geoportal.statistics.gov.uk/).

### Credits
For more information about Local Indicators of Spatial Association see [Anselin (1995)](http://onlinelibrary.wiley.com/doi/10.1111/j.1538-4632.1995.tb00338.x/abstract)

### Developers

The app was developed using [Shiny](https://cran.r-project.org/web/packages/shiny/index.html) and the following [R](https://cran.r-project.org/) packages:

- [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html)
- [sf](https://cran.r-project.org/web/packages/sf/index.html) 
- [spdep](https://cran.r-project.org/web/packages/spdep/index.html) 
- [leaflet](https://cran.r-project.org/web/packages/leaflet/index.html)
- [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)
- [plotly](https://cran.r-project.org/web/packages/plotly/index.html)
- [DT](https://cran.r-project.org/web/packages/DT/index.html)
- [jsonlite](https://cran.r-project.org/web/packages/jsonlite/index.html)
- [geojsonio](https://cran.r-project.org/web/packages/geojsonio/index.html)

Source code is available from [here](https://github.com/traffordDataLab/projects/tree/master/opengovintelligence). 

---

<div class="svg_holder" style="float: left; margin-right: 12px;">
  <svg width="81" height="54">
  	<desc>European flag</desc>
  	<g transform="scale(0.1)">
  	<defs><g id="s"><g id="c"><path id="t" d="M0,0v1h0.5z" transform="translate(0,-1)rotate(18)"/><use xlink:href="#t" transform="scale(-1,1)"/></g><g id="a"><use xlink:href="#c" transform="rotate(72)"/><use xlink:href="#c" transform="rotate(144)"/></g><use xlink:href="#a" transform="scale(-1,1)"/></g></defs>
  	<rect fill="#039" width="810" height="540"/><g fill="#fc0" transform="scale(30)translate(13.5,9)"><use xlink:href="#s" y="-6"/><use xlink:href="#s" y="6"/><g id="l"><use xlink:href="#s" x="-6"/><use xlink:href="#s" transform="rotate(150)translate(0,6)rotate(66)"/><use xlink:href="#s" transform="rotate(120)translate(0,6)rotate(24)"/><use xlink:href="#s" transform="rotate(60)translate(0,6)rotate(12)"/><use xlink:href="#s" transform="rotate(30)translate(0,6)rotate(42)"/></g><use xlink:href="#l" transform="scale(-1,1)"/></g></g>
  </svg>
</div>
<p>This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 693849.</p>
