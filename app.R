library(bs4Dash)
library(dplyr)
library(fst)
library(ggplot2)
library(shiny)

body <- bs4DashBody(
  fluidRow(
    column(
      4,
      bs4Sortable(
        width = 12,
        bs4Card(
          title = "Model",
          width = 12,
          status = "primary",
          closable = FALSE,
          selectInput("model", "", c("continuous", "discrete"))
        ),
        bs4Card(
          title = "Value",
          width = 12,
          status = "primary",
          closable = FALSE,
          selectInput("value", "", c("mean", "median"))
        )
      )
    ),
    shiny::column(
      8,
      bs4Card(
        title = "Plot",
        width = 12,
        status = "success",
        closable = FALSE,
        plotOutput("plot", height = "600px")
      )
    )
  )
)

ui <- bs4DashPage(
  title = "MCMC Results",
  body = body,
  sidebar = bs4DashSidebar(disable = TRUE)
)

server <- function(input, output) {
  results <- read_fst("results.fst")
  output$plot <- renderPlot({
    results %>%
      filter(model == input$model) %>%
      ggplot(.) +
        geom_point(aes_string(x = "beta_true", y = input$value)) +
        geom_abline(slope = 1, intercept = 0) +
        theme_gray(16)
  })
}

shinyApp(ui = ui, server = server)
