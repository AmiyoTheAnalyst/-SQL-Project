###Data Cleaning

select *
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or Blank values
-- 4. Remove any columns or rows which is unnecessary

create table layoffs_staging
like layoffs;

Insert into layoffs_staging
select *
from layoffs;

select *
from layoffs_staging;

SELECT COUNT(*) AS total_rows
FROM layoffs_staging;

#############################################################################

###1.Removing Duplicates

select *,
row_number() over (partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as Row_no
from world_layoffs.layoffs_staging;

with duplicate_val as
(
select *,
row_number() over (partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as Row_no
from world_layoffs.layoffs_staging
)
select *
from duplicate_val
where Row_no>1;

SELECT COUNT(*) AS total_rows
FROM duplicate_val;



## Again creating a table to remove duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_no` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into layoffs_staging2
select *,
row_number() over (partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as Row_no
from world_layoffs.layoffs_staging;

select *
from layoffs_staging2;

SELECT COUNT(*) AS total_rows
FROM layoffs_staging2;

select *
from layoffs_staging2
where Row_no>1;

select *
from layoffs_staging2
where company='Casper';

SET SQL_SAFE_UPDATES = 0;

delete
from layoffs_staging2
where Row_no>1;

SET SQL_SAFE_UPDATES = 1;

######################################################################

### Standardize

select distinct funds_raised_millions,trim(funds_raised_millions)
from layoffs_staging2
order by 1;

SET SQL_SAFE_UPDATES = 0;
update layoffs_staging2
set funds_raised_millions = trim(funds_raised_millions);

select distinct country
from layoffs_staging2
order by 1;

select*
from layoffs_staging2
where industry like '%crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like '%crypto%';

select*
from layoffs_staging2
where country like '%United States%';

update layoffs_staging2
set country = 'United States'
where country like '%United States%';

select  country,trim(trailing '.' from country) 
from layoffs_staging2;

update layoffs_staging2
set country = trim(trailing '.' from country);

select `date`,str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

#######################################################################

###3.Null and blank values

select *
from layoffs_staging2
where industry is null;

select *
from layoffs_staging2
where industry='';

update layoffs_staging2
set industry=null
where industry='';

select t1.industry,t2.industry
from layoffs_staging2 as t1
join layoffs_staging2 as t2
    on t1.company = t2.company
where t1.industry is null
and t2.industry is not null;

update layoffs_staging2 as t1
join layoffs_staging2 as t2
     on t1.company=t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_staging2
where company= 'Airbnb';

#################################################################
###$.Removing unnecessary Row , Column
##Removing row
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

##Removing Column
select *
from layoffs_staging2;

alter table layoffs_staging2
drop column Row_no;

SELECT COUNT(*) FROM layoffs_staging2;
SELECT COUNT(*) FROM layoffs_staging;

################################################################