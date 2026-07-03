# OpenScience_MSc

This repository contains the code and data for Jordan's Open Science MSc project, which examines open science practices among NSERC-funded Canadian researchers.

## Repository Structure

- **`code/`** — R scripts and R Markdown files for scraping, cleaning, and analysis. Run files in numbered order.
- **`data/`** — Data at each stage of processing:
  - `raw-data/` — Original unmodified inputs (downloaded by the `01` scraping scripts)
  - `intermediate-data/` — Checkpoint files produced during cleaning
  - `clean-data/` — Analysis-ready datasets; see `Data_Dictionary.md` for variable descriptions
  - `sample-data/` — Small random samples of the cleaned data for development and testing
- **`archive/`** — Deprecated scripts and data retained for reference

## Note on GitHub Contents

Most data files are excluded from this repository via `.gitignore`. What is available on GitHub:

- All code in `code/`
- README and data dictionary files throughout `data/`
- The full contents of `data/sample-data/`

Raw, intermediate, and clean data files must be obtained separately — see `data/README.md` for access instructions.
