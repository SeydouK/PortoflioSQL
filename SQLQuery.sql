SELECT * 
FROM covidDeaths
ORDER BY 3,4

-- Lets fill Total_deaths and total_cases with random numbers 

UPDATE covidDeaths
SET total_deaths = ABS(CHECKSUM(NEWID()) % 1000)
WHERE total_deaths IS NULL

UPDATE covidDeaths
SET total_cases = ABS(CHECKSUM(NEWID()) % 1000)
WHERE total_cases IS NULL

-- Lets change their type

ALTER TABLE CovidDeaths 
ALTER COLUMN total_deaths INT


ALTER TABLE CovidDeaths 
ALTER COLUMN total_deaths INT

-- Select data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM covidDeaths
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths,
CASE 
	WHEN total_deaths > 0 and total_cases > 0 THEN (Total_deaths/Total_cases) *100 
END AS DeathPercentage
FROM covidDeaths
ORDER BY 1,2 

-- Looking at total cases vs population

SELECT Location, date, Population, total_cases,
CASE 
	WHEN total_deaths > 0 and total_cases > 0 THEN (Total_cases/Population) *100 
END AS DeathPercentage
FROM covidDeaths
ORDER BY 1,2 


-- Looking at countries with highest infection rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((Total_cases/Population)) *100 AS PercentagePopulationInfected
FROM covidDeaths
GROUP BY location, Population
ORDER BY PercentagePopulationInfected DESC

-- Showing the countries with highest death count per Population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM covidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent 

-- Lets look at the continent with the highest deathcount 

SELECT Continent, MAX(CAST(Total_deaths as int)) as TOtalDeathcount 
From covidDeaths
WHERE continent IS NOT NULL 
group by continent
order by TOtalDeathcount DESC

-- GLOBAL NUMBERS 

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths,
CASE 
	WHEN new_cases > 0 and new_deaths > 0 THEN SUM(CAST(new_deaths as int))/SUM(new_cases) *100 
END AS DeathPercentage
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY date, new_cases, new_deaths 
ORDER BY 1,2 

-- Joining two tables 

SELECT * 
FROM covidDeaths as death
JOIN covidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date

-- Looking at Total Population vs Vaccinations 

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (partition by death.Location) AS RollingPeoapleVaccinated
FROM covidDeaths as death
JOIN covidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date	
WHERE death.continent IS NOT NULL
ORDER BY 1,2,3

-- USE CTE

WITH PopvsVAC (continent, Location, Data, Population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (partition by death.Location) AS RollingPeoapleVaccinated
FROM covidDeaths as death
JOIN covidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date	
WHERE death.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)/100
FROM PopvsVAC

-- Lets do the same but with a temp table 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location nvarchar(225),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (partition by death.Location) AS RollingPeoapleVaccinated
FROM covidDeaths as death
JOIN covidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date	
WHERE death.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)/100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (partition by death.Location) AS RollingPeoapleVaccinated
FROM covidDeaths as death
JOIN covidVaccinations as vacc
	ON death.location = vacc.location
	and death.date = vacc.date	
WHERE death.continent IS NOT NULL


SELECT * 
FROM PercentPopulationVaccinated
