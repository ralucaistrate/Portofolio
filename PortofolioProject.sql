-- Select Data that we are goig to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases VS Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases VS Population
SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location LIKE '%united%'
ORDER BY 1,2


-- Looking at Countries with highest Infection Rate compare to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentageOFPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location LIKE '%united%'
GROUP BY location
ORDER BY PercentageOFPopulationInfected DESC


--Showing location with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS
DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--OVERALL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS
DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
