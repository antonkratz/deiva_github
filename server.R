# author:			Anton Kratz
# created:			Sun Dec 20 17:43:02 JST 2015
# last change:			Mon Jun  6 22:10:42 JST 2016

library(shiny)
library(DT)
library(ggplot2)
library(tools)

options(shiny.maxRequestSize=30*1024^2)


shinyServer(function(input, output) {  

	foo <- reactive(inputdata())
	
	up <-   reactive(nrow(subset(foo(), ((foo()$pvalue<=input$pv) & ((foo()$log2FoldChange)>=input$fc)))))
	down <- reactive(nrow(subset(foo(), ((foo()$pvalue<=input$pv) & ((-foo()$log2FoldChange)>=input$fc)))))
	
	output$plot1 <- renderPlot({
	
		bname = basename(input$variable)
		bname_sans_ext = file_path_sans_ext(bname)
		one_two = strsplit(bname_sans_ext, "_vs_")[[1]] 	  	
		one = one_two[1]

		g <- ggplot(foo(), aes(x=baseMean, y=log2FoldChange)) + geom_point(color=ifelse(((foo()$pvalue<=input$pv) & ((abs(foo()$log2FoldChange))>=input$fc)), "red", "black"), alpha = input$alphaslider, shape = 19, size=1) + scale_x_continuous(trans='log2') + coord_cartesian(xlim = ranges$x, ylim = ranges$y) + labs(y = paste("log2FoldChange (positive FC indicates enrichment in ", one, ")", sep="")) 
		

		# add this to the ggplot statement above to add a contour
		# + geom_density2d(color="white")

		terms <- unlist(strsplit(input$searchpoint, "|", fixed = TRUE))
		l <- length(terms)

		pal <- rainbow(l)

		lx <- min(foo()$baseMean)
		ly <- max(foo()$log2FoldChange)

		for(i in 1:l) {
		
			xloc = foo()[grep(terms[i], foo()$symbol, ignore.case=TRUE), ]$baseMean
			yloc = foo()[grep(terms[i], foo()$symbol, ignore.case=TRUE), ]$log2FoldChange
			lbl = foo()[grep(terms[i], foo()$symbol, ignore.case=TRUE), ]$symbol
						
			g <- g + annotate("point", size = 5, shape = 20, color = pal[i], x = xloc, y = yloc)

			# add a legend
			g <- g + annotate("point", size = 5, shape = 19, color = pal[i], x = lx, y = ly-10*i*(ly/100))
			g <- g + annotate("text", x = lx, y = ly-10*i*(ly/100), label=terms[i], color="black")
						
		}
		
		g

		# ggsave(file="test.svg", plot=g, width=10, height=8)
		
	})
	
	output$info <- renderDataTable({
	
		res <- brushedPoints(foo(), input$plot_brush) 
		datatable(res, escape=FALSE, filter = 'top', options = list(pageLength = 10, autoWidth = TRUE))
		
	})

	ranges <- reactiveValues(x = NULL, y = NULL)

	# When a double-click happens, check if there's a brush on the plot.
	# If so, zoom to the brush bounds; if not, reset the zoom.
	observeEvent(input$plot1_dblclick, {
		brush <- input$plot_brush
		if (!is.null(brush)) {
			ranges$x <- c(brush$xmin, brush$xmax)
			ranges$y <- c(brush$ymin, brush$ymax)
		} else {
			ranges$x <- NULL
			ranges$y <- NULL
		}
	})

	inputdata <- reactive({
		fload <- read.table(input$variable, header = TRUE, row.names=1, na.strings="NA", sep = "\t", dec = ".")
		fload
	})

	output$text1 <- renderUI({
		str1 <- paste("<b>UP:", up())
		str2 <- paste("<b>DOWN:", down())
		HTML(paste(str1, str2, sep = '</b><br/>'))
	})
	
	# This does not work, info_rows_all in DT has a bug and simply doesn't give me all the indices of all the rows, only the rows on the current page
	
	output$dbutton <- downloadHandler (
		filename = function() {
	 		paste('export-', Sys.Date(), '.csv', sep='')
	 	},
	 	content = function(file) {
			s = input$info_rows_all
	 		write.csv(foo()[s, ], file)
	 	}
	 )


})
