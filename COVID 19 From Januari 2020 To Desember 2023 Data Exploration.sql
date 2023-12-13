/* Covid 19 Data Exploration From Januari 2020 -  Desember 2023 */

/* SKills thats i used : Aggregate Functions, Creating Views, Converting Data Types, Common Table Expressions, Joins, Temporary Tables, */



Use project ;
 
 -- Modifikasi Terlebih dahulu type data yang diperlukan

Alter table CovidDeath 
Alter column Population BIGINT,
Alter Column total_cases BIGINT;

Select * From CovidDeath 
Where continent is not null
Order By 3,4;

-- Pilih data yang akan digunakan 

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeath 
Where continent is not null
Order By 1,2;

-- Menunjukan Persentase Populasi yang terinfeksi covid 19

Select Location, date, Population, total_cases, (CAST (total_cases as FLOAT) / NULLIF (CAST(population as FLOAT), 0))*100 as PercentPopulationInfected
From CovidDeath
order by 1,2;

-- Total Cases Vs Total Deaths in Indonesia
-- Menunjukan Persentase Kematian akibat infeksi Covid 19

SELECT Location, Date, Total_Cases, Total_Deaths, (CAST(Total_Deaths AS FLOAT) / NULLIF(CAST(Total_Cases AS FLOAT), 0)) * 100 AS DeathPercentage
FROM CovidDeath
WHERE Location LIKE '%indonesia%'
    AND Continent IS NOT NULL
ORDER BY 1, 2;

-- Menunjukan Negara dengan tingkat infeksi covid 19 tertinggi dibandingkan dengan populasi

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((CAST (total_cases as FLOAT) / NULLIF (CAST(population as FLOAT), 0)))*100 as PercentPopulationInfected
From CovidDeath
Group by Location, Population
order by PercentPopulationInfected desc;

-- Menunjukan Negara dengan angka kematian tertinggi

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- Menunjukan Benua dengan angka kematian tertinggi dibandingkan dengan populasi

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- Angka Secara Global

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
where continent is not null 
order by 1,2;

-- Menunjukkan Persentase Populasi yang Telah Menerima Setidaknya Satu Vaksin Covid

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeath dea
Join CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Menggunakan Common Tables Expression untuk melakukan perhitungan persentase vaksin covid 19 pada query sebelumnya

With PopulationXVaccines (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as FLOAT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeath dea
Join CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopulationXVaccines;

-- Membuat Temporary Table

Drop table if exists PercentagePopulationVaccinated
Create table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations float,
RollingPeopleVaccinated float,
)

INSERT INTO PercentagePopulationVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    CovidDeath dea
JOIN
    CovidVaccines vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
 
 Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PercentagePopulationVaccinated

-- Membuat View Untuk Visualisai data nantinya

Create View PercentPopulationVaccinated as 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    CovidDeath dea
JOIN
    CovidVaccines vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL



