# Data Directory

This directory organizes data at different stages of processing:

- **raw-data** – Original, unmodified input data.  
- **intermediate-data** – Partially cleaned data produced after time-consuming preprocessing steps.  
- **clean-data** – Fully processed data ready for analysis.  

All raw data is stored on Google Drive:  
[Google Drive Folder](https://drive.google.com/drive/folders/1FSxIsOkGuVqUTiFzEPaC4xpr_r5OvzNJ?usp=sharing)

## Usage

Cleaning scripts are designed to automatically:

1. Download the raw data from the Google Drive folder.  
2. Generate intermediate data sets in the `intermediate-data` directory when convenient.  
3. Produce finalized, analysis-ready datasets in the `clean-data` directory.

Make sure to run the scripts in the order specified in the project documentation to ensure reproducibility.
