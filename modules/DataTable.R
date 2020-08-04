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
DataTable <- function(input, output, session,data.sf,meta) {
  observe({
    test<-as.data.frame(data.sf())
    test<-t(test)
    test<-as.data.frame(test)
    print(meta())
    test$MemberCode<-rownames(test)
    test2<-merge(test,subset(meta(),select=c(MemberCode,MemberName,Definition,MeasureUnitSymbol)))
    rownames(test2)<-paste0(test2$MemberName," [",test2$MemberCode,"]")
    
    for(i in grep("V",names(test2),value=T)){
      test2[,i]<-paste(test2[,i],test2$MeasureUnitSymbol,sep=" ")    
    }
    
    test2<-subset(test2,selec=-c(MemberCode,MemberName,MeasureUnitSymbol))
    
    output$table <- renderDT(test2,colnames = '', options = list(dom = 't',lengthChange = FALSE,
                                                                 rowCallback = JS(
                                                                   "function(nRow, aData, iDisplayIndex, iDisplayIndexFull) {",
                                                                   "var full_text = aData[",
                                                                   ncol(test2),
                                                                   "]",
                                                                   "$('td:eq(0)', nRow).attr('title', full_text);",
                                                                   "}"),
                                                                 columnDefs = list(list(visible=FALSE, targets=ncol(test2)))))
     
})
}
####