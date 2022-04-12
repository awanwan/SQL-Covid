-- SELECT TOP 10 * FROM CovidDeaths ORDER BY 3,4 

-- SELECT location, date, total_cases,total_deaths,CONCAT(CONVERT(decimal(10,2),(total_deaths/total_cases)*100),'%') AS Percentage 
-- from CovidDeaths 
-- WHERE location LIKE '%states'
-- ORDER BY date ASC

-- SELECT location, date, population, total_cases,CONCAT(CONVERT(decimal(10,2),(total_cases/population)*100),'%') AS Percentage 
-- from CovidDeaths
-- WHERE location LIKE '%states'
-- ORDER BY date ASC
 
-- Looking at countries with Highese Infection Rate compared to population

-- SELECT location, population, MAX(total_cases),MAX(CONCAT(CONVERT(decimal(10,2),(total_cases/population)*100),'%')) AS PercentageInfectionPopulation 
-- from CovidDeaths 
-- GROUP BY location, population
-- ORDER BY PercentageInfectionPopulation desc 


-- Looking at countries with Highese Deaths Rate compared to Infected cases

-- SELECT location, MAX(total_cases) as total_cases, MAX(total_deaths) as total_deaths,MAX(CONCAT(CONVERT(decimal(10,2),(total_deaths/total_cases)*100),'%')) AS PercentageDeathInfection 
-- from CovidDeaths 
-- GROUP BY location
-- ORDER BY PercentageDeathInfection desc 


-- LET'S BREAK THINGS DOWN BY CONTINENT,AND LOOK WHICH COUNTRY HAS THE MOST BIGGER TOTAL CASES IN EACH CONTINENT

-- SELECT continent,location,total_cases
-- FROM [CovidDeaths ]
-- WHERE total_cases IN(
-- SELECT MAX(total_cases) AS max_total_cases
-- FROM CovidDeaths 
-- WHERE continent is not null 
-- GROUP BY continent
-- )
-- ORDER BY total_cases desc



-- USE JOIN TO CONNECT TWO TABLE TO SEE THE RELATION BETWWEN DEA AND VAC 

SELECT dea.continent, dea.location, dea.date, dea.population, 
CONCAT(CONVERT(decimal(10,2),(dea.total_cases/dea.population)*100),'%') AS total_casesPercentage,
CONCAT(CONVERT(decimal(10,2),(dea.total_deaths/dea.population)*100),'%') AS total_deathsPercentage,
CONCAT(CONVERT(decimal(10,2),(vac.total_vaccinations/dea.population)*100),'%') AS total_vaccinationsPercentage,
vac.new_vaccinations,
-- THIS SUM-OVER STATEMENT IS MY FAVORITE FOR NOW!!!
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Location_new_vaccinations
FROM CovidDeaths dea JOIN CovidVaccinations vac ON
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL and vac.total_vaccinations is not NULL
-- WHERE dea.location LIKE '%states'
ORDER BY 1 ASC



-- TO AVOID THE WARNING WE CAN DO THIS SET
SET ANSI_WARNINGS OFF
-- TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
new_vaccinations numeric,
PollingPeopleVaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- THIS SUM-OVER STATEMENT IS MY FAVORITE FOR NOW!!!
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Location_new_vaccinations
FROM CovidDeaths dea JOIN CovidVaccinations vac ON
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1 ASC

SELECT *,(PollingPeopleVaccinated/Population)*100 AS PercentVaxed FROM #PercentagePopulationVaccinated



-- CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION, VIEW IS TOOK FOR PERMANENCE
CREATE VIEW PercentagePopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- THIS SUM-OVER STATEMENT IS MY FAVORITE FOR NOW!!!
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Location_new_vaccinations
FROM CovidDeaths dea JOIN CovidVaccinations vac ON
dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 1 ASC
