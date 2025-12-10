# Math 261A Project 2

## Author & Submission Info
- **Author:** Ethan Kusnadi  
- **Date of Submission:**  December 10, 2025

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

- **paper/**
  - `references.bib`  
    BibTeX file containing all sources cited in the report.

## External Resources
This project used **ChatGPT (GPT-5.1, OpenAI, 2025)** as an external resource. ChatGPT was used for:  
- Feedback and assistance in revising the clarity, organization, and flow of writing
- Assistance for formatting R code and visualizations
- Drafting and refining the Python script for data cleaning and merging
- Guidance on meeting project guidelines and rubric requirements
- Compiling the reference list and drafting this README file
- Converting the report into Quarto format

All base code, data analysis, and interpretation of results were performed independently by the author.  

## Dataset License
The **Parking Meters** and **SFMTA - Parking Citations & Fines** datasets are published by the San Francisco Municipal Transportation Agency (SFMTA) on the [DataSF Open Data Portal](https://data.sfgov.org/).
DataSF provides these datasets under the [Open Data Commons Public Domain Dedication and License (PDDL)](http://opendatacommons.org/licenses/pddl/1.0/), which permits reuse, modification, and redistribution without restriction.

## Acknowledgments
This project repository is based on the template provided by [Rohan Alexander](https://github.com/RohanAlexander/starter_folder/tree/main).
