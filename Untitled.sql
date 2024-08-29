--Patient Demographics
--1. What is the distribution of patients by age group (e.g., 0-18, 19-35, 36-50, 51+)?
select case when date_part('year', CURRENT_DATE)-date_part('year',birthdate) between 0 and 18 then '0-18'
			when date_part('year', CURRENT_DATE)-date_part('year',birthdate) between 19 and 35 then '19-35'
			when date_part('year', CURRENT_DATE)-date_part('year',birthdate) between 36 and 50 then '36-50'
			else '51+'
		end as age_group,
		count('age_group')
from patients 
group by age_group
order by age_group

--2. How many patients are there for each gender?
select gender, count(*) from patients
group by gender
--3.What are the counts of patients by marital status?
select marital, count('marital')
from patients
group by marital
--4.What is the average income of patients grouped by race?
select ethnicity, sum(income) as total_income 
from patients
group by ethnicity
--What is the average time between a patient’s birth and their first recorded encounter?
select 
	avg(first_encounters.first_time-first_encounters.birthdate)
from(
	select min(date_part('year',e.start)) as first_time,p.id, date_part('year',p.birthdate)as birthdate
	from patients p 
	join encounters e
	on p.id=e.patient
	group by p.id, p.birthdate 
	) as first_encounters
--How does the average healthcare expense vary by income bracket and marital status?
select 
	case when income between 0 and 30000 then '0-30k'
			when income between 30001 AND 60000 THEN '30k-60k'
			else '60+'
		end as income_bracket , marital,avg(healthcare_expenses)
from patients
group by marital,income_bracket
order by income_bracket
--What is the correlation between healthcare expenses and income for patients who have 
--been diagnosed with specific high-cost conditions?
SELECT 
    p.income,
    p.healthcare_expenses,
    c.description AS condition_description,
	e.base_encounter_cost
FROM patients p
JOIN conditions c
ON p.id = c.patient
Join encounters e 
on p.id = e. patient
WHERE e.base_encounter_cost > 100
select * from conditions