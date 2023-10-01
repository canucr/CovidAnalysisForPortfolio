SELECT *
FROM CovidDeaths$


SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRateOnPopulation
FROM CovidDeaths$
WHERE continent IS NOT NULL
Group By location, population
Order By 1,2

--showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) as totalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
Group By location
ORDER BY totalDeathCount desc	

-- APPLYING THIS TO CONTINENT INSSTEAD OF LOCATION
SELECT continent, MAX(CAST(total_deaths AS int)) as totalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
Group By continent
ORDER BY totalDeathCount desc	

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS totalCases,SUM(CAST(new_deaths AS INT)) as totalDeaths, SUM(CAST(new_deaths AS INT)) /  SUM(new_cases) * 100 as totalDeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 2

-- joining with vaccinations
SELECT deaths.continent, deaths.location, deaths.date,deaths.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition By deaths.location order by deaths.location) as VaccinatedPeople
FROM CovidDeaths$ deaths 
JOIN CovidVaccinations$ vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL 
ORDER BY 2,3

		
--temp table 
DROP TABLE if exists #PercentVaccinatedPeople
Create Table #PercentVaccinatedPeople
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinatedPeople numeric,
)

Insert Into #PercentVaccinatedPeople
SELECT deaths.continent, deaths.location, deaths.date,deaths.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition By deaths.location order by deaths.location) as VaccinatedPeople
 
FROM CovidDeaths$ deaths 
JOIN CovidVaccinations$ vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
--WHERE deaths.continent IS NOT NULL 
ORDER BY 2,3

Select *,(VaccinatedPeople/ Population)*100
From #PercentVaccinatedPeople

--creating view for later visulusation
Create View PercentVaccinatedPeople as 
SELECT deaths.continent, deaths.location, deaths.date,deaths.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition By deaths.location order by deaths.location) as VaccinatedPeople
 
FROM CovidDeaths$ deaths 
JOIN CovidVaccinations$ vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
--WHERE deaths.continent IS NOT NULL 
--ORDER BY 2,3
 

	
