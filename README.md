## Introduction about runGSEA

runGSEA is a Shiny app of doing GSEA analysis using [fgsea](http://bioconductor.org/packages/release/bioc/html/fgsea.html) package. 

## License
This package is free and open source software, licensed under GPL(>= 2).
 
## Usage
```r
# install 'shiny' package (if 'shiny' is not installed yet)
install.packages("shiny")
# load 'shiny' package
library(shiny)

# the easy way to run this app 
runGitHub("runGSEA", "gangwug")

# Or you can download all files from this page, and place these files into an directory named 'nCVapp'. 
# Then set 'nCVapp' as your working directory (see more introduction about working directory-http://shiny.rstudio.com/tutorial/quiz/). 
# Now you can launch this app in R with the below commands.
runApp("runGSEA")

```
There is an input data and gene set example file ('example_data.csv' and 'example_MsigDB_c2.cp.v7.1.symbols.csv') in this folder. For testing this input data example file, please follow the steps mentioned in this app.   

## For more information

Korotkevich G, Sukhov V, Budin N, Shpak B, Artyomov MA, Sergushichev A. Fast gene set enrichment analysis. bioRxiv, 2021, doi: https://doi.org/10.1101/060012.

## Update news

Will implement [GSEA_R](https://github.com/GSEA-MSigDB/GSEA_R) in the future. 
