# author:			Anton Kratz
# created:			Sun Dec 20 17:43:02 JST 2015
# last change:			Mon Jun  6 22:12:39 JST 2016

library(shiny)
library(DT)
library(ggplot2)

# read in a file "desc.txt" for long descriptions of input files
dat <- read.table("/home/kratz/ShinyApps/deiva_github/desc.txt", stringsAsFactors = FALSE, sep="\t")
nams <- dat[, 1]
dat <- dat[, -1]
names(dat) <- nams

shinyUI(fluidPage(
	
	sidebarLayout(
	
		sidebarPanel(
			textInput("searchpoint", "Locate a gene symbol:", "Calb1|Dlg2|Pcp2"),
			helpText(
				strong("Identify"), ": Draw a rectangle in the scatter plot to identify genes.", tags$br(),
				strong("Locate"), ": Type a gene symbol in the search box above (case doesn't matter). This greps for gene symbols. Plot is updated after each key stroke!", tags$br(),
				strong("Zoom"), ": Double-click inside the blue rectangle to zoom in. Double-click outside of the blue rectangle to zoom out.", tags$br(),
				strong("Contact"), ": Anton Kratz" , a("<anton.kratz@riken.jp>", href="mailto:anton.kratz@riken.jp")),

			strong("Last change"), "Mon Jun  6 22:17:47 JST 2016", tags$br(), tags$br(),


			sliderInput("alphaslider", "alpha channel", min = 0.1, max = 1, value = 0.8, step = 0.01),
			sliderInput("fc", "log2FoldChange is higher than:", min = 0, max = 5, value = 0, step= 1),
			sliderInput("pv", "p value is lower than:", min = 0, max = 0.1, value = 0.05, step= 0.01),
			htmlOutput("text1")
		),

		mainPanel(
			
			selectInput("variable", "Select experiment of interest:", width = "100%", dat),
			plotOutput("plot1", brush = brushOpts(id = "plot_brush", resetOnNew = TRUE), height = 450, dblclick = "plot1_dblclick"),			
			downloadButton('dbutton', 'Download entire (all pages) table as tab-separated CSV ASCII'), tags$hr(),
			dataTableOutput("info")
		)
		
	)

))
