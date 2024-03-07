library(ggplot2)
library(plotly)
library(bslib)

## OVERVIEW TAB INFO

overview_tab <- tabPanel( 
  #h1("National Park Data Analysis"),
  p("Overview"),
  p("BC-2"),
  p("Esabel Zhang, Selena Du, Matthew Chan, Ryan Tandy, Wendy Vo"),
  p("INFO 201 Final Project"),
  p("March 6th, 2024"),
  
  br(),
  
  img(src = "https://hips.hearstapps.com/hmg-prod/images/inside-mesa-arch-at-sunrise-royalty-free-image-1671230031.jpg?crop=1.00xw:0.815xh;0,0.128xh&resize=1200:*"),

  h3("An Introduction:"),
  p("This project seeks to provide users with insights into the visitor patterns
    and trends across different areas of the world. It is also a web application
    for analyzing and visualizing the visitor data for national parks. The first
    interactive page is the comparison of the visitor percentage for each
    national park. The second interactive page focuses on comparing the number
    of visitors across these regions and distribution patterns throughout 
    America. And finally, the third interactive page groups national parks by
    their first letter, then finds the average visitors for each group and
    compares their values. Some questions to consider with our dataset include:"),
  
  p("How is visitor privacy protected when collecting and analyzing visitor data?"),
  p("Were visitors informed that their data would be collected and used for analysis?"),
  p("Was explicit consent obtained from visitors before their data was included in the dataset?"),
  
  br(),
  
  h3("Data Usage"),
  p("Our dataset contains information from the folllowing sources:"),
  p("https://copylists.com/geography/list-of-national-parks/#google_vignette"),
  p("https://nationalparkservice.github.io/data/")
  

)

# prepare dataset - prepare interactive page 1 
national_park <- source("final_project.R", local= TRUE)

## VIZ 1 TAB INFO

viz_1_sidebar <- sidebarPanel(
  h2("National Park Visitor Analysis"),
  
  # Other UI components like sidebar, inputs, etc.
  
  # Inserting analysis section
 # h3("Analysis of National Park Visitors"),
  p("Our interactive pie chart provides a comprehensive overview of how visitors 
    are distributed across various national parks. By examining the chart, 
    it's evident that Great Smoky Mountains National Park stands out as the most
    popular destination, capturing a significant portion of the total visitor count. 
    This popularity could be attributed to its renowned natural landmarks, 
    extensive recreational activities, and ease of access."),
  p("On the other end of the spectrum, Gates of the Arctic attracts a 
    smaller share of visitors. This might be due to its remote location, limited 
    facilities, or specific conservation priorities that restrict visitor numbers. 
    Despite its lower popularity, this park offers unique opportunities for 
    solitude, wildlife viewing, and experiencing untouched natural beauty."),
  p("This analysis underscores the importance of tailored conservation and 
    management strategies for each park. For parks drawing large crowds, 
    managing visitor impact on the environment is crucial. For less-visited 
    parks, strategies to increase awareness and accessibility could help in 
    boosting visitor numbers, thus supporting local conservation and tourism 
    efforts.")
  
)

viz_1_main_panel <- mainPanel(
  # h2("Visitor Percentage by National Park"),
  # plotlyOutput(outputId = "park_Visitor_Percentage_Plot"),
  # img(src = "https://www.usatoday.com/gcdn/authoring/authoring-images/2023/08/25/USAT/70680544007-27457643391-2-d-4-b-57-aa-50-k.jpeg", width = "50%"),
  # p(),
  # 
  # textInput(inputId = "National Park Name",
  #           label = "Park Name")
  
  h2("Visitor Percentage by National Park"),
  
  fluidRow(
    column(width = 8,
           plotlyOutput(outputId = "park_Visitor_Percentage_Plot"),
           plotlyOutput(outputId = "park_Visitor_Percentage_Filter"),
           img(src = "https://www.usatoday.com/gcdn/authoring/authoring-images/2023/08/25/USAT/70680544007-27457643391-2-d-4-b-57-aa-50-k.jpeg", width = "100%"),
           p()
    ),
    column(width = 4,
           textInput(inputId = "National_Park_Name", label = "Park Name (Type exactly the name and it will show you the percentage)"),
           # If you want a checkbox instead, you could use something like:
           # checkboxInput(inputId = "someCheckboxId", label = "Some Checkbox Label", value = TRUE)
           #plotlyOutput(outputId = "results")
    )
  )
)

viz_1_tab <- tabPanel("Visitor Percentage Analysis",
  sidebarLayout(
    viz_1_sidebar,
    viz_1_main_panel
   
  )
)

## VIZ 2 TAB INFO

viz_2_sidebar <- sidebarPanel(
  h2("Regional National Parks Visitor Numbers, Locations, and Patterns"),
  #TODO: Put inputs for modifying graph here
)

viz_2_main_panel <- mainPanel(
     leafletOutput("map"),
     textOutput("analysis_paragraph"),
     plotOutput("region_plot"),
     plotOutput("region_plot2")
)

viz_2_tab <- tabPanel("Regional National Parks Visitor Numbers, Locations, and Patterns",
  sidebarLayout(
    viz_2_sidebar,
    viz_2_main_panel
  )
)

## VIZ 3 TAB INFO

viz_3_sidebar <- sidebarPanel(
  
  #Static Header
  h1("National Parks Average Visitors by Letter", align="center"),
  # p("Ryan Tandy", align="center"),
  # sidebarLayout(
  #   sidebarPanel(width = 4,
              h3("First Letter and Average Visitors Analysis"),
              p("The bar graph shows the average amount of visitors per the first letter.",
                "The y-axis on the graph makes it difficult to know the actual value,",
                "but if you hover over the bars themselves you will see the correct number."),
              p("As we can see in the graph, state parks that start with 'O', 'Y', and",
                "'Z' have the highest average visitor count. This is because those letters",
                "have fewer total National Parks, for example the only National Park that",
                "starts with 'Z' is Zion National Park"),
              p("On the contrary, the letters with a more average visitor count",
                "tends to be the ones with more total National Parks, like 'G'",
                "which has 9 total National Parks."),
                checkboxGroupInput("option",
                                   label = ("Average visitors for parks with 4+ parks vs < 4."),
                                    choices = c("4+ Parks", "< 4 Parks"),
                                    selected = "4+ Parks"),
                textOutput(outputId = "choice"))
    


viz_3_main_panel <- mainPanel(
  h2('Average visitors per letter'),
  plotlyOutput(outputId = "final_plot", 
               width = "500px",
               height = "500px")
  
)

viz_3_tab <- tabPanel("National Parks Average Visitors by Letter",
  sidebarLayout(
    viz_3_sidebar,
    viz_3_main_panel
  )
)

## CONCLUSIONS TAB INFO

conclusion_tab <- tabPanel("Conclusion Tab Title",
                           "Conclusion",
                           h1("Takeaways from the National Park Analysis"),
                           p("In conclusion, drawing insights from our analysis of national park visitors, 
 a key takeaway is the diverse appeal of different parks, spotlighting the need for customized 
 conservation and visitor management strategies. The popularity of the Great Smoky Mountains 
 illustrates the significant influence of accessibility and recreational offerings on visitor 
 numbers, while the quieter allure of Gates of the Arctic and similar parks speaks to a distinct 
 appreciation for solitude and untouched nature."),
                           
                           p("Our regional analysis further emphasizes the varying visitor dynamics across the country. 
 The Southwest's high visitor totals contrast with the Northeast's higher average per park, 
 suggesting that a handful of large parks dominate visitation patterns in some regions, whereas 
 others enjoy a more evenly distributed popularity. This indicates a complex interplay of factors 
 affecting park visitation, from geographical location to available amenities and attractions.
 The project underscores the necessity of ethical data collection and privacy considerations, 
 ensuring that visitor analytics enhance both park management and the visitor experience responsibly.
 By leveraging visitor data thoughtfully, we can better manage park ecosystems and facilitate 
 enjoyable, sustainable visits."),
                           
                           p("In sum, our findings highlight the importance of understanding visitor patterns to inform 
 targeted strategies for park conservation and visitor engagement. Whether managing the impacts
  of high visitation or promoting lesser-known parks, a nuanced approach can help balance visitor 
   enjoyment with the preservation of natural beauty, ensuring these treasures remain vibrant 
for 
   future generations. By embracing a strategy that values both the visitor experience and the 
   imperative of conservation, we can ensure that America's national parks continue to thrive as 
   sources of inspiration, recreation, and preservation. This analysis, not only enriches our 
   understanding of national park visitation, but also supports the broader goal of sustainable
   and informed park management for the future "),
                           
                           br(),
                           
                           img(src = "https://cdn.britannica.com/71/94371-050-293AE931/Mountains-region-Ten-Peaks-Moraine-Lake-Alberta.jpg", width = "50%"),

h2("Picture Reference"),
p("https://cdn.britannica.com/71/94371-050-293AE931/Mountains-region-Ten-Peaks-Moraine-Lake-Alberta.jpg")
)



ui <- navbarPage("National Park Data Analysis",
  overview_tab,
  viz_1_tab, # square : ares & km2
  viz_2_tab, # visiter with different natinal park; bar chart; percentage; which national park has the most visiters
  viz_3_tab, # compare park longtitude, lantitude... select
  conclusion_tab
)
