SELECT * FROM CovidDeaths
where continent is not null
order by 3,4

SELECT * FROM CovidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death %'
FROM CovidDeaths
WHERE location = 'Canada'
order by 1, 2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death %'
FROM CovidDeaths
WHERE location like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows the % of the population that got infected

SELECT location, date, total_cases, population, (total_cases/population)*100 as '% of population'
FROM CovidDeaths
--WHERE location like '%states%'
order by 5

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as '% of population infected'
FROM CovidDeaths
Group By location, population
order by 4 DESC

-- Showing countries with highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
where continent is not null
Group By location, population
Order By TotalDeathCount DESC


-- Breaking down in Continents

-- Continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
where continent is null
Group By location
Order By TotalDeathCount DESC


-- Global Analysis

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'Canada'
where continent is not null
group by date
order by 1, 2

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'Canada'
where continent is not null
--group by date
order by 1, 2


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS VaccinationRollingCount,
(VaccinationRollingCount/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE

with PopVsVac (continent, location, date, population, new_vaccinations, VaccinationRollingCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS VaccinationRollingCount
--(VaccinationRollingCount/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (VaccinationRollingCount/population)*100
FROM PopVsVac;


-- Using Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
VaccinationROllingCount numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS VaccinationRollingCount
--(VaccinationRollingCount/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


SELECT *, (VaccinationRollingCount/population)*100
FROM #PercentPopulationVaccinated
order by 2



-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS VaccinationRollingCount
--(VaccinationRollingCount/population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3