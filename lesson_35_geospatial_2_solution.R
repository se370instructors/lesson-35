#---Lesson 35: Geospatial Analysis II
#-By: Ian Kloo
#-April 2022

library(readr)
library(dplyr)
library(ggplot2)
library(sf)
library(leaflet)


#---Interactive Mapping---#
#if you aren't working on a publication or something that will be printed, consider using an interactive map
#leaflet is a great open-source interactive mapping tool

#-Basemaps
#leaflet functions just like ggplot's layering system - note that we use the pipe instead of "+"
leaflet() %>%
  addTiles()

#you can add different types of base map tiles: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
leaflet() %>%
  addProviderTiles(providers$Stamen.TerrainBackground)

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron)

#and you can coordinates to center your map and zoom
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lng = -73.9571, lat = 41.3889, zoom = 14)

#-Adding Points
df <- read_csv('Starbucks.csv')
df_ny <- df %>%
  filter(!is.na(Latitude) | !is.na(Longitude), `State/Province` == 'NY')


#note that we use '~' to say "this is a column in the provided data"
#you could also use '$' notation if you want, but this is cleaner
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, radius = 4, stroke = NA, fillOpacity = .8)

#you can directly set the color, or even set it with an ifelse() statement
#...more on colors in leaflet later
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, radius = 4, stroke = NA, fillOpacity = .8, 
                   color = ~ifelse(`Ownership Type` == 'Company Owned', 'green', 'blue'))

#-Interactions
#we can specify what happens on-click with the popup argument (click on a point)
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, radius = 4, stroke = NA, fillOpacity = .8,
                   popup = ~`Store Name`)

#more advanced popups: make a new column with what you want - has to be HTML format
#<br> is "break" in HTML and it makes a new line
#using our text analysis skills, we can make a nice looking popup 
df_ny <- df_ny %>%
  mutate(pop = paste0('Store Name: ', `Store Name`, '<br>', 'Phone Number: ', `Phone Number`))

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, radius = 4, stroke = NA, fillOpacity = .8,
                   popup = ~pop)

#cluster markers...i don't really like these but they are popular
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, clusterOptions = markerClusterOptions())

#can also code the size of circles as a variable.  let's use some (fake) data with number of customers per location
sb_local <- read_csv('Starbucks_subset.csv')

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(data = sb_local, lat = ~Latitude, lng = ~Longitude, radius = ~avg_customers/25, stroke = NA, fillOpacity = .5)

#-Adding Lines
#lets draw a line from the newburgh starbucks to the middletown one:
df_lines <- sb_local %>%
  filter(City %in% c('Fishkill', 'Monroe'))

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(data = sb_local, lat = ~Latitude, lng = ~Longitude, radius = ~avg_customers/25, stroke = NA, fillOpacity = .5) %>%
  addPolylines(data = df_lines, lat = ~Latitude, lng = ~Longitude)

#these are "as the crow flies" lines - we'll learn how to do road routing in the next class


#-Adding Polygons (choropleths)
#we can also build choropleths - lets go back to the census data from last class:
load('census_data.Rds')

#leaflet requires that we build a palette, which is actually a function
pal <- colorNumeric('Blues', domain = c(min(ny_census_pop$CENSUS2010POP), max(ny_census_pop$CENSUS2010POP)))
#this function takes in a value and returns a color
pal(ny_census_pop$CENSUS2010POP[1])

#now we can use that palette within leaflet to create the different colors for each shape
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = ny_census_pop, weight = 1, fillColor = ~pal(CENSUS2010POP), fillOpacity = 1)

#the log transformation is a bit trickier than before when working with palettes...
pal <- colorNumeric('Blues', domain = c(min(log10(ny_census_pop$CENSUS2010POP)), max(log10(ny_census_pop$CENSUS2010POP))))

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = ny_census_pop, weight = 1, fillColor = ~pal(log10(CENSUS2010POP)), fillOpacity = 1)


#-Multiple Layers
#start by building up layers like normal but add a "group" attribute
#then add the layers control - let's try an overlayGroup first
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = ny_census_pop, weight = 1, fillColor = ~pal(log10(CENSUS2010POP)), fillOpacity = 1, group = 'Population') %>%
  addCircleMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, radius = 4, stroke = NA, fillOpacity = .25,
                   popup = ~pop, color = 'red', group = 'Starbucks') %>%
  addLayersControl(overlayGroups = c("Population", "Starbucks"), options = layersControlOptions(collapsed = FALSE))


#we can also use baseGroups - note that you can only pick one of these at a time
#typically, baseGroups are used for different map layers
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron, group = 'Light') %>%
  addProviderTiles(providers$CartoDB.DarkMatter, group = 'Dark') %>%
  addPolygons(data = ny_census_pop, weight = 1, fillColor = ~pal(log10(CENSUS2010POP)), fillOpacity = 1, group = 'Population') %>%
  addCircleMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, radius = 4, stroke = NA, fillOpacity = .25,
                   popup = ~pop, color = 'red', group = 'Starbucks') %>%
  addLayersControl(baseGroups = c('Light', 'Dark'), 
                   overlayGroups = c("Population", "Starbucks"), 
                   options = layersControlOptions(collapsed = FALSE))

#-Legends
#legends are not leaflet's strong suites
#if you want them to be human-readable, you can't use the log scale
pal <- colorNumeric('Blues', domain = c(min(ny_census_pop$CENSUS2010POP), max(ny_census_pop$CENSUS2010POP)))
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = ny_census_pop, weight = 1, fillColor = ~pal(CENSUS2010POP), fillOpacity = 1) %>%
  addLegend(data = ny_census_pop, 'bottomright', pal = pal, values = ~CENSUS2010POP)


#putting everything together, we get a full featured interactive map!
pal <- colorNumeric('Blues', domain = c(min(ny_census_pop$CENSUS2010POP), max(ny_census_pop$CENSUS2010POP)))
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron, group = 'Light') %>%
  addProviderTiles(providers$CartoDB.DarkMatter, group = 'Dark') %>%
  addPolygons(data = ny_census_pop, weight = 1, fillColor = ~pal(CENSUS2010POP), fillOpacity = 1, group = 'Population') %>%
  addCircleMarkers(data = df_ny, lat = ~Latitude, lng = ~Longitude, radius = 4, stroke = NA, fillOpacity = .25,
                   popup = ~pop, color = 'red', group = 'Starbucks') %>%
  addLayersControl(baseGroups = c('Light', 'Dark'), 
                   overlayGroups = c("Population", "Starbucks"), 
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addLegend(data = ny_census_pop, 'bottomright', pal = pal, values = ~CENSUS2010POP)


#---Exercise:
#using ACLED (https://acleddata.com/#/dashboard) data of violence in Afghanistan...
#create a map that shows protests in blue, violence against civilians in red and shows the description
#of the even on-click.
#bonus: add a legend describing what each color represents

df_af <- read_csv('Afghanistan.csv')

df_af_sub <- df_af %>%
  filter(event_type %in% c('Protests', 'Violence against civilians')) %>%
  mutate(color = ifelse(event_type == 'Protests', 'blue', 'red'))

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron, group = 'Light') %>%
  addCircleMarkers(data = df_af_sub, lat = ~latitude, lng = ~longitude, stroke = NA, radius = 4, color = ~color,
                   popup = ~notes) %>%
  addLegend('bottomright', colors = c('blue','red'), labels = c('Protests', 'Violence'), opacity = 1)
  
  


