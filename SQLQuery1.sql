Select *
from PortfolioProject..CovidDeaths
order by 3,4


Select *
from PortfolioProject..CovidVaccinations
order by 3,4


--Select Data to be analyzed:


Select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Comparison of Total Cases vs Total Deaths
--Demonstrating the likelihood of death by covid infection in respective country

Select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Comparing total cases vs population & highlighting percent of population infected

Select location,date,population, total_cases, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at countries with highest innfection rate compared to population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentofPopulationInfected desc


--Showing countries with the Highest Death Ccount per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where Continent is not null
Group by Location
order by TotalDeathCount desc

----Continental analysis:

-- continents with the highest death count per populatuin

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where Continent is not null
Group by continent
order by TotalDeathCount desc


--Continents with the highest death count
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Continents with the highest death count
Select continent, Max(cast(total_cases as int)) as TotalCaseCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2


---Global Numbers

Select date,sum(new_cases) as totalnewCases-- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null and total_cases is not null
group by date
order by 1,2

---reflects the spread pattern of covid originating from asia, traveling to North America and then Europe:

Select date,continent,sum(cast(new_cases as int)) as totalnewcases-- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null and total_cases is not null and date = '2020-01-23'
group by continent, date
order by 3 desc

Select sum(new_cases) as totalnewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
--order by 1,2


--Looking at total population vs Vaccinations

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
Order by 2,3

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated, 
(Sum(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)/dea.population)*100
From PortfolioProject.. CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
Order by 2,3


--Using CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  )
select *, (RollingPeopleVaccinated/Population)*100 as PercentofPopulationVaccinated
from PopvsVac

--breaking it down further

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  )
select  Continent,Location,Max(Population) as population,Max(RollingPeopleVaccinated) as TotalPeopleVaccinated, 
Max((RollingPeopleVaccinated/Population)*100) as PercentofPopulationVaccinated
from PopvsVac
group by location,Continent
order by 1,2


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
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
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as PercentofPopulationVaccinated
from #PercentPopulationVaccinated

-- Creating View to store data for later vizualizations

create view PercentPopulationVaccinated  as
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
