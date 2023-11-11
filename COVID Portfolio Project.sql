/*

COVID-19 Data Exploration

Skills used: 
- Joins, 
- CTE's
- Temp Tables
- Windows Functions
- Aggregate Functions
- Creating Views
- Converting Data Types

*/

USE portfolioproject;
select * from covid_deaths;
select * from covid_vaccinations;

-- Select data that we are going to be starting with

SELECT
	location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
	covid_deaths;
    
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in Australia

SELECT
	location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS death_percentage
FROM
	covid_deaths
WHERE
	location = 'Australia';
    

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT
	location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 AS percent_population_infected
FROM
	covid_deaths;


-- Countries with highest infection rates compared to population

SELECT
	location,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX(total_cases/population)*100 AS percent_population_infected
FROM
	covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- Countries with highest death count per population

SELECT
	location,
    MAX(total_deaths) AS total_death_count
FROM
	covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- Breaking things down by continent
--  Continents with the highest death count per population

SELECT
	continent,
    MAX(total_deaths) AS total_death_count
FROM
	covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- Global numbers

SELECT
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    ROUND((SUM(new_deaths)/SUM(new_cases))*100, 2) AS death_percentage
FROM
	covid_deaths
WHERE	
	continent IS NOT NULL
ORDER BY 1,2;


-- Total Population vs. Vaccinations
-- Shows Percentage of Population that has received at least one Covid vaccine

SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated    
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


-- Using CTE to perform Calculation on previous query

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated    
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100 
FROM pop_vs_vac;



-- Using Temp Table to perform Calculation on previous query

DROP TABLE IF EXISTS temp_percent_population_vaccinated;
CREATE TABLE temp_percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
rolling_people_vaccinated bigint
);


INSERT INTO temp_percent_population_vaccinated
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated    
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (rolling_people_vaccinated/population)*100 
FROM temp_percent_population_vaccinated;


-- Creating VIEW to store data for later visualisations

CREATE VIEW v_percent_population_vaccinated AS
SELECT 
	dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated    
FROM
    covid_deaths dea
        JOIN
    covid_vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

