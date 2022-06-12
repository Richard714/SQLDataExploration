--looking at total cases vs population
--shows what percentage of population got covide
Select location, date, total_cases, population, (total_cases/population) * 100 as CasesPerPopulationPercentage
From SQLDataExploration..CovidDeaths$
Where location like '%states%'
order by 1,2

--looking at counties with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, population, 
	MAX((total_cases/population) * 100) as percentPopulationInfected
From SQLDataExploration..CovidDeaths$
Where location like '%states%'
group by location, population
order by percentPopulationInfected desc

In the query below we have to add the “where continent is not null so it pulls up the country 

--showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as MaxDeaths , population, MAX((total_deaths/population) * 100) as DeathPerPopulation
From SQLDataExploration..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by location, population
order by MaxDeaths desc

--Checking its by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLDataExploration..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLDataExploration..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
 (new_cases)*100 as DeathPercentage
From SQLDataExploration..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2

-- total infection rate
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
 (new_cases)*100 as DeathPercentage
From SQLDataExploration..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--Looking at Total population vs Vaccinactions
-- add the dea and vac at the end as alias
-- add a bigint bc int cannot handle the sum of the data
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From SQLDataExploration..CovidDeaths$ dea
Join SQLDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
--2 methods. Can use CTE or Temp table.
--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From SQLDataExploration..CovidDeaths$ dea
Join SQLDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From SQLDataExploration..CovidDeaths$ dea
Join SQLDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

use [SQLDataExploration]
Go

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From SQLDataExploration..CovidDeaths$ dea
Join SQLDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3