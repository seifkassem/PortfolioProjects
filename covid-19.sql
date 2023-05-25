SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid.dbo.CovidDeaths
ORDER BY 1,2


--Death percentage
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM Covid.dbo.CovidDeaths
ORDER BY death_percentage DESC


--Highest death rates
WITH deathr (Location, Population, Total_Cases, Maximum_Death_Rates) AS
(SELECT location, population, MAX(total_cases) total_cases, MAX(total_deaths) maximum_death_rates
FROM Covid.dbo.CovidDeaths
GROUP BY location, population
HAVING MAX(total_deaths) IS NOT NULL
)

SELECT *, ((Maximum_Death_Rates / Total_Cases) * 100) AS Percentage_of_Death_Per_Cases,
	((Maximum_Death_Rates / Population)) * 100 AS Percentage_of_Death_Per_Population
FROM deathr
ORDER BY Maximum_Death_Rates DESC


--Infected percentage
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases / population)) * 100 AS infected_percentage
FROM Covid.dbo.CovidDeaths
GROUP BY location, population
ORDER BY infected_percentage DESC


--Highest death rate by continents
SELECT continent, MAX(total_deaths) AS highest_death_count
FROM Covid.dbo.CovidDeaths
GROUP BY continent
ORDER BY highest_death_count DESC


-- New cases worldwide by date
SELECT date, SUM(new_cases) AS new_cases_worldwide, SUM(new_deaths) AS new_deaths_worldwide,
((SUM(new_deaths) / SUM(new_cases)) * 100) AS percentage_of_death_worldwide
FROM Covid.dbo.CovidDeaths
GROUP BY date
HAVING SUM(new_cases) != 0
ORDER BY date


-- New cases worldwide by date

SELECT SUM(new_cases) AS new_cases_worldwide, SUM(new_deaths) AS new_deaths_worldwide,
((SUM(new_deaths) / SUM(new_cases)) * 100) AS percentage_of_death_per_new_cases
FROM Covid.dbo.CovidDeaths


-- Percentage of vaccinated
WITH vacc_pop (Continent, Location, Date, Population, New_Vaccinations, Accumulative_Vaccinations)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.continent, dea.location ORDER BY dea.location, dea.date) AS accumulative_vaccinations_per_country
FROM Covid.dbo.CovidDeaths dea
JOIN Covid.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
)

SELECT *, (Accumulative_Vaccinations/Population) * 100 AS Accumulative_Percentage_of_Vaccinations_per_Country
FROM vacc_pop
WHERE New_Vaccinations IS NOT NULL
ORDER BY Location, Date