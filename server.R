library(shiny)
library(leaflet)
#library(RColorBrewer)
library(scales)
#library(lattice)
library(dplyr)

shinyServer(function(input, output, session) {
  
  ## Interactive Map ###########################################

  # Create the map
  output$map1 <- reactive(TRUE)
  map1 <- createLeafletMap(session, "map")
  output$mapp <- renderUI({
    input$mapPick
    isolate({
      leafletMap("map", width = "100%", height = "100%",
                 initialTileLayer = input$mapPick,
                 initialTileLayerAttribution = HTML(''),
                 options = list(
                   center = center(), 
                   zoom = zoom(), 
                   maxBounds = list(list(15.961329, -129.92981), list(52.908902, -56.80481)) # Show US only
                   )
                 )
    })
  })
  zoom <- reactive({
    ifelse(is.null(input$map_zoom), 6, input$map_zoom)  # initial zoom = 6, otherwise use current
  })
  center <- reactive({  # essentially, uses default center for initialization, then retains center across new map tiles
    if(is.null(input$map_bounds)) {
      c(37.533333, -77.466667)  # initially center on Richmond, VA
    } else {
      map_bounds <- input$map_bounds  # otherwise, use current center
      c((map_bounds$north + map_bounds$south) / 2.0, 
        (map_bounds$east + map_bounds$west) / 2.0)
    }
  })
  # A reactive expression that returns the set of locs that are
  # in bounds right now
  inBounds <- reactive({
    if (is.null(input$map_bounds))
      return(dat[FALSE, ])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(dat,
      Latitude >= latRng[1] & Latitude <= latRng[2] &
        Longitude >= lngRng[1] & Longitude <= lngRng[2])
  })
  
#   # Precalculate the breaks we'll need for the two histograms
#   centileBreaks <- hist(plot = FALSE, allzips$centile, breaks = 20)$breaks

  output$histCentile <- renderPlot({
    # If no points are in view, don't plot
    if (nrow(inBounds()) == 0)
      return(NULL)
    # Furthermore, if no sightings, don't plot
    sightings <- inBounds()[[input$size]]
    if (sum(sightings) == 0)
      return(NULL)
    # If non-zero sightings, get sightings per night
    sightingspernight <- sightings / inBounds()[["Duration"]]
    nonzerosightingspernight <- sightingspernight[sightingspernight > 0]
    hist(nonzerosightingspernight,
      breaks = 50,
      main = "Camera sightings",
      xlab = "Sightings per night (> 0)",
      #xlim = range(allzips$centile),
      col = '#00DD00',
      border = 'white')
  })
#   
#   output$scatterCollegeIncome <- renderPlot({
#     # If no zipcodes are in view, don't plot
#     if (nrow(inBounds()) == 0)
#       return(NULL)
#     
#     print(xyplot(income ~ college, data = inBounds(), xlim = range(allzips$college), ylim = range(allzips$income)))
#   })
  
  # session$onFlushed is necessary to delay the drawing of the polygons until
  # after the map is created
  session$onFlushed(once=TRUE, function() {
    paintObs <- observe({
      map1$clearShapes()  # clear shapes right before plotting new ones
      zoomScale <- input$map_zoom - 6
      # Clear existing circles before drawing
      sightings <- dat[[input$size]]
      sightingspernight <- sightings / dat[["Duration"]]
      datzerosightings <- dat[sightings == 0, ]
      zerosightingspernight <- sightingspernight[sightings == 0]
      rad <- 200 + 2000 * 2^(-zoomScale)
      try(
        map1$addCircle(
          datzerosightings$Latitude, 
          datzerosightings$Longitude,
          radius = rad,
          datzerosightings$Camera.Deployment.Name,
          options = list(stroke=FALSE, fill=TRUE, fillOpacity=0.4, color = "grey")#, eachOptions = list(color = colors[from:to])
          )
        )
      datnonzerosightings <- dat[sightings > 0, ]
      nonzerosightingspernight <- sightingspernight[sightings > 0]
      rad <- 500 + 2000 * 2^(-zoomScale) * (1 + 700 * nonzerosightingspernight / sum(nonzerosightingspernight))
      rad[rad > 1e5] <- 1e5
      try(
        map1$addCircle(
          datnonzerosightings$Latitude, 
          datnonzerosightings$Longitude,
          radius = rad,
          datnonzerosightings$Camera.Deployment.Name,
          options = list(stroke=FALSE, fill=TRUE, fillOpacity=0.4, color = "blue")#, eachOptions = list(color = colors[from:to])
        )
      )
    })
    
    # TIL this is necessary in order to prevent the observer from
    # attempting to write to the websocket after the session is gone.
    session$onSessionEnded(paintObs$suspend)
  })  # end session$onFlushed
  
  # Show a popup at the given location
  showInfo <- function(camera, var, lat, lng) {
    cam <- dat %>% filter(Camera.Deployment.Name == camera)
    content <- as.character(tagList(
      tags$h4(cam$Camera.Deployment.Name),
      paste("Sightings:", cam[[var]]), tags$br(),
      paste("Camera nights:", round(cam[["Duration"]], 2)), tags$br(),
      paste("Rate:", round(cam[[var]]/cam[["Duration"]], 2), "sightings per night")
#       tags$strong(HTML(sprintf("%s, %s %s",
#         selectedZip$city.x, selectedZip$state.x, selectedZip$zipcode
#       ))), tags$br(),
#       sprintf("Median household income: %s", dollar(selectedZip$income * 1000)), tags$br(),
#       sprintf("Percent of adults with BA: %s%%", as.integer(selectedZip$college)), tags$br(),
#       sprintf("Adult population: %s", selectedZip$adultpop)
    ))
    map1$showPopup(lat, lng, content, camera)
  }

  # When map is clicked, show a popup with city info
  clickObs <- observe({
    map1$clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      showInfo(event$id, input$size, event$lat, event$lng)
    })
  })
  
  session$onSessionEnded(clickObs$suspend)
})
