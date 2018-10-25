### RDF data cubes

This repository contains RDF data cubes that have been converted from tabular CSV flat files using [table2qb](https://github.com/Swirrl/table2qb).

- Claimant count
- Claimant rate
- Households with lone parent not in employment
- Social rented households
- Working age adults with no qualifications
- Working age population

The linked datasets are available on [GM Data Store](http://gmdatastore.org.uk/).

Each [dataset](RDF/datasets) is stored in its own folder with separate csv (input) and ttl (output) subfolders. The csv folder contains an input.csv and columns.csv file. The input.csv file contains the data in a tidy format and columns.csv maps variable names to the relevant component. The ttl folder contains the resulting RDF data cube (cube.ttl) created by table2qb. The commands used to transform the CSV to RDF with table2qb are stored in cube-pipeline.txt.

Separate folders containing reference data - [codelists](RDF/codelists) (possible values of the components) and [components](RDF/components) (dimensions/attributes/measures) - are also included.
