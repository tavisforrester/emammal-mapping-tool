library(shiny)
library(leaflet)

# Choices for drop-downs
maps <- c(
  "Default" = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png", 
  "Street Map" = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}",
  "Satellite" = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
  "Shaded Relief" = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}",
  "Physical" = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer/tile/{z}/{y}/{x}",
  "None" = "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
)

wildlife <- c(
  "American Beaver" = "American.Beaver",
  "American Black Bear" = "American.Black.Bear",
  "American Mink" = "American.Mink",
  "American Red Squirrel" = "American.Red.Squirrel",
  "Blue Jay" = "Blue.Jay",
  "Bobcat" = "Bobcat",
  "Cotton Rat" = "Cotton.Rat",
  "Coyote" = "Coyote",
  "Crow or Raven" = "Crow.or.Raven",
  "Domestic Cat" = "Domestic.Cat",
  "Domestic Cow" = "Domestic.Cow",
  "Domestic Dog" = "Domestic.Dog",
  "Domestic Horse" = "Domestic.Horse",
  "Eastern Chipmunk" = "Eastern.Chipmunk",
  "Eastern Cottontail" = "Eastern.Cottontail",
  "Eastern Fox Squirrel" = "Eastern.Fox.Squirrel",
  "Eastern Gray Squirrel" = "Eastern.Gray.Squirrel",
  "Eastern Spotted Skunk" = "Eastern.Spotted.Skunk",
  "Eastern Woodrat" = "Eastern.Woodrat",
  "Fisher" = "Fisher",
  "Flying Squirrel species" = "Flying.Squirrel.species",
  "Gray Fox" = "Gray.Fox",
  "Long-tailed Weasel" = "Long.tailed.Weasel",
  "Northern Bobwhite" = "Northern.Bobwhite",
  "Northern Flying Squirrel" = "Northern.Flying.Squirrel",
  "Northern Raccoon" = "Northern.Raccoon",
  "Red Fox" = "Red.Fox",
  "River Otter" = "River.Otter",
  "Ruffed Grouse" = "Ruffed.Grouse",
  "Southern Flying Squirrel" = "Southern.Flying.Squirrel",
  "Striped Skunk" = "Striped.Skunk",
  "Turkey Vulture" = "Turkey.Vulture",
  "Unknown Animal" = "Unknown.Animal",
  "Unknown Bird" = "Unknown.Bird",
  "Unknown Canine" = "Unknown.Canine",
  "Unknown Carnivore" = "Unknown.Carnivore",
  "Unknown Feline" = "Unknown.Feline",
  "Unknown Fox" = "Unknown.Fox",
  "Unknown Mouse or Rat" = "Unknown.mouse.or.rat",
  "Unknown Owl" = "Unknown.Owl",
  "Unknown Squirrel" = "Unknown.Squirrel",
  "Unknown Weasel" = "Unknown.Weasel",
  "Virginia Opossum" = "Virginia.Opossum",
  "White-tailed Deer" = "White.tailed.Deer",
  "Wild Boar" = "Wild.Boar",
  "Wild Turkey" = "Wild.Turkey",
  "Woodchuck" = "Woodchuck"
)

# not sure what to do with these variables... anything interesting?
other <- c(
  "Duration" = "Duration",
  "Animal Not On List" = "Animal.Not.On.List",
  "Bicycle" = "Bicycle",
  "Calibration Photos" = "Calibration.Photos",
  "Camera Misfire" = "Camera.Misfire",
  "Camera Trapper" = "Camera.Trapper",
  "Human, non-staff" = "Human..non.staff",
  "No Animal" = "No.Animal",
  "Time Lapse" = "Time.Lapse",
  "Vehicle" = "Vehicle"
)


shinyUI(navbarPage("eMammal", id="nav",

  tabPanel("Interactive map",
    div(class="outer",
      
      tags$head(
        # Include our custom CSS
        includeCSS("styles.css")# ,
        # includeScript("gomap.js")  # gomap.js is only used for Data explorer feature
      ),
      
      htmlOutput("mapp", inline=TRUE)
#       leafletMap("map1", width="100%", height="100%",
#         #initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
#         initialTileLayer = "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
#         initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
#         options=list(
#           center = c(37.533333, -77.466667),  # centered on Richmond, VA
#           zoom = 6,
#           maxBounds = list(list(15.961329,-129.92981), list(52.908902,-56.80481)) # Show US only
#         )
      ),
      
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
        top = 60, left = "auto", right = 20, bottom = "auto",
        width = 250, height = "auto",
        
        h3("Explore your Wildlife!"),
        
        selectInput("mapPick", "Map", maps, selected = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png"),
        # drop-down list to select wildlife species (initial species to display is selected at random)
        selectInput("size", "Wildlife", wildlife, wildlife[sample(1:length(wildlife), 1)]), 
#         conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
#           # Only prompt for threshold when coloring or sizing by superzip
#           numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
#         ),
        
        plotOutput("histCentile", height = 200)#,
        #plotOutput("scatterCollegeIncome", height = 250)
      )#,
      
#       tags$div(id="cite",
#         'Data collected by ', tags$em('Smithsonian Institute & North Carolina State University')
#       )
    )
  )
)
