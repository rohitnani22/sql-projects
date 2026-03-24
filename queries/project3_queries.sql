-- SQL query to clean and extract information from job postings
SELECT
   job_id,
  TRIM(job_title) AS cleaned_title,
  TRIM(job_location) AS cleaned_location,
   TRIM(job_schedule_type) AS cleaned_schedule,
TRIM(SUBSTR(job_location, INSTR(job_location, ',') + 1)) AS extracted_country
FROM job_postings_fact
LIMIT 10;

-- SQL query to categorize job postings based on location and work type
SELECT
  job_id,
  job_title_short,
  job_location,
    CASE
      WHEN LOWER(job_location) = 'anywhere' THEN 'Remote'
      WHEN job_work_from_home = 'True' THEN 'Remote'
      ELSE 'On-Site'
    END AS work_type
FROM job_postings_fact
LIMIT 10;


-- SQL query to analyze salary trends by job title and location
SELECT
    j.job_id,
    j.job_title_short,
    j.job_location,
    j.salary_year_avg,
    c.name AS company_name
FROM job_postings_fact j
JOIN company_dim c ON j.company_id = c.company_id
WHERE j.salary_year_avg IS NOT NULL
ORDER BY j.salary_year_avg DESC
LIMIT 10;

-- SQL query to identify companies with no job postings
SELECT
  c.company_id,
  c.name AS company_name
FROM company_dim c
LEFT JOIN job_postings_fact j ON c.company_id = j.company_id
WHERE j.job_id IS  NULL

-- SQL query to find the most common skills required for a specific job title
SELECT
  j.job_id,
  j.job_title_short,
   c.name AS company_name,
   s.skills,
   s.type AS skill_type
FROM job_postings_fact j
JOIN company_dim c ON j.company_id = c.company_id
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE j.job_title_short = 'Data Analyst'
LIMIT 20;
 
-- SQL query to compare average salaries for remote vs on-site positions by job title
 SELECT
 'Remote' AS work_type,
  job_title_short,
  ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM job_postings_fact
WHERE job_work_from_home = 'True'
    AND salary_year_avg IS NOT NULL
GROUP BY job_title_short
 UNION ALL
 SELECT
  'On-Site' AS work_type,
   job_title_short,
   ROUND(AVG(salary_year_avg), 2) AS avg_salary
FROM job_postings_fact
WHERE job_work_from_home = 'False'
  AND salary_year_avg IS NOT NULL
GROUP BY job_title_short
 ORDER BY avg_salary DESC;

-- SQL query to analyze the demand for specific skills in job postings for a given job title
WITH skill_demand AS (
    SELECT
    s.skills,
    s.type AS skill_type,
    COUNT(sj.job_id) AS job_count
    FROM skills_dim s
    JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
    JOIN job_postings_fact j ON sj.job_id = j.job_id
    WHERE j.job_title_short = 'Data Analyst'
    GROUP BY s.skills, s.type
)
SELECT
    skills,
    skill_type,
    job_count
FROM skill_demand
ORDER BY job_count DESC
LIMIT 10;

--average salary for top 10 skills in job postings
with skill_salary as (
 SELECT
     s.skills,
     ROUND(AVG(j.salary_year_avg), 2) AS avg_salary,
     COUNT(j.job_id) AS job_count
    FROM skills_dim s
    JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
    JOIN job_postings_fact j ON sj.job_id = j.job_id
    WHERE j.salary_year_avg IS NOT NULL
    GROUP BY s.skills
    HAVING COUNT(j.job_id) > 10
)
SELECT
    skills,
    avg_salary,
    job_count
FROM skill_salary
ORDER BY avg_salary DESC
LIMIT 10;


-- SQL query to categorize job postings based on salary ranges and analyze distribution
WITH salary_segments AS (
SELECT
  job_id,
  job_title_short,
  job_location,
  CAST(salary_year_avg AS REAL) AS salary,
   CASE
      WHEN CAST(salary_year_avg AS REAL) >= 200000 THEN 'Premium'
      WHEN CAST(salary_year_avg AS REAL) >= 100000 THEN 'High'
      WHEN CAST(salary_year_avg AS REAL) >= 60000  THEN 'Mid'
      WHEN CAST(salary_year_avg AS REAL) >= 30000  THEN 'Entry'
       ELSE 'Below Market'
          END AS salary_tier
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
SELECT
    salary_tier,
    COUNT(*) AS total_jobs,
    ROUND(AVG(salary), 2) AS avg_salary,
    ROUND(MIN(salary), 2) AS min_salary,
    ROUND(MAX(salary), 2) AS max_salary
FROM salary_segments
GROUP BY salary_tier
ORDER BY avg_salary DESC;


-- SQL query to analyze salary distribution by job title and categorize into tiers
WITH salary_segments AS (
SELECT
job_title_short,
salary_year_avg,
CASE
      WHEN CAST(salary_year_avg AS REAL) >= 150000.0 THEN 'Premium'
      WHEN CAST(salary_year_avg AS REAL) >= 100000.0 THEN 'High'
      WHEN CAST(salary_year_avg AS REAL) >= 70000.0  THEN 'Mid'
      WHEN CAST(salary_year_avg AS REAL) >= 40000.0  THEN 'Entry'
      ELSE 'Below Market'
        END AS salary_tier
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)
SELECT
    job_title_short,
    salary_tier,
    COUNT(*) AS job_count
FROM salary_segments
GROUP BY job_title_short, salary_tier
ORDER BY job_title_short, AVG(CAST(salary_year_avg AS REAL)) DESC;


-- SQL query to analyze the trend of job postings over time and identify seasonal patterns
WITH monthly_postings AS (
SELECT
  STRFTIME('%Y-%m', job_posted_date) AS month,
  COUNT(*) AS total_jobs
FROM job_postings_fact
GROUP BY month
)
SELECT
  month,
  total_jobs,
  LAG(total_jobs) OVER (ORDER BY month) AS prev_month_jobs,
  total_jobs - LAG(total_jobs) OVER (ORDER BY month) AS month_change
FROM monthly_postings
ORDER BY month;

-- SQL query to rank job titles based on average salary and identify top-paying roles
WITH job_avg_salary AS (
    SELECT
    job_title_short,
    AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    GROUP BY job_title_short
)
SELECT
    job_title_short,
    avg_salary,
    DENSE_RANK() OVER (
        ORDER BY avg_salary DESC
    ) AS salary_rank
FROM job_avg_salary
ORDER BY salary_rank;


-- SQL query to analyze the demand for specific skills across all job postings and identify high-demand skills
CREATE VIEW IF NOT EXISTS v_skill_demand AS
SELECT
    s.skills,
    s.type AS skill_type,
    COUNT(sj.job_id) AS total_demand,
    ROUND(AVG(j.salary_year_avg), 2) AS avg_salary
FROM skills_dim s
JOIN skills_job_dim sj ON s.skill_id = sj.skill_id
JOIN job_postings_fact j ON sj.job_id = j.job_id
GROUP BY s.skills, s.type;
select*
from v_skill_demand
order by total_demand DESC
limit 10 ;

