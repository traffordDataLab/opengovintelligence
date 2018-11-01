## CubiQL querying of GM DataStore ##

# load libraries
library(ghql) ; library(jsonlite) ; library(tidyverse) 

# load lsoa to local authority lookup
lookup <- read_csv("https://www.traffordDataLab.io/spatial_data/lookups/lsoa_to_ward_best-fit_lookup.csv") %>% 
  select(lsoa11cd, lad17nm)

# set up CubiQL endpoint
client <- GraphqlClient$new(url = "http://cubiql.gmdatastore.org.uk/graphql")

# Claimant count
# http://gmdatastore.org.uk/data/claimant-count

qry <- Query$new()
qry$query('query', 
'
{
  cubiql {
  dataset_claimant_count {
  description
  title
  observations {
  page(first: 2000) {
  observation {
  reference_area {
  label
  }
  count
  reference_period {
  label
  }
  }
  }
  }
  }
  }
  }
')
response <- fromJSON(client$exec(qry$queries$query), flatten = TRUE)

claimant_count <- map_df(response$data$cubiql$dataset_claimant_count$observations$page, as_data_frame) %>% 
  rename(date = reference_period.label,
         lsoa11cd = reference_area.label,
         value = count) %>% 
  mutate(date = as.Date(paste(date, '01', sep = "-"), format = '%Y-%m-%d'),
         measure = "Residents claiming JSA or Universal Credit")

# Households with lone parent not in employment
# http://gmdatastore.org.uk/data/households-with-lone-parent-not-in-employment

qry <- Query$new()
qry$query('query', '
          {
          cubiql {
          dataset_households_with_lone_parent_not_in_employment {
          description
          title
          observations {
          page(first: 2000) {
          observation {
          reference_area {
          label
          }
          count
          }
          }
          }
          }
          }
          }
          ')
response <- fromJSON(client$exec(qry$queries$query), flatten = TRUE)
listviewer::jsonedit(response)

households_with_lone_parent_not_in_employment <- map_df(response$data$cubiql$dataset_households_with_lone_parent_not_in_employment$observations$page, as_data_frame) %>% 
  rename(lsoa11cd = reference_area.label,
         value = count) %>% 
  mutate(date = as.Date("2011-03-27", format = '%Y-%m-%d'),
         measure = "Households with lone parent not in employment")

# Social rented households
# http://gmdatastore.org.uk/data/social-rented-households

qry <- Query$new()
qry$query('query', '
          {
          cubiql {
          dataset_social_rented_households {
          description
          title
          observations {
          page(first: 2000) {
          observation {
          reference_area {
          label
          }
          count
          }
          }
          }
          }
          }
          }
          ')
response <- fromJSON(client$exec(qry$queries$query), flatten = TRUE)

social_rented_households <- map_df(response$data$cubiql$dataset_social_rented_households$observations$page, as_data_frame) %>% 
  rename(lsoa11cd = reference_area.label,
         value = count) %>% 
  mutate(date = as.Date("2011-03-27", format = '%Y-%m-%d'),
         measure = "Social rented households")

# Working age adults with no qualifications
# http://gmdatastore.org.uk/data/working-age-adults-with-no-qualifications

qry <- Query$new()
qry$query('query', '
          {
          cubiql {
          dataset_working_age_adults_with_no_qualifications {
          description
          title
          observations {
          page(first: 2000) {
          observation {
          reference_area {
          label
          }
          count
          }
          }
          }
          }
          }
          }
          ')
response <- fromJSON(client$exec(qry$queries$query), flatten = TRUE)
listviewer::jsonedit(response)

working_age_adults_with_no_qualifications <- map_df(response$data$cubiql$dataset_working_age_adults_with_no_qualifications$observations$page, as_data_frame) %>% 
  rename(lsoa11cd = reference_area.label,
         value = count) %>% 
  mutate(date = as.Date("2011-03-27", format = '%Y-%m-%d'),
         measure = "Working-age adults with no qualifications")

# Bind datasets together

df <- bind_rows(claimant_count, 
                households_with_lone_parent_not_in_employment, 
                social_rented_households, 
                working_age_adults_with_no_qualifications) %>% 
  left_join(., lookup, by = "lsoa11cd") %>% 
  select(date, lsoa11cd, lad17nm, measure, value) %>% 
  mutate(lsoa11cd = factor(lsoa11cd),
         lad17nm = factor(lad17nm),
         measure = factor(measure),
         value = as.integer(value))

