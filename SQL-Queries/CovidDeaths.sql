-- Select Covid Death data from coviddeaths table
select * from dbo.coviddeaths$
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
from dbo.coviddeaths$
Where continent is not null 
order by 1,2

-- Total cases vs Total Deaths
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from dbo.coviddeaths$
where continent is not null
order by 1,2

-- Total Cases vs Population
Select Location, date, total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
from dbo.coviddeaths$
order by 1,2

-- Highest infection Rate per location
select Location,population,MAX(total_cases) as HigestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from dbo.coviddeaths$
where continent is not null
group by location,population
order by PercentagePopulationInfected desc

-- Highest deathcount per location
select Location,population,MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as PercentagePopulationDeathCount
from dbo.coviddeaths$
where continent is not null
group by location,population
order by PercentagePopulationDeathCount desc


-- Highest deathcount per CONTINENT
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.coviddeaths$
where continent is null
group by location
order by TotalDeathCount desc


-------  GLOBAL Analysis  ------------------------------------

-- Total cases vs Total Deaths
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
	(SUM(cast(new_deaths as int))/SUM(new_cases) )*100 as Death_percentage
from dbo.coviddeaths$
where continent is not null
--group by date
order by 1 desc



---  Population vs Vaccination
-- Join death and vaccination tables
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths$ as dea
Join covidvaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From coviddeaths$ as dea
Join covidvaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *
From PopvsVac

 

 -- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From coviddeaths$ as dea
Join covidvaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths$ as dea
Join covidvaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 