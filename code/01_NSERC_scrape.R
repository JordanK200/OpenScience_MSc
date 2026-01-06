#############################
# NSERC Database WebScrape
# Mathew Vis-Dunbar, with a couple edits from Jason Pither
# 2025-11-07
# Searches for Discover Grants - Individual between fiscal years 2015/2016 and 2024/2025
# and extracts all results
#############################

# Jason: Create a function with some options
scrape_nserc <- function(testrun = TRUE) {
# testrun will limit the search and download to just 2 pages of records  
# this function will return a data.frame that contains NSERC records
  
library(RSelenium)
library(magrittr) # for pipes

  # THIS CODE DIDN'T WORK FOR ME
# start the server
# selenium_server <- rsDriver(
#   browser = "firefox",
#   chromever = "latest",
#   phantomver = NULL
# )

# Edited by Jason
# This worked for me

selenium_server <- rsDriver(
  browser = "chrome",
  #chromever = NULL,
  phantomver = NULL
)
# initiate the driver; will launch Firefox
driver <- selenium_server$client

# load the relevant page
driver$navigate("https://www.nserc-crsng.gc.ca/ase-oro/index_eng.asp")

# extract the html
html <- driver$getPageSource()[[1]]

# SEARCH
#############################

# variables
date_dropdown_element <- '//div[@id="main-container"]/div[1]/div[1]/div[1]/div[1]/button[1]'
date_range_element <- '//label[@for="ui-multiselect-fiscalyearfrom-option-10"]'
advanced_search_element <- '//div[@id="block1"]/div[1]/a[1]'
program_dropdown_element <- '//div[@id="toggle-content-id1"]/div[1]/div[1]/div[1]/button[1]'
grant_selection_element <- '//input[@id="ui-multiselect-program-option-95"]'
search_button_element <- '//button[@id="buttonSearch"]'

# DATE RANGE
# select the dropdown for fiscal year, and choose 2015/2016
driver$findElement(using = "xpath", date_dropdown_element)$clickElement()
driver$findElement(using = "xpath", date_range_element)$clickElement()

# PROGRAM SELECTION
# click on advanced search, access the program drop down and select the relevant program
driver$findElement(using = "xpath", advanced_search_element)$clickElement()
driver$findElement(using = "xpath", program_dropdown_element)$clickElement()
driver$findElement(using = "xpath", grant_selection_element)$clickElement()

# This second repeated line was causing the checked box for the Discovery
# Grant - individual to become unchecked, so the query was returning ALL grants

#driver$findElement(using = "xpath", grant_selection_element)$clickElement()

# RUN THE SEARCH
driver$findElement(using = "xpath", search_button_element)$clickElement()

# CLEAN UP
rm(list = c("date_dropdown_element", "date_range_element", "advanced_search_element", "program_dropdown_element", "grant_selection_element", "search_button_element"))

# RESULTS
#############################

# UPDATE RESULTS PER PAGE
# variables
results_per_page <- 200
result_length_element <- paste0('//div[@id="result_length"]/label[1]/select[1]/option[@value="',
                                results_per_page,
                                '"]')
driver$findElement(using = "xpath", result_length_element)$clickElement()

# PREPARE TO EXTRACT RESULTS
# variables
element_start <- '//table[@id="result"]/tbody/tr/td['
element_end <- ']'
extraction_elements <- data.frame(
  element = c("name",
              "project_title",
              "amount",
              "year",
              "program"), 
  column = c(1:5)
  )
extraction_elements$xpath <- sapply(extraction_elements$column, function(x) paste0(element_start, x, element_end))
# extraction_elements$xpath has the xml location of each column / variable of interest

# functions
# generic function to extract tabular data
get_elements <- function(elementPath = NULL){
  element <- driver$findElements(using = "xpath", elementPath)
  values <- unlist(lapply(element, function(x) x$getElementText()))
  return(values)
}

get_attributes <- function(elementPath = NULL, attribute = NULL){
  element <- driver$findElements(using = "xpath", elementPath)
  values <- unlist(lapply(element, function(x) x$getElementAttribute(attribute)))
  return(values)
}

# specific functions for each column, call get_elements()
get_names <- function(){
  get_elements(subset(extraction_elements, element == "name", select = "xpath", drop = TRUE))
}
get_project_titles <- function(){
  get_elements(subset(extraction_elements, element == "project_title", select = "xpath", drop = TRUE))
}
get_amount <- function(){
  get_elements(subset(extraction_elements, element == "amount", select = "xpath", drop = TRUE))
}
get_year <- function(){
  get_elements(subset(extraction_elements, element == "year", select = "xpath", drop = TRUE))
}
get_program <- function(){
  get_elements(subset(extraction_elements, element == "program", select = "xpath", drop = TRUE))
}
get_urls <- function(){
  get_attributes(paste0(subset(extraction_elements, element == "project_title", select = "xpath", drop = TRUE), "/a"), "href")
}

# need a pause here (JASON)
# i found that without this pause the function crashed occassionaly
cat("Taking a five second breath...\n\n")
Sys.sleep(5)

# PAGINATE THROUGH TO LAST PAGE DOING THE SAME
# some simple math for determining how much data we will be collecting
total_records <- driver$findElement(using = "xpath", '//div[@id="result_info"]')$getElementText() %>%
  unlist() %>%
  sub("Showing.*of ", "", .) %>%
  sub(",", "", .) %>%
  sub(" .*", "", .) %>%
  as.integer()
pages <- ceiling(total_records/200)

# place holders for the extracted data
applicant_name <- vector(length = total_records)
project_title <- vector(length = total_records)
amount <- vector(length = total_records)
year <- vector(length = total_records)
program <- vector(length = total_records)
url <- vector(length = total_records)

# need to keep an index track for populating the placeholders
counter <- 1

# find the next button, and then loop through each page, extracting the relevant
# information
next_button <- driver$findElement(using = "xpath", '//a[@id="result_next"]')

# If test run, then do just 2 pages

if(testrun) { pages <- 2 } else {}

for(page in 1:pages){
  cat(paste0("Executing page ", page, " of ", pages, " pages.\n"))
  start <- counter
  end <- counter + results_per_page - 1
  applicant_name[start:end] <- get_names()
  project_title[start:end] <- get_project_titles()
  amount[start:end] <- get_amount()
  year[start:end] <- get_year()
  program[start:end] <- get_program()
  url[start:end] <- get_urls()
  next_button$clickElement()
  counter <- counter + results_per_page
  cat(paste0("Total records retrieved: ", counter, "\n"))
  time_remaining <- ceiling((pages - page) * 30 / 60)
  ifelse(time_remaining > 1,
         print(paste0("Approximate time remaining: ", time_remaining, " minutes.")),
         print(paste0("Approximate time remaining: ", time_remaining, " minute."))
  )
  if(page != pages){
    cat("Taking a twenty second breath...\n\n")
    Sys.sleep(20)
  }
}

# move everything into a dataframe
df <- data.frame(
  applicant_name,
  project_title,
  amount,
  year,
  program,
  url
)

return(df)
# CLOSE THE DRIVER & CONNECTION
#############################

driver$close()
selenium_server$server$stop()

# end function
}