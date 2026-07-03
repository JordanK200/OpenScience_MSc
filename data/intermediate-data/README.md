# Intermediate-data Directory

This directory contains partially processed datasets produced during time-consuming cleaning steps in `02_Data_Cleaning.Rmd`. These files checkpoint progress so that expensive steps do not need to be re-run from scratch.

- **OA_PLOS_Hold.rds** – Intermediate hold of PLOS open access publication records, produced mid-cleaning before final merges.
- **canonical_id_resolution_log.csv** – Log of decisions made when resolving author identifiers to canonical forms.
