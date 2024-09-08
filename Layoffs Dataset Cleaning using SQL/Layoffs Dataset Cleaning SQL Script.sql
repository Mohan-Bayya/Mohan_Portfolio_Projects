USE layoffs_dataset;

-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standarize the Data
-- 3. Haandling Null Values, Blank values 
-- 4. Remove Any Unnecessary Columns/Rows.

SELECT * FROM layoffs;

-- Creating a new table layoffs_staging which is similar to layoffs
CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- 1. Remove Duplicates
	-- Identifying the duplicates 
WITH CTE AS(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions ORDER BY date desc) as row_numbers
from layoffs_staging)

SELECT * FROM CTE WHERE row_numbers > 1;

	-- Creating a new table layoffs_staging_2 which is similar to layoffs_staging_2 with row_numbers to remove duplicates
    
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_numbers` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging_2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions ORDER BY date desc) as row_numbers
from layoffs_staging;

SELECT * FROM layoffs_staging_2 WHERE row_numbers > 1;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging_2 WHERE row_numbers > 1;
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM layoffs_staging_2 WHERE row_numbers > 1;


	-- 2.Standardizing data
		-- Trimming the trailing and leading charcters of column values
        -- Updating the different representation of a same column values
        -- Checking spelling mistakes
        -- Changing columns to correct datatype format and then modify to correct datatype
	
-- Column 'company'
SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = TRIM(company);

-- Column 'industry'			
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY 1;

SELECT *  
FROM layoffs_staging_2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Column 'location'
SELECT DISTINCT location 
FROM layoffs_staging_2
ORDER BY 1;

-- Column 'country'
SELECT DISTINCT country 
FROM layoffs_staging_2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging_2
ORDER BY 1;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Column 'date'
SELECT date 
FROM layoffs_staging_2;

SELECT date,str_to_date(date,"%m/%e/%Y") 
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET date = str_to_date(date,"%m/%e/%Y");

ALTER TABLE layoffs_staging_2
MODIFY COLUMN date DATE;

		

	-- 3. Handling Null Values, Blank values.
    
-- COLUMN 'industry'
SELECT * FROM layoffs_staging_2
WHERE industry IS NULL OR industry = "";

SELECT t1.industry,t2.industry
FROM layoffs_staging_2 t1
join layoffs_staging_2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = "")
AND (t2.industry IS NOT NULL AND t2.industry != "") ;

UPDATE layoffs_staging_2 t1
	join layoffs_staging_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = "")
AND (t2.industry IS NOT NULL AND t2.industry != "") ; 

SELECT *
from layoffs_staging_2;

-- 4. Remove Any Unnecessary Columns/Rows.
	-- COLUMN 'total_laid_off'
SELECT * FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

	-- COLUMN 'row_numbers' 
ALTER TABLE layoffs_staging_2
DROP COLUMN row_numbers;

SELECT *
from layoffs_staging_2;


