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


#you can add different types of base map tiles: http://leaflet-extras.github.io/leaflet-providers/preview/index.html


#and you can coordinates to center your map and zoom


#-Adding Points
df <- read_csv('Starbucks.csv')



#note that we use '~' to say "this is a column in the provided data"
#you could also use '$' notation if you want, but this is cleaner



#you can directly set the color, or even set it with an ifelse() statement
#...more on colors in leaflet later



#-Interactions
#we can specify what happens on-click with the popup argument (click on a point)


#more advanced popups: make a new column with what you want - has to be HTML format
#<br> is "break" in HTML and it makes a new line
#using our text analysis skills, we can make a nice looking popup 



#cluster markers...i don't really like these but they are popular


#can also code the size of circles as a variable.  let's use some (fake) data with number of customers per location
sb_local <- read_csv('Starbucks_subset.csv')

#-Adding Lines
#lets draw a line from the newburgh starbucks to the middletown one:

#these are "as the crow flies" lines - we'll learn how to do road routing in the next class


#-Adding Polygons (choropleths)
#we can also build choropleths - lets go back to the census data from last class:
load('census_data.Rds')

#leaflet requires that we build a palette, which is actually a function

#this function takes in a value and returns a color

#now we can use that palette within leaflet to create the different colors for each shape

#the log transformation is a bit trickier than before when working with palettes...


#-Multiple Layers
#start by building up layers like normal but add a "group" attribute
#then add the layers control - let's try an overlayGroup first


#we can also use baseGroups - note that you can only pick one of these at a time
#typically, baseGroups are used for different map layers

#-Legends
#legends are not leaflet's strong suites
#if you want them to be human-readable, you can't use the log scale


#putting everything together, we get a full featured interactive map!

#---Exercise:
#using ACLED (https://acleddata.com/#/dashboard) data of violence in Afghanistan...
#create a map that shows protests in blue, violence against civilians in red and shows the description
#of the even on-click.
#bonus: add a legend describing what each color represents

df_af <- read_csv('Afghanistan.csv')


  


