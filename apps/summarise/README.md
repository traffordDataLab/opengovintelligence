# <span style="color: #ccc;">Trafford Worklessness Pilot:</span> [<span style="color: #e24a90;">Summarise</span>](http://www.trafforddatalab.io/opengovintelligence/summarise.html)

#### Background
This web application has been developed by the [<span style="color: #e24a90;">Trafford Data Lab</span>](https://www.trafforddatalab.io/) as part of the European Union funded [<span style="color: #e24a90;">OpenGovIntelligence</span>](http://www.opengovintelligence.eu) project. It is the result of a co-creation exercise involving [<span style="color: #e24a90;">Trafford Council</span>](http://www.trafford.gov.uk/residents/residents.aspx), the [<span style="color: #e24a90;">Greater Manchester Combined Authority</span>](https://www.greatermanchester-ca.gov.uk/) and the [<span style="color: #e24a90;">Department for Work and Pensions</span>](https://www.gov.uk/government/organisations/department-for-work-pensions) to help reduce worklessness across the Greater Manchester region.
>The OpenGovIntelligence project aims to modernize Public Administration by connecting it to Civil Society through the innovative application of Linked Open Statistical Data (LOSD). We believe the publication of high quality public statistics can transform society, services and enterprises throughout Europe.

The application is part of a [<span style="color: #e24a90;">suite of tools</span>](http://www.trafforddatalab.io/opengovintelligence/) that visualise linked open statistical data relating to worklessness to help identify need and locate assets or groups that could support the delivery of Jobcentre Plus services.

#### The app
Once the application has loaded you will see information displayed for the Greater Manchester region as a whole. By choosing a Local Authority from the select list presented beneath the map, the map will change to display the new boundary and the line chart displaying a 3-year time series of claimant data will be updated to include the chosen Local Authority.

A further select list will now be available beneath the map, allowing you to choose a ward within your selected Local Authority. Once you have made your selection the map and time series chart will again update with the new information. You will therefore be able to compare claimant rates for the ward, Local Authority and Greater Manchester. An additional chart will also be displayed beneath the time series chart showing data from the UK Business Register and Employment Survey (BRES) 2015. This chart gives an indication of the number of people living in the selected ward who are employed within different industry sectors.

The time series chart and map are interactive. The values for the line chart can be easily read by selecting the individual data points or hovering over them. The map allows you to pan and zoom around the currently chosen boundary. Once you select an electoral ward, additional information can also be displayed including the number and location of General Practices, Dentists, Food Banks, Jobcentre Plus and Probation offices. To view this information on the map, simply select the item of interest from the list presented in the bottom-left corner of the map.

#### Sources
The following datasets were used in the application:
- [<span style="color: #e24a90;">Claimant count by sex and age</span>](https://www.nomisweb.co.uk/datasets/ucjsa) (September 2018, ONS)
- [<span style="color: #e24a90;">Census</span>](https://www.nomisweb.co.uk/census/2011) (2011, ONS)
- [<span style="color: #e24a90;">UK Business Register and Employment Survey (BRES)</span>](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/employmentandemployeetypes/bulletins/businessregisterandemploymentsurveybresprovisionalresults/2014revisedand2015provisional) (2015)
- [<span style="color: #e24a90;">Dentists</span>](http://www.cqc.org.uk/about-us/transparency/using-cqc-data) (September 2018, CQC)
- [<span style="color: #e24a90;">Food Banks</span>](http://www.gmpovertyaction.org/maps/) (January 2018, GM Poverty Action)
- [<span style="color: #e24a90;">General practices</span>](http://www.cqc.org.uk/about-us/transparency/using-cqc-data) (October 2018, CQC)
- [<span style="color: #e24a90;">Probation offices</span>](http://www.cgmcrc.co.uk/contact-us/our-offices/) (Cheshire & Greater Manchester CRC)
- [<span style="color: #e24a90;">Jobcentre Plus</span>](https://www.gov.uk/government/publications/dwp-jobcentre-register) (May 2018, DWP)

All the datasets are published under the [<span style="color: #e24a90;">Open Government Licence v3.0</span>](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

Spatial vector boundary layers were provided by the ONS' [<span style="color: #e24a90;">Open Geography Portal</span>](http://geoportal.statistics.gov.uk/). Contains National Statistics and OS data © Crown copyright and database right 2018.

#### Developers
The app was developed using javascript and the following libraries:
- [<span style="color: #e24a90;">d3</span>](https://d3js.org/)
- [<span style="color: #e24a90;">leaflet</span>](https://leafletjs.com/)

The source code is available [<span style="color: #e24a90;">here</span>](https://github.com/traffordDataLab/opengovintelligence).

---
<div>
    <img src="../../eu_flag.png" alt="Flag of the European Union" style="float: left; margin-right: 12px; height: 5em;"/>
    <span class="footerText">This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 693849.</span>
</div>
