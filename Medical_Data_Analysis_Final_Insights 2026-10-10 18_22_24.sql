CREATE OR REPLACE TABLE
`medical-data-analysis-511204.medical_dataset.medical_data_cleaned` AS

SELECT DISTINCT
    Patient_ID,
    SAFE_CAST(Age AS INT64) AS Age,

    CASE
        WHEN TRIM(Gender) = 'M' THEN 'Male'
        WHEN TRIM(Gender) = 'F' THEN 'Female'
        WHEN TRIM(Gender) = 'O' THEN 'Others'
    END AS Gender,

    TRIM(Blood_Group) AS Blood_Group,
    TRIM(Medical_Condition) AS Medical_Condition,
    TRIM(Admission_Type) AS Admission_Type,
    TRIM(Hospital) AS Hospital,
    SAFE_CAST(Billing_Amount AS NUMERIC) AS Billing_Amount,
    SAFE_CAST(Length_of_Stay_Days AS INT64) AS Length_of_Stay_Days,
    TRIM(Test_Result) AS Test_Result

FROM `medical-data-analysis-511204.medical_dataset.medical_row`

WHERE
    Patient_ID IS NOT NULL
    AND SAFE_CAST(Age AS INT64) BETWEEN 0 AND 120
    AND TRIM(Gender) IN ('M', 'F', 'O')
    AND SAFE_CAST(Billing_Amount AS NUMERIC) >= 0
    AND SAFE_CAST(Length_of_Stay_Days AS INT64) >= 0
    AND TRIM(Blood_Group) IN
        ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
    AND TRIM(Medical_Condition) != ''
    AND TRIM(Admission_Type) IN ('Emergency', 'Urgent', 'Elective')
    AND TRIM(Hospital) != ''
    AND TRIM(Test_Result) IN ('Normal', 'Abnormal', 'Inconclusive');
    
SELECT
    'Original' AS Table_Name,
    COUNT(*) AS Total_Rows
FROM medical-data-analysis-511204.medical_dataset.medical_row

UNION ALL

SELECT
    'Cleaned' AS Table_Name,
    COUNT(*) AS Total_Rows
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

SELECT
    column_name,
    data_type
FROM medical-data-analysis-511204.medical_dataset.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'medical_data_cleaned'
ORDER BY ordinal_position;

-- starts SQL Analysis

-- Total Patients
-- Average Age
-- Gender-wise Patient Count
-- Medical Condition-wise Patient Count
-- Average Billing Amount

-- Total Patients
SELECT COUNT(*) AS Total_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_row;

-- gentder wise patients count
SELECT
    Gender,
    COUNT(*) AS Total_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_row
GROUP BY Gender;

 -- Age-wise Patient Analysis
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        WHEN Age BETWEEN 51 AND 65 THEN '51-65'
        ELSE 'Above 65'
    END AS Age_Group,
    COUNT(*) AS Total_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned
GROUP BY Age_Group
ORDER BY Total_Patients DESC;

-- Medical Condition-wise Patient Count
SELECT Medical_Condition, COUNT(*) AS Total_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned
GROUP BY Medical_Condition
ORDER BY Total_Patients DESC;

-- Admission Type Analysis
SELECT Admission_Type, COUNT(*) AS Total_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned
GROUP BY Admission_Type
ORDER BY Total_Patients DESC;

-- Hospital-wise Patient Count
SELECT Hospital, COUNT(*) AS Total_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned
GROUP BY Hospital
ORDER BY Total_Patients DESC;

--  Average Billing Amount
SELECT
    ROUND(AVG(Billing_Amount), 2) AS Average_Billing_Amount,
    ROUND(MIN(Billing_Amount), 2) AS Minimum_Billing_Amount,
    ROUND(MAX(Billing_Amount), 2) AS Maximum_Billing_Amount
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

8. Average Length of Stay
SELECT
    ROUND(AVG(Length_of_Stay_Days), 2) AS Average_Stay_Days,
    MIN(Length_of_Stay_Days) AS Minimum_Stay_Days,
    MAX(Length_of_Stay_Days) AS Maximum_Stay_Days
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

--  Blood Group Analysis
SELECT Blood_Group, COUNT(*) AS Total_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned
GROUP BY Blood_Group
ORDER BY Total_Patients DESC;


-- Final Business Insights
SELECT
    COUNT(*) AS Total_Patients,
    ROUND(AVG(Age), 2) AS Average_Age,
    ROUND(AVG(Billing_Amount), 2) AS Average_Billing_Amount,
    ROUND(AVG(Length_of_Stay_Days), 2) AS Average_Stay_Days,
    COUNT(DISTINCT Hospital) AS Total_Hospitals,
    COUNT(DISTINCT Medical_Condition) AS Total_Medical_Conditions
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

