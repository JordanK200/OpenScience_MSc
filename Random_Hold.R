Testtt <- PLOS_Data %>%
  filter(DOI == "10.1371/journal.pone.0313255")

OA_PLOS_Data_TEST <- oa_fetch(doi = Testtt$DOI)


author_data <- oa_fetch(
  entity = "authors",
  search = "Carmen Avila-Casado",
  per_page = 5
)   

john_lewis_universityofottawa

# Fetch works by a specific author at a specific institution
works_data <- oa_fetch(
  entity = "works",
  # Filter by author name (use .search for partial matches)
  "authorships.author.display_name.search" = "Carmen Avila-Casado", 
  # Filter by institution ROR or OpenAlex ID
  "authorships.institutions.ror" = "02nr0ka47",
  verbose = TRUE
)

# Search using text strings
works <- oa_fetch(
  entity = "works",
  author.display_name = "Carmen Avila-Casado",
  institution.name = "University of Toronto" # Note: This might be less precise than the ID
)

author_data <- oa_fetch(
  entity = "authors",
  search = "John E. Lewis",
  last_known_institutions.id = "I153718931"  # University of Toronto's OpenAlex ID
)
