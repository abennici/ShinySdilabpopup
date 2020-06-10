#---------------------------------------------------------------------------------------------------------
#packages
library("ows4R")
library("sp")
library("shiny")
library("DT")
library("shinyWidgets")
library("shinycssloaders")
library("ggplot2")
########################
getColumnDefinitions = function(fc) {
    do.call("rbind",lapply(fc$featureType[[1]]$carrierOfCharacteristics,function(x){data.frame(MemberCode=ifelse(!is.null(x$code),x$code,""),
                                                                                               MemberName=ifelse(!is.null(x$memberName$value),x$memberName$value,""),
                                                                                               MemberType=ifelse(!is.null(x$valueType$aName$attrs[['xlink:href']]),x$valueType$aName$attrs[['xlink:href']],""),
                                                                                               PrimitiveType=ifelse(!is.null(x$valueType$aName$value),sub(".*:", "", x$valueType$aName$value),""),
                                                                                               MinOccurs=ifelse(!is.null(x$cardinality$range$lower),x$cardinality$range$lower,""),
                                                                                               MaxOccurs=ifelse(!is.null(x$cardinality$range$upper$value),x$cardinality$range$upper$value,""),
                                                                                               Definition=ifelse(!is.null(x$definition),x$definition,""),
                                                                                               MeasureUnitSymbol=ifelse(!is.null(x$valueMeasurementUnit$identifier$value),x$valueMeasurementUnit$identifier$value,""),
                                                                                               MeasureUnitName=ifelse(!is.null(x$valueMeasurementUnit$name$value),x$valueMeasurementUnit$name$value,""))}))
}   
###
# #Connect to OGC CSW Catalogue to get METADATA
CSW <- CSWClient$new(
    url = "https://geonetwork-sdi-lab.d4science.org/geonetwork/srv/eng/csw",
    serviceVersion = "2.0.2",
    logger = "INFO"
)
#######################
# Options for Spinner
options(spinner.color="#0275D8", spinner.color.background="#ffffff", spinner.size=1)

#taille popup :max=
ui <- fluidPage(
    fluidRow(
        column(
            width = 4,
            tags$h4("Sdilab popup select by url query"),
            tags$img(src="https://www.blue-cloud.org/sites/all/themes/arcadia/logo.png",height=30,align = "right"),   
            br(),
            radioGroupButtons(
                inputId = "visuBtn",
                label = "Type of visual:",
                choices = c(Data = "table",Plot="plot",'Time serie'="timeserie",'Request info'="queryText"),
                selected ="table",
                status = "sucess"
            ),
            conditionalPanel(
                condition = "input.visuBtn == 'table'",
                DTOutput('table')%>%withSpinner(type = 2)),
            
            conditionalPanel(
                condition = "input.visuBtn=='queryText'",
                verbatimTextOutput(outputId = "queryText")),
            conditionalPanel(
                condition = "input.visuBtn == 'plot'",
                dropdown(
                    
                    tags$h3("Select variables"),
                    
                    pickerInput(inputId = 'xcol2',
                                label = 'X Variable',
                                choices = c(),
                                options = list(`style` = "btn-info")),
                    
                    pickerInput(inputId = 'ycol2',
                                label = 'Y Variable',
                                choices = c(),
                                options = list(`style` = "btn-warning")),
                    
                    style = "unite", icon = icon("gear"),
                    status = "default", width = "250px",
                    animate = animateOptions(
                        enter = animations$fading_entrances$fadeInLeftBig,
                        exit = animations$fading_exits$fadeOutRightBig
                    )
                    ),
                    plotOutput(outputId = 'plot1')
                ),
            ####################################ADD
            conditionalPanel(
                condition = "input.visuBtn=='timeserie'",
                dropdown(
                    radioGroupButtons(
                        inputId = "simu",
                        label = "Format of data :",
                        choices = c('single column' = "single",'multi columns'="multi"),
                        selected ="single",
                        status = "sucess"
                    ),
                    conditionalPanel(
                        condition = "input.simu == 'multi'",
                        
                        pickerInput(inputId = 'day',label = 'day',choices = c()),
                        pickerInput(inputId = 'month2',label = 'month',choices = c()),
                        pickerInput(inputId = 'year2',label = 'year',choices = c()),
                        pickerInput(inputId = 'ycol3',
                                    label = 'Y Variable',
                                    choices = c())
                    ),
                    conditionalPanel(
                        condition = "input.simu == 'single'",
                        pickerInput(inputId = 'date',label = 'date',choices = c()),
                        pickerInput(inputId = 'format',label = 'format',choices = c("dd/mm/yyyy","mm/dd/yyyy","dd/mm/yy","mm/dd/yy"))
                    ),
                    animate = animateOptions(
                        enter = animations$fading_entrances$fadeInLeftBig,
                        exit = animations$fading_exits$fadeOutRightBig
                    )
                ),
                
                #plotOutput(outputId = 'plot2')
                DTOutput('table2')
            ),
            
            prettySwitch(inputId = "switch2", label = "App's benchmark:",status = "primary"),
            conditionalPanel(
                condition = "input.switch2",
                verbatimTextOutput(outputId = "time")),
            prettySwitch(inputId = "switch3", label = "Numbers of values:",status="primary"),
            conditionalPanel(
                condition = "input.switch3",
                verbatimTextOutput("value"))
        )
    )
)

server <- function(input, output, session) {
    resume.table<-data.frame(NULL)
    
    observe({
        
        start_time <- Sys.time()
        
        query <- parseQueryString(session$clientData$url_search)
        
        output$queryText <- renderText({
            #query <- parseQueryString(session$clientData$url_search)
            paste(sep = "",
                  "pid: ", query$pid, "\n",
                  "layer: ", query$layer, "\n",
                  "wfs_server: ",query$wfs_server, "\n",
                  "wfs_version: ", query$wfs_version, "\n",
                  "strategy: ", query$strategy, "\n",
                  "par: ", query$par, "\n",
                  "geom: ", query$geom, "\n",
                  "x: ", query$x, "\n",
                  "y: ", query$y, "\n",
                  "srs: ",query$srs, "\n"
            )
        })
        
        pid <- if (!is.null(query$pid)){
            as.character(query$pid)
        }else{
            NULL
            
        }
        
        layer <-if (!is.null(query$layer)){
            as.character(query$layer)
        }else{
            NULL
            
        }
        
        wfs_server <-if (!is.null(query$wfs_server)){
            as.character(query$wfs_server)
        }else{
            NULL
            
        }
        
        wfs_version <-if (!is.null(query$wfs_version)){
            as.character(query$wfs_version)
        }else{
            NULL
            
        }
        
        strategy <-if (!is.null(query$strategy)){
            as.character(query$strategy)
        }else{
            NULL
            
        }
        
        par <-if (!is.null(query$par)){
            as.character(query$par)
        }else{
            NULL
            
        }
        
        geom <-if (!is.null(query$geom)){
            as.character(query$geom)
        }else{
            NULL
            
        }
        
        x <-if (!is.null(query$x)){
            query$x
        }else{
            NULL
            
        }
        
        y <-if (!is.null(query$y)){
            query$y
        }else{
            NULL
            
        }
        
        srs <-if (!is.null(query$srs)){
             paste0("'",query$srs,"'")
         }else{
             "'EPSG:4326'"
             
         }
        
        if(!is.null(layer)&!is.null(wfs_server)&!is.null(wfs_version)&!is.null(strategy)){
            
             # #Connect to OGC CSW Catalogue to get METADATA
              CSW <- CSWClient$new(
                  url = "https://geonetwork-sdi-lab.d4science.org/geonetwork/srv/eng/csw",
                  serviceVersion = "2.0.2",
                  logger = "INFO"
              )
             # #Get metadata for dataset
            #  md <- CSW$getRecordById(pid, outputSchema = "http://www.isotc211.org/2005/gmd")
              fc <- CSW$getRecordById(paste0(pid,"_dsd"), outputSchema = "http://www.isotc211.org/2005/gfc")
            #Connect to OGC WFS to get DATA
            WFS <- WFSClient$new(
                url = wfs_server,
                serviceVersion = wfs_version,
                logger = "INFO"
            )
            #Get feature type for dataset
            ft <- WFS$capabilities$findFeatureTypeByName(layer)
            #Get data features for dataset
            
            coord<-NULL
            coord<-paste0("BBOX(",geom,",",x,",",y,",",x,",",y,",",srs,")")
            if(is.null(par)&&is.null(coord))data.sf <- ft$getFeatures()
            if(is.null(par)&&!is.null(coord))data.sf <- ft$getFeatures(cql_filter = gsub(" ", "%20", gsub("''", "%27%27", URLencode(coord))))
            if(!is.null(par)&&is.null(coord)){
                data.sf <- switch(strategy,
                                  "ogc_filters"=ft$getFeatures(cql_filter = gsub(" ", "%20", gsub("''", "%27%27", URLencode(par)))),
                                  "ogc_viewparams"=ft$getFeatures(viewparams = URLencode(par))
                )
            }
            if(!is.null(par)&&!is.null(coord)){
                data.sf <- switch(strategy,
                                  "ogc_filters"=ft$getFeatures(cql_filter = gsub(" ", "%20", gsub("''", "%27%27", URLencode(paste0(par," AND ",coord))))),
                                  "ogc_viewparams"=ft$getFeatures(viewparams = URLencode(par),cql_filter = gsub(" ", "%20", gsub("''", "%27%27", URLencode(coord))))
                )
            }
            
            end_time <- Sys.time()
            
            x <- names(data.sf)
            
            # Can use character(0) to remove all choices
            if (is.null(x))
                x <- character(0)
            
            # Can also set the label and select items
            updatePickerInput(session, "xcol2",
                              label = "X Variable",
                              choices = x,
                              selected = head(x, 1)
            )
            
            y <- names(data.sf)
            
            # Can use character(0) to remove all choices
            if (is.null(y))
                y <- character(0)
            
            # Can also set the label and select items
            updatePickerInput(session, "ycol2",
                              label = "Y Variable",
                              choices = y,
                              selected = head(y, 1)
            )
        
            data.sp<-as.data.frame(data.sf)
            #
            yy <- names(data.sf)
            
            # Can use character(0) to remove all choices
            if (is.null(y))
                yy <- character(0)
            
            # Can also set the label and select items
            updatePickerInput(session, "ycol3",
                              label = "Y Variable",
                              choices = yy,
                              selected = head(yy, 1)
            )
            day <- c("NA",names(data.sf))
             
             # Can use character(0) to remove all choices
             if (is.null(day))day <- character(0)
             
             # Can also set the label and select items
             updatePickerInput(session, "day",
                               label = "day",
                               choices = day,
                               selected = head(day, 1)
             )
             
             month2 <- names(data.sf)
             
             # Can use character(0) to remove all choices
             if (is.null(month2))month2 <- character(0)
             
             # Can also set the label and select items
             updatePickerInput(session, 'month2',
                               label = 'month',
                               choices = month2,
                               selected = head(month2, 1)
             )
             
             year2 <- names(data.sf)
             
             # Can use character(0) to remove all choices
             if (is.null(year2))year2 <- character(0)
             
             # Can also set the label and select items
             updatePickerInput(session, "year2",
                               label = "year",
                               choices = year2,
                               selected = head(year2, 1)
             )
             
             date <- names(data.sf)
             
             # Can use character(0) to remove all choices
             if (is.null(date))date <- character(0)
             
             # Can also set the label and select items
             updatePickerInput(session, "date",
                               label = "date",
                               choices = date,
                               selected = head(date, 1)
             )
            
              output$plot1 <- renderPlot({
               ggplot(data.sp,aes(x=data.sp[,input$xcol2],y=data.sp[,input$ycol2]))+geom_point()+labs(x=input$xcol2,y=input$ycol2)
                    })
             #if(!is.null(day)&!is.null(month2)&!is.null(year2)){
              #writedate<-paste(01,data.sp[,input$month2],data.sp[input$year2],sep="/")
              #data.sp$time<-as.Date(paste(01,data.sp[,input$month2],data.sp[,input$year2],sep="/"),format="%d/%m/%Y")
              #data.sp$time<-as.Date(writedate,format="%d/%m/%Y")}
              output$plot2 <- renderPlot({
              ggplot(data.sp,aes(x=data.sp$time,y=data.sp[,input$ycol3]))+geom_point()+labs(x="Time serie",y=input$ycol3)
              })
            meta<-getColumnDefinitions(fc)
            test<-as.data.frame(data.sf)
            test<-t(test)
            test<-as.data.frame(test)
            #names(test)<-paste0("V",names(test))
            test$MemberCode<-rownames(test)
            test2<-merge(test,subset(meta,select=c(MemberCode,MemberName,Definition,MeasureUnitSymbol)))
            rownames(test2)<-paste0(test2$MemberName,"[",test2$MemberCode,"]")
            #lapply(grep("V",ff,value=T))
            for(i in grep("V",names(test2),value=T)){
                test2[,i]<-paste(test2[,i],test2$MeasureUnitSymbol,sep=" ")    
            }
            #lapply(grep("V",names(test2),value=T),function(x){
            #test2$x<-paste(test2$x,test2$MeasureUnitSymbol,sep=" ")})
            test2<-subset(test2,selec=-c(MemberCode,MemberName,MeasureUnitSymbol))
            #data.sp <- as(data.sf, "Spatial")
            #resume.table<<-as.data.frame(head(data.sp))
          #  output$table <- renderDT(t(as.data.frame(data.sf)), colnames = "",
          #                           options = list(autoWidth = TRUE, bSort = FALSE),class = "cell-border stripe")
              
            #output$table <- renderDT(t(as.data.frame(data.sf)), options = list(lengthChange = FALSE))
            output$table <- renderDT(test2, options = list(lengthChange = FALSE,
                                                           rowCallback = JS(
                                                               "function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {",
                                                               "var full_text = aData[",
                                                               ncol(test2),
                                                               "]",
                                                               "$('td:eq(0)', nRow).attr('title', full_text);",
                                                               "}"),
                                                           columnDefs = list(list(visible=FALSE, targets=ncol(test2)))))
            
            #output$table2 <- renderDT(data.sp, options = list(lengthChange = FALSE))
            
            #output$table <- renderTable({as.data.frame(data.sf)})
            output$value <- renderText({paste(sep = "","number of values : ",nrow(data.sf))})
            
            output$time <- renderText({paste(sep = "","running time : ",round(end_time - start_time,2)," sec")})
            
        }else{}
    })
    
}

shinyApp(ui, server)
