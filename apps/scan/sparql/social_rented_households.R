# Social rented households
# http://gmdatastore.org.uk/data/social-rented-households

library(SPARQL) ; library(tidyverse)

endpoint <- "http://gmdatastore.org.uk/sparql"

query <- paste0( 
  "SELECT DISTINCT ?lsoa11cd ?lsoa11nm ?lad17nm ?measure ?value 
  WHERE { 
  ?s <http://purl.org/linked-data/cube#dataSet> <http://gmdatastore.org.uk/data/social-rented-households> . 
  <http://gmdatastore.org.uk/data/social-rented-households> <http://purl.org/dc/terms/description> ?measure.
  ?s <http://purl.org/linked-data/sdmx/2009/dimension#refArea> ?lsoaurl . 
  ?s <http://gmdatastore.org.uk/def/measure-properties/count> ?value . 
  ?lsoaurl <http://publishmydata.com/def/ontology/spatial/memberOf> <http://gmdatastore.org.uk/def/geography/collection/lsoa> .
  ?lsoaurl <http://www.w3.org/2000/01/rdf-schema#label> ?lsoa11cd .
  ?lsoaurl <http://statistics.data.gov.uk/def/statistical-geography#officialname> ?lsoa11nm .
  ?lsoaurl <http://publishmydata.com/def/ontology/spatial/within> ?districturl .
  ?districturl <http://publishmydata.com/def/ontology/spatial/memberOf> <http://gmdatastore.org.uk/def/geography/collection/districts> .
  ?districturl <http://statistics.data.gov.uk/def/statistical-geography#officialname> ?lad17nm . 
  }   ")

social_rented_households <- SPARQL(endpoint, query)$results %>% 
  mutate(date = as.Date("2011-03-27", format = '%Y-%m-%d')) %>% 
  select(date, everything())