-- 1. Distribution of patients by age group
SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(birthdate)) BETWEEN 0 AND 18 THEN '0-18'
        WHEN EXTRACT(YEAR FROM AGE(birthdate)) BETWEEN 19 AND 35 THEN '19-35'
        WHEN EXTRACT(YEAR FROM AGE(birthdate)) BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+' 
    END AS age_group,
    COUNT(*) AS patient_count
FROM patients
GROUP BY age_group
ORDER BY age_group;

-- 2. Number of patients by gender
SELECT gender, COUNT(*) AS patient_count
FROM patients
GROUP BY gender;

-- 3. Counts of patients by marital status
SELECT marital, COUNT(*) AS patient_count
FROM patients
GROUP BY marital;

-- 4. Average income of patients by race
SELECT ethnicity, AVG(income) AS avg_income
FROM patients
GROUP BY ethnicity;

-- 5. Average time between birth and first recorded encounter
SELECT AVG(first_encounter_date - birthdate) AS avg_time_to_first_encounter
FROM (
    SELECT 
        p.id,
        p.birthdate,
        MIN(e.start) AS first_encounter_date
    FROM patients p
    JOIN encounters e ON p.id = e.patient
    GROUP BY p.id
) AS first_encounters;

-- 6. Average healthcare expenses by income bracket and marital status
SELECT 
    CASE 
        WHEN income BETWEEN 0 AND 30000 THEN '0-30k'
        WHEN income BETWEEN 30001 AND 60000 THEN '30k-60k'
        ELSE '60k+' 
    END AS income_bracket,
    marital,
    AVG(healthcare_expenses) AS avg_healthcare_expenses
FROM patients
GROUP BY marital, income_bracket
ORDER BY income_bracket;

-- 7. Correlation between healthcare expenses and income for high-cost conditions
SELECT 
    p.income,
    p.healthcare_expenses,
    c.description AS condition_description
FROM patients p
JOIN conditions c ON p.id = c.patient
JOIN encounters e ON p.id = e.patient
WHERE e.base_encounter_cost > 100;

-- 8. Average time between birth and first recorded encounter (Alternate)
SELECT 
    p.id AS patient_id,
    MIN(e.start) - p.birthdate AS time_to_first_encounter
FROM patients p
JOIN encounters e ON p.id = e.patient
GROUP BY p.id;

-- 9. Average healthcare expense by income bracket and marital status (Alternate)
SELECT 
    marital,
    CASE 
        WHEN income BETWEEN 0 AND 30000 THEN '0-30k'
        WHEN income BETWEEN 30001 AND 60000 THEN '30k-60k'
        ELSE '60k+' 
    END AS income_bracket,
    AVG(healthcare_expenses) AS avg_healthcare_expenses
FROM patients
GROUP BY marital, income_bracket;

-- 10. Age distribution of patients with chronic conditions
SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(p.birthdate)) BETWEEN 0 AND 18 THEN '0-18'
        WHEN EXTRACT(YEAR FROM AGE(p.birthdate)) BETWEEN 19 AND 35 THEN '19-35'
        WHEN EXTRACT(YEAR FROM AGE(p.birthdate)) BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+' 
    END AS age_group,
    COUNT(*) AS patient_count
FROM patients p
JOIN conditions c ON p.id = c.patient
WHERE c.is_chronic = TRUE
GROUP BY age_group;

-- 11. Correlation between healthcare expenses and income for specific high-cost conditions (Alternate)
SELECT 
    p.income,
    p.healthcare_expenses,
    c.description AS condition_description
FROM patients p
JOIN conditions c ON p.id = c.patient
WHERE c.base_encounter_cost > 1000;

-- 12. Ethnic groups with the highest average healthcare expenses adjusted for income
SELECT 
    ethnicity,
    AVG(healthcare_expenses::numeric / NULLIF(income, 0)) AS avg_expenses_per_income
FROM patients
GROUP BY ethnicity;

-- 13. Average duration of encounters per patient by encounter class
SELECT 
    encounterclass,
    AVG(stop - start) AS avg_duration
FROM encounters
GROUP BY encounterclass;

-- 14. Average encounter costs by payer and provider
SELECT 
    provider,
    payer,
    AVG(total_claim_cost) AS avg_total_claim_cost
FROM encounters
GROUP BY provider, payer;

-- 15. Monthly trend of total encounter costs over the past year
SELECT 
    EXTRACT(YEAR FROM start) AS year,
    EXTRACT(MONTH FROM start) AS month,
    SUM(total_claim_cost) AS total_cost
FROM encounters
WHERE start >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY year, month
ORDER BY year, month;

-- 16. Providers with the highest total claim costs and correlation with service types
SELECT 
    provider,
    encounterclass,
    SUM(total_claim_cost) AS total_claim_cost
FROM encounters
GROUP BY provider, encounterclass
ORDER BY total_claim_cost DESC;

-- 17. Unique conditions per encounter class
SELECT 
    encounterclass,
    COUNT(DISTINCT c.description) AS unique_conditions_count
FROM encounters e
JOIN conditions c ON e.id = c.encounter
GROUP BY encounterclass;

-- 18. Time trend of the most common conditions over the past year
SELECT 
    EXTRACT(MONTH FROM c.start) AS month,
    c.description AS condition_description,
    COUNT(*) AS occurrence_count
FROM conditions c
WHERE c.start >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY month, condition_description
ORDER BY month, occurrence_count DESC;

-- 19. Patients with the highest number of different conditions and their average healthcare expense
SELECT 
    p.id AS patient_id,
    COUNT(DISTINCT c.code) AS condition_count,
    AVG(p.healthcare_expenses) AS avg_healthcare_expenses
FROM patients p
JOIN conditions c ON p.id = c.patient
GROUP BY p.id
ORDER BY condition_count DESC;

-- 20. Incidence rate of chronic conditions by age group
SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(p.birthdate)) BETWEEN 0 AND 18 THEN '0-18'
        WHEN EXTRACT(YEAR FROM AGE(p.birthdate)) BETWEEN 19 AND 35 THEN '19-35'
        WHEN EXTRACT(YEAR FROM AGE(p.birthdate)) BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+' 
    END AS age_group,
    COUNT(*) AS chronic_condition_count
FROM patients p
JOIN conditions c ON p.id = c.patient
WHERE c.is_chronic = TRUE
GROUP BY age_group;

-- 21. Distribution of encounter costs by condition type for high-cost conditions
SELECT 
    c.description AS condition_description,
    AVG(e.total_claim_cost) AS avg_total_claim_cost
FROM conditions c
JOIN encounters e ON c.encounter = e.id
WHERE e.total_claim_cost > 1000
GROUP BY condition_description;

-- 22. Frequency of encounters for specific conditions and correlation with total claim costs
SELECT 
    c.description AS condition_description,
    COUNT(e.id) AS encounter_count,
    SUM(e.total_claim_cost) AS total_claim_cost
FROM conditions c
JOIN encounters e ON c.encounter = e.id
GROUP BY condition_description
ORDER BY encounter_count DESC;

-- 23. Trend in immunization rates over the last 2 years
SELECT 
    EXTRACT(YEAR FROM date) AS year,
    description AS immunization_name,
    COUNT(*) AS immunization_count
FROM immunizations
WHERE date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY year, immunization_name
ORDER BY year, immunization_name;

-- 24. Patients most likely to be missing multiple recommended immunizations
SELECT 
    p.id AS patient_id,
    COUNT(i.description) AS missing_immunization_count
FROM patients p
LEFT JOIN immunizations i ON p.id = i.patient
WHERE i.date IS NULL
GROUP BY p.id
HAVING COUNT(i.description) > 1;

-- 25. Immunization rates by healthcare expenses
SELECT 
    p.healthcare_expenses,
    COUNT(i.code) AS immunization_count
FROM patients p
LEFT JOIN immunizations i ON p.id = i.patient
GROUP BY p.healthcare_expenses;

-- 26. Average cost of immunizations for patients who received all required immunizations in the past year
SELECT 
    AVG(i.base_cost) AS avg_immunization_cost
FROM immunizations i
WHERE i.date >= CURRENT_DATE - INTERVAL '1 year'
AND i.patient IN (
    SELECT DISTINCT patient 
    FROM immunizations 
    WHERE date >= CURRENT_DATE - INTERVAL '1 year'
);

-- 27. Distribution of immunization types among patients with chronic conditions
SELECT 
    i.description AS immunization_name,
    COUNT(DISTINCT p.id) AS patient_count
FROM immunizations i
JOIN patients p ON i.patient = p.id
JOIN conditions c ON p.id = c.patient
WHERE c.is_chronic = TRUE
GROUP BY immunization_name;

-- 28. Correlation between total healthcare expenses and the number of encounters per patient
SELECT 
    p.healthcare_expenses,
    COUNT(e.id) AS encounter_count
FROM patients p
JOIN encounters e ON p.id = e.patient
GROUP BY p.healthcare_expenses;

