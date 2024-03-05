# Final Project - data wrangling 
# Natoinal park

library(dplyr)
library(stringr)
library(testthat)
library(jsonlite)

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

# create new column that shows the first letter in the National Park
combined_dy <- combined_dy %>%
  mutate(letter = substr(title, 1, 1))

average_visitors_by_letter <- combined_dy %>%
  group_by(letter) %>%
  summarise(average_visitors = mean(visitors, na.rm = TRUE))
