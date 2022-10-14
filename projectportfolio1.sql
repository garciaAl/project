
select *
from portfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from portfolioProject..covidvaccinations
order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths
order by 1,2

--Looking at total cases VS total deaths
--shows the likelyhood of fying if you contract covid in your ocuntry
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--looking at the total cases vs popilation
--shows percentage of population that got covid
select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from portfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--countries with highest infection rates compared to population

select location, population, MAX(total_cases)as highestinfectioncount, MAX((total_cases/population))*100 as percentpopulationinfected
from portfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by percentpopulationinfected desc

--countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc


--BREAKING THINGS DOWN BY CONTINENT
select continent, Max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is not null --and location in('asia', 'africa', 'North america', 'South america', 'Europe', 'oceania', 'world', 'international', 'European union')
group by continent
order by totaldeathcount desc


-- showing continents with the highest death counts per peopulation 

select location, Max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is null and location in('asia', 'africa', 'North america', 'South america', 'Europe', 'oceania', 'world', 'international', 'European union')
group by location  
order by totaldeathcount desc

-- Global Number
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2


--joining tables

select *
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date

--total population vs. vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --, (rollingpeoplevaccinated/population)*100
From portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --, (rollingpeoplevaccinated/population)*100
From portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


-- temp table

drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --, (rollingpeoplevaccinated/population)*100
From portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--create view to store data for later visualizations 


Create View percentpopulationvaccinated2 as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated --, (rollingpeoplevaccinated/population)*100
From portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3



