<style>
.link
{
    color: #e24a90;
}
</style>
# <span style="color: #ccc;">Trafford Worklessness Pilot:</span> [<span class="link">Signpost</span>](http://www.trafforddatalab.io/opengovintelligence/signpost.html)

#### Background
This web application has been developed by the [<span class="link">Trafford Data Lab</span>](https://www.trafforddatalab.io/) as part of the European Union funded [<span class="link">OpenGovIntelligence</span>](http://www.opengovintelligence.eu) project. It is the result of a co-creation exercise involving [<span class="link">Trafford Council</span>](http://www.trafford.gov.uk/residents/residents.aspx), the [<span class="link">Greater Manchester Combined Authority</span>](https://www.greatermanchester-ca.gov.uk/) and the [<span class="link">Department for Work and Pensions</span>](https://www.gov.uk/government/organisations/department-for-work-pensions) to help reduce worklessness across the Greater Manchester region.
>The OpenGovIntelligence project aims to modernize Public Administration by connecting it to Civil Society through the innovative application of Linked Open Statistical Data (LOSD). We believe the publication of high quality public statistics can transform society, services and enterprises throughout Europe.
The application is part of a [<span class="link">suite of tools</span>](http://www.trafforddatalab.io/opengovintelligence/) that visualise linked open statistical data relating to worklessness to help identify need and locate assets or groups that could support the delivery of Jobcentre Plus services.

#### The app
The application loads with the interactive map displaying the boundaries of the Local Authorities in Greater Manchester. The top-right corner of the screen contains the **information panel** and the top-left corner of the screen contains the **interactive map controls**. You can pan/drag and zoom the map using a variety of different methods depending on the type of device you are using. If you are using a mouse with a scroll-wheel, you can zoom in and out using the wheel and pan/drag by holding the mouse button down and moving the mouse. Touchscreen devices can use the pinch-to-zoom gesture to zoom in and out and use the touch-and-drag gesture to pan/drag the map. Trackpad devices usually employ similar gestures to touchscreen.

##### Information panel
The information panel comprises different sections. Initially just the select list containing the services which are able to be viewed is displayed. When you select an interactive item displayed on the map, such as one of the Local Authority boundaries or a location of a service chosen from the select list, information about the selected item appears in the information panel. The information panel is cleared by clicking on an area of the map which does not contain any interactive elements, i.e. outside the boundary of Greater Manchester.

Choosing a service from the select list causes the locations of that service to be displayed on the map, represented by marker 'pins'. These markers are interactive and clicking on them will display the information about the service in the information panel. When a service has been chosen, clicking on the icon showing a white arrow within a pink circle in the top-right corner of the information panel will reveal further information about the dataset and provide links to access the data.

##### Interactive map controls

There are three map controls displayed in the top-left corner of the screen: geolocate (compass icon), search (magnifying glass icon) and reachability (bulleye icon).

**Geolocate** attempts to calculate your current location and zoom in to that area on the map. To use this feature your device will need to have GPS capabilities and you will be asked to give permission for the app to access these features. If this is successful, after a few seconds you should see your approximate location displayed on the map with a blue dot and a buffer circle.

**Search** gives you the opportunity to enter either an address, postcode or place name to quickly zoom to that location on the map. If a number of locations match your search criteria, the options will be displayed below the search box. Entering partial postcode information may give unpredictable results.

**Reachability** is very useful when determining how easy it is for a client to access services from their location. You can read more about this feature in our [<span class="link">Medium article</span>](https://medium.com/@traffordDataLab/out-of-reach-introducing-our-distance-and-travel-time-plugin-859932cb12e5) and see [<span class="link">demonstration videos on Vimeo</span>](https://vimeo.com/user71230875).

To use the reachability feature, click on the icon and the options will appear. The first two icons allow choose whether you want to draw a new reachability area (pencil icon) or delete an existing one (bin/trash can icon). The next two icons determine if the reachability area is based on distance (road icon) or time (clock icon). Underneath are the travel mode options: driving (car icon), cycling (bicycle icon) and walking (person icon). Finally the distance or time options are presented in a select list (in 5 minute or 0.5 kilometre intervals depending on whether the distance or time icon is selected). The interval checkbox next to the select list allows either all intervals from the minimum up to the value chosen in the select list to be displayed (checked) or just the single selected value (unchecked).

When you are ready to draw your reachability area(s), select the draw icon and then choose an area on the map. You can draw further areas if you wish by choosing another location on the map. The reachability tool stays in draw mode until you deselect it by clicking again on the draw icon. Once the tool is deselected the reachability area(s) you have created are interactive and you can select them and see the information about them displayed in the information panel.

To delete reachability areas, open the tool and select the delete icon. If only one reachability area was displayed it will automatically be deleted and the reachability tool will be deselected. If you have more than one reachability area you need to choose which to delete. Simply selected anywhere within the reachability boundary of the area you want to delete. The delete mode will remain selected until there are no more reachability areas or until you deselect the delete mode.

#### Sources
The following datasets were used in the application:
- [<span class="link">Dentists</span>](http://www.cqc.org.uk/about-us/transparency/using-cqc-data) (September 2018, CQC)
- [<span class="link">Food Banks</span>](http://www.gmpovertyaction.org/maps/) (January 2018, GM Poverty Action)
- [<span class="link">General practices</span>](http://www.cqc.org.uk/about-us/transparency/using-cqc-data) (October 2018, CQC)
- [<span class="link">Probation offices</span>](http://www.cgmcrc.co.uk/contact-us/our-offices/) (Cheshire & Greater Manchester CRC)
- [<span class="link">Jobcentre Plus</span>](https://www.gov.uk/government/publications/dwp-jobcentre-register) (May 2018, DWP)

Spatial vector boundary layers were provided by the ONS' [<span class="link">Open Geography Portal</span>](http://geoportal.statistics.gov.uk/).

#### Developers
The app was developed using javascript and the following libraries:
- [<span class="link">leaflet</span>](https://leafletjs.com/)
- [<span class="link">leaflet.awesome-markers</span>](https://github.com/lvoogdt/Leaflet.awesome-markers)
- [<span class="link">leaflet.control.geocoder</span>](https://github.com/perliedman/leaflet-control-geocoder)
- [<span class="link">leaflet.locate</span>](https://github.com/domoritz/leaflet-locatecontrol)
- [<span class="link">leaflet.markercluster</span>](https://github.com/danzel)
- [<span class="link">fontawesome</span>](https://fontawesome.com)

The source code is available [<span class="link">here</span>](https://github.com/traffordDataLab/opengovintelligence).

---
<div class="footer">
    <img src="../eu_flag.png" alt="Flag of the European Union" style="float: left; margin-right: 12px; height: 5em;"/>
    <span class="footerText">This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 693849.</span>
</div>
