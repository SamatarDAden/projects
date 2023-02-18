Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Order By location, date

--Selecting column data that will be used

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Order By location, date

--Total Cases vs Deaths/Death Rate

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
Order By location, date

--Total Cases vs Infection Rate

Select Location, Date, Population, total_cases, (total_cases/Population)*100 as InfectionRate
From PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
and continent is not null
Order By location, date

--Infection Rate/Cases vs Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as InfectionRate
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
--Where continent is not null
Group By Location, Population
Order By InfectionRate desc

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as InfectionRate
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
--Where continent is not null
Group By Location, Population, date
Order By InfectionRate desc

--Continent vs Total Deaths

Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is null
and location not in ('World', 'European Union', 'International')
Group By Location
Order By TotalDeathCount desc

--Global Cases, Deaths and Death Rate values

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
--Group by date
--Order By location, date

--Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) 
 OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingVaccinations
-- , (RollingVaccinations/population)*100
--Unable to use derived column to calculate a new column for vaccination rates, Common Table Expression (CTE) or Temp Table are solutions for this
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order By location, date

--CTE

With VacPop (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(int,vac.new_vaccinations)) 
 OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingVaccinations
-- , (RollingVaccinations/population)*100 
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By location, date
)
Select *, (RollingVaccinations/Population)*100
From VacPop

--Temp Table

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(int,vac.new_vaccinations)) 
 OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingVaccinations
-- , (RollingVaccinations/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By location, date

Select *, (RollingVaccinations/Population)*100
From  #PercentagePopulationVaccinated
 
--View creation for visualizations

 Create View PercentagePopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(convert(int,vac.new_vaccinations)) 
 OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingVaccinations
-- , (RollingVaccinations/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order By location, date

Select *
From PercentagePopulationVaccinated
