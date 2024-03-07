# Final Project
# Natoinal park
library(dplyr)
library(stringr)
library(testthat)
library(jsonlite)
library(ggplot2)
library("plotly")
library(shiny)
library(leaflet)
library(rsconnect)

national_park_name <- read.csv("national_parks.csv")
national_ana <- fromJSON("https://query.data.world/s/mfrcsythc5dh53b4dahsm2a37j6rjn?dws=00000") # ana- analysis

# change column title
national_park_name <- national_park_name %>%
  rename( "Name" = "Acadia" )

# join two dataset
combined_dy <-  national_ana %>%
  left_join(national_park_name,by = c("title" = "Name"))

# may be delete some columns
combined_dy <- combined_dy %>%
  select(-c("description"))

# change character to number
combined_dy <- combined_dy %>%
  mutate(visitors = as.numeric(gsub(",", "", combined_dy$visitors)))
max_visiter <- max(combined_dy$visitors)
min_visiter <- min(combined_dy$visitors)
mean_np_visiter <- mean(combined_dy$visitors) # visiter 

typeof(combined_dy$area)
typeof(combined_dy$coordinates) # these are all list 
# combined_dy <- combined_dy %>%
#   mutate(area = as.numeric(unlist(gsub(",", "", combined_dy$area))))
#          
# combined_dy <- combined_dy %>%
#   mutate(area = as.numeric(gsub(",", "", combined_dy$coordinates)))

# each row compare visiter number with mean
combined_dy <- combined_dy %>%
  mutate(above_below_mean = ifelse(visitors > mean_np_visiter, "Above Mean", "Below Mean"))

sum_visiter <- sum(combined_dy$visitors)
combined_dy <- combined_dy %>%
  mutate(percentage = (visitors/sum_visiter) * 100)
# requirement -  Must create at least one new categorical variable

# create a dataframe that contained national park is world heritage site
world_heritage_dy <- combined_dy %>%
  filter(world_heritage_site == TRUE)
world_heritage <- data.frame(
  "National Park Name" = world_heritage_dy$title,
  "Area" = world_heritage_dy$area,
  "Visiter" = world_heritage_dy$visitors) # clear version

# requirement - Must create at least one summarization data frame

# ryan
combined_dy <- combined_dy %>%
  mutate(letter = substr(title, 1, 1))

average_visitors_by_letter <- combined_dy %>%
  group_by(letter) %>%
  summarise(average_visitors = mean(visitors, na.rm = TRUE))
park_count_by_letter <- combined_dy %>%
  group_by(letter) %>%
  summarise(park_count = n_distinct(title))

letters_with_more_than_3_parks <- park_count_by_letter %>%
  filter(park_count > 3)

letters_more_than_3 <- letters_with_more_than_3_parks$letter

combined_dy_filtered <- combined_dy %>%
  filter(letter %in% letters_more_than_3)

average_visitors_for_more_than_3_parks <- combined_dy_filtered %>%
  group_by(letter) %>%
  summarise(average_visitors = mean(visitors, na.rm = TRUE))

print(average_visitors_for_more_than_3_parks)
avg_4_plus <- sum(average_visitors_for_more_than_3_parks$average_visitors)/length(average_visitors_for_more_than_3_parks$letter)
print(avg_4_plus)


park_count_by_letter <- combined_dy %>%
  group_by(letter) %>%
  summarise(park_count = n_distinct(title))

letters_with_less_than_4_parks <- park_count_by_letter %>%
  filter(park_count < 4)

letters_less_than_4 <- letters_with_less_than_4_parks$letter

combined_dy_filtered <- combined_dy %>%
  filter(letter %in% letters_less_than_4)

average_visitors_for_less_than_4_parks <- combined_dy_filtered %>%
  group_by(letter) %>%
  summarise(average_visitors = mean(visitors, na.rm = TRUE))

print(average_visitors_for_less_than_4_parks)
avg_4_under <- sum(average_visitors_for_less_than_4_parks$average_visitors)/length(average_visitors_for_less_than_4_parks$letter)
print(avg_4_under)




# matthew 
#The geographic center of the 48 contiguous states according to Wikipedia
center_usa <- c(latitude = 39.50, longitude = -98.35)

combined_dy <- combined_dy %>%
  mutate(latitude = combined_dy$coordinates$latitude,
         longitude = combined_dy$coordinates$longitude)
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
