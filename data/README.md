### RDF data cubes

This repository contains RDF data cubes that have been converted from tabular CSV flat files using [table2qb](https://github.com/Swirrl/table2qb).

- [Claimant count](http://gmdatastore.org.uk/data/claimant-count)
- [Claimant rate](http://gmdatastore.org.uk/data/claimant-rate)
- [Households with lone parent not in employment](http://gmdatastore.org.uk/data/households-with-lone-parent-not-in-employment)
- [Social rented households](http://gmdatastore.org.uk/data/social-rented-households)
- [Working age adults with no qualifications](http://gmdatastore.org.uk/data/working-age-adults-with-no-qualifications)
- [Working age population](http://gmdatastore.org.uk/data/working-age-population)

The linked datasets are licensed under the [Open Government Licence v3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

Each [dataset](RDF/datasets) is stored in its own folder with separate csv (input) and ttl (output) subfolders. The csv folder contains an input.csv and columns.csv file. The input.csv file contains the data in a tidy format and columns.csv maps variable names to the relevant component. The ttl folder contains the resulting RDF data cube (cube.ttl) created by table2qb. The commands used to transform the CSV to RDF with table2qb are stored in cube-pipeline.txt.

Separate folders containing reference data - [codelists](RDF/codelists) (possible values of the components) and [components](RDF/components) (dimensions/attributes/measures) - are also included.
