library(dplyr)
library(stringr)
library(testthat)
library(jsonlite)
library(ggplot2)
library("plotly")
library(shiny)
library(leaflet)

#The geographic center of the 48 contiguous states according to Wikipedia
center_usa <- c(latitude = 39.50, longitude = -98.35)

#group each nation park into one of the four regions
combined_dy <- combined_dy %>%
  mutate(region = ifelse(latitude >= center_usa["latitude"] & longitude <= center_usa["longitude"], "Northwest",
                  ifelse(latitude >= center_usa["latitude"] & longitude > center_usa["longitude"], "Northeast",
                  ifelse(latitude < center_usa["latitude"] & longitude <= center_usa["longitude"], "Southwest",
                  ifelse(latitude < center_usa["latitude"] & longitude > center_usa["longitude"], "Southeast",
                  "Unknown")))))

region_visitor_counts <- combined_dy %>%
  group_by(region) %>%
  summarize(visitors_number = sum(visitors, na.rm = TRUE))

avg_visitors <- combined_dy %>%
  group_by(region) %>%
  summarize(avg_visitors = mean(visitors))

combined_dy <- merge(combined_dy, avg_visitors, by = "region")

region_df <- merge(region_visitor_counts, avg_visitors, by = "region")

park_counts <- combined_dy %>%
  group_by(region) %>%
  summarise(total_parks = n())

region_df <- region_df %>%
  left_join(park_counts, by = "region")

#applying fitting colors to each region
region_colors <- c("Northwest" = "lightblue", "Northeast" = "darkgreen", 
                   "Southwest" = "gold", "Southeast" = "red")

#arrange the bars to be in descending order
visitor_counts <- region_df %>%
  arrange(desc(visitors_number))

visitor_counts$region <- factor(visitor_counts$region, levels = visitor_counts$region)

region_plot <- ggplot(visitor_counts, aes(x = region, y = visitors_number/1000000, fill = region)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = region_colors) +  
  labs(title = "Total National Park Visitors in Each Region of the United States",
       x = "Region",
       y = "Visitors (in millions)") +
  theme_minimal()


region_plot2 <- ggplot(avg_visitors, aes(x = region, y = avg_visitors/1000000, fill = region)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = region_colors) +
  labs(title = "Average Visitor Count per National Park by Region",
       x = "Region",
       y = "Average Visitor Count") +
  theme_minimal()

ggplotly(region_plot)
ggplotly(region_plot2)

ui <- fluidPage(
  titlePanel("Regional National Parks Visitor Numbers, Locations, and Patterns"),
  mainPanel(leafletOutput("map"),
  textOutput("analysis_paragraph"),
  plotOutput("region_plot"),
  plotOutput("region_plot2")
  )
)

server <- function(input, output, session) {
  output$analysis_paragraph <- renderText({
    "This page analyzes the visitor numbers and average visitors across the four regions in the US. With this analysis, we can see interesting facts of the distribution and popularity of national parks in different parts of the country. Among the regions, the Southwest is the most visited, with a total of 34,365,185 visitors across the parks in the region. But despite having the highest visitor number, the Southwest actually has a relatively low average visitor count on average compared to the other regions. This suggests that there is a higher number of larger and more visited parks in this region In contrast, the Northeast region records a total of 5,993,661 visitors across a small number of parks but it has the highest average visitor number at 1,498,415 per park. The Northwest and Southeast regions also see significant visitor numbers, with 25,581,159 and 16,955,404 visitors respectively. However, these regions have relatively lower average visitor counts compared to the Northeast. This indicates that there is a wider distribution of visitor numbers across parks in these regions. Overall, the analysis tells us the differing visitor numbers and preferences across the different regions of the US and it can help us understand how national parks are scattered geographically and statiscally in the country."
  })
  output$map <- renderLeaflet({
    #create leaflet map
    leaflet(data = combined_dy) %>%
      setView(lng = -98.35, lat = 39.50, zoom = 2) %>%  #center map on USA
      addTiles() %>%
      addMarkers(lng = ~longitude, lat = ~latitude, popup = ~paste("Park:", title, "<br>", "Visitors:", visitors, "<br>", "Region:", region))
    })
   output$region_plot <- renderPlot({
    region_plot
  })
   output$region_plot2 <- renderPlot({
    region_plot2
  })
}

shinyApp(ui = ui, server = server)

