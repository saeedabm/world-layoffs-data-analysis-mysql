# World Layoffs Data Analysis | MySQL

## Project Overview
This project focuses on analyzing global layoffs data using MySQL. It covers two major stages of data analysis: **Data Cleaning** and **Exploratory Data Analysis (EDA)** to prepare raw data, identify patterns, and uncover meaningful insights.

## Tools & Technologies
- MySQL
- MySQL Workbench
- SQL

## Dataset
The dataset contains global company layoff records, including company names, industries, locations, dates, total employees laid off, percentage of workforce laid off, funding stages, and funds raised.

*Dataset source: Add your original dataset source link here.*

## Project Workflow

### 1. Data Cleaning
Performed data cleaning to improve data quality and consistency.

Key operations:
- Created staging tables to preserve the original dataset.
- Identified and removed duplicate records using `ROW_NUMBER()` and CTEs.
- Standardized company names, industry values, and country names.
- Converted date values from text to DATE format.
- Handled missing and NULL values using self-joins.
- Removed records with no available layoff information.
- Performed validation checks on the cleaned dataset.

### 2. Exploratory Data Analysis (EDA)
*In Progress*

Exploring the cleaned dataset to identify trends and patterns in global layoffs.

Planned analysis:
- Companies with the highest layoffs.
- Layoffs across different industries and countries.
- Yearly and monthly layoff trends.
- Layoffs by company funding stage.
- Companies with the highest percentage of workforce laid off.

```

## SQL Concepts Demonstrated
- SELECT, WHERE, ORDER BY
- GROUP BY and Aggregate Functions
- Joins and Self-Joins
- Common Table Expressions (CTEs)
- Window Functions
- String and Date Functions
- Data Manipulation (UPDATE, DELETE)
- NULL Handling and Data Validation

## Objective
To strengthen practical SQL skills by working with a real-world dataset and demonstrate the ability to clean, explore, and analyze data using MySQL.
