/*
COVID-19 Data Exploration in SQL
*/

--Previewing the data

SELECT 
  *
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
WHERE 
  continent IS NOT NULL
ORDER BY
  3,4

SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
ORDER BY 
  1,2


-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases) * 100 AS death_percentage
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
WHERE location = 'United States'
ORDER BY 
  1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population contracted covid

SELECT
  location,
  date,
  population,
  total_cases,
  ROUND((total_cases/population) * 100,3) AS case_percentage
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
WHERE location = 'United States'
ORDER BY 
  1,2


-- Looking at countries with highest case rates compared to population

SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  MAX(ROUND((total_cases/population) * 100,3)) AS percent_population_infected
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
GROUP BY
  location,
  population
ORDER BY 
  percent_population_infected DESC


-- Looking at highest death count by country

SELECT
  location,
  MAX(total_deaths) AS highest_death_count,
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY 
  highest_death_count DESC


-- Looking at highest death count by continent

SELECT 
  location,
  MAX(total_deaths) AS highest_death_count,
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
WHERE
  continent IS NULL
  AND location NOT LIKE '%income%'
GROUP BY
  location
ORDER BY 
  highest_death_count DESC


-- Looking at highest death count by continent population

SELECT 
  location,
  MAX(total_deaths) AS highest_death_count,
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
WHERE
  continent IS NULL
  AND location NOT LIKE '%income%'
GROUP BY
  location
ORDER BY 
  highest_death_count DESC


-- Looking at global numbers

SELECT 
  SUM(new_cases) AS total_new_cases,
  SUM(new_deaths) AS total_new_deaths,
  ROUND(SUM(new_deaths)/SUM(new_cases) * 100,3) AS death_percentage
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths`
WHERE
  continent IS NOT NULL
ORDER BY
  death_percentage DESC
  

-- Looking at running total vaccinations per location

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS running_total_new_vaccinations
FROM
  `covid-analysis-378101.covid_analysis.covid_deaths` AS dea
JOIN 
  `covid-analysis-378101.covid_analysis.covid_vaccinations` AS vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  2,3


-- Creating view to store date for later visualizations

CREATE VIEW
  covid-analysis-378101.covid_analysis.PercentPopulationVaccinates AS
  SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS running_total_new_vaccinations
  FROM 
    `covid-analysis-378101.covid_analysis.covid_deaths` AS dea
  JOIN 
    `covid-analysis-378101.covid_analysis.covid_vaccinations` AS vac
    ON
      dea.location = vac.location
      AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL
