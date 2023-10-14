

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



Select *
FROM PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4



-- Select Data that we are going to be starting with


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


Select Location, date, total_cases, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where location like '%india%'
and  continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population got Covid 

Select Location, date, Population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
where location like '%india%'
and continent is not null 
order by  4 desc 

-- Countries with Highest Infection Rate compared to Population 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0)))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--where location like '%india%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by Continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating Views to store data for later visualizations

-- View 1 (PercentPopulationVaccinated)

Create View  PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


-- View 2 (RollingPeopleVaccinated)
 
Create View RollingPeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3