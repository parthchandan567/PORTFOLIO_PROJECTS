SELECT *
FROM covid_data
WHERE continent is not null
order by 3,4;
SELECT location, date, total_cases,new_cases,total_deaths,population
FROM covid_data
ORDER BY 1,2; 
-- LOOKIN AT total_cases vs total_deaths
-- Shows likelyhood of dying if you contract covid in your country
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths::numeric / total_cases::numeric) * 100.00 AS DeathPercentage
FROM covid_data
WHERE location like 'India'
AND continent is not null
ORDER BY 1, 2;

-- Looking at total cases vs population
SELECT
    location,
    date,
    total_cases,
	population,
    (total_cases::numeric / population) * 100.00 AS PERCENT_population_infected
FROM covid_data
WHERE location like 'India'
ORDER BY 1, 2;

--Looking at countries with highest infection rate compared to poulation
SELECT
    location,
	population,
    MAX(total_cases) AS Highest_infection_count,
    MAX(total_cases::numeric / population) * 100.00 AS Percent_population_infected
FROM covid_data
--WHERE location like 'India'
WHERE continent is not null
GROUP BY 1,2
ORDER BY Percent_population_infected DESC;


--Coutries with highest death count per population
SELECT
    location,
	MAX(cast(total_deaths as int)) as Total_death_count
FROM covid_data
--WHERE location like 'India'
WHERE continent is not null
GROUP BY 1
ORDER BY Total_death_count DESC;

-- Lets breakup by continent
SELECT
    continent,
	MAX(cast(total_deaths as int)) as Total_death_count
FROM covid_data
--WHERE location like 'India'
WHERE continent is not null
GROUP BY 1
ORDER BY Total_death_count DESC;


-- Showing continents with highest death count
SELECT
    continent,
	MAX(cast(total_deaths as int)) as Total_death_count
FROM covid_data
--WHERE location like 'India'
WHERE continent is not null
GROUP BY 1
ORDER BY Total_death_count DESC;


-- global


SELECT
  --  date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS numeric)) AS total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths AS numeric)) / SUM(new_cases) * 100.00
    END AS Death_percentage
FROM covid_data
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- LOOKING AT POPULATION VS VACCINATION
-- LOOKING AT POPULATION VS VACCINATION
WITH POPVSVAC (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        CAST(vac.new_vaccinations AS numeric) AS new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
    FROM covid_data dea
    JOIN covid_vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)

-- Now, you should have a query here that uses the CTE
SELECT *, (popvsvac.cumulative_vaccinations / population) * 100.00 AS vaccination_percentage
FROM POPVSVAC;



--temp table
DROP TABLE if exists percentpopulationvaccinated
CREATE TABLE percentpopulationvaccinated
(
    continent VARCHAR(255),
    location VARCHAR(255),
    date TIMESTAMP,
    population NUMERIC,
    new_vaccinations NUMERIC,
    cumulative_percentage NUMERIC
);

-- Insert data from the CTE into the new table
INSERT INTO percentpopulationvaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(vac.new_vaccinations AS NUMERIC) AS new_vaccinations,
    (CAST(vac.new_vaccinations AS NUMERIC) / dea.population) * 100.00 AS cumulative_percentage
FROM covid_data dea
JOIN covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Retrieve data from the new table
SELECT *
FROM percentpopulationvaccinated;



--CREATING VIEW
CREATE VIEW percentpoulationvaccinated as 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    CAST(vac.new_vaccinations AS NUMERIC) AS new_vaccinations,
    (CAST(vac.new_vaccinations AS NUMERIC) / dea.population) * 100.00 AS cumulative_percentage
FROM covid_data dea
JOIN covid_vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


