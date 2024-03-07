library(ggplot2)
library(plotly)
library(dplyr)

national_park <- source("final_project.R", local= TRUE)

server <- function(input, output){
  
  # interactive 1 
  output$park_Visitor_Percentage_Plot <- renderPlotly({
    
    # Prepare the pie chart data. Assuming 'combined_dy' is your dataset variable name.
    p <- plot_ly(combined_dy, labels = ~title, values = ~percentage, type = 'pie',
                 textinfo = 'none', insidetextorientation = 'radial') %>%
      layout(title = "Visitor Percentage by National Park")

  })
  
  output$park_Visitor_Percentage_Filter <- renderPlotly({
      filter_dy <- combined_dy %>%
        filter(title == input$National_Park_Name)
      
    p <- plot_ly(filter_dy, labels = ~title, values = ~percentage, type = 'pie',
                 textinfo = 'none', insidetextorientation = 'radial') %>%
      layout(title = "Visitor Percentage by National Park")
    
  })
  
  # interactive 2
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
  
  #interactive 3
output$final_plot <- renderPlotly({
    final_plot <- ggplot(average_visitors_by_letter)+
      geom_col(mapping = aes(
        x = letter,
        y = average_visitors, 
        fill = letter))
    return(ggplotly(final_plot))
  })
  output$choice <- renderText({
    ch <- if (input$option == "< 4 Parks"){
      print(avg_4_under)
    } else{
      print(avg_4_plus)
    }
  })
  
  
  
}
 
  
