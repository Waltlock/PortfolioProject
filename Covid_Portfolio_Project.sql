Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4



--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3, 4


--Select the data that we are going to be using 

Select Location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at the Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, 
    CASE 
        WHEN CAST(total_cases AS FLOAT) = 0 THEN 0
        ELSE (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100) 
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%Philippines%'
and continent is not null
ORDER BY 1, 2

--Cast allows you to change the value type from int, to non numeric values
--FLOAT = Decimal numbers
--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, population total_cases, 
    CASE 
        WHEN CAST(total_cases AS FLOAT) = 0 THEN 0
        ELSE (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)*100) 
    END AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY  1, 2


-- Looking at countries with highest infection rate compared to population

SELECT Location, continent, population, max(Cast(total_cases as BIGINT)) AS HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, continent, population 
ORDER BY  PercentPopulationInfected Desc


--Sometimes the dataset is being stores as a string rather than a data type
--Meaning the Max function opperates as a lexixographical order like only seeing 9's in the first space of "HighestInfectionCount"

--To fix this cast the coloumn and convert string  to Interger 
--BIGINT  has a bigger range than INT (Safe to use to avoid potential overflow)


--Showing the Countries with the highest Death Count Per Poplution

SELECT Location, MAX(Cast(total_deaths as BigInt)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY location 
ORDER BY  TotalDeathCount DESC


--LETS BREAK THINGS DOWNN BY CONTINENT

SELECT continent, MAX(Cast(total_deaths as BigInt)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY  TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT sum(new_cases) as NewTotalCases, sum(CAST(new_deaths AS BIGINT)) as NewTotalDeaths, 
SUM(
 CASE 
        WHEN CAST(new_cases AS FLOAT) = 0 THEN 0
        ELSE (CAST(new_deaths AS FLOAT) / CAST(new_cases AS FLOAT)*100) 
    END) AS NewDeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY  1,2

--Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(BIGINT,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
dea.Date) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY  1,2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(BIGINT,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
dea.Date) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (Rolling_People_Vaccinated/population)*100
from PopvsVac
 

 -- Temp Table
 
 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(225),
 Location nvarchar (225),
 Date datetime,
 Population numeric,
 New_Vaccination numeric,
 Rolling_People_Vaccinated numeric
 )

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(BIGINT,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
dea.Date) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select*, (Rolling_People_Vaccinated/population)*100
from #PercentPopulationVaccinated
 

 -- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(BIGINT,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location,
dea.Date) AS Rolling_People_Vaccinated
--,(Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
