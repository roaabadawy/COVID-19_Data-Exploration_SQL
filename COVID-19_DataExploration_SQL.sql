/* 
COVID-19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


-- Select Data that i am going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Shows likelihood of dying if contracting COVID in Egypt 
-- calculate the case fatality rate (CFR) in Egypt
Select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercantage
From PortfolioProject..CovidDeaths
Where continent is not null and location = 'Egypt'
Order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with COVID
Select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null and location = 'Egypt'
order by 1,2


-- Countries with highest infected rate compared to population
Select location, population, Round(max((total_cases/population)*100), 2) as InfectedRate
From PortfolioProject..CovidDeaths
where continent is not null 
Group by location, population
order by InfectedRate desc


-- Countries with Highest Death Count
Select location, max(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
Group by location
order by TotalDeathCount desc


-- Showing contintents with the highest death count 
Select continent, max(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global numbers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, CVac.new_vaccinations
, SUM(cast(CVac.new_vaccinations as int)) over (PARTITION by CDeath.location order by CDeath.location, CDeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as CDeath
Join PortfolioProject..CovidVaccinations as CVac
	ON CDeath.location = CVac.location and CDeath.date = CVac.date
where CDeath.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
with PopVaccinations(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, CVac.new_vaccinations
,SUM(cast(CVac.new_vaccinations as int)) over (PARTITION by CDeath.location order by CDeath.location, CDeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as CDeath
Join PortfolioProject..CovidVaccinations as CVac
	ON CDeath.location = CVac.location and CDeath.date = CVac.date
where CDeath.continent is not null 

)

Select *, (RollingPeopleVaccinated/Population)*100
From PopVaccinations



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
Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, CVac.new_vaccinations
,SUM(cast(CVac.new_vaccinations as int)) over (PARTITION by CDeath.location order by CDeath.location, CDeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as CDeath
Join PortfolioProject..CovidVaccinations as CVac
	ON CDeath.location = CVac.location and CDeath.date = CVac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select CDeath.continent, CDeath.location, CDeath.date, CDeath.population, CVac.new_vaccinations
,SUM(cast(CVac.new_vaccinations as int)) over (PARTITION by CDeath.location order by CDeath.location, CDeath.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as CDeath
Join PortfolioProject..CovidVaccinations as CVac
	ON CDeath.location = CVac.location and CDeath.date = CVac.date
where CDeath.continent is not null 

