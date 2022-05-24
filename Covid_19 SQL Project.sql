/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
FROM [Portfolio Project].[dbo].[Covid_deaths$]
WHERE continent is not null
order by 3,4;

 SELECT *
 FROM [Portfolio Project].[dbo].[Covid_vaccination$]
 order by 3,4;
  SELECT location,date,total_cases,new_cases,total_deaths,population
  from [Portfolio Project].[dbo].[Covid_deaths$]
  order by 1,2

  --looking Total cases veds new cases
  ----Finding death rate in % = (deaths/cases)*100
  SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Rate 
  from [Portfolio Project].[dbo].[Covid_deaths$]
  WHERE location LIKE '%india%'
  order by 1,2 DESC

  
  --Cases per population in % = (total cases/population)*100
  SELECT location,date,total_cases,Population,total_deaths,(total_deaths/total_cases)*100 AS Death_Rate 
  from [Portfolio Project].[dbo].[Covid_deaths$]
  WHERE location LIKE '%india%'
  order by 1,2 DESC
  
  --Highest infection rate
SELECT location,Population,MAX(total_cases)as HighestCase,MAX((total_cases/Population)*100) AS infection_rate
FROM [Portfolio Project].[dbo].[Covid_deaths$] WHERE continent is not null
GROUP BY location,Population
ORDER BY infection_rate DESC;

SELECT location,Population,date,MAX(total_cases)as HighestCase,MAX((total_cases/Population)*100) AS infection_rate
FROM [Portfolio Project].[dbo].[Covid_deaths$] 
--where location like '%states%'
WHERE continent is not null
GROUP BY location,Population,date
ORDER BY infection_rate DESC;



--Highest death count per population
SELECT location,Population,MAX(total_deaths)as Totaldeathcount
FROM [Portfolio Project].[dbo].[Covid_deaths$] 
WHERE continent is not null  
GROUP BY location,Population
ORDER BY Totaldeathcount DESC;
--Table 2---
SELECT location,SUM(cast(new_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].[dbo].[Covid_deaths$] 
--WHERE location like is '%states%'
WHERE continent is null
and location not in ('World', 'European Union','International')
GROUP BY location
ORDER BY TotalDeathCount DESC;




--showing Continentwise highest data death count
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].[dbo].[Covid_deaths$]  WHERE continent is  not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GLobal data--
--Overall cases and deaths


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 FROM [Portfolio Project].[dbo].[Covid_deaths$]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--	Looking at total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].[dbo].[Covid_deaths$]  dea
Join [Portfolio Project].[dbo].[Covid_vaccination$]  vac
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
From [Portfolio Project].[dbo].[Covid_deaths$]  dea
Join [Portfolio Project].[dbo].[Covid_vaccination$]  vac
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
From [Portfolio Project].[dbo].[Covid_deaths$]  dea
Join [Portfolio Project].[dbo].[Covid_vaccination$]  vac
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
From [Portfolio Project].[dbo].[Covid_deaths$]  dea
Join [Portfolio Project].[dbo].[Covid_vaccination$]  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;
Select *
From PercentPopulationVaccinated;
