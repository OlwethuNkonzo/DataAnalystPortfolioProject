--Select the Dataset that we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM
Portfolio.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract the virus in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM
Portfolio.dbo.CovidDeaths WHERE location like '%South Africa%'
ORDER BY 1,2 

--Looking at Total Cases vs Population
--Shows what percentage of the population tested positive for covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
FROM
Portfolio.dbo.CovidDeaths WHERE location like '%South Africa%'
ORDER BY 1,2 

--Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
FROM
Portfolio.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 4 desc

--Showing the countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM
Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Let's break things down by Continent
--Showing Continents with Highest Death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM
Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(population) as GlobalPopulation, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM
Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM Portfolio.dbo.CovidDeaths dea
JOIN Portfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM Portfolio.dbo.CovidDeaths dea
JOIN Portfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE (NOT IN USE BECAUSE I HAVE ALREADY USED CTE)
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM Portfolio.dbo.CovidDeaths dea
JOIN Portfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating Views to store data for later visualization

--View for Percentage of people that are vaccinated per country
GO
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM Portfolio.dbo.CovidDeaths dea
JOIN Portfolio.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
GO


--View for Death Percentage in South Africa
GO
Create View DeathPercentageSA as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM
Portfolio.dbo.CovidDeaths WHERE location like '%South Africa%'
--ORDER BY 1,2 
GO

--View for CovidPercentage in South Africa
GO
Create View CovidPercentageSA as
SELECT location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
FROM
Portfolio.dbo.CovidDeaths WHERE location like '%South Africa%'
--ORDER BY 1,2
GO

--View for Highest Infected Countries
GO
Create View HighestInfectedCountries as
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
FROM
Portfolio.dbo.CovidDeaths
GROUP BY location, population
--ORDER BY 4 desc
GO

--View for Countries with Highest Death Count
GO
Create View HighestDeathCount as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM
Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount desc
GO

--View for continents with Highest Death Count
GO
Create View ContinentDeathCount as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM
Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount desc
GO

--View for Global Numbers

GO
CREATE VIEW GlobalDeathRate as
SELECT SUM(population) as GlobalPopulation, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM
Portfolio.dbo.CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
--ORDER BY 1,2
GO

GO
Create View CovidDeathDataset as
SELECT location, population, date, total_cases, new_cases, total_deaths
FROM
Portfolio.dbo.CovidDeaths
--ORDER BY 1,2
GO