library(tidyverse)
library(stringi)
library(humaniformat)

clean_cihr_data <- function(file_path) {
  
  # 1. Load CIHR dataset
  cihr_data <- read_csv(file_path)
  
  # 2. Clean all text columns (fix encoding, remove accents, trim)
  cihr_clean <- cihr_data %>%
    mutate(across(
      where(is.character),
      \(x) x |>
        iconv(from = "latin1", to = "UTF-8") |>       # fix encoding (e.g., é)
        stringi::stri_trans_general("Latin-ASCII") |> # accents → ascii (é→e)
        trimws()                                      # remove whitespace
    ))
  
  # 3. Convert CIHR_Contribution to numeric
  cihr_clean$CIHR_Contribution <-
    as.numeric(gsub("[\\$,]", "", cihr_clean$CIHR_Contribution))
  
  # 4. Extract grant year from Competition_CD (year is the first 4 digits)
  cihr_clean$Year <- as.numeric(stringr::str_extract(
    cihr_clean$Competition_CD, "^[0-9]{4}"
  ))
  
  # 5. Keep only the first author (everything before the first semicolon)
  cihr_clean <- cihr_clean %>%
    mutate(Name = trimws(sub(";.*", "", Name)))
  
  # 6. Parse names into components
  cihr_clean$Name <- humaniformat::format_reverse(cihr_clean$Name)
  cihr_clean <- cbind(cihr_clean, parse_names(cihr_clean$Name))
  cihr_clean <- select(cihr_clean, -Name)
  
  # 7. Identify name conflicts
  cihr_conflicts <- cihr_clean %>%
    group_by(first_name, last_name) %>%
    filter(
      n_distinct(middle_name, na.rm = TRUE) > 1 |
        n_distinct(salutation, na.rm = TRUE) > 1 |
        n_distinct(suffix, na.rm = TRUE) > 1
    ) %>%
    arrange(first_name, last_name)
  
  # 8. Separate non-conflict rows
  cihr_no_conflicts <- cihr_clean %>%
    anti_join(cihr_conflicts, by = c("first_name", "last_name"))
  
  # 9. Summary for non-conflict authors (first + last name)
  cihr_summary <- cihr_no_conflicts %>%
    group_by(first_name, last_name) %>%
    summarise(
      n_awards_CIHR = n(),
      total_amount_CIHR = sum(CIHR_Contribution, na.rm = TRUE),
      oldest_year_CIHR = min(Year, na.rm = TRUE),
      newest_year_CIHR = max(Year, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(total_amount_CIHR))
  
  # 10. Summary for conflict authors (include middle_name)
  cihr_summary_conflicts <- cihr_conflicts %>%
    group_by(first_name, middle_name, last_name) %>%
    summarise(
      n_awards_CIHR = n(),
      total_amount_CIHR = sum(CIHR_Contribution, na.rm = TRUE),
      oldest_year_CIHR = min(Year, na.rm = TRUE),
      newest_year_CIHR = max(Year, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(total_amount_CIHR))
  
  # Return all cleaned outputs
  list(
    full_data = cihr_clean,
    conflicts = cihr_conflicts,
    summary_clean = cihr_summary,
    summary_conflicts = cihr_summary_conflicts
  )
}
