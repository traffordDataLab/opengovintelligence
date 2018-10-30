# <span style="color: #ccc;">Trafford Worklessness Pilot:</span> [<span style="color: #e24a90;">Summarise</span>](http://www.trafforddatalab.io/opengovintelligence/summarise.html)

#### Background
This web application has been developed by the [<span style="color: #e24a90;">Trafford Data Lab</span>](https://www.trafforddatalab.io/) as part of the European Union funded [<span style="color: #e24a90;">OpenGovIntelligence</span>](http://www.opengovintelligence.eu) project. It is the result of a co-creation exercise involving [<span style="color: #e24a90;">Trafford Council</span>](http://www.trafford.gov.uk/residents/residents.aspx), the [<span style="color: #e24a90;">Greater Manchester Combined Authority</span>](https://www.greatermanchester-ca.gov.uk/) and the [<span style="color: #e24a90;">Department for Work and Pensions</span>](https://www.gov.uk/government/organisations/department-for-work-pensions) to help reduce worklessness across the Greater Manchester region.
>The OpenGovIntelligence project aims to modernize Public Administration by connecting it to Civil Society through the innovative application of Linked Open Statistical Data (LOSD). We believe the publication of high quality public statistics can transform society, services and enterprises throughout Europe.
The application is part of a [<span style="color: #e24a90;">suite of tools</span>](http://www.trafforddatalab.io/opengovintelligence/) that visualise linked open statistical data relating to worklessness to help identify need and locate assets or groups that could support the delivery of Jobcentre Plus services.

#### The app
Once the application has loaded you will see information displayed for the Greater Manchester region as a whole. By choosing a Local Authority from the select list presented beneath the map, the map will change to display the new boundary and the line chart displaying a 3-year time series of claimant data will be updated to include the chosen Local Authority.

A further select list will now be available beneath the map, allowing you to choose a ward within your selected Local Authority. Once you have made your selection the map and time series chart will again update with the new information. You will therefore be able to compare claimant rates for the ward, Local Authority and Greater Manchester. An additional chart will also be displayed beneath the time series chart showing data from the UK business register and employment survey (BRES) 2015. This chart gives an indication of the number of people living in the selected ward who are employed within different industry sectors.

The map and time series chart are interactive. The map allows you to pan and zoom around the currently chosen boundary. Addition information is also displayed, such as the number and location of betting shops once you select an electoral ward. The values for the line chart can be easily read by selecting the individual data points.

#### Sources
The following datasets were used in the application:
- [<span style="color: #e24a90;">Claimant count by sex and age</span>](https://www.nomisweb.co.uk/datasets/ucjsa) (September 2018, ONS)
- [<span style="color: #e24a90;">Census</span>](https://www.nomisweb.co.uk/census/2011) (2011, ONS)
- [<span style="color: #e24a90;">UK business register and employment survey (BRES)</span>](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/bulletins/businessregisterandemploymentsurveybresprovisionalresults/2014revisedand2015provisional) (2015)
- [<span style="color: #e24a90;">Gambling premises in Greater Manchester</span>](https://secure.gamblingcommission.gov.uk/PublicRegister) (September 2018, Gambling Commission)

Spatial vector boundary layers were provided by the ONS' [<span style="color: #e24a90;">Open Geography Portal</span>](http://geoportal.statistics.gov.uk/).

#### Developers
The app was developed using javascript and the following libraries:
- [<span style="color: #e24a90;">d3</span>](https://d3js.org/)
- [<span style="color: #e24a90;">leaflet</span>](https://leafletjs.com/)

The source code is available [<span style="color: #e24a90;">here</span>](https://github.com/traffordDataLab/opengovintelligence).

---
<div>
    <img src="../eu_flag.png" alt="Flag of the European Union" style="float: left; margin-right: 12px; height: 5em;"/>
    <span class="footerText">This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 693849.</span>
</div>
