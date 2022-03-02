library(leaflet)
library(rgdal)
library(RColorBrewer)

bike_ped_demand <- readOGR("https://opendata.arcgis.com/datasets/28e4a0950e5a497aaffa8615870167d5_0.geojson")
transit_ridership <- readOGR("https://opendata.arcgis.com/datasets/7acc9d583379456eacfbb82e5ff07370_0.geojson")

names(bike_ped_demand)
summary(bike_ped_demand$BikeDemandScore)

transit_boardings <- subset(transit_ridership, !is.na(transit_ridership$AVGBoard))
names(transit_ridership)
summary(transit_ridership)

transit_alightings <- subset(transit_ridership, !is.na(transit_ridership$AVGAlight))

bike_demand_bins <- c(0, 10, 20, 30, 40, 50, 60, 70)
bike_demand_pal <- colorBin("YlGnBu", domain = bike_ped_demand$BikeDemandScore, bins = bike_demand_bins)

transit_boardings_bins <- c(0, 1, 2, 5, 10, 50, 100, 1200)
transit_boardings_pal <- colorBin("YlOrRd", domain = transit_boardings$AVGBoard, bins = transit_boardings_bins)

transit_alightings_bins <- c(0, 1, 2, 5, 10, 50, 100, 1200)
transit_alightings_pal <- colorBin("YlOrRd", domain = transit_alightings$AVGAlight, bins = transit_alightings_bins)

# set pop-up content
bike_ped_demand$popup <- paste("<strong>", "Zone ID: ", bike_ped_demand$zone_id, "</strong>",
                               "</br>", "Bike Demand Score: ", bike_ped_demand$BikeDemandScore)
transit_boardings$popup <- paste("<strong>", "Stop Name: " , transit_boardings$StopName, "</strong>",
                                 "</br>", "AVG Daily Boardings: ", transit_boardings$AVGBoard,
                                 "</br>", "AVG Daily Alightings: ", transit_boardings$AVGAlight)

transit_alightings$popup <- paste("<strong>", "Stop Name: " , transit_alightings$StopName, "</strong>",
                                 "</br>", "AVG Daily Boardings: ", transit_alightings$AVGBoard,
                                 "</br>", "AVG Daily Alightings: ", transit_alightings$AVGAlight)

m <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = bike_ped_demand,
              stroke = TRUE,
              weight = 0.2,
              color = "#ABABAB",
              smoothFactor = 0.3,
              opacity = 1,
              fillColor = ~bike_demand_pal(BikeDemandScore),
              fillOpacity = 0.8,
              popup = ~popup,
              group = "Bike Demand Score",
              highlightOptions = highlightOptions(color = "#E2068A",
                                                  weight = 1.5,
                                                  fillOpacity = 0.5)) %>%
  addCircleMarkers(data = transit_boardings, 
                   ~Longitude,
                   ~Latitude, 
                   radius = 5, 
                   stroke = TRUE, 
                   color = "#FFFFFF", 
                   weight = 1, 
                   fillOpacity = 1,
                   fillColor = ~transit_boardings_pal(AVGBoard),
                   group = "Transit Boardings",
                   popup = ~popup)%>%
  addCircleMarkers(data = transit_alightings, 
                   ~Longitude,
                   ~Latitude, 
                   radius = 5, 
                   stroke = TRUE, 
                   color = "#FFFFFF", 
                   weight = 1, 
                   fillOpacity = 1,
                   fillColor = ~transit_alightings_pal(AVGBoard),
                   group = "Transit Alightings",
                   popup = ~popup)%>%
  addLegend("bottomright",
            opacity = 1,
            pal = bike_demand_pal,
            title = "Bike Demand Score",
            values = bike_demand_bins,
            group = "Bike Demand Score")%>%
  addLegend("bottomright",
            opacity = 1,
            pal = transit_boardings_pal,
            title = "Daily AVG Transit Boardings",
            values = transit_boardings_bins,
            group = "Transit Boardings") %>%
  addLegend("bottomright",
            opacity = 1,
            pal = transit_boardings_pal,
            title = "Daily AVG Transit Alightings",
            values = transit_alightings_bins,
            group = "Transit Alightings") %>%
  addLayersControl(baseGroups = c("Transit Boardings", "Transit Alightings"),  
                  overlayGroups = c("Bike Demand Score"),
                   options = layersControlOptions(collapsed = FALSE))
  
m

