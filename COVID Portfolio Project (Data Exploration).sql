Select *
from SQLPortfolioProject..CovidDeaths
Where continent is not NULL 
order by 3,4

--Select *
--from SQLPortfolioProject..CovidVaccinations
--order by 3,4

 Select Location,date,total_cases,new_cases,total_deaths,population
 from SQLPortfolioProject..CovidDeaths
 order by 1,2

 --Here we are looking at Total Cases vs Total Deaths
 --Shows the likelihood of dying if you contract covid in your country (ie. US)
 Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from SQLPortfolioProject..CovidDeaths
 Where Location like '%states%'
 order by 1,2

 --Here we are looking at Total Cases vs Population
 --Shows what percentage of population contracted Covid (ie. US)
Select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
 from SQLPortfolioProject..CovidDeaths
 Where Location like '%states%'
 order by 1,2

 --Looking at Countries with Highest Infection Rate vs Population
 Select Location,population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 from SQLPortfolioProject..CovidDeaths
 Group by location,population
 order by percentpopulationinfected desc

  --Looking at Countries with Highest Death Count per Population
  --Had to cast total_deaths as int to run/compute data properly (nvar vs int)**
  --Where continent is NOT NULL: ensures that ¡®continent¡¯ is actually 'continent' and not 'country'**

 Select Location,Max(cast(total_deaths as int)) as TotalDeathCount
 From SQLPortfolioProject..CovidDeaths
Where continent is not NULL 
 Group by location
 order by TotalDeathCount desc 


 --LET'S BREAK THINGS DOWN BY CONTINENT
 Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
  From SQLPortfolioProject..CovidDeaths
  Where continent is not null 
 Group by continent
 order by TotalDeathCount desc 

 --GLOBAL NUMBERS
 --new_deaths' a more accurate representation of total deaths**

 Select date, SUM(new_cases), SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))-- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  From SQLPortfolioProject..CovidDeaths
  Where continent is not null 
  Group by date
 order by 1,2

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage-- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  From SQLPortfolioProject..CovidDeaths
  Where continent is not null 
 order by 1,2

 -- Looking at Total Population vs Vaccinations 

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From SQLPortfolioProject..CovidDeaths dea 
 Join SQLPortfolioProject..CovidVaccinations vac 
      On dea.location = vac.location
	  and dea.date = vac.date
	    Where dea.continent is not null 
	  order by 2,3

--USE CTE
With Popvsvac (Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From SQLPortfolioProject..CovidDeaths dea 
 Join SQLPortfolioProject..CovidVaccinations vac 
      On dea.location = vac.location
	  and dea.date = vac.date
	    Where dea.continent is not null 
	  --order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from popvsvac


--TEMP TABLE
--did drop table to just in case there is already object of same name in database**

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
Continent nvarchar (235),
Location nvarchar (235),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From SQLPortfolioProject..CovidDeaths dea 
 Join SQLPortfolioProject..CovidVaccinations vac 
      On dea.location = vac.location
	  and dea.date = vac.date
	    Where dea.continent is not null 
	  --order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualazations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From SQLPortfolioProject..CovidDeaths dea 
 Join SQLPortfolioProject..CovidVaccinations vac 
      On dea.location = vac.location
	  and dea.date = vac.date
	    Where dea.continent is not null 
	  --order by 2,3

--Now we can use the view as an actual table!

      Select *
      From PercentPopulationVaccinated
