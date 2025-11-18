library(tidyverse)
library(rcrossref)
library(humaniformat)
library(stringi)

clean_plos_data <- function(file_path, test = FALSE, test_n = 100) {
  
  # 1. Load dataset
  plos_data <- read_csv(file_path)
  
  # 2. Filter to Canadian corresponding or first author
  plos_data_cad <- plos_data %>%
    filter(Corresponding_Author_Country == "Canada" |
             First_Author_Country == "Canada")
  
  # 3. Optional test subset
  if(test) {
    plos_data_cad <- plos_data_cad %>% slice(1:test_n)
  }
  
  # 4. Fetch CrossRef metadata for DOIs
  cr_data_cad <- cr_works(dois = plos_data_cad$DOI, .progress = "text")
  
  # 5. Extract and clean author data
  cr_author_data <- cr_data_cad$data %>%
    select(doi, author) %>%
    unnest(author) %>%
    mutate(author_full = stri_trans_general(
      paste(given, family, sep = " "), 
      "Latin-ASCII"
    ))
  
  # 5.5 Removing the unnecessary columns from the CR output. If suffix is not removed, there is an error because parse_names also produces a suffix column.
  cr_author_data <- select(cr_author_data, -any_of(c(
    "affiliation.name", "affiliation1.name", "affiliation2.name", 
    "affiliation3.name", "affiliation4.name", "affiliation5.name", 
    "affiliation1.id.id", "affiliation1.id.id.type", 
    "affiliation1.id.asserted.by", "X...Montreal..Canada.", 
    "affiliation.id.id", "affiliation.id.id.type", 
    "affiliation.id.asserted.by", "X.Canada.", "X.Canada..1", "suffix"
  )))
  
  # 6. Parse names into components
  cr_author_data <- cbind(cr_author_data, parse_names(cr_author_data$author_full))
  cr_author_data <- select(cr_author_data, -author_full, -given, -family)
  
  # 7. Identify name conflicts
  cr_name_conflicts <- cr_author_data %>%
    group_by(first_name, last_name) %>%
    filter(
      n_distinct(middle_name, na.rm = TRUE) > 1 |
        n_distinct(salutation, na.rm = TRUE) > 1 |
        n_distinct(suffix, na.rm = TRUE) > 1
    ) %>%
    arrange(first_name, last_name)
  
  # Return list of cleaned data
  list(
    author_data = cr_author_data,
    name_conflicts = cr_name_conflicts
  )
}
