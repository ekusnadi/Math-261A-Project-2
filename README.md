# Math 261A Project 2

## Author & Submission Info
- **Author:** Ethan Kusnadi  
- **Date of Submission:**  

## Project Structure

- **scripts/**
  - `build_blockface_dataset.py`  
    Python script that constructs the blockface-level dataset by cleaning and merging parking meter and citation data, parsing street numbers, applying parity-based matching, resolving ambiguous citation-to-blockface matches, and computing citation rates per meter.  

- **data/**
  - `Parking_Meters.csv`  
    Raw SFMTA Parking Meters dataset.
  - `SFMTA_Meter_Citations_2025.csv`  
    Raw SFMTA parking meter citation dataset for 2025.  
  - `blockface_regression_dataset_2025.csv`  
    Final regression-ready blockface dataset produced by the processing script.  
  *(Raw data is included locally for reproducibility.)*

- **references.bib**  
  BibTeX file containing all sources cited in the report.

## Dataset License
The **Parking Meters** and **SFMTA - Parking Citations & Fines** datasets are published by the San Francisco Municipal Transportation Agency (SFMTA) on the DataSF Open Data Portal.
DataSF provides these datasets under the Open Data Commons Public Domain Dedication and License (PDDL), which permits reuse, modification, and redistribution without restriction.
