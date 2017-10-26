### Example GraphQL queries using [SWIRRL's graphql-qb service](http://graphql-qb.publishmydata.com)

<br>

- [List all available datasets](http://graphql-qb.publishmydata.com/index.html?query=%7B%0A%20%20datasets%20%7B%0A%20%20%20%20uri%0A%20%20%20%20title%0A%20%20%20%20description%0A%20%20%7D%0A%7D%0A)
- [List the dimensions in each dataset](http://graphql-qb.publishmydata.com/index.html?query=%7B%0A%20%20dataset_earnings%20%7B%0A%20%20%20%20title%0A%20%20%20%20description%0A%20%20%20%20dimensions%20%7B%0A%20%20%20%20%20%20uri%0A%20%20%20%20%20%20values%20%7B%0A%20%20%20%20%20%20%20%20label%0A%20%20%20%20%20%20%20%20uri%0A%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D)
- [Filter datasets about gender](http://graphql-qb.publishmydata.com/index.html?query=%7B%0A%20%20datasets(dimensions%3A%20%7Band%3A%20%5B%22http%3A%2F%2Fstatistics.gov.scot%2Fdef%2Fdimension%2Fgender%22%5D%7D)%20%7B%0A%20%20%20%20uri%0A%20%20%20%20title%0A%20%20%7D%0A%7D%0A)
- [Show all the variables in the earnings dataset](http://graphql-qb.publishmydata.com/index.html?query=%7B%0A%20%20dataset_earnings%20%7B%0A%20%20%20%20title%0A%20%20%20%20dimensions%20%7B%0A%20%20%20%20%20%20uri%0A%20%20%20%20%20%20values%20%7B%0A%20%20%20%20%20%20%20%20label%0A%20%20%20%20%20%20%20%20uri%0A%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D%0A)
- [Show observations in workplace based earnings dataset for all gender](http://graphql-qb.publishmydata.com/index.html?query=%7B%0A%20%20dataset_earnings%20%7B%0A%20%20%20%20title%0A%20%20%20%20observations(dimensions%3A%20%7Bgender%3A%20ALL%2C%20population_group%3A%20WORKPLACE_BASED%7D)%20%7B%0A%20%20%20%20%20%20matches%20%7B%0A%20%20%20%20%20%20%20%20median%0A%20%20%20%20%20%20%20%20reference_period%0A%20%20%20%20%20%20%20%20reference_area%0A%20%20%20%20%20%20%20%20measure_type%0A%20%20%20%20%20%20%20%20uri%0A%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D%0A)
- [Something more fancy](http://graphql-qb.publishmydata.com/index.html?query=%7B%0A%20%20datasets(dimensions%3A%20%7Band%3A%20%5B%22http%3A%2F%2Fstatistics.gov.scot%2Fdef%2Fdimension%2Fgender%22%5D%7D)%20%7B%0A%20%20%20%20uri%0A%20%20%20%20title%0A%20%20%20%20description%0A%20%20%20%20schema%0A%20%20%20%20dimensions%20%7B%0A%20%20%20%20%20%20uri%0A%20%20%20%20%7D%0A%20%20%7D%0A%20%20dataset_earnings%20%7B%0A%20%20%20%20observations(dimensions%3A%20%7Bgender%3A%20ALL%7D)%20%7B%0A%20%20%20%20%20%20matches%20%7B%0A%20%20%20%20%20%20%20%20median%0A%20%20%20%20%20%20%20%20population_group%0A%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%20%20%7D%0A%20%20dataset_healthy_life_expectancy%20%7B%0A%20%20%20%20title%0A%20%20%7D%0A%7D%0A)

<br>

SWIRRL's GitHub repo is here: [https://github.com/Swirrl/graphql-qb](https://github.com/Swirrl/graphql-qb)
