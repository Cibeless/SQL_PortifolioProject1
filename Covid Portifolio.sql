--Covid-19 Data --> Data Analyst Portfolio Project |SQL
-- data from: https://ourworldindata.org/covid-deaths

select * from Portifolio_Covid..CovidDeaths
order by 3,4

--select * from Portifolio_Covid..CovidVaccination
--order by 3,4

--Select data that we are going to use ok!
--

select location, date, total_cases, new_cases, total_deaths from Portifolio_Covid ..CovidDeaths
order by 1, 2

--looking at total cases X total deaths
--How many? Percentage of people die in this case
--shows lokelihood of dying in you contract covid in your country for exemple

select location, date, total_cases, total_deaths (total_deaths / total/cases) / * 100 as DeathPercentage 
from Portifolio_Covid ..CovidDeaths
where location like '%states%' --the word 'states' in location can be 'United States'
order by 1, 2

--Looking total cases X population
--Show what percentage of population got covid
select location, date, population, total_cases (total_cases / population ) * 100 as PercentPopulationInfected
where location like '%states%' --the word 'states' in location can be 'United States'
order by 1, 2

-- Looking at countries with highest Infection rate compared to population
-- In this case is Max function -- the highest one
 --The highest infection rate by country -> Location Andora percentage of infection 17.125477256077 

select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases / population)) * 100 as PercentPopulationInfected 
from Portifolio_Covid..CovidDeaths
--where location like '%states%'
Group by Location, Population --add group by
order by PercentPopulationInfected desc --Location Andora percentage of infection of Covid-19 = 17.125477256077 
--Andora have a small population but have highest % of infection - Covid isn  in control

--How many people die in coutries with highest death count per population

Select location, max(cast(total_deaths as int)) as totalDeathCount 
From Portifolio_Covid..CovidDeaths -- ineed to convert as a numeric cast because is nvarchar (conversion int)-->*cast
Group by Location
order by TotalDeathCount desc

-- Is ineed to fix the data because there is groups in location as world - europe - africa 
--in this case is ineed to select where the countinet is not NULL
--In location world africa south america are group of entire continent so its not supposed to be there so we need to change so thats why we use continet not null
select * from Portifolio_Covid..CovidDeaths
where continent is not null --here
order by 3,4

-- So now is possible to check
-- USA is number one of total death count

Select location, max(cast (total_deaths as int)) as totalDeathCount 
From Portifolio_Covid..CovidDeaths -- ineed to convert as a numeric cast because is nvarchar (conversion int)
where continent is not null
Group by Location
order by TotalDeathCount desc

--FROM HERE MORE ADVANCEDE VIEWS TO USE TO TABLEAU LATER OK!

--breaking things down by continent to check it properly ---
-- TO CHECK THE WORLD


-- stiil there is an error (see below) the continent in this case 
-- North America seems only USA TotalDeathsCount - where is Canada data??
Select continent max( cast (total_deaths as int)) as totalDeathCount 
From Portifolio_Covid..CovidDeaths -- ineed to convert as a numeric cast because is nvarchar (conversion int)
where continent is not null
Group by continent -- in this case o group by é por 
order by TotalDeathCount desc

-- the correct will be by location than we can put it on tableau
-- In this case North America is with 847942 totalDeathCount

select location, max (cast (total_deaths as int)) as TotalDeathCount
from Portifolio_Covid..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS
-- AGRAGATE FUNCTIONS ARE USED SUM

--wich date the total /world
Select date, SUM(new_cases) --
from Portifolio_Covid..CovidDeaths
where continent is not null
group by date
order by 1, 2

-- per day
Select date, SUM(new_cases)as total_cases, sum( cast ( new_deaths as int))as total_deaths, sum (cast (new_deaths as int)) /sum 
(new_cases) * 100 DeathPercentage  
from Portifolio_Covid..CovidDeaths
where continent is not null
group by date
order by 1, 2

-- to check in the world =150574977 total cases = Death percentage %

Select date, SUM(new_cases)as total_cases, sum( cast ( new_deaths as int))as total_deaths, sum (cast (new_deaths as int)) /sum 
(new_cases) * 100 DeathPercentage  
from Portifolio_Covid..CovidDeaths
where continent is not null
order by 1, 2

-- refresh the data we have
Select * from Portifolio_Covid..CovidVaccination

-- NOW -> JOIN THE TWO TABLES ------------------------- CovidDeaths + Covid Vaccinations
-- just remember with join is possible to get the both tables
-- select * from Portifolio_Covid..CovidDeaths
-- select * from Portifolio_Covid..CovidVaccination

-- FUCTION = JOIN
-- join the both tables and put the same location and date

select * from Portifolio_Covid..CovidDeaths dea -- CovidDeaths = nomeado como dea 
Join Portifolio_Covid..CovidVaccination vac --CovidVaccination = nomeado como vac
	on dea.location = vac.location
	and dea.date = vac. date

--Looking at total population X Vacination
-- Vacinations increasing per day can be seen in new vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portifolio_Covid..CovidDeaths dea
Join Portifolio_Covid..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3

-- Roling count add up over here
-- we are not going to use total ov vaccination but the new vacination
-- partition by = divide o conjunto de resultados em partições distinta

select data.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast (vac.new_vaccinations as int)) over (partition by  dea.location) -- -> PARTITION BY LOCATION
from Portifolio_Covid..CovidDeaths dea
join Portifolio_Covid..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- is possible also besides cast - convert int for exemplo (convert = cast
-- Albania 347702
-- is a rolling account - RollingPeopleVaccinated (Max number)

select data.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert (int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, -- -> PARTITION BY LOCATION / convert besides cast 
	(RollingPeopleVaccinated / population)* 100 --RollingPeopleVaccinated shareded for population = how many people are vaccinated
from Portifolio_Covid..CovidDeaths dea
join Portifolio_Covid..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
-- RollingPeopleVaccinated
-- te number of coluns nedd to be the same 
-- Alvania 12% é vacinada
with PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert (int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- -> PARTITION BY LOCATION / convert besides cast 
	--(RollingPeopleVaccinated / population)* 100 --RollingPeopleVaccinated shareded for population = how many people are vaccinated
from Portifolio_Covid..CovidDeaths dea
join Portifolio_Covid..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp table
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255), --especify the data type 
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert (int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- -> PARTITION BY LOCATION / convert besides cast 
	--(RollingPeopleVaccinated / population)* 100 --RollingPeopleVaccinated shareded for population = how many people are vaccinated
from Portifolio_Covid..CovidDeaths dea
join Portifolio_Covid..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated

--Creating a view to store data fro later visualization

Create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert (int, vac.new_vaccinations)) over (partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- -> PARTITION BY LOCATION / convert besides cast 
	--(RollingPeopleVaccinated / population)* 100 --RollingPeopleVaccinated shareded for population = how many people are vaccinated
from Portifolio_Covid..CovidDeaths dea
join Portifolio_Covid..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--veiw 
select * from PercentagePopulationVaccinated