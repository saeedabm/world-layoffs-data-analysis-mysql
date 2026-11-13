
-- ============================================================
-- PROJECT: WORLD LAYOFFS - DATA CLEANING
-- TOOL: MySQL
-- OBJECTIVE: Clean and prepare raw layoffs data for analysis
-- ============================================================


-- ============================================================
-- SECTION 1: CREATE STAGING TABLE
-- Purpose: Preserve the original dataset and perform cleaning
-- operations on a separate copy.
-- ============================================================

SELECT *
FROM world_layoffs.layoffs;

-- Create a staging table with the same structure
CREATE TABLE layoffs_staging
LIKE world_layoffs.layoffs;

-- Copy the original data into the staging table
INSERT INTO layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

-- Verify the staging table
SELECT *
FROM layoffs_staging;


-- ============================================================
-- SECTION 2: IDENTIFY AND REMOVE DUPLICATES
-- Purpose: Identify duplicate records using ROW_NUMBER()
-- and remove the extra occurrences.
-- ============================================================

-- Identify potential duplicates using all relevant columns
WITH duplicate_cte AS
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Check duplicate records for a specific company
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create a second staging table with an additional row_num column
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

-- Insert records with row numbers assigned to duplicates
INSERT INTO layoffs_staging2
(
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    row_num
)
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY
            company,
            location,
            industry,
            total_laid_off,
            percentage_laid_off,
            `date`,
            stage,
            country,
            funds_raised_millions
    ) AS row_num
FROM world_layoffs.layoffs_staging;

-- Disable safe update mode temporarily
SET SQL_SAFE_UPDATES = 0;

-- Delete duplicate records, keeping the first occurrence
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Verify duplicate removal
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- ============================================================
-- SECTION 3: STANDARDIZE DATA
-- Purpose: Correct inconsistent text values, remove unwanted
-- spaces and standardize date formats.
-- ============================================================

-- Remove leading and trailing spaces from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Check distinct industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Identify inconsistent crypto industry values
SELECT industry
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

-- Standardize crypto industry values
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- Check distinct location values
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- Check distinct country values
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Remove trailing commas from United States values
UPDATE layoffs_staging2
SET country = TRIM(TRAILING ',' FROM country)
WHERE country LIKE 'United States%';

-- Convert date values from text to DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the column datatype from TEXT to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ============================================================
-- SECTION 4: HANDLE NULL AND MISSING VALUES
-- Purpose: Identify missing values, replace blank values with
-- NULL and populate missing industry values where possible.
-- ============================================================

-- Identify records with missing industry values
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Convert blank industry values into NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';

-- Populate missing industry values using matching company records
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
AND TRIM(t2.industry) <> '';

-- Check records where both layoff fields are missing
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- ============================================================
-- SECTION 5: REMOVE UNNECESSARY RECORDS AND COLUMNS
-- Purpose: Remove records that do not contain layoff
-- information and drop temporary columns.
-- ============================================================

-- Remove the temporary row number column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Delete records where both layoff fields are NULL
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- ============================================================
-- SECTION 6: FINAL DATA VALIDATION
-- Purpose: Verify the cleaned dataset before further analysis.
-- ============================================================

-- View the cleaned dataset
SELECT *
FROM layoffs_staging2;

-- Check total number of records
SELECT COUNT(*) AS total_records
FROM layoffs_staging2;

-- Check for remaining NULL industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

-- Check distinct industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Check date range
SELECT
    MIN(`date`) AS earliest_layoff_date,
    MAX(`date`) AS latest_layoff_date
FROM layoffs_staging2;

-- Check for remaining duplicate records
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layoffs_staging2
GROUP BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
HAVING COUNT(*) > 1;

-- ============================================================
-- END OF DATA CLEANING PROJECT
-- ============================================================
