# WaterWheel
R code to present environmental attribute information on a WaterWheel diagram
Prepared by:
Tim Kerr
Aqualinc Research Ltd.
Christchurch
New Zealand

This was prepared as part of the "Wheel of Water" research project, funded by the New Zealand Ministry of Bussiness, Innovation and Employment, under contract No. ALNC1102
Further details of the Wheel of Water project are available from:
https://wheelofwater.wordpress.com/

This work was carried out with the cooperation of the Takaka Freshwater and Land Advisory Group
http://www.tasman.govt.nz/environment/water/water-resource-management/water-catchment-management/water-management-partnerships-flags/takaka-fresh-water-and-land-advisory-group/

The code is in constant development, but provided under a "minimum viable product" ethos.

To make it work:
Copy all the files and folders to a directory.
From within R, "Source" app.R
Lastly, (again from within R) call:
shinyApp(ui = ui,server = server)
This will start the Rshiny app, which provides additional options to publish to the web if you so desire.

The default data is saved as two data frames in the Data/Takaka.RData file.
