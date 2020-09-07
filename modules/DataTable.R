###Module
# Function for module UI
DataTableUI <- function(id) {
  ns <- NS(id)
  # Options for Spinner
  options(spinner.color="#0275D8", spinner.color.background="#ffffff", spinner.size=1)
  #tabPanel("DataTable", DTOutput(ns('table')))
  tabPanel("DataTable", div(DTOutput(ns('table'))%>%withSpinner(type = 2),  style = "font-size:80%"))
  
}

# Function for module server logic
DataTable <- function(input, output, session,data,dsd) {
  observe({
    tab<-as.data.frame(data())
    tab<-t(tab)
    tab<-as.data.frame(tab)
    print(meta())
    tab$MemberCode<-rownames(tab)
    tab2<-merge(tab,subset(dsd(),select=c(MemberCode,MemberName,Definition,MeasureUnitSymbol)))
    rownames(tab2)<-paste0(tab2$MemberName," [",tab2$MemberCode,"]")
    
    for(i in grep("V",names(tab2),value=T)){
      tab2[,i]<-paste(tab2[,i],tab2$MeasureUnitSymbol,sep=" ")    
    }
    
    tab2<-subset(tab2,selec=-c(MemberCode,MemberName,MeasureUnitSymbol))
    
    output$table <- renderDT(tab2,colnames = '', options = list(dom = 't',lengthChange = FALSE,
                                                                 rowCallback = JS(
                                                                   "function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {",
                                                                   "var full_text = aData[",
                                                                   ncol(tab2),
                                                                   "]",
                                                                   "$('td:eq(0)', nRow).attr('title', full_text);",
                                                                   "}"),
                                                                 columnDefs = list(list(visible=FALSE, targets=ncol(tab2)))))
     
})
}
####