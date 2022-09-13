select *
from PortfolioProject..CovidDeaths
order by 3,4

select * 
from PortfolioProject..Vaccination
order by 3,4

--select data that we are going to be using

select location, date, total_cases, total_deaths, population
from CovidDeaths
order by 1,2

--looking at total_cases vs total_deaths
select location, date, total_deaths, total_cases, ((total_deaths/total_cases)*100) as DeathParcentage
from CovidDeaths
where location= 'bangladesh'
order by 1,2

--looking at Total Cases vs Population
-- showing what percentage of population got covid
select location, date, population, total_cases, ((total_cases/population)*100) as InfectedParcentage
from CovidDeaths
where location= 'bangladesh'
order by 1,2

--highest infection rated countries
select location, population, max(total_cases), max(((total_cases/population)*100)) as InfectedParcentage
from CovidDeaths
group by location, population
order by InfectedParcentage desc

--showing continent highest death
select location, max(cast(total_deaths as int))
from CovidDeaths
where continent is null
group by location

--showing countries with Highest death count per Population

select location, max(cast(total_deaths as int))
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--Global Numbers
select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by DeathPercentage desc 


--looking at Total Population VS Vaccination
with PopvsVac( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location, dth.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dth
join PortfolioProject..Vaccination vac
	on dth.location=vac.location
	and dth.date = vac.date	
where dth.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location, dth.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dth
join PortfolioProject..Vaccination vac
	on dth.location=vac.location
	and dth.date = vac.date	
--where dth.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store data for later Visualizations

create view PercentagePopulationVaccinated as
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location, dth.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dth
join PortfolioProject..Vaccination vac
	on dth.location=vac.location
	and dth.date = vac.date	
where dth.continent is not null
