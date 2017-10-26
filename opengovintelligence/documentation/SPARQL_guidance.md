The following example SPARQL query uses [SWIRRL's](http://www.swirrl.com/) PublishMyData instance: [GM Data Store](http://gmdatastore.org.uk)


### Querying JSA claimant counts

This SPARQL query obtains a count of all [Job Seekers Allowance](https://www.gov.uk/jobseekers-allowance) (JSA) claimants in June 2017 by each electoral ward within [Greater Manchester](https://github.com/traffordDataLab/boundaries/blob/master/wards.geojson).

``` SPARQL
SELECT ?ward_code ?count
WHERE {
  ?s <http://purl.org/linked-data/cube#dataSet> <http://gmdatastore.org.uk/data/jsa-by-ward>.
  ?s <http://gmdatastore.org.uk/def/dimension/gender> <http://gmdatastore.org.uk/def/concept/gender/all>.
  ?s <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> <http://reference.data.gov.uk/id/month/2017-06>.
  ?s <http://gmdatastore.org.uk/def/measure-properties/count> ?count.
  ?s <http://purl.org/linked-data/sdmx/2009/dimension#refArea> ?ward_code_uri.
  ?ward_code_uri <http://www.w3.org/2004/02/skos/core#notation> ?ward_code.
}
```
The ```SELECT``` statement defines 2 variables: "**ward_code**" and "**count**" which will serve as the outputs for our query. These can be thought of as the column headings in a traditional spreadsheet output.

The ```WHERE``` clause, delimited by the ```{}``` characters, contains the instructions to describe what data we want from the database.

Inside the ```WHERE``` clause, everything is expressed in triples (as this is how the data is stored!) in the order: **subject**, **predicate**, **object**. In our example you will see that the subjects in each of our triples are variables, and mostly the same variable ```?s```. (The **s** stands logically for **subject** and serves as a general placeholder when we are not interested in the output.) Each triple can be thought of as an instruction to the database, refining what information we are looking for.

The first line defines the dataset we are interested in obtaining data from:
``` SPARQL
?s <http://purl.org/linked-data/cube#dataSet> <http://gmdatastore.org.uk/data/jsa-by-ward>.
```
This ensures that we only obtain data from the required dataset, and not potentially other datasets within the database which contain the same terms. Next we want to filter the data, first by gender and second by the time period, to ensure we get the correct data we are looking for:
``` SPARQL
?s <http://gmdatastore.org.uk/def/dimension/gender> <http://gmdatastore.org.uk/def/concept/gender/all>.
```
The statement above asks for data relating to all genders, however we could easily amend this to return data for just females or just males if so required.
``` SPARQL
?s <http://purl.org/linked-data/sdmx/2009/dimension#refPeriod> <http://reference.data.gov.uk/id/month/2017-06>.
```
The statement above asks only for the data relating to **June 2017**.

Finally, the last 3 lines deal with obtaining the actual return values from the query. The first item, obtaining the count of claimants, is straightforward:
``` SPARQL
?s <http://gmdatastore.org.uk/def/measure-properties/count> ?count.
```
The statement above gets the count value for the number of JSA claimants and stores the value in the variable ```?count```. As you saw in the complete query code listed at the top, this variable is declared in the ```SELECT``` statement as one of our outputs.

To obtain the ward code for each of the counts we need to introduce an extra step. The wards are defined as URIs (Uniform Resource Identifiers) in the dataset like this: ```http://statistics.data.gov.uk/id/statistical-geography/E05000650``` which is a bit verbose. To just obtain the ward code which is the ```E05000650``` part we first load the full URI into a temporary variable ```?ward_code_uri```. On the next line we then extract just the code itself and load that into the output variable ```?ward_code```:
``` SPARQL
?ward_code_uri <http://www.w3.org/2004/02/skos/core#notation> ?ward_code.
```

As you can see, the SPARQL code is littered with URI references which give meaning to the terms used in the data. But how do we know what these URIs are? By using the GUI (Graphical User Interface) provided by the triple store, we can explore the dataset and look at the [metadata for an object](http://gmdatastore.org.uk/data/jsa-by-ward/month/2017-06/E05000650/gender/all/people-claiming-JSA/count) which describes it. This reveals the URIs and definitions we need to use in our query.

---

We could leave it there, however one aspect not shown in our example is the use of ```PREFIX``` which appears in many SPARQL queries. This is used to simplify the look of queries so that common URIs are not required to be used in their entirety. In the example code below our original query has been rewritten to show how PREFIXes are used:
``` SPARQL
PREFIX purl_qb: <http://purl.org/linked-data/cube#>
PREFIX purl_dim: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?ward_code ?count
WHERE {
  ?s purl_qb:dataSet <http://gmdatastore.org.uk/data/jsa-by-ward>.
  ?s <http://gmdatastore.org.uk/def/dimension/gender> <http://gmdatastore.org.uk/def/concept/gender/all>.
  ?s purl_dim:refPeriod <http://reference.data.gov.uk/id/month/2017-06>.
  ?s <http://gmdatastore.org.uk/def/measure-properties/count> ?count.
  ?s purl_dim:refArea ?ward_code_uri.
  ?ward_code_uri skos:notation ?ward_code.
}
```

You can copy and paste the query examples presented here into the SPARQL [endpoint](http://gmdatastore.org.uk/sparql) of the [GM Data Store](http://gmdatastore.org.uk) to see the results.

Alternatively you can see the output from this query visualised using an [R script](https://github.com/traffordDataLab/OpenGovIntelligence/blob/master/R/JSA_claimants.R) we created.
