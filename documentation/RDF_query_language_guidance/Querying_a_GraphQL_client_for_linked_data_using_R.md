
Querying a GraphQL client for linked data using R
-------------------------------------------------

<br />

The following script relies on the [`ghql`](https://github.com/ropensci/ghql) R package (Chamberlain 2017) to query multidimensional QB datasets using [GraphQL](http://graphql.org/). The example uses the graphql-qb service at [graphql-qb.publishmydata.com](graphql-qb.publishmydata.com) which stores data from [statistics.gov.scot](statistics.gov.scot).

------------------------------------------------------------------------

##### Install the `ghql` package from GitHub (and `devtools` if not already installed)

``` r
devtools::install_github("hadley/devtools")
devtools::install_github("ropensci/ghql")
```

##### Load the necessary R packages

``` r
library(ghql) # for querying 
library(jsonlite) # for parsing the json response
library(httr) # for working with URLs
library(tidyverse) # for tidying data
```

##### Initialize the GraphQL client by pointing it to the appropriate endpoint e.g. <http://graphql-qb.publishmydata.com/graphql>

``` r
client <- GraphqlClient$new(url = "http://graphql-qb.publishmydata.com/graphql")
```

No OAuth token is required for this endpoint but the `headers` argument can be used for this purpose.

##### Make a Query class object

``` r
qry <- Query$new()
```

##### Add your GraphQL query, e.g. Filter datasets about gender and return the title and description

``` r
qry$query('query', '
  {
    datasets(dimensions: {and: ["http://statistics.gov.scot/def/dimension/gender"]}) {
      title
      description
    }
  }
')
```

##### Return the responses

``` r
responses <- client$exec(qry$queries$query)
```

##### Convert to a dataframe and return column names

``` r
df <- as.data.frame(responses)
glimpse(df)
```

    ## Observations: 55
    ## Variables: 2
    ## $ data.datasets.title       <chr> "Mid-Year Population Estimates (hist...
    ## $ data.datasets.description <chr> "Mid-year estimates by age and gende...

##### Change the column names

``` r
df <- rename(df, Dataset = data.datasets.title,
             Description = data.datasets.description)
```

The table below shows the first 6 responses.

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
Dataset
</th>
<th style="text-align:left;">
Description
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Mid-Year Population Estimates (historical geographical boundaries)
</td>
<td style="text-align:left;">
Mid-year estimates by age and gender. Higher level geographies are aggregated using 2001 data zones.
</td>
</tr>
<tr>
<td style="text-align:left;">
Pupil Attainment
</td>
<td style="text-align:left;">
Number of pupils who attained a given number of qualifications by level and stage.
</td>
</tr>
<tr>
<td style="text-align:left;">
Earnings
</td>
<td style="text-align:left;">
Median gross weekly earnings (£s) by gender and workplace/residence measure.
</td>
</tr>
<tr>
<td style="text-align:left;">
Income Support Claimants
</td>
<td style="text-align:left;">
Number of income support claimants by age and gender (age split not available for gender).
</td>
</tr>
<tr>
<td style="text-align:left;">
Healthy Life Expectancy
</td>
<td style="text-align:left;">
Years of Healthy Life Expectancy (including confidence intervals) by gender
</td>
</tr>
<tr>
<td style="text-align:left;">
Disability Living Allowance
</td>
<td style="text-align:left;">
Number of Disability Living Allowance claimants by age group and gender.
</td>
</tr>
</tbody>
</table>
<br />

### References

-   Chamberlain, Scott (2017). ghql: General Purpose GraphQL Client. R package version 0.0.3.9110. <https://github.com/ropensci/ghql>
-   Ooms, Jeroen (2014). The jsonlite Package: A Practical and Consistent Mapping Between JSON Data and R Objects. arXiv:1403.2805 \[stat.CO\] URL <https://arxiv.org/abs/1403.2805>.
-   Wickham, Hadley (2017). httr: Tools for Working with URLs and HTTP. R package version 1.3.1. <https://CRAN.R-project.org/package=httr>
-   Wickham, Hadley (2017). tidyverse: Easily Install and Load 'Tidyverse' Packages. R package version 1.1.1. <https://CRAN.R-project.org/package=tidyverse>
