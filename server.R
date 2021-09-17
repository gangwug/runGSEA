###load 'shiny' package
if (!require(shiny)) {
  install.packages("shiny")
}
##load 'dplyr' package
if (!require(dplyr)) {
  install.packages("dplyr")
  library(dplyr)
}  else  {
  library(dplyr)
}
##load 'purrr' package
if (!require(purrr)) {
  install.packages("purrr")
  library(purrr)
}  else  {
  library(purrr)
}
##load 'homologene' package
if (!require(homologene)) {
  install.packages("homologene")
  library(homologene)
}  else  {
  library(homologene)
}
##load 'fgsea' package
if (!require(fgsea)) {
  if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  BiocManager::install("fgsea")
  library(fgsea)
}  else  {
  library(fgsea)
}
### By default, the file size limit is 5MB. It can be changed by
### setting this option. Here we'll raise limit to 300MB.
options(shiny.maxRequestSize = 300*1024^2, stringsAsFactors = FALSE)

### load the example data (ranked by mean expression of each gene across all samples from GSE25097)
exampleD = readRDS("dataFormat.rds")

###set a flag for 'Run' button
runflag <- 0
###uploading file
shinyServer(function(input, output) {
  ## show the example data
  output$example <- renderTable({
    return( head(exampleD) )
  })
  ## show the input data file
  output$contents <- renderTable({
    ## input$file1 will be NULL initially. After the user selects and uploads a file, 
    ## it will be a data frame with 'name', 'size', 'type', and 'datapath' columns.
    ## The 'datapath' column will contain the local filenames where the data can be found.
    inFile <- input$file1
    if (is.null(inFile)) {
      return(NULL)
    }
    testD <-  read.csv(inFile$datapath)
    if ( ncol(testD) < 2 ) {
      testD <- read.delim(inFile$datapath)
    } 
    return( head(testD) )
  })
  ## run fgsea
  datasetInput <- reactive({
    ## Change when the "update" button is pressed
    if ( input$update > runflag) {
      isolate({
        withProgress({
          setProgress(message = "Processing corpus...")
          
          inFile <- input$file1
          if (is.null(inFile)) {
            return(NULL)
          }
          testD <-  read.csv(inFile$datapath)
          if ( ncol(testD) < 2 ) {
            testD <- read.delim(inFile$datapath)
          } 
          colnames(testD)[1:2] = c("geneSym", "rankv")
          ##check whether to do homolog analysis
          sampleFlag <- input$sflag
          if (sampleFlag == "mouse") {
            testD = homologene(testD$geneSym, inTax = 10090, outTax = 9606) %>%
              dplyr::select(hGene = "9606", mGene = "10090") %>%
              group_by(mGene) %>%
              dplyr::mutate(nhv = n() ) %>%
              dplyr::filter(nhv == 1) %>%
              group_by(hGene) %>%
              dplyr::mutate(mhv = n() ) %>%
              dplyr::filter(mhv == 1) %>%
              dplyr::select(-nhv, -mhv) %>%
              inner_join(testD, by = c("mGene" = "geneSym") ) %>% 
              dplyr::select(geneSym = hGene, rankv) %>% 
              dplyr::arrange(rankv)
          }
          ##get the rank value
          ranks = testD$rankv
          names(ranks) = testD$geneSym
          ##get the gene set data
          inFileB <- input$file2
          if (is.null(inFileB)) {
            return(NULL)
          }
          pathwaysH <-  read.csv(inFileB$datapath)
          if ( ncol(pathwaysH) < 2 ) {
            pathwaysH <- read.delim(inFileB$datapath)
          } 
          colnames(pathwaysH) = c("setName", "geneNum", "genes", "setSource")
          ##do the GSEA analysis
          pathwaysL = pathwaysH$genes %>% 
            purrr::map(function(z) {
              zv = strsplit(z, ";") %>% unlist()
              return(zv)
            })
          names(pathwaysL) = pathwaysH$setName
          ##get the min and max size for the gene set
          minv = input$minSize
          maxv = input$maxSize
          ##run analysis
          oldw <- getOption("warn")
          options(warn = -1)
          fgseaRes <- fgseaMultilevel(pathwaysL, ranks, minSize = minv, maxSize = maxv)
          fgseaOut <- dplyr::mutate(fgseaRes, 
                                    leadingEdge = unlist(lapply(leadingEdge, function(z) 
                                                                            { paste(unlist(z), collapse = ";") }))
                                    ) %>% 
            as.data.frame() %>% 
            dplyr::arrange(NES)
          options(warn = oldw)
        })
      })
      runflag <- input$update
      return(fgseaOut)
    }  else  {
      return(NULL)
    }
  })
  ## show the prediction result
  output$tabout <- renderTable({
    taboutD <- datasetInput()
    head(taboutD[,1])
  })
  ## downloading file
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste("runGSEA", '.csv', sep='') 
    },
    content = function(file) {
      write.csv(datasetInput(), file, row.names=FALSE)
    }
  )
})

