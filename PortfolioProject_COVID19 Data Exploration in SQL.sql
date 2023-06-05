Select *
From CovidDeaths
Where continent is not null
Order By 3,4

Select *
From CovidVaccinations
Order By 3,4

-- Select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From CovidDeaths
Where Location Like 'Indonesia'
Order By 1,2

-- Looking at the Total Cases vs Population
-- Shows % of population got COVID

Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From CovidDeaths
Where Location Like 'Indonesia'
Order By 1,2

-- Looking at countries with highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Group By location, population
Order By PercentPopulationInfected Desc

-- Showing the countries with the highest Death Count per Population

Select location, Max(cast(total_deaths as int)) As TotalDeathCount
From CovidDeaths
Where continent Is Not Null
Group By location
Order By TotalDeathCount Desc

-- Let's break things down by continent
-- Showing the continents with the highest Death Count per Population

Select continent, Max(cast(total_deaths as int)) As TotalDeathCount
From CovidDeaths
Where continent Is Not Null
Group By continent
Order By TotalDeathCount Desc

-- Global Numbers

Select Sum(cast(new_cases as int)) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(cast(new_cases as int))*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition By dea.location 
Order By dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

-- Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition By dea.location 
Order By dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
Order By 2,3

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition By dea.location 
Order By dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated