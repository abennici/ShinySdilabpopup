# ShinySdilabpopup
For Docker run :
wget https://raw.githubusercontent.com/abennici/ShinySdilabpopup/master/Dockerfile
docker build -t shinysdilabpopup .
docker run -p 3839:3838 shinysdilabpopup
