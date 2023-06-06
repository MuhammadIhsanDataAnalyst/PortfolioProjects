Select *
From HumanResources

-- Renaming 'id' column to 'employee_id'

Exec sp_rename 'HumanResources.id', 'employee_id', 'Column'

---------------------------------------------------------------------------------
-- Updating date format

Select birthdate
From HumanResources

Update HumanResources
Set birthdate = case
	when birthdate like '%/%' then convert(date, birthdate)
	when birthdate like '%-%' then convert(date, birthdate)
	Else Null
End

Select hire_date
From HumanResources

Update HumanResources
Set hire_date = case
	when hire_date like '%/%' then convert(date, hire_date)
	when hire_date like '%-%' then convert(date, hire_date)
	Else Null
End

Select termdate
From HumanResources

Update HumanResources
Set termdate = case
	when termdate like '%/%' then Convert(date,SUBSTRING(termdate,0,11))
	when termdate like '%-%' then Convert(date,SUBSTRING(termdate,0,11))
	Else Null
End

---------------------------------------------------------------------------------
-- Adding "Age" column

Alter Table HumanResources
Add age int

Select birthdate, CURRENT_TIMESTAMP, year(birthdate) as birthyear, year(CURRENT_TIMESTAMP) as currentyear, (year(CURRENT_TIMESTAMP)-year(birthdate)) as age
From HumanResources

Update HumanResources
Set age = (year(CURRENT_TIMESTAMP)-year(birthdate))

Select min(age) as youngest, max(age) as oldest
From HumanResources

---------------------------------------------------------------------------------
/* QUESTIONS:
1. What is the gender breakdown of employees in the company?
2. What is the race/ethnicity breakdown of employees in the company?
3. What is the age distribution of employees in the company?
4. How many employees work at headquarters vs. remote locations?
5. What is the average length of employment for employees who have been terminated?
6. How does the gender distribution vary across departments and job titles?
7. What is the distribution of job titles across the company?
8. Which department has the highest turnover rate?
9. What is the distribution of employees across locations by city and state?
10. How has the company's employee count charged over time based on hire and term dates?
11. What is the tenure distribution for each department?
*/

-- 1. What is the gender breakdown of employees in the company?

Select gender, Count(*) as count
From HumanResources
Where age > 18 And termdate is null
Group by gender

-- 2. What is the race/ethnicity breakdown of employees in the company?

Select race, count(*) as count
From HumanResources
Where age > 18 And termdate is null
Group By race
Order By 2 Desc

-- 3. What is the age distribution of employees in the company?

Select age
From HumanResources
Where termdate is null

Select min(age) as youngest, max(age) as oldest
From HumanResources
Where age > 18 And termdate is null

With CTE_AgeGroup as (
Select 
	Case
		When age >= 18 and age <= 24 Then '18-24'
		When age >= 25 and age <= 34 Then '25-34'
		When age >= 35 and age <= 44 Then '35-44'
		When age >= 45 and age <= 54 Then '45-54'
		When age >= 55 and age <= 64 Then '55-64'
		Else '65+'
	End as AgeGroup
From HumanResources
Where age > 18 And termdate is null
)
Select *, count(*) as CountAge
From CTE_AgeGroup
Group By AgeGroup
Order By AgeGroup

With CTE_AgeGroupGender as (
Select 
	Case
		When age >= 18 and age <= 24 Then '18-24'
		When age >= 25 and age <= 34 Then '25-34'
		When age >= 35 and age <= 44 Then '35-44'
		When age >= 45 and age <= 54 Then '45-54'
		When age >= 55 and age <= 64 Then '55-64'
		Else '65+'
	End as AgeGroup, gender
From HumanResources
Where age > 18 And termdate is null
)
Select *, count(*) as CountAge
From CTE_AgeGroupGender
Group By AgeGroup, gender
Order By AgeGroup, CountAge desc

-- 4. How many employees work at headquarters vs. remote locations?

Select location, count(*) as count
From HumanResources
Where age > 18 And termdate is null
Group by location

-- 5. What is the average length of employment for employees who have been terminated?

Select avg(DATEDIFF(Day,hire_date,termdate))/365 as avg_length_employment
From HumanResources
Where termdate is not null

-- 6. How does the gender distribution vary across departments and job titles?

Select department, gender, count(*) as count
From HumanResources
Where age > 18 And termdate is null
Group By department, gender
Order By 1

-- 7. What is the distribution of job titles across the company?
 
Select jobtitle, count(*) as count
From HumanResources
Where age > 18 And termdate is null
Group By jobtitle
Order By 1 desc

-- 8. Which department has the highest turnover rate?

Select department, total_count, terminated_count, (terminated_count/total_count) as termination_rate
From (
	Select department,
	count(*) as total_count,
	Sum(Case When termdate is not null Then 1 Else 0 End) as terminated_count
	From HumanResources
	Where age >= 18
	Group By department
	) as subquery
Order By termination_rate desc

-- 9. What is the distribution of employees across locations by city and state?

Select location_state, count(*) as count
From HumanResources
Where age > 18 And termdate is null
Group By location_state
Order By 2 desc

-- 10. How has the company's employee count charged over time based on hire and term dates?

Select year, hires, terminations, (hires - terminations) as net_change, ((hires - terminations)/hires) * 100 as net_change_percentage
From (
	Select 
		year(hire_date) as year,
		count(*) as hires,
		Sum(Case When termdate is not null Then 1 Else 0 End) as terminations
	From HumanResources
	Where age >= 18
	Group By year(hire_date)
	) as subquery
Order By year asc

-- 11. What is the tenure distribution for each department?

Select department, Avg(DATEDIFF(DAY, hire_date, termdate)/365) as Avg_tenure
From HumanResources
Where termdate is not null and age >= 18
Group By department
Order By 1