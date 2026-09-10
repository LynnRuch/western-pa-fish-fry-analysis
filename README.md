# Western Pennsylvania Fish Fry Analysis

A PostgreSQL data-cleaning and Tableau visualization project using public-source Western Pennsylvania Lenten fish fry data.

## Live Dashboard

**[View the interactive Western PA Lenten Fish Fry Locator on Tableau Public](https://public.tableau.com/app/profile/lynn.ruch/viz/WesternPA2026LentenFishFry/WesternPALentFishFryLocator)**

## Project Overview

This project prepares public-source fish fry location data for analysis and visualization. The workflow combines PostgreSQL transformations with manually reviewed geographic corrections used in the Tableau project.

The SQL workflow:
- preserves the raw source data in a staging table
- limits locations to a 30-mile radius of Pittsburgh
- standardizes venue classifications
- converts source flags into user-friendly Yes/No values
- uses venue notes to supplement missing take-out information
- validates transformed values and record counts
- joins cleaned records to manually reviewed address, city, and coordinate data
- produces a final analysis-ready dataset for visualization

The resulting dataset contains 216 Western Pennsylvania fish fry locations.

## Repository Structure

```text
western-pa-fish-fry-analysis/
├── README.md
├── data/
│   ├── fish_fry_raw.csv
│   └── fish_fry_geography.csv
├── sql/
│   └── fish_fry_cleaning.sql
└── tableau/
    └── [Tableau workbook].twbx
```

## Data

The original fish fry records come from the Western Pennsylvania Regional Data Center (WPRDC) Pittsburgh Fish Fry Map dataset. The records were collected by Code for Pittsburgh from public sources including news outlets, social media, and public submissions.

Source: https://data.wprdc.org/dataset/pittsburgh-fish-fry-map

The source dataset is published under the Creative Commons CC0 public-domain dedication.

`fish_fry_raw.csv` contains the project source snapshot used for the analysis.

`fish_fry_geography.csv` contains the manually reviewed geographic fields used to preserve address, city, latitude, and longitude corrections from the Tableau project.

## SQL Cleaning

The PostgreSQL workflow is documented in `sql/fish_fry_cleaning.sql`.

It demonstrates staging-table design, Common Table Expressions (CTEs), geographic distance calculation, `CASE` expressions, data standardization, validation, `LEFT JOIN`, and creation of an analysis-ready table.

Ambiguous venue classifications were manually reviewed and the resulting decisions were encoded in SQL so that the transformation is documented and repeatable.

## Tableau Visualization

The Tableau dashboard provides geographic mapping, dynamic filtering, cross-filtering between visualizations, and venue/service attributes for exploring locations.

The Tableau workbook is included in the `tableau/` directory for inspection, while the live Tableau Public dashboard can be used directly in a browser.

**[Open the live interactive dashboard](https://public.tableau.com/app/profile/lynn.ruch/viz/WesternPA2026LentenFishFry/WesternPALentFishFryLocator)**

## Tools

PostgreSQL • SQL • DBeaver • Tableau • Excel

## Author

**Lynn Ruch**

M.S. Data Science candidate, University of Pittsburgh
