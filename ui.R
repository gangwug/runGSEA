library(shiny)
##uploading file
shinyUI(fluidPage(
  titlePanel(h2("Welcome to runGSEA") ),
  sidebarLayout(
    
    sidebarPanel(
      fluidRow(
        column(6,
               fileInput('file1', label=h5('Choose ranked gene list'),
                         accept=c('text/csv', 
                                  'text/comma-separated-values,text/plain', '.csv')) ),
        column(6,
               fileInput('file2', label=h5('Choose MSigDB gene set'),
                         accept=c('text/csv', 
                                  'text/comma-separated-values,text/plain', '.csv')) )
      ),
      fluidRow (
        column(6,
             radioButtons('sflag', label=h5('Species'),
                          choices=c("human"='human', "mouse"='mouse'),
                          selected='human', inline=FALSE) )
      ),
      fluidRow(
        column(6,
               numericInput("minSize", label=h5("minSize"), value=10) )
      ),
      fluidRow(
        column(6,
               numericInput("maxSize", label=h5("maxSize"), value=1000) )
      ),
     br(),
     br(),
     fluidRow(
       column(3,
              actionButton("update", label=h5("Run")) ),
       column(3,
              downloadButton('downloadData', label='Download' ) )
     )
    ),
    
    mainPanel(
      helpText(h4('Starting point: File format') ),
      helpText(h5('The input file contains ranked gene list (e.g., ranked by p-value of rhythmic analysis or differential analysis):')),
      tableOutput('example'),
      helpText(h4('Step1: Upload the ranked gene list and gene set') ),
      helpText(h5('Please take a look at the input gene list selected on the left:') ),
      tableOutput('contents'),
      ##the temporaly output value for checking the value during running shiny app
      #textOutput('teptext'),
      br(),
      helpText(h4('Step2: Run') ),
      helpText(h5('If the input file is shown as expected, please set parameters on the left and click Run button.') ),
      br(),
      helpText(h4('Step3: Download') ),
      helpText(h5('You could download the output results by clicking Download button on the left.'),
      tableOutput('tabout'))
    )
  )
))
