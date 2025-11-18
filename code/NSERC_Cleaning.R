library(tidyverse)
library(humaniformat)
library(stringi)

clean_nserc_data <- function(file_path) {
  
  # 1. Load data
  nserc_data <- read_csv(file_path)
  
  # 2. Remove non-ASCII characters from names
  nserc_data$Name <- stri_trans_general(nserc_data$Name, "Latin-ASCII")
  
  # 3. Convert Fiscal Year to a clean numeric (extract first year in range)
  nserc_data <- nserc_data %>%
    mutate(`Fiscal Year` = as.numeric(sub("-.*", "", `Fiscal Year`)))
  
  # 4. Parse names
  nserc_data$Name <- humaniformat::format_reverse(nserc_data$Name)
  nserc_data <- cbind(nserc_data, parse_names(nserc_data$Name))
  nserc_data <- select(nserc_data, -Name)
  
  # 5. Identify author conflicts
  nserc_conflicts <- nserc_data %>%
    group_by(first_name, last_name) %>%
    filter(
      n_distinct(middle_name, na.rm = TRUE) > 1 |
        n_distinct(salutation, na.rm = TRUE) > 1 |
        n_distinct(suffix, na.rm = TRUE) > 1
    ) %>%
    arrange(first_name, last_name)
  
  # 6. Separate conflict vs non-conflict data
  nserc_no_conflicts <- nserc_data %>%
    anti_join(nserc_conflicts, by = c("first_name", "last_name"))
  
  # 7. Summaries for clean (non-conflict) authors
  nserc_summary <- nserc_no_conflicts %>%
    group_by(first_name, last_name) %>%
    summarise(
      n_awards_NSERC = n(),
      total_amount_NSERC = sum(`Amount($)`, na.rm = TRUE),
      oldest_year_NSERC = min(`Fiscal Year`, na.rm = TRUE),
      newest_year_NSERC = max(`Fiscal Year`, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(total_amount_NSERC))
  
  # 8. Summaries for conflict authors (keep middle name)
  nserc_summary_conflicts <- nserc_conflicts %>%
    group_by(first_name, middle_name, last_name) %>%
    summarise(
      n_awards_NSERC = n(),
      total_amount_NSERC = sum(`Amount($)`, na.rm = TRUE),
      oldest_year_NSERC = min(`Fiscal Year`, na.rm = TRUE),
      newest_year_NSERC = max(`Fiscal Year`, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(total_amount_NSERC))
  
  # Return everything as a list
  list(
    full_data = nserc_data,
    conflicts = nserc_conflicts,
    summary_clean = nserc_summary,
    summary_conflicts = nserc_summary_conflicts
  )
}
