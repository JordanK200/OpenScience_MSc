library(rvest) # for parsing html

# nserc export file with a url column
# this is simple a write.csv from the NSERC scrape file final output
# I have a sample export in the root of this project.
data_file <- "nserc-export_20260106_sample.csv"

# read in the data
dat <- read.csv(data_file)

# isolate just the url column, here, just using a few sample urls
dat_url <- dat$url[c(1,10, 30, 40)]

# function to loop through and gather all details.
# the output is a nested list, one list item per url
# each with three lists, one for column headers, 
# one for column values, one for the url. This is just in case over the
# years, the columns have changed and to be able to match back on the url
# to the original nserc export. What's not covered here
# is validating the length of each nested list item
# and then collapsing that into a data frame.

get_award_details <- function(url_list = NULL) {
  awards_details <- list()
  for(i in 1:length(url_list)){
    return_object <- read_html(url_list[i]) |>
      html_element(".researchDetails") |>
      html_table()
    # print(return_object)
    object_details <- list(
      variables = unlist(c(return_object[,1], return_object[-1,3])),
      values = unlist(c(return_object[,2], return_object[-1,4])),
      url = url_list[i]
      )
    awards_details[[i]] <- object_details
    # print(awards_details[[i]])
    Sys.sleep(5)
  }
  return(awards_details)
}

output <- get_award_details(dat_url)
