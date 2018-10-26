# Claimant count
# http://gmdatastore.org.uk/data/claimant-count

library(SPARQL) ; library(tidyverse)

endpoint <- "http://gmdatastore.org.uk/sparql"

query <- paste0( 
  "SELECT DISTINCT ?date ?lsoa11cd ?lsoa11nm ?lad17nm ?measure ?value 
  WHERE { 
  ?s <http://purl.org/linked-data/cube#dataSet> <http://gmdatastore.org.uk/data/claimant-count> . 
  <http://gmdatastore.org.uk/data/claimant-count> <http://purl.org/dc/terms/description> ?measure.
  ?s <http://purl.org/linked-data/sdmx/2009/dimension#refArea> ?lsoaurl . 
  ?s <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> ?dateurl .
  ?dateurl <http://www.w3.org/2000/01/rdf-schema#label> ?date .
  ?s <http://gmdatastore.org.uk/def/measure-properties/count> ?value . 
  ?lsoaurl <http://publishmydata.com/def/ontology/spatial/memberOf> <http://gmdatastore.org.uk/def/geography/collection/lsoa> .
  ?lsoaurl <http://www.w3.org/2000/01/rdf-schema#label> ?lsoa11cd .
  ?lsoaurl <http://statistics.data.gov.uk/def/statistical-geography#officialname> ?lsoa11nm .
  ?lsoaurl <http://publishmydata.com/def/ontology/spatial/within> ?districturl .
  ?districturl <http://publishmydata.com/def/ontology/spatial/memberOf> <http://gmdatastore.org.uk/def/geography/collection/districts> .
  ?districturl <http://statistics.data.gov.uk/def/statistical-geography#officialname> ?lad17nm . 
  }   ")

claimant_count <- SPARQL(endpoint, query)$results %>% 
  mutate(date = as.Date(paste(date, '01', sep = "-"), format = '%Y-%m-%d'))
