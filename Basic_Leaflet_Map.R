library(leaflet)
library(rgdal)
library(RColorBrewer)

bike_ped_demand <- readOGR("https://opendata.arcgis.com/datasets/28e4a0950e5a497aaffa8615870167d5_0.geojson")
transit_ridership <- readOGR("https://opendata.arcgis.com/datasets/7acc9d583379456eacfbb82e5ff07370_0.geojson")

names(bike_ped_demand)
summary(bike_ped_demand$BikeDemandScore)

transit_ridership <- subset(transit_ridership, !is.na(transit_ridership$AVGAlight))
names(transit_ridership)
summary(transit_ridership)

bike_demand_bins <- c(0, 10, 20, 30, 40, 50, 60, 70)
bike_demand_pal <- colorBin("YlGnBu", domain = bike_ped_demand$BikeDemandScore, bins = bike_demand_bins)

# set pop-up content
bike_ped_demand$popup <- paste("<strong>", "Zone ID: ", bike_ped_demand$zone_id, "</strong>",
                               "</br>", "Bike Demand Score: ", bike_ped_demand$BikeDemandScore)
transit_ridership$popup <- paste("<strong>", "Stop Name: " , transit_ridership$StopName, "</strong>",
                                 "</br>", "AVG Daily Boardings: ", transit_ridership$AVGBoard,
                                 "</br>", "AVG Daily Alightings: ", transit_ridership$AVGAlight)

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
  addCircleMarkers(data = transit_ridership, 
                   ~Longitude,
                   ~Latitude, 
                   radius = 2, 
                   stroke = TRUE, 
                   color = "#424242", 
                   weight = 1, 
                   fillOpacity = 1, 
                   fillColor ="#FDFDFD",
                   group = "Transit Ridership",
                   popup = ~popup)%>%
  addLegend("bottomright",
            opacity = 1,
            colors = c("#ffffcc", "#c7e9b4", "#7fcdbb", "#41b6c4", "#1d91c0", "#225ea8", "#0c2c84"),
            title = "Bike Demand Score",
            labels = c("< 10.00", "10.01 - 20.00", "20.01 - 30.00", "30.01 - 40.00", "40.01 - 50.00", "50.01 - 60.00", "60.01 - 70.00"))%>%
  addLayersControl(overlayGroups = c("Transit Ridership", "Bike Demand Score"),
                   options = layersControlOptions(collapsed = FALSE))
  
m

