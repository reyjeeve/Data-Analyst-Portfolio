--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if Covid is Contracted

SELECT
	Location, 
	date,
	total_cases,
	total_deaths,
	(CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 as DeathChance
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, 
	date,
	total_cases,
	population,
	(CAST(total_cases AS FLOAT)/CAST(Population AS FLOAT))*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Countries with High Infection rates
-- Compared to population

SELECT Location, 
	Population,
	MAX(CAST(total_cases AS FLOAT)) as HighestInfectionCount,
	MAX(
	(CAST(total_cases AS FLOAT)/CAST(Population AS FLOAT))
	)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
Group by Location,
	Population
order by CasePercentage desc

-- Show countries with the highest death rate with respect to population

SELECT Location, 
	MAX(
	CAST(total_deaths AS FLOAT)/CAST(Population AS FLOAT)
	)*100 as DeathPercentage,
	Population,
	MAX(CAST(total_deaths AS FLOAT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location,
	Population
order by DeathPercentage desc

-- Showing continents with the highest death rate in terms of population

SELECT
	continent, 
	SUM(CAST(total_deaths AS FLOAT))/SUM(Population) as ContinentDeathRate,
	SUM(Population) as ContinentPopulation,
	SUM(CAST(total_deaths AS FLOAT)) as ContinentDeaths
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent 
order by ContinentDeathRate desc

--GLOBAL NUMBERS

SELECT
	date,
	SUM(new_cases) as TotalCasesPerDay,
	SUM(new_deaths) as TotalDeathsPerDay,
	SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentagePerDay
FROM
	PortfolioProject..CovidDeaths
where
	continent is not null
Group By
	date
order by 1

--Looking at Total Population vs Vaccination

Select dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as FLOAT)) 
	OVER (Partition by dea.location
	Order by dea.location, dea.Date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order By 1,2,3

--USE CTE (We can't use a column that was created in the same
--SELECT statement)

With PopvsVac
(
Continent, Location, Date, Population,
New_Vaccinations, TotalVaccinated
)
as
(
Select dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as FLOAT)) 
	OVER (Partition by dea.location
	Order by dea.location, dea.Date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
)
Select *, (TotalVaccinated/Population)*100 as PercentPopVacPerLoc
From PopvsVac
Order By Location, Date

-- Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as FLOAT)) 
	OVER (Partition by dea.location
	Order by dea.location, dea.Date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date

Select *, (TotalVaccinated/Population)*100 as PercentPopVacPerLoc
From #PercentPopulationVaccinated
Where Continent is not null
Order by 1,2

-- Creating View to store data for later visualizations

USE PortfolioProject
GO
Create View PopulationVaccinated as
Select dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as FLOAT)) 
	OVER (Partition by dea.location
	Order by dea.location, dea.Date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'PopulationVaccinated')
    DROP VIEW PopulationVaccinated;
