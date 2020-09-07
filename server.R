server <- function(input, output, session) {
  
  data<-callModule(module = QueryInfo, id = "id_1")
  callModule(module = DataTable,id="id_2",reactive(data$data),reactive(data$dsd))
  
}