--File...
--Split the file to two tables: CovidDeaths & CovidVaccinations

Select *
From CovidDeaths
Where continent is not null
Order By 3,4

Select *
From CovidVaccinations
Order By 3,4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying of you contract covid in USA

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%states%'
Order By 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max(total_deaths/population)*100 as PercentPopulationInfected
From CovidDeaths
Group By Location, Population
Order By PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
-- Discovered that some locations are actually a continent, where its continent is however null

Select Location, Max(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

Select continent, Max(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)/new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Order By 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From CovidDeaths dea JOIN CovidVaccinations vac 
  ON dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea JOIN CovidVaccinations vac 
  ON dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 


-- TEMP TABLE

Drop Table if exist #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea JOIN CovidVaccinations vac 
  ON dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea JOIN CovidVaccinations vac 
  ON dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated


