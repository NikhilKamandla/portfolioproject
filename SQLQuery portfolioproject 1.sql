select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 1,2


select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you covid in your country


select location,date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--Looking at total cases vs Population
-- Shows what percentage of population got covid

select location,date, population, total_cases,  (total_cases/ population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%india%'
order by 1,2


--Looking at countries with Highest Infection Rate to Population

select location, population, Max( total_cases) as HighestInfectionCount,  Max((total_cases/ population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Group by location, population
order by PercentagePopulationInfected desc


-- Showing the countries with Highest Death Count Per Population

select location, Max(Cast( Total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by location, population
order by  totaldeathcount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, Max(Cast( Total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is  not null
Group by continent
order by  totaldeathcount desc

--Showing the Continent with highest deaths per populations

select location, Max(Cast( Total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by location, population
order by  totaldeathcount desc

-- Global Numbers


select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases ) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%india%'
where continent is not null
--group by date
order by 1,2

--Select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
--, sum( convert(int,vac.new_vaccinations) ) over (partition by dea.location order by dea.location , dea.date) as rolling people vaccinated
--from PortfolioProject..CovidDeaths dea
--Join  PortfolioProject..CovidVaccinations$ vac
--on dea.location = vac.location
--and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

with PopvsVac (continent,location, date, population, rollingpeoplevaccinated, new_vaccinations)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac 



-- TempTable

Drop Table if exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated 


--Creating View to store data for later visulization

--Create View percentpopulationvaccinated as

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations$ vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
----order by 2,3


Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated1

