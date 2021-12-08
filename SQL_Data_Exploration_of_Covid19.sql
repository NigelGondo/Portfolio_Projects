-- THIS SCRIPT IS THERE TO DO SOME COVID 19 DATA EXPLORATION

-- Exploring the two data tables from the covid 19 database
USE Covid_19_Statistics;


SELECT * 
FROM CovidDeaths$;


SELECT * 
FROM CovidVaccinations$;


-- There was an issue with a datatype in the new deaths column. When imported it was assigned as a varchar data type
-- So changing the datatype to integer
ALTER TABLE CovidDeaths$
ALTER COLUMN new_deaths INT;


-- Now to bring some calculations in the queries
SELECT continent, 
	   FORMAT(SUM(new_cases), '#,###,###') AS TOTAL_CASES,
	   FORMAT(SUM(new_deaths), '#,###,###') AS TOTAL_DEATHS
FROM CovidDeaths$
GROUP BY continent
ORDER BY TOTAL_CASES desc, TOTAL_DEATHS desc;


-- Calculation of the death rate based on confirmed cases by country
SELECT location, 
	   FORMAT((SUM(new_deaths) / SUM(new_cases)), 'P') as Death_Rate
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Death_Rate desc;


-- Top 10 Countries with highest death rate
SELECT location, 
	   FORMAT((SUM(new_deaths) / SUM(new_cases)), 'P') as Death_Rate
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Death_Rate desc
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;


-- Calculating average new deaths of per day for each continent
SELECT continent, 
	   AVG(new_deaths) AS Average_Deaths
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent;


-- There was an issue with a datatype in the new deaths column. When imported it was assigned as a varchar data type
-- So changing the datatype to integer
ALTER TABLE CovidDeaths$
ALTER COLUMN total_deaths INT;


-- Calculating average total deaths to date for each continent
Select continent, 
	   AVG(total_deaths) as Average_Deaths
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent;


-- Creating views so as to quickly query common data wanted by users
CREATE VIEW death_rate AS
Select continent, 
	   AVG(total_deaths) as Average_Deaths
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent;


-- Executing the views created. These maybe common daily queries required by users so makes sense to create a view to simplfy it
SELECT * FROM death_rate;


-- There was an issue with a datatype in the new vaccinations column. When imported it was assigned as a varchar data type
-- So changing the datatype to integer
ALTER TABLE CovidVaccinations$
ALTER COLUMN new_vaccinations INT;


-- Moving on to the vaccination table to calculate vaccination rate against country population
SELECT location,
	   population, 
	   SUM(new_vaccinations), 
	   FORMAT(SUM(new_vaccinations) / population, '#,###,###') as Vaccination_Rate
FROM CovidVaccinations$
GROUP BY location, population
ORDER BY Vaccination_Rate;


-- Top 10 Countries driving vaccinations
SELECT location,
	   population, 
	   SUM(new_vaccinations) AS 'New Vaccinations', 
	   FORMAT(SUM(new_vaccinations) / population, '#,###,###') AS 'Vaccination Rate'
FROM CovidVaccinations$
GROUP BY location, population
ORDER BY 'Vaccination Rate' DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

-- Joining Tables
SELECT cd.date, cd.new_cases, cd.new_deaths, cv.new_vaccinations
FROM CovidDeaths$ cd
INNER JOIN 
CovidVaccinations$ cv 
ON cd.date = cv.date;


SELECT cd.date, cd.new_cases, cd.new_deaths, cv.new_vaccinations
FROM CovidDeaths$ cd
LEFT JOIN 
CovidVaccinations$ cv 
ON cd.date = cv.date;


SELECT cd.date, cd.new_cases, cd.new_deaths, cv.new_vaccinations
FROM CovidDeaths$ cd
RIGHT JOIN 
CovidVaccinations$ cv 
ON cd.date = cv.date;


-- Creating indexes. Since we are dealing with a large date set indexing will be benefitial in getting quick results
CREATE INDEX cases_deaths_index
ON CovidDeaths$(new_cases, new_deaths, date); 


CREATE INDEX vaccination_index
ON CovidVaccinations$ (date, new_vaccinations); 


-- Using a case statement to determine if a country is a covid 19 Hotspot and determine level of lockdown required
SELECT continent, 
	   location,  
	   AVG(new_cases) AS Average_Daily_Cases,
	   AVG(new_deaths) AS Average_Deaths, 
	   CASE WHEN AVG(new_cases) >= 500 THEN 'STRICT LOCKDOWN REQUIRED'
	   WHEN AVG(new_cases) >= 300 THEN 'ADJUSTED LOCKDOWN REQUIRED' 
	   WHEN AVG(new_cases) >= 100 THEN 'MODERATE LOCKDOWN REQUIRED'
	   ELSE 'SOFT LOCKDOWN'  END AS Lockdown_Level
FROM CovidDeaths$
WHERE date LIKE '2020-04%'
GROUP BY continent, location;


-- To query to see if a higher GDP per capita results in lower cases and deaths
SELECT cd.continent, 
	   cd.location, 
	   FORMAT(SUM(cd.new_cases), '#,###,###') AS Cases,
	   FORMAT(SUM(cd.new_deaths), '#,###,###') AS Deaths,
	   FORMAT(cv.gdp_per_capita, '#,###,###')
FROM CovidDeaths$ cd 
INNER JOIN
CovidVaccinations$ cv 
ON cd.date = cv.date
GROUP BY cd.continent, cd.location, cv.gdp_per_capita
ORDER BY Deaths;
