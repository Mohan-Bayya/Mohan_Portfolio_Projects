SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM covid_dataset.coviddeaths
where continent != ""
order by 1,2;

-- Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
FROM covid_dataset.coviddeaths
where location = "India" and continent != ""
order by 2 desc ;

-- Total Cases vs Population
SELECT Location, date,  population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM covid_dataset.coviddeaths
where location = "India" and  continent != ""
order by 2 desc ;

-- Countries with Hightest Infection Rate compared to Population
with cte as(
SELECT Location,  population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as InfectedPercentage
FROM covid_dataset.coviddeaths
where continent != ""
group by location, population),
cte1 as (select *,dense_rank() over(order by InfectedPercentage desc ) as rnk from cte)

select * from cte1;

-- Countries with Hightest Death Count 
SELECT location , MAX(CAST(total_deaths AS UNSIGNED)) AS HighestDeathCount
FROM covid_dataset.coviddeaths
where continent != ""
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Continents with Hightest Death Count
with cte as( 
SELECT continent ,date, SUM(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covid_dataset.coviddeaths
where continent != ""
GROUP BY continent,date
ORDER BY TotalDeathCount DESC),
cte1 as(
select continent,MAX(CAST(TotalDeathCount AS UNSIGNED)) AS HighestDeathCount
from cte
group by continent 
order by 2 desc)
select * from cte1;

-- Total Death Percentage
select sum(new_cases) as total_cases, 
sum(cast(new_deaths as  unsigned int)) as total_deaths, 
sum(cast(new_deaths as unsigned int))/sum(new_cases) as TotalDeathPercentage
from coviddeaths;

-- People Vaccinated  Till Date
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(cast(new_vaccinations as unsigned))  over(partition by location order by location,date rows between unbounded preceding and current row ) as TotalVacinationsTillDate
from  coviddeaths dea 
inner join covidvaccinations vac
on dea.location = vac.location and dea.date  = vac.date 
where dea.continent is not null
order by 2,3;

-- Using CTE to find TotalVacinationsPercenatgeTillDat
with PopvsVac as(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(cast(new_vaccinations as unsigned))  over(partition by location order by location,date rows between unbounded preceding and current row ) as TotalVacinationsTillDate
from  coviddeaths dea 
inner join covidvaccinations vac
on dea.location = vac.location and dea.date  = vac.date 
where dea.continent is not null
order by 2,3
)
select *, round((TotalVacinationsTillDate/population)*100,2) as TotalVacinationsPercenatgeTillDate from PopvsVac;


-- Temp Table

drop temporary table if exists PercentagePopulationVaccinated;
create temporary table PercentagePopulationVaccinated  (
select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations AS new_vaccinations, 
    SUM(vac.new_vaccinations)
        OVER (
            PARTITION BY dea.location 
            ORDER BY dea.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS TotalVaccinationsTillDate from  coviddeaths dea 
inner join covidvaccinations vac
on dea.location = vac.location and dea.date  = vac.date 
where dea.continent is not null
order by 2,3
);

select *, round((TotalVacinationsTillDate/population)*100,2) as TotalVacinationsPercenatgeTillDate from PercentagePopulationVaccinated;

-- creating view to store data 

create view PercentagePopulationVccinated as
select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations AS new_vaccinations, 
    SUM(vac.new_vaccinations)
        OVER (
            PARTITION BY dea.location 
            ORDER BY dea.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS TotalVaccinationsTillDate from  coviddeaths dea 
inner join covidvaccinations vac
on dea.location = vac.location and dea.date  = vac.date 
where dea.continent is not null
order by 2,3;

select *, round((TotalVaccinationsTillDate/population)*100,2) as TotalVacinationsPercenatgeTillDate from PercentagePopulationVaccinated;


