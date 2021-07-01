select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Order by 3,4

select *
from PortfolioProject.dbo.CovidVac
Order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is null
order by 1,2

--looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2 

--looking at the total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2 

--looking at countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--Breaking down by continent

--Showing Continents with Highest Deathcount per Population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers 

--summing the new cases which will show the total cases given a day, sum of new deaths, calculating the global death percentage,
--dont forget to delete anything related to the date

select sum(new_cases) as total_Global_cases, sum(cast(new_deaths as int)) as total_Global_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2 

-- Global population vs vaccinations or Total amount of people globally that have been vaccinated
-- need to partition by to break up by location, why?, because everytime there is a new location then the count needs to start over. 
--we are not allowing the aggrigate function to continue to run everytime theres a new location
-- example, run only threw canada then dont continue on to America.
--remember to conver to int and order by date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as Rolling_People_Vaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVac vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--cant use a column you just created for calculations. So must create a cte or temp table
--cte goal is to calculate the percent of people vaccinated in the US

--temp table

drop table if exists #Percent_Population_Vaccinated
create table #Percent_Population_Vaccinated
(
continent nvarchar(255),
location varchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as Rolling_People_Vaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVac vac
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (Rolling_People_Vaccinated/population)*100
from #Percent_Population_Vaccinated

--creating a view to store data for later visualizations

create view Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as Rolling_People_Vaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVac vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from Percent_Population_Vaccinated