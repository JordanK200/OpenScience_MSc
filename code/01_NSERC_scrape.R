library(rvest)
library(stringr)
library(stringi)
library(httr2)
library(tidyverse)
library(readxl)

# Link to NSERC's Awards Data
page_url <- "https://open.canada.ca/data/en/dataset/c1b0f627-8c29-427c-ab73-33968ad9176e"

# Create a session temp directory for downloads
tmp_dir <- file.path(tempdir(), "nserc_downloads")
dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

message("Using temp directory: ", tmp_dir)

# Scrape all links on the page
links <- read_html(page_url) %>%
  html_elements("a") %>%
  html_attr("href") %>%
  unique() %>%
  na.omit()

# Make absolute URLs if needed
links <- url_absolute(links, page_url)

# Extract fiscal year from award/Expenditures file names
link_tbl <- tibble(
  url = links,
  filename = basename(links),
  year = coalesce(
    str_extract(filename, "\\d{4}(?=_award)"),
    str_extract(filename, "\\d{4}(?=_Expenditures)")
  )
)

# Filter to target years
link_tbl <- link_tbl %>%
  mutate(year = as.integer(year)) %>%
  filter(between(year, 2012, 2024)) %>%
  arrange(year)

# Function that downloads each file into the temp directory
download_one <- function(url, filename, out_dir) {
  
  dest <- file.path(out_dir, filename)
  
  if (file.exists(dest)) {
    message("Already exists: ", filename)
    return(dest)
  }
  
  request(url) |>
    req_user_agent("R downloader (Jordan)") |>
    req_perform() |>
    resp_body_raw() |>
    writeBin(dest)
  
  message("Downloaded: ", filename)
  dest
}

# Download awards data into temp directory
download_paths <- purrr::pwalk(
  link_tbl,
  ~ download_one(..1, ..2, tmp_dir)
)

# Find paths to each downloaded file
files <- list.files(
  tmp_dir,
  pattern = "\\.(csv|xlsx|xls)$",
  full.names = TRUE,
  ignore.case = TRUE
)

# Load all files
data_list <- purrr::map(files, function(path) {
  ext <- tolower(tools::file_ext(path))
  
  if (ext == "csv") {
    readr::read_csv(path, show_col_types = FALSE, col_types = cols(.default = col_character()))
  } else {
    readxl::read_excel(path, col_types = "text")
  }
})

# Assign file names
names(data_list) <- basename(files)

# Fix column name encoding inconsistencies
data_list_clean <- purrr::map(data_list, function(df) {
  nm <- names(df)
  
  if (any(!stringi::stri_enc_isutf8(nm))) {
    nm2 <- iconv(nm, from = "latin1", to = "UTF-8")
    nm2[is.na(nm2)] <- nm[is.na(nm2)]
    names(df) <- nm2
  }
  
  df
})

# Fix naming issues
data_list_clean <- map(data_list_clean, \(df) {
  df %>%
    rename(ProgramName = any_of(c("ProgramNaneEN", "ProgramNameEN"))) %>%
    rename(Department  = any_of(c("Department-Département", "DepartmentEN"))) %>%
    rename(Institution = any_of(c("Institut", "Institution-Établissement"))) %>%
    rename(FiscalYear  = any_of("FiscalYear-Exercice financier")) %>%
    rename(CompetitionYear = any_of("CompetitionYear-Année de concours"))
})

  
# Bind list variables into one big df
data_df <- bind_rows(data_list_clean)

# Only keep "Discovery Grants Program - Individual" rows 
data_df_discovery <- data_df %>%
  filter(ProgramName == "Discovery Grants Program - Individual")

# After filtering, there should be 131957 rows
# This matches the number of rows when using the NSERC awards website

# Save data
write_csv(data_df_discovery, file = file.path("data", "raw-data", "RAW_NSERC.csv"))
