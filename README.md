# Shiny Sdilab Popup
**Shiny Sdilab Popup** is a toolbox application intended to provide multiple possibilities of graphical visualizations in popup format pluggable to OpenFairViewer.
His application has been developed in Blue Cloud project.

## R libraries

The following libraries can be installed from CRAN
```
install.packages(c('R6', 'httr', 'openssl','sf','rgdal','geometa','ows4R','shiny','DT','shinyWidgets','shinycssloaders','jsonlite','remotes'), repos='http://cran.r-project.org')
```

## Docker
A Dockerfile is provided and can be used to build up containers with the application.

To build and run the application issue the following commands :
```
wget https://raw.githubusercontent.com/abennici/ShinySdilabpopup/master/Dockerfile
docker build -t shinysdilabpopup .
docker run -p 3839:3838 shinysdilabpopup
```