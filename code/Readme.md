# Code Directory

This directory contains all scripts and code used in this project.

Files are numbered in the correct sequence in which they should be run to reproduce the full scraping, cleaning, and analysis workflow.

## 01 Scripts

These scripts automatically download required data from the web. Run both before `02_Data_Cleaning.Rmd`; if skipped, the cleaning script will fall back to the backups stored on Google Drive.

- **01_CIHR_scrape.R** – Scrapes CIHR funding data.
- **01_NSERC_scrape.R** – Scrapes NSERC funding data.

## 02 Script

- **02_Data_Cleaning.Rmd** – Walks through each step in the data cleaning process. Reads raw data (from the `01` scripts or Google Drive), produces intermediate datasets in `data/intermediate-data/`, and outputs analysis-ready datasets in `data/clean-data/`.

## 03 Script

- **03_Preliminary_Analysis.Rmd** – Conducts preliminary descriptive analyses on the cleaned data.
