## Indices of Multiple Deprivation, 2015 - SPARQL ##

library(SPARQL) ; library(tidyverse) ; library (forcats)

endpoint <- "http://opendatacommunities.org/sparql"

query <- paste0( 
  "SELECT DISTINCT ?lsoa11cd ?index_domain ?decile ?rank
  WHERE {
  ?metcty <http://www.w3.org/2004/02/skos/core#notation> 'E11000001' .
  ?inmetcty <http://publishmydata.com/def/ontology/spatial/within> ?metcty .
  ?lsoa <http://publishmydata.com/def/ontology/spatial/within> ?inmetcty .
  ?lsoa <http://www.w3.org/2004/02/skos/core#notation> ?lsoa11cd .
  ?refArea <http://www.w3.org/2004/02/skos/core#notation> ?lsoa11cd .
  
  ?s <http://opendatacommunities.org/def/ontology/geography/refArea> ?refArea .
  ?s <http://opendatacommunities.org/def/ontology/communities/societal_wellbeing/imd/decObs> ?decile .
  ?s <http://opendatacommunities.org/def/ontology/communities/societal_wellbeing/imd/indices> ?index .
  ?index <http://www.w3.org/2000/01/rdf-schema#label> ?index_domain.
  
  ?s2 <http://opendatacommunities.org/def/ontology/geography/refArea> ?refArea .
  ?s2 <http://opendatacommunities.org/def/ontology/communities/societal_wellbeing/imd/rankObs> ?rank .
  ?s2 <http://opendatacommunities.org/def/ontology/communities/societal_wellbeing/imd/indices> ?index2 .
  ?index2 <http://www.w3.org/2000/01/rdf-schema#label> ?index_domain.
  
  FILTER (!regex(?index_domain, 'Affecting','i')) . 
  }ORDER BY ?lsoa11cd")

results <- SPARQL(endpoint,query)$results

imd <- mutate(results, 
              lsoa11cd = factor(lsoa11cd), 
              index_domain = fct_recode(index_domain, 
                                           "Index of Multiple Deprivation" = "a. Index of Multiple Deprivation (IMD)",
                                           "Income" = "b. Income Deprivation Domain",
                                           "Employment" = "c. Employment Deprivation Domain",
                                           "Education, Skills and Training" = "d. Education, Skills and Training Domain",
                                           "Health Deprivation and Disability" = "e. Health Deprivation and Disability Domain",
                                           "Crime" = "f. Crime Domain",
                                           "Barriers to Housing and Services" = "g. Barriers to Housing and Services Domain",
                                           "Living Environment" = "h. Living Environment Deprivation Domain"),
              decile = factor(decile), 
              rank = as.integer(rank))

rm(endpoint, query, results)
