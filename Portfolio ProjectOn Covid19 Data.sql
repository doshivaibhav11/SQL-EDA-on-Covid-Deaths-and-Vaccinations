/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select * from PortfolioProjectOnCovidData..CovidDeaths
order by 3,4

select * from PortfolioProjectOnCovidData..CovidVaccinations
order by 3,4


---

select * from CovidDeaths
where continent is not null
order by 3,4

--- Location and Datewise new covid cases and its total death count

Select Location ,date,new_cases,total_cases,total_deaths,population from CovidDeaths
where continent is not null
order by 1,2


--- Looking at Total Cases vs Total Deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as [Death%]
from CovidDeaths
where location like '%India%'
order by 1,2


--- Looking at Total Cases vs Population
---Show How much % of population got covid

Select location,date,total_cases,population,(total_deaths/population)*100 as [PopulationInfected %]
from CovidDeaths
where location like '%India%'
order by 1,2

--- Countries with Highest Infection Rate compared to Population

Select Location,Population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as [PopulationInfected %]
from CovidDeaths
Group by location,population
order by 4 desc

--- Countries with Highest Death Count per Population

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
order by 2 desc

--- Showing Continents with the highest death count per population

select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

---GLOBAL Numbers

Select SUM(cast(new_deaths as int)) as total_deaths,SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)*100)/SUM(new_cases) as [Death %]
from CovidDeaths
where continent is not null
order by 1,2

---Total Population vs Vaccinations

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(Cast(cv.new_vaccinations as int)) OVER(Partition by cd.Location Order by cd.location,cd.date) as VaccinatedPeoplebyCountry
from CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3


---Total Population vs Vaccinations using CTE

With PopvsVac
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int )) OVER(Partition by cd.location order by cd.location,cd.date) as VaccinatedPeoplebyCountry
from CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cv.location and cd.date=cv.date
where cd.continent is not null and cd.location='India'
)

Select * , (cast(VaccinatedPeoplebyCountry as float)*100/cast(Population as int)) as [VaccinatedPeoplebyCountry in %]
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #VaccinatedPeoplebyCountrypercent
Create Table #VaccinatedPeoplebyCountrypercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #VaccinatedPeoplebyCountrypercent
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int )) OVER(Partition by cd.location order by cd.location,cd.date) as VaccinatedPeoplebyCountry
from CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cv.location and cd.date=cv.date
where cd.continent is not null and cd.location='India'


Select * , (cast(VaccinatedPeoplebyCountry as float)*100/cast(Population as int)) as [VaccinatedPeoplebyCountry in %]
from #VaccinatedPeoplebyCountrypercent


-- Creating View to store data for later visualizations

CREATE View VaccinatedPeoplePercent as 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,SUM(CAST(cv.new_vaccinations as int )) OVER(Partition by cd.location order by cd.location,cd.date) as VaccinatedPeoplebyCountry
from CovidDeaths cd
Join CovidVaccinations cv
On cd.location=cv.location and cd.date=cv.date
where cd.continent is not null 