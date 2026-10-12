-- 1. Check Duplicate Patient IDs
SELECT
    Patient_ID,
    COUNT(*) AS Duplicate_Count
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
GROUP BY Patient_ID
HAVING COUNT(*) > 1;


-- 2. Check Invalid Age Values
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE SAFE_CAST(Age AS INT64) NOT BETWEEN 0 AND 120
   OR SAFE_CAST(Age AS INT64) IS NULL;


-- 3. Check Missing or Invalid Gender
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE Gender IS NULL
   OR TRIM(Gender) NOT IN ('M', 'F', 'O', 'Male', 'Female', 'Others');
SELECT
    COUNT(*) AS Total_Rows,
    COUNTIF(Patient_ID IS NULL) AS Missing_Patient_ID,
    COUNTIF(Age IS NULL) AS Missing_Age,
    COUNTIF(Gender IS NULL OR TRIM(Gender) = '') AS Missing_Gender,
    COUNTIF(Medical_Condition IS NULL) AS Missing_Medical_Condition,
    COUNTIF(Billing_Amount IS NULL) AS Missing_Billing_Amount
FROM medical-data-analysis-511204.medical_dataset.medical_row;

SELECT
    COUNT(*) AS Total_Rows,
    COUNTIF(Patient_ID IS NULL) AS Missing_Patient_ID,
    COUNTIF(Age IS NULL) AS Missing_Age,
    COUNTIF(Gender IS NULL OR TRIM(Gender) = '') AS Missing_Gender,
    COUNTIF(Medical_Condition IS NULL) AS Missing_Medical_Condition,
    COUNTIF(Billing_Amount IS NULL) AS Missing_Billing_Amount
FROM medical-data-analysis-511204.medical_dataset.medical_row;

SELECT
    Patient_ID,
    COUNT(*) AS Duplicate_Count
FROM medical-data-analysis-511204.medical_dataset.medical_row
GROUP BY Patient_ID
HAVING COUNT(*) > 1;

-- 4. Check Negative Billing Amount
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE SAFE_CAST(Billing_Amount AS NUMERIC) < 0
   OR SAFE_CAST(Billing_Amount AS NUMERIC) IS NULL;


-- 5. Check Negative Length of Stay
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE SAFE_CAST(Length_of_Stay_Days AS INT64) < 0
   OR SAFE_CAST(Length_of_Stay_Days AS INT64) IS NULL;


-- 6. Check Invalid Blood Group
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE Blood_Group IS NULL
   OR TRIM(Blood_Group) NOT IN (
       'A+', 'A-', 'B+', 'B-',
       'AB+', 'AB-', 'O+', 'O-'
   );


-- 7. Check Missing Medical Condition
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE Medical_Condition IS NULL
   OR TRIM(Medical_Condition) = '';


-- 8. Check Invalid Admission Type
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE Admission_Type IS NULL
   OR TRIM(Admission_Type) NOT IN (
       'Emergency', 'Urgent', 'Elective'
   );


-- 9. Check Missing Hospital
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE Hospital IS NULL
   OR TRIM(Hospital) = '';


-- 10. Check Invalid Test Results
SELECT *
FROM `medical-data-analysis-511204.medical_dataset.medical_row`
WHERE Test_Result IS NULL
   OR TRIM(Test_Result) NOT IN (
       'Normal', 'Abnormal', 'Inconclusive'
   );

-- data cleaning preprocessing
CREATE OR REPLACE TABLE
`medical-data-analysis-511204.medical_dataset.medical_data_cleaned` AS

WITH Cleaned_Source AS (
    SELECT
        TRIM(Patient_ID) AS Patient_ID,

        SAFE_CAST(Age AS INT64) AS Age,

        CASE
            WHEN LOWER(TRIM(Gender)) IN ('m', 'male')
                THEN 'Male'

            WHEN LOWER(TRIM(Gender)) IN ('f', 'female')
                THEN 'Female'

            WHEN LOWER(TRIM(Gender)) IN ('o', 'other', 'others')
                THEN 'Others'

            ELSE NULL
        END AS Gender,

        UPPER(TRIM(Blood_Group)) AS Blood_Group,

        TRIM(Medical_Condition) AS Medical_Condition,

        TRIM(Admission_Type) AS Admission_Type,

        TRIM(Hospital) AS Hospital,

        SAFE_CAST(Billing_Amount AS NUMERIC)
            AS Billing_Amount,

        SAFE_CAST(Length_of_Stay_Days AS INT64)
            AS Length_of_Stay_Days,

        TRIM(Test_Result) AS Test_Result

    FROM
    `medical-data-analysis-511204.medical_dataset.medical_row`
)

SELECT DISTINCT
    Patient_ID,
    Age,
    Gender,
    Blood_Group,
    Medical_Condition,
    Admission_Type,
    Hospital,
    Billing_Amount,
    Length_of_Stay_Days,
    Test_Result

FROM Cleaned_Source

WHERE
    Patient_ID IS NOT NULL
    AND Patient_ID != ''

    AND Age BETWEEN 0 AND 120

    AND Gender IN ('Male', 'Female', 'Others')

    AND Blood_Group IN (
        'A+', 'A-', 'B+', 'B-',
        'AB+', 'AB-', 'O+', 'O-'
    )

    AND Medical_Condition IS NOT NULL
    AND Medical_Condition != ''

    AND Admission_Type IN (
        'Emergency', 'Urgent', 'Elective'
    )

    AND Hospital IS NOT NULL
    AND Hospital != ''

    AND Billing_Amount >= 0

    AND Length_of_Stay_Days >= 0

    AND Test_Result IN (
        'Normal', 'Abnormal', 'Inconclusive'
    );

SELECT
    COUNT(*) AS Total_Rows
FROM
medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

--SQL Data Analysis
-- Total Patients
SELECT
    'Original Table' AS Table_Name,
    COUNT(*) AS Total_Rows
FROM medical-data-analysis-511204.medical_dataset.medical_row;

---Average age
SELECT
    ROUND(AVG(Age), 2) AS Average_Age,
    MIN(Age) AS Minimum_Age,
    MAX(Age) AS Maximum_Age
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`;





--  Gender-wise Patient Count
SELECT
    Gender,
    COUNT(*) AS Total_Patients
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`
GROUP BY Gender
ORDER BY Total_Patients DESC;
--Age-wise Patient Analysis
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50'
        WHEN Age BETWEEN 51 AND 65 THEN '51-65'
        ELSE 'Above 65'
    END AS Age_Group,

    COUNT(*) AS Total_Patients

FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`

GROUP BY Age_Group

ORDER BY
    CASE Age_Group
        WHEN 'Under 18' THEN 1
        WHEN '18-35' THEN 2
        WHEN '36-50' THEN 3
        WHEN '51-65' THEN 4
        WHEN 'Above 65' THEN 5
    END;
-- Medical Condition-wise Patient Count
SELECT
    Medical_Condition,
    COUNT(*) AS Total_Patients
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`
GROUP BY Medical_Condition
ORDER BY Total_Patients DESC;
-- Admission Type Analysis
SELECT
    Admission_Type,
    COUNT(*) AS Total_Patients
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`
GROUP BY Admission_Type
ORDER BY Total_Patients DESC;
-- Hospital-wise Patient Count
SELECT
    Hospital,
    COUNT(*) AS Total_Patients
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`
GROUP BY Hospital
ORDER BY Total_Patients DESC;
--Average Billing Amount
SELECT
    ROUND(AVG(Billing_Amount), 2) AS Average_Billing_Amount,
    ROUND(MIN(Billing_Amount), 2) AS Minimum_Billing_Amount,
    ROUND(MAX(Billing_Amount), 2) AS Maximum_Billing_Amount,
    ROUND(SUM(Billing_Amount), 2) AS Total_Billing_Amount
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`;
-- Average Length of Stay
SELECT
    ROUND(AVG(Length_of_Stay_Days), 2) AS Average_Stay_Days,
    MIN(Length_of_Stay_Days) AS Minimum_Stay_Days,
    MAX(Length_of_Stay_Days) AS Maximum_Stay_Days
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`;
--Blood Group Analysis
SELECT
    Blood_Group,
    COUNT(*) AS Total_Patients
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`
GROUP BY Blood_Group
ORDER BY Total_Patients DESC;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Patient_ID) AS Non_Null_Patient_IDs,
    COUNT(DISTINCT Patient_ID) AS Unique_Patient_IDs
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

SELECT
    Patient_ID,
    COUNT(*) AS Record_Count
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned
GROUP BY Patient_ID
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Patient_ID) AS Non_Null_IDs,
    COUNTIF(Patient_ID IS NULL) AS Null_IDs,
    COUNT(DISTINCT Patient_ID) AS Unique_Patients
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

SELECT
    COUNT(*) AS Original_Total_Rows
FROM medical-data-analysis-511204.medical_dataset.medical_row;

SELECT
    COUNT(*) AS Total_Rows,

    COUNTIF(Patient_ID IS NULL) AS Missing_Patient_ID,

    COUNTIF(Age IS NULL) AS Missing_Age,

    COUNTIF(Gender IS NULL) AS Missing_Gender,

    COUNTIF(Hospital IS NULL) AS Missing_Hospital,

    COUNTIF(Medical_Condition IS NULL)
        AS Missing_Medical_Condition,

    COUNTIF(Billing_Amount IS NULL)
        AS Missing_Billing_Amount

FROM medical-data-analysis-511204.medical_dataset.medical_row;


SELECT
    'Original Table' AS Table_Name,
    COUNT(*) AS Total_Rows
FROM medical-data-analysis-511204.medical_dataset.medical_row

UNION ALL

SELECT
    'Cleaned Table' AS Table_Name,
    COUNT(*) AS Total_Rows
FROM medical-data-analysis-511204.medical_dataset.medical_data_cleaned;

SELECT *
FROM medical-data-analysis-511204.medical_dataset.medical_row
LIMIT 10;

WITH Checked_Data AS (
    SELECT
        *,
        SAFE_CAST(Age AS INT64) AS Age_Num,
        SAFE_CAST(Billing_Amount AS NUMERIC) AS Billing_Num,
        SAFE_CAST(Length_of_Stay_Days AS INT64) AS Stay_Num
    FROM `medical-data-analysis-511204.medical_dataset.medical_row`
)

SELECT
    COUNT(*) AS Original_Rows,

    COUNTIF(
        Patient_ID IS NULL OR TRIM(Patient_ID) = ''
    ) AS Invalid_Patient_ID,

    COUNTIF(
        Age_Num IS NULL OR Age_Num NOT BETWEEN 0 AND 120
    ) AS Invalid_Age,

    COUNTIF(
        Gender IS NULL
        OR LOWER(TRIM(Gender))
           NOT IN ('m', 'male', 'f', 'female', 'o', 'others')
    ) AS Invalid_Gender,

    COUNTIF(
        UPPER(TRIM(Blood_Group))
        NOT IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')
        OR Blood_Group IS NULL
    ) AS Invalid_Blood_Group,

    COUNTIF(
        Medical_Condition IS NULL
        OR TRIM(Medical_Condition) = ''
    ) AS Invalid_Medical_Condition,

    COUNTIF(
        Admission_Type IS NULL
        OR TRIM(Admission_Type)
           NOT IN ('Emergency', 'Urgent', 'Elective')
    ) AS Invalid_Admission_Type,

    COUNTIF(
        Hospital IS NULL OR TRIM(Hospital) = ''
    ) AS Invalid_Hospital,

    COUNTIF(
        Billing_Num IS NULL OR Billing_Num < 0
    ) AS Invalid_Billing_Amount,

    COUNTIF(
        Stay_Num IS NULL OR Stay_Num < 0
    ) AS Invalid_Length_of_Stay,

    COUNTIF(
        Test_Result IS NULL
        OR TRIM(Test_Result)
           NOT IN ('Normal', 'Abnormal', 'Inconclusive')
    ) AS Invalid_Test_Result

FROM Checked_Data;

SELECT
    Gender,
    COUNT(*) AS Total_Count
FROM medical-data-analysis-511204.medical_dataset.medical_row
WHERE
    Gender IS NULL
    OR LOWER(TRIM(Gender))
       NOT IN ('m', 'male', 'f', 'female', 'o', 'others')
GROUP BY Gender
ORDER BY Total_Count DESC;

SELECT
    Gender,
    COUNT(*) AS Total_Count
FROM medical-data-analysis-511204.medical_dataset.medical_row
WHERE
    Gender IS NULL
    OR LOWER(TRIM(Gender))
       NOT IN ('m', 'male', 'f', 'female', 'o', 'others')
GROUP BY Gender
ORDER BY Total_Count DESC;


-- Test Result Analysis
SELECT
    Test_Result,
    COUNT(*) AS Total_Patients
FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`
GROUP BY Test_Result
ORDER BY Total_Patients DESC;

-- Final Business Insights
SELECT
    COUNT(DISTINCT Patient_ID) AS Total_Patients,

    ROUND(AVG(Age), 2) AS Average_Age,

    ROUND(AVG(Billing_Amount), 2)
        AS Average_Billing_Amount,

    ROUND(SUM(Billing_Amount), 2)
        AS Total_Billing_Amount,

    ROUND(AVG(Length_of_Stay_Days), 2)
        AS Average_Stay_Days,

    COUNT(DISTINCT Hospital) AS Total_Hospitals,

    COUNT(DISTINCT Medical_Condition)
        AS Total_Medical_Conditions,

    COUNTIF(Gender = 'Male') AS Male_Patients,

    COUNTIF(Gender = 'Female') AS Female_Patients,

    COUNTIF(Gender = 'Others') AS Other_Gender_Patients

FROM `medical-data-analysis-511204.medical_dataset.medical_data_cleaned`;