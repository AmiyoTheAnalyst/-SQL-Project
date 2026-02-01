###EDA

select company,sum(funds_raised_millions)
from layoffs_staging2
group by company
order by sum(funds_raised_millions) desc;

select min(`date`),max(`date`)
from layoffs_staging2;

select industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by sum(total_laid_off) desc;

select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by sum(total_laid_off) desc;

select substring(`date`,1,7) as Month_Year,sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by  Month_Year
order by  Month_Year;

with Rolling_Total as
(
select substring(`date`,1,7) as Month_Year,sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by  Month_Year
order by  Month_Year
)
select Month_Year, total_off, sum(total_off) over(order by Month_Year ) as rolling_total
from Rolling_Total;

####Max laid off in a year
with cp as
(select company,year(`date`) as Year_1,max(total_laid_off) as Max_laid_Off
from layoffs_staging2
group by company,year(`date`)
)
select Year_1,sum(Max_laid_off) as Total_laid_Off, 
       dense_rank() over (order by sum(Max_laid_off) desc ) as Ranking
from cp
where Max_laid_Off is not null
and Year_1 is not null
group by Year_1
order by 2 desc;
