SELECT * FROM PortfolioProject.coviddeathsc
order by 3,4;
SELECT * FROM PortfolioProject.covidvaccinationsnew
order by 3,4;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject.coviddeathsc
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM PortfolioProject.coviddeathsc
order by 1,2;

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM PortfolioProject.coviddeathsc
Where location like '%Canada%'
order by 1,2;

-- Looking at Total cases vs population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject.coviddeathsc
-- Where location like '%Canada%'
order by 1,2;


SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject.coviddeathsc
order by 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject.coviddeathsc
Group by Location, Population
order by PercentagePopulationInfected desc;

-- Showing countries with highest Death count per population
SELECT Location, Max(total_deaths) as TotalDeathCount
FROM PortfolioProject.coviddeathsc
where continent is not null
Group by Location
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, Max(total_deaths) as TotalDeathCount
FROM PortfolioProject.coviddeathsc
where continent is not null
Group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(New_Cases))*100 as DeathPercentage 
FROM PortfolioProject.coviddeathsc
WHERE continent is not null
Group By date
order by 1,2;

-- LOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.coviddeathsc dea
Join PortfolioProject.covidvaccinationsnew vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;


SELECT dea.continent, 
       dea.location, 
       dea.date, 
       population, 
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeathsc dea
JOIN PortfolioProject.covidvaccinationsnew vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


SELECT dea.continent, 
       dea.location, 
       dea.date, 
       population, 
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
     --  ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject.coviddeathsc dea
JOIN PortfolioProject.covidvaccinationsnew vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.coviddeathsc dea
JOIN PortfolioProject.covidvaccinationsnew vac
ON dea.location = vac.location
AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- TEMP TABLE

CREATE TABLE PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    PortfolioProject.coviddeathsc dea
JOIN PortfolioProject.covidvaccinationsnew vac ON dea.location = vac.location AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;

















