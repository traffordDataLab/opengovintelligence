<style>
.link
{
    color: #e24a90;
}
</style>
# <span style="color: #ccc;">Trafford Worklessness Pilot:</span> [<span class="link">Scan</span>](http://www.trafforddatalab.io/opengovintelligence/scan.html)

#### Background
This web application has been developed by the [<span class="link">Trafford Data Lab</span>](https://www.trafforddatalab.io/) as part of the European Union funded [<span class="link">OpenGovIntelligence</span>](http://www.opengovintelligence.eu) project. It is the result of a co-creation exercise involving [<span class="link">Trafford Council</span>](http://www.trafford.gov.uk/residents/residents.aspx), the [<span class="link">Greater Manchester Combined Authority</span>](https://www.greatermanchester-ca.gov.uk/) and the [<span class="link">Department for Work and Pensions</span>](https://www.gov.uk/government/organisations/department-for-work-pensions) to help reduce worklessness across the Greater Manchester region.
>The OpenGovIntelligence project aims to modernize Public Administration by connecting it to Civil Society through the innovative application of Linked Open Statistical Data (LOSD). We believe the publication of high quality public statistics can transform society, services and enterprises throughout Europe.
The application is part of a [<span class="link">suite of tools</span>](http://www.trafforddatalab.io/opengovintelligence/) that visualise linked open statistical data relating to worklessness to help identify need and locate assets or groups that could support the delivery of Jobcentre Plus services.

#### The app
The map visualises the spatial distribution of key indicators relating to worklessness using a technique called Local Indicators of Spatial Association [<span class="link">(Anselin, 1995)</span>](http://onlinelibrary.wiley.com/doi/10.1111/j.1538-4632.1995.tb00338.x/abstract). The map shows Lower-layer Super Output Areas (LSOAs) which typically contain around 1,500 residents or 400 households as statistically significant **spatial clusters** (High-High and Low-Low) or **spatial outliers** (Low-High and High-Low). An LSOA marked 'High-High' exhibits positive spatial autocorrelation because it has high values of x and is surrounded by areas with similarly high values. Conversely, an LSOA marked 'High-Low' indicates negative spatial autocorrelation because it records a high value of x and is surrounded by areas with low values.
By hovering over the LSOAs on the map, information such as the indicator value, electoral ward and deprivation data are displayed in the panel.
There are a number of map options available. Hovering over the layer icon below the zoom control (+ - buttons) displays choices for the map backgrounds, such as road atlas and satellite views, as well as the locations of Jobcentre Plus offices which can be overlaid on the map.

#### Sources
The following datasets were used in the application:
- [<span class="link">Claimant count by sex and age</span>](https://www.nomisweb.co.uk/datasets/ucjsa) (September 2018, ONS)
- [<span class="link">LC5601EW - Highest level of qualification by economic activity</span>](https://www.nomisweb.co.uk/census/2011/lc5601ew) (March 2011, Census 2011)
- [<span class="link">KS107EW - Lone parent households with dependent children</span>](https://www.nomisweb.co.uk/census/2011/KS107EW) (March 2011, Census 2011)
- [<span class="link">Tenure - Social rented households</span>](https://www.nomisweb.co.uk/census/2011/ks402ew) (March 2011, Census 2011)
- [<span class="link">Indices of Multiple Deprivation</span>](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2015) (2015, MHCLG)

Spatial vector boundary layers were provided by the ONS' [<span class="link">Open Geography Portal</span>](http://geoportal.statistics.gov.uk/).

#### Credits
For more information about Local Indicators of Spatial Association see Luc Anselin's 1995 [<span class="link">paper</span>](https://doi.org/10.1111/j.1538-4632.1995.tb00338.x).

#### Developers
The app was developed using [<span class="link">Shiny</span>](https://cran.r-project.org/web/packages/shiny/index.html) and the following [<span class="link">R</span>](https://cran.r-project.org/) packages:
- [<span class="link">leaflet</span>](https://cran.r-project.org/web/packages/leaflet/index.html)
- [<span class="link">sf</span>](https://cran.r-project.org/web/packages/sf/index.html)
- [<span class="link">SPARQL</span>](https://cran.r-project.org/web/packages/SPARQL/index.html)
- [<span class="link">spdep</span>](https://cran.r-project.org/web/packages/spdep/index.html)
- [<span class="link">tidyverse</span>](https://cran.r-project.org/web/packages/tidyverse/index.html)

The source code is available [<span class="link">here</span>](https://github.com/traffordDataLab/opengovintelligence).

---
<div class="footer">
    <img src="../eu_flag.png" alt="Flag of the European Union" style="float: left; margin-right: 12px; height: 5em;"/>
    <span class="footerText">This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 693849.</span>
</div>
