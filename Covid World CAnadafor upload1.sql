select*
from PORTFOLIOS..CovidDeaths$
where continent is not null
order by 3

--Selected Data I started with

select location, date, total_deaths, total_cases, population
from PORTFOLIOS..CovidDeaths$
where continent is not null
order by 3


--WORLD TOTAL CASES, TOTAL DEATHS

select location,MAX(cast(total_deaths as int)) TotalDeaths, MAX(cast(total_cases as int)) Totalcases
from PORTFOLIOS..CovidDeaths$
where continent is not null
group by location
order by 3 desc






--COUNTRY CANADA likelihood of dying with a view on Total cases vs Total Deathsm

select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as mortalityratepercentage
from PORTFOLIOS..CovidDeaths$
where continent is not null and location = 'canada'
order by 1,2 desc



--COUNTRY CANADA Covid infection per population(per Date)
--TOTAL PERCENTAGE OF POPULATION THAT CAUGT COVID

select location, max(total_cases), population,(Max(total_cases/population))*100 as Infectionrate
from PORTFOLIOS..CovidDeaths$
where continent is not null and location = 'canada'
group by location, population


select location, date,  total_cases, population,(total_cases/population)*100 as Infectionrate
from PORTFOLIOS..CovidDeaths$
where continent is not null and location = 'canada'
order by 1


--World Covid infection per population
--TOTAL PERCENTAGE OF THE WORLD THAT CAUGT COVID

select location, population, MAX(Cast(total_cases as int))as CountryCases, Max((total_cases/population))*100 PopulationInfectionRate
from PORTFOLIOS..CovidDeaths$
where continent is not null
group by location, population
order by PopulationInfectionRate desc


--World Covid death count

select location, MAX(Cast(total_deaths as int))as CountryDeaths
from PORTFOLIOS..CovidDeaths$
where continent is not null
group by location
order by CountryDeaths desc


--CONTINENTS WITH HIGHEST DEATH COUNT
select location, MAX(cast(total_deaths as int))as ContinentalDeaths
from PORTFOLIOS..CovidDeaths$
where continent is not null
group by location
order by ContinentalDeaths desc


select continent, MAX(cast(total_deaths as int))as ContinentalDeaths
from PORTFOLIOS..CovidDeaths$
where continent is not null
group by continent
order by ContinentalDeaths desc



--GLOBAL STATISTICS 

--TOTAL WORLD NEW CASES AND NEW DEATHS

select date,  SUM(new_cases) as totalnewcases, SUM(CAST(new_deaths AS int)) as totalnewdeaths
from PORTFOLIOS..CovidDeaths$
where continent is not nulL
GROUP BY date
order by 1,2


--TOTAL WORLD NEW DEATH PERCENTAGE TO NEW CASES
select date,  SUM(CAST(new_deaths AS int)) as totalnewdeaths, SUM(new_cases) as totalnewcases,
SUM(CAST(new_deaths AS int)) / SUM(new_cases) AS DEATHCORRELATION
from PORTFOLIOS..CovidDeaths$
where continent is not nulL
GROUP BY date
order by 1,2

--TOTAL WORLD  DEATH PERCENTAGE NEW CASES
select SUM(CAST(total_deaths AS int)) as totalnewdeaths, SUM(total_cases) as totalnewcases,
SUM(CAST(total_deaths AS int)) / SUM(total_cases)* 100 as TotalWorldMortalityrate
from PORTFOLIOS..CovidDeaths$


--TOTAL POPULATION AND VACCINATION
select Death.continent,  Death.location, Death.date,Vacc.new_vaccinations , death.population
from PORTFOLIOS..CovidDeaths$ as Death
join PORTFOLIOS..CovidVaccinatins$ as Vacc
 on death.location = Vacc.location
 and death.date = vacc.date
 where death.continent is not nulL
 order by 2,3


 select Death.continent,  Death.location, Death.date, Vacc.new_vaccinations,
 sum(convert(int, Vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date) as totalvaccinations, death.population
from PORTFOLIOS..CovidDeaths$ as Death
join PORTFOLIOS..CovidVaccinatins$ as Vacc
 on death.location = Vacc.location
 and death.date = vacc.date
 where death.continent is not nulL
 group by Death.continent, death.location, death.date, death.population, vacc.new_vaccinations
 order by 2,3


 --USING A CTE\  --VACCINATION VS POPULATION CHALLENGE


 WITH POPUVACC (CONTINENT, LOCATION, DATE, NEW_VACCINATIONS,totalvaccinations,POPULATION)
 as (select Death.continent,  Death.location, Death.date, Vacc.new_vaccinations,
 sum(convert(int, Vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date) as totalvaccinations, 
 death.population
from PORTFOLIOS..CovidDeaths$ as Death
join PORTFOLIOS..CovidVaccinatins$ as Vacc
 on death.location = Vacc.location
 and death.date = vacc.date
 where death.continent is not nulL
 group by Death.continent, death.location, death.date, death.population, vacc.new_vaccinations)
  select*, (totalvaccinations/POPULATION)*100
 from POPUVACC


 --USING A TEMP TABLE --VACCINATION VS POPULATION CHALLENGE

 drop table if exists #TEMP_POPVAC 
 CREATE TABLE #TEMP_POPVAC 
 (continent NVARCHAR(255), 
 location NVARCHAR(255),
 date DATETIME, 
 new_vaccinations NUMERIC,
 totalvaccinations NUMERIC,
  POPULATION NUMERIC)
 
 INSERT INTO #TEMP_POPVAC 
select Death.continent,  Death.location, Death.date, Vacc.new_vaccinations,
 sum(convert(int, Vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date) as totalvaccinations, 
 death.population
from PORTFOLIOS..CovidDeaths$ as Death
join PORTFOLIOS..CovidVaccinatins$ as Vacc
 on death.location = Vacc.location
 and death.date = vacc.date
 where death.continent is not nulL
 group by Death.continent, death.location, death.date, death.population, vacc.new_vaccinations


 Select*
 from #TEMP_POPVAC


 ---VIEWS
 create view PercentageofPopulationVaccinated as
 select Death.continent,  Death.location, Death.date, Vacc.new_vaccinations,
 sum(convert(int, Vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date) as totalvaccinations, 
 death.population
from PORTFOLIOS..CovidDeaths$ as Death
join PORTFOLIOS..CovidVaccinatins$ as Vacc
 on death.location = Vacc.location
 and death.date = vacc.date
 where death.continent is not nulL
 group by Death.continent, death.location, death.date, death.population, vacc.new_vaccinations


 create view CanadadeathPercentage as
 select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as mortalityratepercentage
from PORTFOLIOS..CovidDeaths$
where continent is not null and location = 'canada'
--order by 1,2 desc


create view TotalCasesandDeaths as
select location,MAX(cast(total_deaths as int)) TotalDeaths, MAX(cast(total_cases as int)) Totalcases
from PORTFOLIOS..CovidDeaths$
where continent is not null
group by location
--order by 3 desc
