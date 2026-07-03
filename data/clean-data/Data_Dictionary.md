# Data Dictionary — Clean Data

This document describes all variables in the three clean datasets.

- [Cleaned_Master_Data.csv](#cleaned_master_datacsv) — Author–publication-level dataset (45,284 rows × 56 columns)
- [DOI_Level_Data.csv](#doi_level_datacsv) — Publication-level dataset (5,160 rows × 19 columns)
- [Author_Level_Data.csv](#author_level_datacsv) — Author-level dataset (2,099 rows × 13 columns)

---

## Cleaned_Master_Data.csv

The unit of observation is an **author–publication pair**. A single publication appears multiple times if multiple NSERC-funded authors from that publication are in the dataset.

| Variable | Type | Description |
|----------|------|-------------|
| `Publication_Day` | integer | Day of publication (1–31) |
| `Publication_Month` | integer | Month of publication (1–12) |
| `Publication_Year` | integer | Year of publication (2018–2025) |
| `DOI` | character | Digital Object Identifier |
| `Primary_Topic_Field` | character | Broad disciplinary field (e.g., "Health Professions", "Neuroscience"; 25 unique values) |
| `Primary_Topic_Subfield` | character | Specific subfield within the primary topic field (178 unique values) |
| `Corresponding_Author_Country` | character | Country of the corresponding author |
| `First_Author_Country` | character | Country of the first author |
| `Data_Section_Text_Generated` | character | Section(s) where data availability text was detected (`"Method"`, `"Fulltext"`). NA if `Data_Generated = FALSE`. |
| `Data_Generated` | character | Whether data were generated in the study (`"True"`/`"False"` stored as strings) |
| `Data_Shared` | character | Whether data were shared (`"True"`/`"False"` stored as strings) |
| `Data_Location` | character | Where data were shared (`"Online"`, `"Supplementary Information"`, or both). NA if `Data_Shared = FALSE`. |
| `DA_data` | character | Raw extracted text of the data availability statement |
| `Accessions` | character | Accession numbers for deposited data |
| `URL_data` | character | URL(s) where data can be accessed |
| `Repositories_data` | character | Name(s) of repository/repositories where data are stored |
| `Data_DOIs` | character | DOIs assigned to shared datasets |
| `Preprint_Match` | logical | Whether a preprint matching this publication was found |
| `Preprint_DOI` | character | DOI of the matched preprint. NA if `Preprint_Match = FALSE`. |
| `Preprint_Day` | integer | Day the preprint was posted |
| `Preprint_Month` | integer | Month the preprint was posted |
| `Preprint_Year` | integer | Year the preprint was posted (2016–2024) |
| `Preprint_URL` | character | URL of the preprint |
| `Preprint_Server` | character | Server where the preprint was posted (e.g., `"ArXiv"`, `"bioRxiv"`, `"Research Square"`; 19 unique values) |
| `Code_Section_Text_Generated` | character | Section(s) where code availability text was detected (combinations of `"DA"`, `"Method"`, `"Fulltext"`, `"Supplementary"`). NA if `Code_Generated = FALSE`. |
| `Code_Generated` | character | Whether code was generated as part of the study (`"True"`/`"False"` stored as strings) |
| `Code_Shared` | character | Whether code was shared (`"True"`/`"False"` stored as strings) |
| `Code_Location` | character | Where code was shared (`"Online"`, `"Supplementary Information"`). NA if `Code_Shared = FALSE`. |
| `Protocol_Shared` | logical | Whether a formal protocol was shared |
| `n_protocols` | integer | Number of protocols shared (1–10). NA if `Protocol_Shared = FALSE`. |
| `Protocol_Location` | character | Where the protocol was shared (e.g., `"Journal"`, `"Repository"`, `"Collection"`) |
| `Protocol_Source` | character | Journal or collection publishing the protocol (e.g., `"Journal of Visualized Experiments"`, `"MethodsX"`; 44 unique values) |
| `Protocol_URL` | character | URL or DOI of the protocol |
| `has_common_authors` | character | Comma-separated TRUE/FALSE values indicating whether this publication shares authors with other publications in the dataset |
| `Registration_Shared` | logical | Whether study pre-registration information was reported |
| `Registries` | character | Registry where the study was registered (e.g., `"CT.gov"`, `"PROSPERO"`) |
| `Registration_Number` | integer | Number of registration identifiers found (1–3) |
| `Registration` | character | Registration identifier(s) (e.g., ClinicalTrials.gov NCT number, PROSPERO CRD number) |
| `Mention_Number` | integer | Number of times registration is mentioned in the paper (1–25) |
| `Registration_Section_Reported` | character | Section(s) where registration was mentioned (semicolon-separated; e.g., `"abstract;methods"`) |
| `Registration_Detected_As` | character | How registration was detected (`"text"` or `"link,text"`) |
| `Quarter` | character | Publication quarter (e.g., `"2020 Q2"`; 2018 Q1 – 2025 Q1) |
| `source` | character | Dataset source: `"PLOS"` (PLOS ONE) or `"Comparator"` (comparator journal sample) |
| `Discipline` | character | MeSH terms or subject keywords for the publication |
| `combined_id` | character | Unique author identifier linking to Author_Level_Data. Format: `firstname_lastname_institution` |
| `author_position` | character | Author's position in the author list (`"first"`, `"middle"`, `"last"`) |
| `is_corresponding` | character | Whether this author is the corresponding author (`"True"`/`"False"` stored as strings) |
| `publication_year` | integer | Year of publication (same as `Publication_Year`, though may include a small number of 2017 rows; retained for merging convenience) |
| `funders` | character | Funding sources listed in the publication (semicolon-separated) |
| `nserc_top_year_5yr` | integer | Year of the author's highest-value NSERC award in the 5 years prior to publication |
| `nserc_top_award_5yr` | integer | Value (CAD) of the author's highest NSERC award in the 5-year window prior to publication ($11,000–$140,000). NA if no award found in window. |
| `nserc_top_z_5yr` | numeric | Z-score of `nserc_top_award_5yr` relative to discipline peers in that year. NA if no award found in window. |
| `nserc_top_year_all` | integer | Year of the author's highest-value NSERC award across all available years |
| `n_awards_nserc` | integer | Total number of NSERC awards received by the author (1–5). NA if no award found. |
| `nserc_top_award_all` | integer | Value (CAD) of the author's highest NSERC award across all available years ($12,000–$141,000). NA if no award found. |
| `nserc_top_z_all` | numeric | Z-score of `nserc_top_award_all` relative to discipline peers in that year. NA if no award found. |

---

## DOI_Level_Data.csv

The unit of observation is a **unique publication (DOI)**. One row per paper, summarizing open science practices at the publication level. NSERC funding variables reflect the highest-funded NSERC-linked author associated with that publication in the 5 years prior to publication.

| Variable | Type | Description |
|----------|------|-------------|
| `DOI` | character | Digital Object Identifier (unique per row) |
| `Publication_Day` | integer | Day of publication (1–31) |
| `Publication_Month` | integer | Month of publication (1–12) |
| `Publication_Year` | integer | Year of publication (2018–2025) |
| `Primary_Topic_Field` | character | Broad disciplinary field (25 unique values) |
| `Primary_Topic_Subfield` | character | Specific subfield within the primary topic field (178 unique values) |
| `Corresponding_Author_Country` | character | Country of the corresponding author |
| `First_Author_Country` | character | Country of the first author (35 unique values) |
| `Data_Generated` | character | Whether data were generated in the study (`"True"`/`"False"` stored as strings) |
| `Data_Shared` | character | Whether data were shared (`"True"`/`"False"` stored as strings) |
| `Data_Location` | character | Where data were shared (`"Online"`, `"Supplementary Information"`, or both). NA if `Data_Shared = FALSE`. |
| `Code_Generated` | character | Whether code was generated as part of the study (`"True"`/`"False"` stored as strings) |
| `Code_Shared` | character | Whether code was shared (`"True"`/`"False"` stored as strings) |
| `Code_Location` | character | Where code was shared (`"Online"`, `"Supplementary Information"`). NA if `Code_Shared = FALSE`. |
| `Quarter` | character | Publication quarter (e.g., `"2020 Q2"`; 2018 Q1 – 2025 Q1) |
| `source` | character | Dataset source: `"PLOS"` (PLOS ONE) or `"Comparator"` (comparator journal sample) |
| `nserc_top_award_5yr` | integer | Value (CAD) of the highest NSERC award held by any linked author in the 5 years prior to publication ($11,000–$140,000). NA if no award found. |
| `nserc_top_year_5yr` | integer | Year that highest 5-year award was received (2013–2024). NA if no award found. |
| `nserc_top_z_5yr` | numeric | Z-score of `nserc_top_award_5yr` relative to discipline peers in that year. NA if no award found. |

---

## Author_Level_Data.csv

The unit of observation is a **unique author**. One row per author; counts and locations summarize open science practices across all of that author's publications in the dataset. NSERC funding variables reflect the author's full funding history.

| Variable | Type | Description |
|----------|------|-------------|
| `combined_id` | character | Unique author identifier (unique per row). Format: `firstname_lastname_institution`. Links to `combined_id` in Cleaned_Master_Data. |
| `n_publications` | integer | Total number of publications by this author in the dataset (1–20) |
| `n_data_generated` | integer | Number of publications where data were generated (0–20) |
| `n_data_shared` | integer | Number of publications where data were shared (0–20) |
| `n_data_linked` | integer | Number of publications where a data link (URL or DOI) was provided (0–9) |
| `data_locations` | character | Data sharing locations across publications, semicolon-separated by publication (`"Online"`, `"Supplementary Information"`, or both). NA if no data shared. |
| `n_code_generated` | integer | Number of publications where code was generated (0–16) |
| `n_code_shared` | integer | Number of publications where code was shared (0–7) |
| `code_locations` | character | Code sharing locations across publications, semicolon-separated by publication (`"Online"`, `"Supplementary Information"`, or both). NA if no code shared. |
| `nserc_top_award_all` | integer | Value (CAD) of the author's highest NSERC award across all available years ($12,000–$141,000) |
| `nserc_top_year_all` | integer | Year the author's highest NSERC award was received (2005–2024) |
| `nserc_top_z_all` | numeric | Z-score of `nserc_top_award_all` relative to discipline peers in that year (−1.21 – 6.15) |
| `n_awards_nserc` | integer | Total number of NSERC awards received (1–5) |
