-- =====================================================
-- Total Customers
-- =====================================================

SELECT COUNT(*) AS total_customers
FROM bankchurners;

-- =====================================================
-- Customer churn rate
-- =====================================================

SELECT 
COUNT(*) AS total_customers,
SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
ROUND(
SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*) * 100,2
) AS churn_rate_percentage
FROM bankchurners;

-- =====================================================
-- Churn distribution by card category
-- =====================================================

SELECT 
Card_Category,
COUNT(*) AS churned_customers
FROM bankchurners
WHERE Attrition_Flag = 'Attrited Customer'
GROUP BY Card_Category
ORDER BY churned_customers DESC;

-- =====================================================
-- Average credit limit by income category
-- =====================================================

SELECT 
Income_Category,
ROUND(AVG(Credit_Limit),2) AS avg_credit_limit
FROM bankchurners
GROUP BY Income_Category
ORDER BY avg_credit_limit DESC;

-- =====================================================
-- Top 10 highest transaction customers
-- =====================================================

SELECT 
CLIENTNUM,
Total_Trans_Amt
FROM bankchurners
ORDER BY Total_Trans_Amt DESC
LIMIT 10;

-- =====================================================
-- Average inactivity months by churn status
-- =====================================================

SELECT 
Attrition_Flag,
ROUND(AVG(Months_Inactive_12_mon),2) AS avg_inactive_months
FROM bankchurners
GROUP BY Attrition_Flag;

-- =====================================================
-- Average transaction count by churn status
-- =====================================================

SELECT 
Attrition_Flag,
ROUND(AVG(Total_Trans_Ct),2) AS avg_transactions
FROM bankchurners
GROUP BY Attrition_Flag;

-- =====================================================
-- Average utilization ratio
-- =====================================================

SELECT 
Attrition_Flag,
ROUND(AVG(Avg_Utilization_Ratio),3) AS avg_utilization
FROM bankchurners
GROUP BY Attrition_Flag;

-- =====================================================
-- Top Customers by Transaction Amount
-- =====================================================

SELECT 
    CLIENTNUM AS customer_id,
    Total_Trans_Amt AS total_transaction_amount,
    RANK() OVER (ORDER BY Total_Trans_Amt DESC) AS spending_rank
FROM bankchurners
LIMIT 10;

-- =====================================================
-- Customer Segmentation by Transaction Activity
-- =====================================================

SELECT 
    CLIENTNUM AS customer_id,
    Total_Trans_Ct AS total_transactions,
    CASE 
        WHEN Total_Trans_Ct >= 80 THEN 'High Activity'
        WHEN Total_Trans_Ct >= 40 THEN 'Medium Activity'
        ELSE 'Low Activity'
    END AS customer_activity_segment
FROM bankchurners;

-- =====================================================
-- Average Transaction Amount by Card Category
-- =====================================================

SELECT 
    Card_Category AS card_type,
    ROUND(AVG(Total_Trans_Amt),2) AS avg_transaction_amount
FROM bankchurners
GROUP BY Card_Category
ORDER BY avg_transaction_amount DESC;

-- =====================================================
-- Customer Churn Rate by Income Category
-- =====================================================

SELECT 
    Income_Category AS income_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) / COUNT(*) * 100,2
    ) AS churn_rate_percentage
FROM bankchurners
GROUP BY income_group
ORDER BY churn_rate_percentage DESC;

-- =====================================================
-- Customers with Highest Credit Utilization
-- =====================================================

SELECT 
    CLIENTNUM AS customer_id,
    Credit_Limit AS credit_limit,
    Total_Revolving_Bal AS revolving_balance,
    Avg_Utilization_Ratio AS utilization_ratio
FROM bankchurners
ORDER BY utilization_ratio DESC
LIMIT 10;

-- =====================================================
-- Customer Relationship Distribution
-- =====================================================

SELECT 
    Total_Relationship_Count AS total_products,
    COUNT(*) AS customer_count
FROM bankchurners
GROUP BY total_products
ORDER BY customer_count DESC;

-- =====================================================
-- Average Credit Limit by Churn Status
-- =====================================================

SELECT 
    Attrition_Flag AS customer_status,
    ROUND(AVG(Credit_Limit),2) AS avg_credit_limit
FROM bankchurners
GROUP BY customer_status;

-- =====================================================
-- Customer Distribution by Inactive Months
-- =====================================================

SELECT 
    Months_Inactive_12_mon AS inactive_months,
    COUNT(*) AS customer_count
FROM bankchurners
GROUP BY inactive_months
ORDER BY inactive_months;

-- =====================================================
-- Top 5% Highest Spending Customers
-- =====================================================

WITH spending_rank AS (
    SELECT 
        CLIENTNUM AS customer_id,
        Total_Trans_Amt AS total_transaction_amount,
        NTILE(20) OVER (ORDER BY Total_Trans_Amt DESC) AS spending_percentile
    FROM bankchurners
)
SELECT 
    customer_id,
    total_transaction_amount
FROM spending_rank
WHERE spending_percentile = 1;

-- =====================================================
-- Transaction Comparison: Churned vs Retained Customers
-- =====================================================

SELECT 
    customer_status,
    AVG(total_transactions) AS avg_transaction_count
FROM (
    SELECT 
        Attrition_Flag AS customer_status,
        Total_Trans_Ct AS total_transactions
    FROM bankchurners
) AS transaction_data
GROUP BY customer_status;

-- =====================================================
-- Customers with Credit Limit Above Average
-- =====================================================

SELECT 
    CLIENTNUM AS customer_id,
    Credit_Limit AS credit_limit
FROM bankchurners
WHERE Credit_Limit > (
    SELECT AVG(Credit_Limit)
    FROM bankchurners
)
ORDER BY credit_limit DESC;

-- =====================================================
-- Identify High Churn Risk Customers
-- =====================================================

WITH churn_risk AS (
    SELECT 
        CLIENTNUM AS customer_id,
        Months_Inactive_12_mon,
        Total_Trans_Ct,
        CASE 
            WHEN Months_Inactive_12_mon >= 3 
            AND Total_Trans_Ct < 40
            THEN 'High Risk'
            ELSE 'Low Risk'
        END AS churn_risk_level
    FROM bankchurners
)
SELECT *
FROM churn_risk
WHERE churn_risk_level = 'High Risk';

-- =====================================================
-- Revenue Contribution by Card Category
-- =====================================================

WITH card_revenue AS (
    SELECT 
        Card_Category AS card_type,
        SUM(Total_Trans_Amt) AS total_revenue
    FROM bankchurners
    GROUP BY card_type
)
SELECT 
    card_type,
    total_revenue,
    ROUND(
        total_revenue * 100 / SUM(total_revenue) OVER (),
        2
    ) AS revenue_percentage
FROM card_revenue
ORDER BY revenue_percentage DESC;

-- =====================================================
-- 21. Customer Service Friction Spiral (Contacts vs Churn)
-- =====================================================

SELECT 
    Contacts_Count_12_mon AS customer_contacts_count,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_pct
FROM bankchurners
GROUP BY customer_contacts_count
ORDER BY customer_contacts_count ASC;

-- =====================================================
-- 22. Transaction Count Velocity Decline (Q4 vs Q1)
-- =====================================================

SELECT 
    CASE 
        WHEN Total_Ct_Chng_Q4_Q1 < 0.5 THEN 'Severe Drop (<0.50x)'
        WHEN Total_Ct_Chng_Q4_Q1 < 0.7 THEN 'Moderate Drop (0.50x - 0.69x)'
        WHEN Total_Ct_Chng_Q4_Q1 < 1.0 THEN 'Mild Drop (0.70x - 0.99x)'
        ELSE 'Stable or Growing (>=1.0x)'
    END AS transaction_velocity_band,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_pct
FROM bankchurners
GROUP BY transaction_velocity_band
ORDER BY churn_rate_pct DESC;

-- =====================================================
-- 23. Normalized Churn Rate by Card Category (Accurate %)
-- =====================================================

SELECT 
    Card_Category,
    COUNT(*) AS total_cardholders,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_cardholders,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS category_churn_rate_pct,
    ROUND(AVG(Credit_Limit), 2) AS avg_credit_limit,
    ROUND(AVG(Total_Trans_Amt), 2) AS avg_annual_spend
FROM bankchurners
GROUP BY Card_Category
ORDER BY category_churn_rate_pct DESC;

-- =====================================================
-- 24. Multi-Product Retention Power (Relationship Count)
-- =====================================================

SELECT 
    Total_Relationship_Count AS products_held,
    COUNT(*) AS customer_count,
    SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) AS churned_count,
    ROUND(
        SUM(CASE WHEN Attrition_Flag = 'Attrited Customer' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_rate_pct,
    ROUND(AVG(Total_Revolving_Bal), 2) AS avg_revolving_balance
FROM bankchurners
GROUP BY products_held
ORDER BY products_held ASC;

-- =====================================================
-- 25. High-Value At-Risk Customers (Immediate Retention Target)
-- =====================================================

SELECT 
    CLIENTNUM AS customer_id,
    Card_Category,
    Credit_Limit,
    Total_Trans_Amt AS annual_spend,
    Total_Trans_Ct AS transaction_count,
    Months_Inactive_12_mon,
    Contacts_Count_12_mon,
    Total_Ct_Chng_Q4_Q1 AS velocity_change
FROM bankchurners
WHERE Attrition_Flag = 'Existing Customer'
  AND (Total_Trans_Amt >= 10000 OR Credit_Limit >= 20000)
  AND (Months_Inactive_12_mon >= 2 OR Contacts_Count_12_mon >= 3 OR Total_Ct_Chng_Q4_Q1 < 0.6)
ORDER BY annual_spend DESC
LIMIT 15;
