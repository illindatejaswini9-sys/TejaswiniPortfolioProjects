-- MyStrongPass123
select * from PortfolioProjects.. CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProjects.. CovidDeaths
order by 1,2

-- totalcases vs total deaths

select location,date,total_cases,new_cases,total_deaths,
Round(total_deaths/NULLIF(total_cases,0) *100,3) as deathpercentage
from PortfolioProjects.. CovidDeaths
where location LIKE '%states%'
order by 1,2

-- looking at Total Cases vs population
select location,date,total_cases,population,
(total_cases/population)*100 as casespop
from PortfolioProjects..CovidDeaths
where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select location,cast(max(total_deaths) as  int) as highestdeathrate
from PortfolioProjects..CovidDeaths
where continent is not NULL
GROUP BY location
order by highestdeathrate DESC

-- let's break things down by continent

select location, max(total_deaths) as death_rate
from CovidDeaths
where continent is  NULL
group by location
order by death_rate desc
-- otherwise if continent is not null it is not giving accurate answers 

select continent,cast(max(total_deaths) as  int) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not NULL
GROUP BY continent
order by TotalDeathCount DESC


-- Global Numbers

select sum(new_cases) as totalcases,sum(new_deaths) as totaldeaths,
sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from PortfolioProjects.. CovidDeaths
where continent is not null 
order by 1,2

-- looking at total population vs vaccinations

select dea.continent , dea.[location], dea.date, 
dea.population,vac.new_vaccinations ,
sum(CAST(dea.new_vaccinations as int)) over (PARTITION by dea.location order by dea.DATE ) as Rollingpeoplevaccinated
-- rollingpeoplevaccinated/population
from PortfolioProjects..CovidVaccinations vac
join PortfolioProjects..CovidDeaths dea
on dea.[location] = vac.[location] 
and dea.[date] = vac.[date]
where dea.continent is not NULL
order by 2,3

--now we need sum of the vaccination in that area/population 
--use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent , dea.[location], dea.date, 
dea.population,vac.new_vaccinations ,
sum(CAST(dea.new_vaccinations as int)) over (PARTITION by dea.location order by dea.DATE ) as Rollingpeoplevaccinated
-- rollingpeoplevaccinated/population
from PortfolioProjects..CovidVaccinations vac
join PortfolioProjects..CovidDeaths dea
on dea.[location] = vac.[location] 
and dea.[date] = vac.[date]
where dea.continent is not NULL
)
Select *, CAST(RollingPeopleVaccinated AS DECIMAL(18,6))
    / NULLIF(CAST(Population AS DECIMAL(18,6)), 0) * 100
From PopvsVac


-- creating temporary table

create table #percentagepeoplevaccinated (
    continent NVARCHAR(100),
    LOCATION NVARCHAR(100),
    date DATETIME,
    population numeric,
    new_vaccinations numeric,
    Rollingpeoplevaccinated numeric

)

insert into #percentagepeoplevaccinated 
    select dea.continent , dea.[location], dea.date, 
dea.population,vac.new_vaccinations ,
sum(CAST(dea.new_vaccinations as int)) over (PARTITION by dea.location order by dea.DATE ) as Rollingpeoplevaccinated
-- rollingpeoplevaccinated/population
from PortfolioProjects..CovidVaccinations vac
join PortfolioProjects..CovidDeaths dea
on dea.[location] = vac.[location] 
and dea.[date] = vac.[date]
where dea.continent is not NULL

Select *, CAST(RollingPeopleVaccinated AS DECIMAL(18,6))
    / NULLIF(CAST(Population AS DECIMAL(18,6)), 0) * 100
From #percentagepeoplevaccinated

--create a view
GO
Create VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 











