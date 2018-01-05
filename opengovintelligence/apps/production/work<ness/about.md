
### Work<ness app

This application has been developed by Trafford Data Lab as part of a European Union funded [OpenGovIntelligence](http://www.opengovintelligence.eu) project. It is the result of a co-creation excercise involving Trafford Council, Greater Manchester Combined Authority and the Department for Work and Pensions to assist with reducing worklessness across the Greater Manchester region.

>The OpenGovIntelligence project aims to modernize Public Administration by connecting it to Civil Society through the innovative application of Linked Open Statistical Data (LOSD). We believe the publication of high quality public statistics can transform society, services and enterprises throughout Europe.

The application allows data relating to worklessness to be visualised in a variety of ways, improving the understanding of the scale and extent of need.

### Maps

The maps show key indicator datasets relating to worklessness using a technique called Local Indicators of Spatial Association (LISA) which identifies clusters of hot (high worklessness) and cold (low worklessness) geographic areas. The areas are Lower-layer Super Output Areas (LSOA) which are statistically comparable geographies containing approximately 1,500 residents or 650 households on average.

The clusters are categorised according to [Anselin 1995](http://onlinelibrary.wiley.com/doi/10.1111/j.1538-4632.1995.tb00338.x/abstract):

- **High High** - High counts surrounded by other areas of high counts
- **Low Low** - Low counts surrounded by other areas of low counts
- **Low High** - Low counts surrounded by areas of high counts
- **High Low** - High counts currounded by areas of low counts

By hovering over the LSOAs on the map, information such as the electoral ward and local authority it lies within, the value for the indicator chosen and deprivation data is displayed in a moveable panel.

In addition to the datasets which are mapped spatially there are a number of other map options available. Hoving over the layer icon situated under the zoom control (+ - buttons) displays choices for the map backgrounds, such as a satellite and road atlas views, as well as the locations of Jobcentre Plus sites, gambling premises and GP practices which can be overlayed on the map.

### Charts

This section allows temporal (time series) data to be displayed and compared for electoral wards, local authorities and the Greater Manchester district as a whole. The data can be displayed for single or multiple areas (checking the multiple box), on single or separate charts (checking the facet box). Simply begin typing into the box provided to add areas and choose them from the options provided.

The data selected is also displayed in a table below the charts. This table can be sorted by the various headings and also downloaded as a Comma Separated Values (CSV) file via the button provided.

### Sources

The following datasets were used in the application:

- [Claimant count by sex and age](https://www.nomisweb.co.uk/datasets/ucjsa) (ONS, October 2011)
- [LC5601EW - Highest level of qualification by economic activity](https://www.nomisweb.co.uk/census/2011/lc5601ew) (Census 2011)
- [KS107EW - Lone parent households with dependent children](https://www.nomisweb.co.uk/census/2011/KS107EW) (Census 2011)
- [Tenure - Social rented households](https://www.nomisweb.co.uk/census/2011/ks402ew) (Census 2011)

Spatial vector boundary layers were also used from the ONS' [Open Geography Portal](http://geoportal.statistics.gov.uk/).

### Credits
For more information about Local Indicators of Spatial Association see [Anselin (1995)](http://onlinelibrary.wiley.com/doi/10.1111/j.1538-4632.1995.tb00338.x/abstract)

### Developers

The app was developed using [Shiny](https://cran.r-project.org/web/packages/shiny/index.html) and the following R packages:

- [tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html)
- [sf](https://cran.r-project.org/web/packages/sf/index.html) 
- [spdep](https://cran.r-project.org/web/packages/spdep/index.html) 
- [leaflet](https://cran.r-project.org/web/packages/leaflet/index.html)
- [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)
- [DT](https://cran.r-project.org/web/packages/DT/index.html)

Source code is available from [here](https://github.com/traffordDataLab/projects/tree/master/opengovintelligence/apps/beta). 

---

<div class='svg_holder' style="float: left; margin-right: 12px;">
  <svg width="81" height="54">
  	<desc>European flag</desc>
  	<g transform="scale(0.1)">
  	<defs><g id="s"><g id="c"><path id="t" d="M0,0v1h0.5z" transform="translate(0,-1)rotate(18)"/><use xlink:href="#t" transform="scale(-1,1)"/></g><g id="a"><use xlink:href="#c" transform="rotate(72)"/><use xlink:href="#c" transform="rotate(144)"/></g><use xlink:href="#a" transform="scale(-1,1)"/></g></defs>
  	<rect fill="#039" width="810" height="540"/><g fill="#fc0" transform="scale(30)translate(13.5,9)"><use xlink:href="#s" y="-6"/><use xlink:href="#s" y="6"/><g id="l"><use xlink:href="#s" x="-6"/><use xlink:href="#s" transform="rotate(150)translate(0,6)rotate(66)"/><use xlink:href="#s" transform="rotate(120)translate(0,6)rotate(24)"/><use xlink:href="#s" transform="rotate(60)translate(0,6)rotate(12)"/><use xlink:href="#s" transform="rotate(30)translate(0,6)rotate(42)"/></g><use xlink:href="#l" transform="scale(-1,1)"/></g></g>
  </svg>
</div>
<p>This project has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 693849.</p>