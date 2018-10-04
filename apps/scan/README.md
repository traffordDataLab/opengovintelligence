# scan

## Summary

This [R](https://cran.r-project.org/) [Shiny](https://shiny.rstudio.com/) application visualises [DWP](https://www.gov.uk/government/organisations/department-for-work-pensions) [claimant count](https://www.nomisweb.co.uk/datasets/ucjsa) data for Greater Manchester both spatially and temporally.

## Running the app

The application is hosted on [shinyapps.io](http://www.shinyapps.io/) at the following address: [https://trafforddatalab.shinyapps.io/worklessness/](https://trafforddatalab.shinyapps.io/worklessness/)

You can also run the application locally in your R session by executing the following code:
  
``` r
library(shiny)
runGitHub("trafforddatalab/opengovintelligence", subdir = "apps/scan/")
```

## Features

**Spatial analysis**

A technique known as Local Indicators of Spatial Association ([Anselin, 1995](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1538-4632.1995.tb00338.x)) is used to identify clusters of neighbourhoods with high or low claimant counts. 2011 Census proxies for worklessness are also visualised.

**Time Series**

Claimant counts for up to four areas are visualised as time series.

## Data Sources

The app uses the following datasets:

- [Claimant count by sex and age](https://www.nomisweb.co.uk/datasets/ucjsa) (Latest available month, ONS)
- [LC5601EW - Highest level of qualification by economic activity](https://www.nomisweb.co.uk/census/2011/lc5601ew) (March 2011, Census 2011)
- [KS107EW - Lone parent households with dependent children](https://www.nomisweb.co.uk/census/2011/KS107EW) (March 2011, Census 2011)
- [Tenure - Social rented households](https://www.nomisweb.co.uk/census/2011/ks402ew) (March 2011, Census 2011)
- [Indices of Multiple Deprivation](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2015) (2015, MHCLG)

Spatial vector boundary layers were provided by the ONS' [Open Geography Portal](http://geoportal.statistics.gov.uk/).

