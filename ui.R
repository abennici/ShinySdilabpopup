ui <- fluidPage(
  tags$head(tags$link(rel="stylesheet", type="text/css", href="popup.css")),
  fluidRow(
    column(
      width = 4,
      tags$h4("Sdilab popup",
              tags$img(src="https://www.blue-cloud.org/sites/all/themes/arcadia/logo.png",height=28,align = "right")),
      
      mainPanel(
        
        # Output: Tabset w/ plot, summary, and table ----
        tabsetPanel(type = "tabs",
                    QueryInfoUI(id = "id_1"),
                    DataTableUI(id="id_2")
        )
      )
    )
  ) 
)
