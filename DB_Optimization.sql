-- ================================
-- Project 2: Database Optimization
-- & Advanced SQL Queries
-- ================================

-- Query 1: CTE - High Value Customers
WITH high_value_customers AS (
    SELECT 
        customerid,
        MonthlyCharges,
        tenure,
        churn
    FROM customers2
    WHERE MonthlyCharges > 70
)
SELECT 
    churn,
    COUNT(*) AS total,
    ROUND(AVG(MonthlyCharges), 2) AS avg_charges,
    ROUND(AVG(tenure), 2) AS avg_tenure
FROM high_value_customers
GROUP BY churn;

-- Query 2: Subquery - Above Average Churners
SELECT 
    customerid,
    MonthlyCharges,
    tenure,
    churn
FROM customers2
WHERE MonthlyCharges > (
    SELECT AVG(MonthlyCharges) 
    FROM customers2
)
AND churn = 'Yes'
ORDER BY MonthlyCharges DESC
LIMIT 10;

-- Query 3: Index Creation
CREATE INDEX idx_churn 
ON customers2(churn);

CREATE INDEX idx_contract 
ON customers2(Contract);

SELECT 
    Contract,
    churn,
    COUNT(*) AS total,
    ROUND(AVG(MonthlyCharges), 2) AS avg_charges
FROM customers2
GROUP BY Contract, churn
ORDER BY Contract;

-- Query 4: View Creation
CREATE VIEW churn_summary AS
SELECT 
    Contract,
    churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(MonthlyCharges), 2) AS avg_charges,
    ROUND(AVG(tenure), 2) AS avg_tenure
FROM customers2
GROUP BY Contract, churn;

SELECT * FROM churn_summary;

-- Query 5: Risk Level Report
SELECT 
    Contract,
    COUNT(*) AS total,
    SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_charges,
    ROUND(AVG(tenure), 2) AS avg_tenure,
    CASE 
        WHEN SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 30 
        THEN 'High Risk'
        WHEN SUM(CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM customers2
GROUP BY Contract;