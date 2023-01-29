select * 
from Covid..[covid-deaths]
where continent is not null
order by 3,4


--select * 
--from Covid..[covid-vaccinations]
--order by 3,4

-- Select necessary data --

select location,date,total_cases,new_cases,total_deaths,population 
from Covid..[covid-deaths]
order by 1,2

-- total cases vs total deaths --

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid..[covid-deaths]
where location like '%States%'
order by 1,2

-- total cases vs population --
-- percentages of population that has Covid --

select location,date,population,total_cases, (total_cases/population)*100 as DeathPercentage
from Covid..[covid-deaths]
where location like '%States%'
order by 1,2

-- countries with highest infection rate compared to population --\

select location,population, max (total_cases) as HighestInfectionCount, max (total_cases/population)*100 as PercentPopulationInfected 
from Covid..[covid-deaths]
--where location like '%States%'
group by location,population
order by PercentPopulationInfected desc

-- highest death rate in countries --
select location, max (total_deaths) as TotalDeathCount 
from Covid..[covid-deaths]
--where location like '%States%'
where continent is not null
group by location
order by TotalDeathCount desc

-- death rate by continent --

select continent, max (cast(total_deaths as int)) as TotalDeathCount 
from Covid..[covid-deaths]
--where location like '%States%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL DATA --

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covid..[covid-deaths]
--Where location like '%states%'
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations --
-- Percentage of Population that recieved at least one Covid Vaccine --

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as AggVaccinationCount
--, (AggVaccinationCount/population)*100
From Covid..[covid-deaths] cd
Join Covid..[covid-vaccinations] cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query --

With PopvsVac (continent, location, date, population, new_vaccinations, AggVaccinationCount)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as AggVaccinationCount
--, (AggVaccinationCount/population)*100
From Covid..[covid-deaths] cd
Join Covid..[covid-vaccinations] cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
--order by 2,3
)
Select *, (AggVaccinationCount/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query --

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AggVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as AggVaccinationCount
--, (AggVaccinationCount/population)*100
From Covid..[covid-deaths] cd
Join Covid..[covid-vaccinations] cv
	On cd.location = cv.location
	and cd.date = cv.date
--where dea.continent is not null 
--order by 2,3
Select *,(AggVaccinationCount/Population)*100
From #PercentPopulationVaccinated




-- Creating View for visualizations --

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as AggVaccinationCount
--, (AggVaccinationCount/population)*100
From Covid..[covid-deaths] cd
Join Covid..[covid-vaccinations] cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
