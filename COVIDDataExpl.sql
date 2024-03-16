USE PortfolioProject;
 SELECT *
 FROM CovidDeaths$
 WHERE continent is NOT NULL
 ORDER BY 3,4

 SELECT *
 FROM CovidVaccinations$
 ORDER BY 3,4

 SELECT location,date,total_cases,new_cases,total_deaths,population
 FROM CovidDeaths$
  WHERE continent is NOT NULL
 ORDER BY 1,2
 --Likelihood of dying if you contract covid in your country
 SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 DeathPercentage
 FROM CovidDeaths$
 WHERE location='India'
 ORDER BY 1,2

 --Looking at tot cases vs population
 --percentage of population infected
  SELECT location,date,total_cases,population,(total_cases/population)*100 InfectedRate
 FROM CovidDeaths$
  WHERE continent is NOT NULL
-- WHERE location='India'
 ORDER BY 1,2

--Countries w highest infection rate
 SELECT location,population,MAX(total_cases) HighestInfectionRate,MAX(total_cases/population)*100 InfectedRate
 FROM CovidDeaths$
-- WHERE location='India'
GROUP BY location,population
 ORDER BY InfectedRate desc

 --Countries with highest death count per population

  SELECT location,population,MAX(CAST(total_deaths as INT)) DeathCount,MAX(total_deaths/population)*100 DeathRate
 FROM CovidDeaths$
 WHERE continent is NOT NULL
GROUP BY location,population
 ORDER BY DeathCount desc

  --Continent with highest death count
   SELECT continent,MAX(CAST(total_deaths as INT)) DeathCount,MAX(total_deaths/population)*100 DeathRate
 FROM CovidDeaths$
 WHERE continent is NOT NULL
GROUP BY continent
 ORDER BY DeathCount desc

 --Global numbers

  SELECT SUM(new_cases) as TotNC,SUM(cast(new_deaths as INT)) as TotND ,SUM(cast(new_deaths as INT))/SUM(new_cases)*100 DeathPercentage
 FROM CovidDeaths$
 WHERE continent is NOT NULL
 --GROUP BY date
 ORDER BY 1,2

 --Tot pop vs Vaccination
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location Order BY dea.location,
 dea.date) as RollingpeopleVaccinated
  FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 On dea.location=vac.location and dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 1,2,3
 
 --uSE CTE 
 WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingpeopleVaccinated)
 AS 
 (
  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location Order BY dea.location,
 dea.date) as RollingpeopleVaccinated
 --(RollingpeopleVaccinated/population)*100
  FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 On dea.location=vac.location and dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 1,2,3
 )
 SELECT *,(RollingpeopleVaccinated/population)*100
 FROM PopvsVac


 DROP TABLE if exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
);
 --Temp table
 INSERT INTO #PercentPopVaccinated
   SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location Order BY dea.location,
 dea.date) as RollingpeopleVaccinated
 --(RollingpeopleVaccinated/population)*100
  FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 On dea.location=vac.location and dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 1,2,3
 
 SELECT *,(RollingpeopleVaccinated/population)*100
 FROM #PercentPopVaccinated

 --Creating view for later viz
 CREATE VIEW PercentPopVaccinated as
    SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location Order BY dea.location,
 dea.date) as RollingpeopleVaccinated
 --(RollingpeopleVaccinated/population)*100
  FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
 On dea.location=vac.location and dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 1,2,3
 SELECT * FROM PercentPopVaccinated